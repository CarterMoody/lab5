/*
    Name:         Robert Hensley, Carter Moody
    Section:      09
    Description:  MIPS simulator (with pipelines)
*/

/* I/O Libraries */
import java.io.*; 
import java.util.Scanner;

/* Objects */
import java.lang.String;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Arrays;

class pipe {
    public String opcode;
    public Boolean oneSquash = false;
    public Boolean threeSquash = false;
    public Boolean stall = false;
    public int pc = 0;

    pipe(String opcode, int pc) {
        this.opcode = opcode;
        this.pc = pc;
    }
}

class Globals {
    /* Constants */

    public static final String ARGS_ERROR = "\nUse the following command line arguments -> java lab4 file.asm";
    public static final String LABEL_ERROR = "\nLabel incorrectly formatted (must be alphanumeric): ";
    public static final int MEMORY_SIZE = 8192;

    /* Variables */
    /* Note: order of register placement matters for dumping */
    public static Map<String, Integer> registerMap = new LinkedHashMap<String, Integer>() {{
        
        put("pc", 0);   // pc register

        put("$0", 0);   // zero register

        /* return registers */
        put("$v0", 0);
        put("$v1", 0);

        /* function arguments */
        for(int i = 0; i < 4; i++)
            put("$a" + i, 0);  

        /* temporary registers */
        for(int i = 0; i < 8; i++)
            put("$t" + i, 0);  

        /* saved registers */
        for(int i = 0; i < 8; i++)
            put("$s" + i, 0);  

        /* more temporary registers */
        put("$t8", 0);
        put("$t9", 0);     

        put("$sp", 0);  // stack pointer

        put("$ra", 0);  // return address
        
    }};

    public static LinkedList<pipe> pipelineList = 
        new LinkedList<pipe>(Arrays.asList(
            new pipe("empty", 0),
            new pipe("empty", 0),
            new pipe("empty", 0)
        ));
        
    public static Map<String, Integer> labelMap = new HashMap<String, Integer>();
    /* Lab 3 Objects */
    public static int[] memory = new int[MEMORY_SIZE];
    public static ArrayList<inst> instList = new ArrayList<inst>();

    public static int Cycles = 1;
    public static int Instructions = 0; // Used instead of 
    public static int pipePC = 0;

    public static int totalBranches;
    public static int takenBranches;
    public static int GHRSize;
    public static int[] GHR;
    public static Map<Integer, Integer> predictionTable = new HashMap<Integer, Integer>() {{
    }};
    public static int correctPredictions = 0;
    public static int incorrectPredictions = 0;



}

class lab5 {

    /* Methods */

    public static void write_csv() {

        int i = 0;
        try {
            final FileWriter fw = new FileWriter("coordinates.csv");
            final BufferedWriter out = new BufferedWriter(fw);

            while(Globals.memory[i] != 0) {
                out.write(Globals.memory[i] + "," + Globals.memory[i + 1] + "\n");
                i += 2;
            }

            out.close();
        } catch (IOException e) {
  
        }
        
    }

    // parses an asm file
    private static void read_asm(String asm_file) throws IOException {

        ArrayList<String> code = new ArrayList<String>();

        /* File I/O */
        File file = new File(asm_file);
        Scanner sc = null;

        /* Pass 1 Objects */
        String line;
        String labelList[];

        /* Pass 2 Objects */
        String opcode;
        String commandLine[];
        int lineNo = 1;

        try { 
            sc = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.err.println("Caught IOException: " + e.getMessage());
            System.exit(1);
        }

        /* Pass 1 

            - loop through file
                - remove whitespace and remove comment lines
                - search if colon exists in each line
                    - if it exists, get contents before colon (remove space)
                    - create label object and append it to the label array

        */ 

        while (sc.hasNextLine()) {

            /* read in a line while removing comments */
            line = sc.nextLine();
            
            if(line.equals("#")) {
                line = "";
            } else {
                line = line.split("#")[0];
            }

            /* add labels to HashMap */
            if(line.contains(":")) {
                labelList = line.split(":");

                labelList[0] = labelList[0].replaceAll("\\s", "");
            
                if(!labelList[0].matches("[a-zA-Z0-9]+")) {
                    throw new IOException(Globals.LABEL_ERROR + labelList[0]);
                }
                
                Globals.labelMap.put(labelList[0], code.size() + 1);
                
                if(labelList.length == 2) {
                    line = labelList[1];
                } else {
                    line = "";
                }
            } 
            
            /* add line if it's not blank */
            if(!line.replaceAll("\\s", "").equals("")) {
                code.add(line);
            }
        }

        sc.close();

        /* Pass 2: loop through array of instructions and create instruction objects */

        for(String inst : code) {
            inst = inst.trim();             // trim Leading and Trailing Whitespace
            if(inst.charAt(0) == 'j') {
                commandLine = inst.split("\\s");
                opcode = commandLine[0];
                commandLine = Arrays.copyOfRange(commandLine, 1, commandLine.length);     // Remove first element (opcode) from Command Line Array
            } else {
                commandLine = inst.replaceAll("\\s", "").split(",");
                opcode = commandLine[0].split("\\$")[0];
                commandLine[0] = '$' + commandLine[0].split("\\$")[1];
            }

            Globals.instList.add(new inst(opcode, commandLine, lineNo));

            lineNo++;
        }
    }

