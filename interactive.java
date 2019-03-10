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

    /* run until the program ends */
    private static void run() {
        int pc = Globals.registerMap.get("pc");

        while(pc != Globals.instList.size()) {
            Globals.instList.get(pc).run(); // run instruction
            pc = Globals.registerMap.get("pc");
        }
    }

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

    /* print branch stats */
    private static void printBranchStats() {
        double Accuracy = (double)Globals.correctPredictions / Globals.totalBranches * 100;

        System.out.println(String.format("\naccuracy %.2f", Accuracy) + "% (" + Globals.correctPredictions + " correct predictions, " + Globals.totalBranches + " predictions)\n");
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
                case 'o' : lab5.write_csv();                    break;
                case 'g' : lab5.printGHR();                     break;
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
                case 'o' : lab5.write_csv();                    break;
                case 'g' : lab5.printGHR();                     break;
                case 'q' : sc.close(); System.exit(0);          break;
            }
        }


    }
}