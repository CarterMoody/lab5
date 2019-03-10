/*
    Name:         Robert Hensley, Carter Moody
    Section:      09
    Description:  a class of user input methods
*/

/* I/O Libraries */
import java.io.*; 
import java.util.Scanner;
import java.util.Formatter;

/* Objects */
import java.lang.String;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Arrays;

/* 
User Options:
    h = show help
    d = dump register state
    p = show pipeline registers
    s = step through a single clock cycle step (i.e. simulate 1 cycle and stop)
    s num = step through num clock cycles
    r = run until the program ends and display timing summary
    m num1 num2 = display data memory from location num1 to num2
    c = clear all registers, memory, and the program counter to 0
    q = exit the program
*/

class interactive{

    /* error messages */
    private static final String HELP_MESSAGE = 
        "\nh = show help" +
        "\nd = dump register state" +
        "\np = show pipeline registers" +
        "\ns = step through a single clock cycle step (i.e. simulate 1 cycle and stop)" +
        "\ns num = step through num clock cycles" +
        "\nr = run until the program ends and display timing summary" +
        "\nm num1 num2 = display data memory from location num1 to num2" +
        "\nc = clear all registers, memory, and the program counter to 0" +
        "\nq = exit the program\n";

    private static final String PARSE_INT_ERROR = "        Invalid integer value (reverting to default value)";
    private static final String MEM_ARGS_ERROR  = "        Invalid amount of arguments (use: m num1 num2)";

    /* print registers */
    public static void dump() {

        int i = 0;

        System.out.println();

        for (Map.Entry<String, Integer> entry : Globals.registerMap.entrySet()) {
            
            if(i == 0) {
                System.out.println(entry.getKey() + " = " + entry.getValue());
            } else {
                System.out.print(String.format("%-16s", entry.getKey() + " = " + entry.getValue()));
                if((i % 4) == 0)
                    System.out.println();
            }

            i++;
            
        }

        System.out.println("\n");

    }

    /* run step(s) */
    private static void step(String userInput) {
        int pc = Globals.registerMap.get("pc");
        int numInst = 1;
        String args[] = userInput.split(" ");

        if(args.length == 2) {
            try {
                numInst = Integer.parseInt(args[1]); 
            } catch (NumberFormatException e) {
                System.out.println(PARSE_INT_ERROR);
            }
        }

        /* run instructions (until end reached) */
        for(int i = 0; (i < numInst) && (pc != Globals.instList.size()); i++) {
            Globals.instList.get(pc).run(); // run instruction
            pc = Globals.registerMap.get("pc");
        }

        System.out.println("        " + numInst + " instruction(s) executed");
    }

    /* run until the program ends 
    private static void run() {
        int pc = Globals.registerMap.get("pc");

        while(pc != Globals.instList.size()) {
            Globals.instList.get(pc).run(); // run instruction
            pc = Globals.registerMap.get("pc");
        }
    }
    */

    /* m num1 num2 = display data memory from location num1 to num2 */
    private static void memory(String userInput) {
        int memStart = 0;
        int memEnd = 0;

        String args[] = userInput.split(" ");

        if(args.length != 3) {
            System.out.println(MEM_ARGS_ERROR);
            return;
        }

        /* read in memStart and memEnd */
        try {
            memStart = Integer.parseInt(args[1]); 
        } catch (NumberFormatException e) {
            System.out.println(PARSE_INT_ERROR);
        }

        memEnd = memStart; // default value

        try {
            memEnd = Integer.parseInt(args[2]); 
        } catch (NumberFormatException e) {
            System.out.println(PARSE_INT_ERROR);
        }

        /* print memory content */

        System.out.println();
        for(;memStart <= memEnd; memStart ++) {
            System.out.println("[" + memStart + "] = " + Globals.memory[memStart]);
        }
        System.out.println();

    }

    /* clear all registers */
    private static void clear() {
        for (Map.Entry<String, Integer> entry : Globals.registerMap.entrySet()) {
            entry.setValue(0);
        }
        System.out.println("        Simulator reset\n");
    }

    /* 
        Branch Predictor Methods
        (called in run function)
    */

    /* run until the program ends */
    public static void run() {
        int pc = Globals.registerMap.get("pc");
        int pipePC;
        int prediction = 0;
        int index = 0;
        inst currentInst, nextInst;
        pipe newPipe;

        createGHR();

        while(pc != Globals.instList.size()) {
            
            currentInst = Globals.instList.get(pc);

            currentInst.run(); // run instruction
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
                        newPipe.stall = true;
                    }
                } 

            }

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

            }

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

    /* print branch stats */
    private static void printBranchStats() {
        double Accuracy = (double)Globals.correctPredictions / Globals.totalBranches * 100;

        System.out.println(String.format("\naccuracy %.2f", Accuracy) + "% (" + Globals.correctPredictions + " correct predictions, " + Globals.totalBranches + " predictions)\n");
    }

    // figure file
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

    /* interactive mode */
    public static void interactiveLoop() {

        Scanner sc = new Scanner(System.in);
        System.out.print("mips> ");
        String userInput = sc.nextLine();

        char c;     // user input option                                 

        /* loop until quit */
        while ((c = userInput.toLowerCase().charAt(0)) != 'q') { 

            switch(c) {
                case 'h' : System.out.println(HELP_MESSAGE);    break;      // Show Help
                case 'd' : dump();                              break;      // Dump Register State
                case 's' : step(userInput);                break;      // Step through <userInput> clock cycles
                case 'r' : run();                               break;      // Run Until Completion
                case 'm' : memory(userInput);                   break;      // Display Integer Memory Map
                case 'c' : clear();                             break;      // Clear Registers, Memory, PC = 0
                case 'b' : printBranchStats();                  break;      // Display CPI and Instruction Info
                case 'o' : write_csv();                    break;
                case 'g' : printGHR();                     break;
            }
            System.out.print("mips> ");
            userInput = sc.nextLine();
        }
        sc.close();
        System.exit(0);
    }

    /* non-interactive mode */
    public static void runScript(String script) {

        File file = new File(script);
        Scanner sc = null;
        String line;

        try { 
            sc = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.err.println("Caught IOException: " + e.getMessage());
            System.exit(1);
        }

        while (sc.hasNextLine()) {
            line = sc.nextLine();
            System.out.println("mips> " + line);
            switch(line.toLowerCase().charAt(0)) {
                case 'h' : System.out.println(HELP_MESSAGE);    break;      // Show Help
                case 'd' : dump();                              break;      // Dump Register State
                case 's' : step(line);                          break;      // Step through <line> clock cycles
                case 'r' : run();                               break;      // Run Until Completion
                case 'm' : memory(line);                        break;      // Display Integer Memory Map
                case 'c' : clear();                             break;      // Clear Registers, Memory, PC = 0
                case 'b' : printBranchStats();                  break;
                case 'o' : write_csv();                         break;
                case 'g' : printGHR();                          break;
                case 'q' : sc.close(); System.exit(0);          break;
            }
        }


    }
}