    /* run until the program ends */
    public static void run() {
        int pc = Globals.registerMap.get("pc");
        int pipePC;
        int prediction = 0;
        int index = 0;
        inst currentInst, nextInst;
        pipe newPipe;

        while(pc != Globals.instList.size()) {
            
            currentInst = Globals.instList.get(pc);

            currentInst.emulate_instruction(); // run instruction
            //interactive.dump();

            // set pipe pc properly
            if(currentInst.opcode.matches("j|jal|jr|beq|bne")) {
                pipePC = pc + 1;
            } else {
                pipePC = Globals.registerMap.get("pc");
            }

            pc = Globals.registerMap.get("pc");
            
            newPipe = new pipe(currentInst.opcode, pipePC);

            // check for lw stall
            if(currentInst.opcode.equals("lw")) {
                nextInst = Globals.instList.get(pc);

                // check if next instruction uses lw result
                if ((nextInst.rs.equals(currentInst.rt)) 
                 || (nextInst.rt.equals(currentInst.rt))) {

                    if (nextInst.opcode.matches("lw|addi")) {
                        if (nextInst.rs.equals(currentInst.rt)){
                            newPipe.stall = true;
                        }
                    }

                    else {
                        //if (nextInst.opcode.matches("addi")){
                            newPipe.stall = true;
                       // }
                    }
                } 

            }

            
            // squash flag
            //predictBranch();
            if(currentInst.opcode.matches("beq|bne")){
                index = parseGHR();
                prediction = predictBranch(index);

                if (currentInst.taken == true){
                    Globals.GHR = shiftLeft(Globals.GHR);
                    Globals.GHR[Globals.GHRSize-1] = 1;
                    newPipe.threeSquash = true;
                    Globals.totalBranches += 1;
                    Globals.takenBranches += 1;

                    // Prediction was correct, increment
                    if (prediction == 2 || prediction == 3){
                        Globals.correctPredictions += 1;
                    }
                    // prediction was false, decrement
                    if (prediction == 0 || prediction == 1){
                        Globals.incorrectPredictions += 1;
                    }
                    int newPrediction = prediction+1;
                    if (newPrediction > 3){
                        newPrediction = 3;
                    }
                    Globals.predictionTable.put(index, newPrediction);
                    
                }

                if (currentInst.taken == false){
                    Globals.GHR = shiftLeft(Globals.GHR);
                    Globals.GHR[Globals.GHRSize-1] = 0;
                    Globals.totalBranches += 1;

                    if (prediction == 2 || prediction == 3){
                        Globals.incorrectPredictions += 1;
                    }
                    if (prediction == 0 || prediction == 1){
                        Globals.correctPredictions += 1;
                    }
                    int newPrediction = prediction-1;
                    if (newPrediction < 0){
                        newPrediction = 0;
                    }
                    Globals.predictionTable.put(index, newPrediction);
                }

                //printGHR();

            }

            // if(currentInst.opcode.matches("beq|bne") && currentInst.taken) {
            //     Globals.GHR = shiftLeft(Globals.GHR);
            //     Globals.GHR[Globals.GHRSize-1] = 1;
            //     newPipe.threeSquash = true;
            //     Globals.totalBranches += 1;
            //     Globals.takenBranches += 1;

            //     if (prediction == 1){

            //     }
            //     printGHR();
            // }

            // if (currentInst.opcode.matches("beq|bne") && (currentInst.taken == false)){
            //     Globals.GHR = shiftLeft(Globals.GHR);
            //     Globals.GHR[Globals.GHRSize-1] = 0;
            //     Globals.totalBranches += 1;
            //     printGHR();
            // }

            Globals.pipelineList.add(newPipe);

            // check for jump
            if(currentInst.opcode.matches("j|jal|jr")) {
                Globals.pipelineList.add(new pipe("squash", pipePC + 1));
            }

            // squash instructions
            if(newPipe.threeSquash) {

                // add the next three instructions (to be squashed)
                Globals.pipelineList.add(new pipe(Globals.instList.get(pipePC + 1).opcode, pipePC + 1));
                Globals.pipelineList.add(new pipe(Globals.instList.get(pipePC + 2).opcode, pipePC + 2));
                Globals.pipelineList.add(new pipe(Globals.instList.get(pipePC + 3).opcode, pipePC + 3));
            }

        }

        // fill the end of the pipeline with empty vals
        for(int i = 0; i < 4; i++) {
            Globals.pipelineList.add(new pipe("empty", pc));
        }
    }

