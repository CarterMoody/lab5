# Name:         Robert Hensley, Carter Moody
# Section:      09
# Description:  returns the quotient of a 64-bit integer (divisor must be a power of 2)


#   public static void Line (int x0, int y0, int x1, int y1) {
#     int st, temp, deltax, deltay, error, y, ystep;

#     if (Math.abs(y1 - y0) > Math.abs(x1 - x0)) 
#     {
#       st = 1;
#     } else {
#       st = 0;
#     }
  
#     if (st == 1) {
#         // swap x0 and y0
#         temp = x0;
#         x0 = y0;
#         y0 = temp;

#         // swap x1 and y1
#         temp = x1;
#         x1 = y1;
#         y1 = x1;
#     }
   
#     if (x0 > x1) {
  
#         // swap x0 and x1
#         temp = x1;
#         x1 = x0;
#         x0 = x1;

#         // swap y0 and y1
#         temp = y0;
#         y0 = y1;
#         y1 = y0;

#     }
  
#     deltax = x1 - x0;
#     deltay = Math.abs(y1 - y0);
#     error = 0;
#     y = y0;
   
#     if (y0 < y1) {
#       ystep = 1;
#     } else {
#       ystep = -1;
#     }
   
#     // Setup Buffer Writing to File
#     try {
#       final FileWriter fw = new FileWriter("outfilename.csv");
#       final BufferedWriter out = new BufferedWriter(fw);
#       for (int x = x0; x0 <= x1; x++) {
#           if (st == 1) {
#               //plot(y,x);
#               out.write((y) + "," + (x) + "\n");
#           } else {
#              //plot(x,y);\
#              out.write((x) + "," + (y) + "\n");

#           }
  
#           error = error + deltay;
  
#           if (2*error >= deltax) {
#               y = y + ystep;
#               error = error - deltax;
#           } //end if
#       }  //end for loop
#     } catch (IOException e) {

#     }
    
# } //end function

.data

welcome:
    .asciiz "This program puts line points in a csv file\n\n"

str_fileName:
    .asciiz "line.csv"

.text

# allocate memory for 3 chars + \0
li $v0, 9
li $a0, 4       # allocate 4 bytes for 4 chars
syscall
move $s0, $v0
addi $s0, $s0, 3    # point to end of the buffer

writePointsToCSV:
    li $t1, 10          # end the line with \n
    sb $t1, 0($s0)      # store \n in buffer at last position
    addi $s0, $s0, -1   # move buffer pointer to 3rd position (second to last)
    sb $s2, 0($s0)      # Store $s2 (x or y) at 3rd position
    addi $s0, $s0, -1   # move buffer pointer to 2nd position
    li $t1, 44          # load a comma (,) at this position
    sb $t1, 0($s0)      # store the comma!
    addi $s0, $s0, -1   # move buffer pointer to first position
    sb $s3, 0($s0)      # Store $s3 (x or y) at 1st position

    # buffer is pointed to by $s0
    # buffer contains [$s2][,][$s3][\n]
    
    # write to File!
    li $v0, 15      # system call to write to file
    move $a0, $s6   # file descriptor
    move $a1, $s0   # address of buffer from which to write
    li $a2, 4       # hardcoded buffer length
    syscall         # write to file


    jr $ra              # return to writeLoop





# File Creation
file_open:
    li $v0, 13
    la $a0, str_fileName
    li $a1, 1    # Create File
    li $a2, 0   # File Permissions
    syscall     # File descriptor gets returned in $v0
    move $s6, $v0   # Save FD

    
file_close:
    li $v0, 16      # system call to close the file
    move $a0, $s6   # file descriptor to close
    syscall         # close the file