    // Takes GHR and Turns it into an index
    public static int parseGHR(){
        int index = 0;
        int counter = 0;
        String binaryString = "";

        while (counter < Globals.GHRSize){
            binaryString += Globals.GHR[counter];
            //System.out.println(binaryString);
            counter++;
        }

        index = Integer.parseInt(binaryString, 2);
        //System.out.println(index);

        // if (Globals.GHR[3] == 1){
        //     index += 1;
        // }
        // if (Globals.GHR[2] == 1){
        //     index += 2;
        // }
        // if (Globals.GHR[1] == 1){
        //     index += 4;
        // }
        // if (Globals.GHR[0] == 1){
        //     index += 8;
        // }
        return index;
    }

    public static int predictBranch(int index){
        //int index = parseGHR();
        int prediction = Globals.predictionTable.get(index);
        //System.out.println("Index: " + index);
        return prediction;
    }

    public static int[] shiftLeft(int[] nums) {
        if (nums == null || nums.length <= 1) {
            return nums;
        }
        int start = nums[0];
        System.arraycopy(nums, 1, nums, 0, nums.length - 1);
        nums[nums.length - 1] = start;
        return nums;
    }

    public static void printGHR(){
        int counter = 0;
        while(counter < Globals.GHRSize){
            System.out.print("[" + Globals.GHR[counter] + "], ");
            counter++;
        }
        System.out.println();
    }

    public static void fillGHR(){
        int counter = 0;
        while(counter < Globals.GHRSize){
            Globals.GHR[counter] = 0;
            counter++;
        }
    }

    public static void createPredictionTable(){
        int counter = 0;
        double predictionTableSize = Math.pow(2, Globals.GHRSize); 
        while (counter < predictionTableSize){
            Globals.predictionTable.put(counter, 0);
            counter++;
        }
    }

    public static void createGHR(){
        createPredictionTable();
        // System.out.println("Globals.GHRSize: " + Globals.GHRSize);
        Globals.GHR = new int[Globals.GHRSize];
        fillGHR();
        //printGHR();
        // System.out.println("GHRSize: " + Globals.GHR.length);
    }

    public static void Circle(int xc, int yc, int r) {
        // store xc as a0
        // store yc as a1
        // store r  as a2
    }

    public static void Line(int x0, int y0, int x1, int y1) {
        // store x0 as a0
        // store y0 as a1
        // store x1 as a2
        // store y1 as a3

        // run Line.asm
    }

    // this stores the 
    public static void runCoords() {

    }

    public static void writeCoords() {

    }

    public static void main(String args[]) throws IOException, IllegalArgumentException {

        if(!(args.length == 1 || args.length == 2 || args.length == 3)) {
            throw new IllegalArgumentException(Globals.ARGS_ERROR);
        }

        read_asm(args[0]);      // build instruction objects

        //run();                  // emulate instructions, build pipeline

        /* select mode */
        if (args.length == 3){
            Globals.GHRSize = Integer.parseInt(args[2]);


            // fillGHR();
            createGHR();
            run();
            interactive.runScript(args[1]);
        }
        int intTest;
        if (args.length == 2) {
            try{
                intTest = Integer.parseInt(args[1]);
                Globals.GHRSize = intTest;
                // Globals.GHR = new ArrayList[Globals.GHRSize];
                // fillGHR();
                createGHR();
                run();
                interactive.interactiveLoop();
            } catch (NumberFormatException nfe){
                Globals.GHRSize = 2;
                // Globals.GHR = new int[Globals.GHRSize];
                // fillGHR();
                createGHR();
                run();
                interactive.runScript(args[1]);
            }
            //Globals.GHRSize = Integer.parseInt(args[2]);
            //interactive.interactiveLoop();
            //interactive.runScript(args[1]);
        } else {
            Globals.GHRSize = 2;
            // Globals.GHR = new int[Globals.GHRSize];
            // fillGHR();
            createGHR();
            run();
            interactive.interactiveLoop();
        }

    }  
    
}