main:
    # User I/O

        # print welcome message
        li      $v0, 4
        la      $a0, welcome
        syscall

    # Logic

    # a0: Stores x0                     (x0)
    # a1: Stores y0                     (y0) 
    # a2: Stores x1                     (x1)
    # a3: Stores y1                     (y1)

    # t0: Stores st                     (st)             
    # t1 Stores temp                    (temp)
    # t2: Stores deltax                 (deltax)
    # t3: Stores deltay                 (deltay)
    # t4: Stores error                  (error)
    # t5: Stores y                      (y)
    # t6: Stores ystep                  (ystep)
    # t7: Stores x                      (used for writeLoop)

    # s0: Stores Final X point value
    # s1: Stores Final Y point value

    # Clear Registers
    move $t0, $zero
    move $t1, $zero
    move $t2, $zero
    move $t3, $zero                # Move Zero into $temps, clearing it
    move $t4, $zero                # Might be more instructions than add rd, $zero, $zero
    move $t5, $zero
    move $t6, $zero
    move $t7, $zero

    # calculate Absolute Value of y1 - y0
    sub $t0, $a3, $a1       # Compute y1 - y0
    ori $t1, $t0, $zero     # Copy $t0 into $t1
    slt $t2, $t1, $zero         # Is $t1 less than 0?
    beq $t2, $zero, absContinue1    # Is $t1 less than 0?
    sub $t1, $zero, $t0     # Negative minus Negative = Positive
    ori $s1, $zero, $t1     # copy absolute value answer into $s1 for later

    absContinue1:               # $t1 contains the absolute value of y1 - y0

    # Calculate Absolute Value of x1 - x0
    sub $t3, $a2, $a0       # Compute x1 - x0
    ori $t4, $t3, $zero     # Copy $t3 into $t4
    slt $t5, $t4, $zero         # Is $t4 less than 0?
    beq $t5, $zero, absContinue2    # Is $t4 less than 0?
    sub $t4, $zero, $t3     # Negative minus Negative = Positive

    absContinue2:               # $t4 contains the absolute value of x1 - x0

    sub $t5, $t1, $t4       # (Math.abs(y1 - y0) > Math.abs(x1 - x0)) 
    slt $t2, $t5, $zero
    beq $t2, $zero, absIf
    # else
    add $t0, $zero, $zero   # st = 0;
    j skipIfST              # Jump to after if(st==1)

    absIf:
    addi $t0, $zero, 1      # st = 1
    # Swap x0 and y0
    add $t1, $zero, $a0     # temp = x0
    add $a0, $zero, $a1     # x0 = y0
    add $a1, $zero, $t1     # y0 = temp
    # Swap x1 and y1
    addi $t1, $zero, $a2    # temp = x1
    add $a2, $zero, $a3     # x1 = y1
    add $a3, $zero, $t1     # y1 = temp

    skipIfST:
 
    # if (x0 > x1)
    slt $t7, $a2, $a0       # $t7 will be 1 if x1 < x0
    beq $t7, $zero, falseSwap
    # swap x0 and x1
    add $t1, $zero, $a0     # temp = x0
    add $a0, $zero, $a2     # x0 = x1
    add $a2, $zero, $t1     # x1 = temp
    # swap y0 and y1
    add $t1, $zero, $a1     # temp = y0
    add $a1, $zero, $a3     # y0 = y1
    add $a3, $zero, $t1     # y1 = temp

    falseSwap:

    sub $t2, $a2, $a0       # deltax = x1 - x0
    ori, $t3, $zero, $s1    # deltay = Math.abs(y1 - y0) from earlier
    add $t4, $zero, $zero   # error = 0
    add $t5, $zero, $a1     # y = y0

    slt $t7, $a1, $a3       # $t7 will be 1 if y0 < y1
    beq $t7, $zero, falseYStep
    addi $t6, $zero, 1      # ystep = 1
    j skipfalseYStep

    falseYStep:
    addi $t6, $zero, -1     # ystep = -1

    skipfalseYStep:

    # for (int x = x0; x <= x1; x++) {
    add $t7, $zero, $a0     # x = x0
    writeLoop:
    beq $t7, $a2, exitWriteLoop
    beq $t0, $zero, elseSTZero
        # out.write((y) + "," + (x) + "\n");
    # #t5 contains y
    # $t7 contains x
    add $s2, $zero, $t5     # $s2 contains y
    add $s3, $zero, $t7     # $s3 contains x
    j skipElseSTZero

    elseSTZero:             # ST == 0
        # out.write((x) + "," + (y) + "\n");
    # #t5 contains y
    # $t7 contains x
    add $s2, $zero, $t7     # $s2 contains x
    add $s3, $zero, $t5     # $s3 contains y



    skipElseSTZero:
    jal writePointsToCSV      # Calls function to write $s2 then ',' then $s3 then '\n' to file
    addi $t7, $t7, 1        # x++
    j writeLoop

    exitWriteLoop:


    j exitProgram

    exitProgram:                                    
        # exit
	    li      $v0, 10
	    syscall
