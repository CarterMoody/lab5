# Name:         Robert Hensley, Carter Moody
# Section:      09
# Description:  returns the quotient of a 64-bit integer (divisor must be a power of 2)

.text


main:

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

    ################################################################################
    #### PSEUDO FUNCTION CALLS ####
    ################################################################################
    # Body
    #  addi $a0, $zero, 30
    # addi $a1, $zero, 80
    #  addi $a2, $zero, 30
    #  addi $a3, $zero, 30

     #Left Leg
       addi $a0, $zero, 20
       addi $a1, $zero, 1
       addi $a2, $zero, 30
       addi $a3, $zero, 30



    ################################################################################
    ################################################################################
    ################################################################################


    # Clear Registers
    move $t0, $zero
    move $t1, $zero
    move $t2, $zero
    move $t3, $zero                # Move Zero into $temps, clearing it
    move $t4, $zero                # Might be more instructions than add rd, $zero, $zero
    move $t5, $zero
    move $t6, $zero
    move $t7, $zero
    move $t8, $zero
    move $t9, $zero


    # calculate Absolute Value of y1 - y0
    sub $t0, $a3, $a1       # Compute y1 - y0
    ori $t1, $t0, 0     # Copy $t0 into $t1
    slt $t2, $t1, $zero         # Is $t1 less than 0?
    beq $t2, $zero, absContinue1    # Is $t1 less than 0?
    sub $t1, $zero, $t0     # Negative minus Negative = Positive
    

    absContinue1:               # $t1 contains the absolute value of y1 - y0
    #ori $s1, $t1, 0             # copy absolute value answer into $s1 for later

    # Calculate Absolute Value of x1 - x0
    sub $t3, $a2, $a0       # Compute x1 - x0
    ori $t4, $t3, 0     # Copy $t3 into $t4
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
    addi $t1, $a2, 0        # temp = x1
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

    sub $t9, $a2, $a0       # deltax = x1 - x0


        # calculate Absolute Value of y1 - y0
    sub $t7, $a3, $a1              # Compute y1 - y0
    ori $t1, $t7, 0                # Copy $t0 into $t1
    slt $t2, $t1, $zero            # Is $t1 less than 0?
    beq $t2, $zero, absContinue3   # Is $t1 less than 0?
    sub $t1, $zero, $t7            # Negative minus Negative = Positive
    

    absContinue3:               # $t1 contains the absolute value of y1 - y0

    ori $t3, $t1, 0        # deltay = Math.abs(y1 - y0) from earlier


    ###################
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
    add $s5, $zero, $a2     # $s5 contains copy of x1
    addi $s5, $s5, 1        # add 1 to $s5 for loop beq condition
    writeLoop:
    beq $t7, $s5, exitWriteLoop     # break on x > x1
    beq $t0, $zero, elseSTZero      # is ST==0?
    # out.write((y) + "," + (x) + "\n");
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
    #jal writePointsToCSV      # Calls function to write $s2 then ',' then $s3 then '\n' to file

    add $t4, $t4, $t3       # error = error + deltay


    # if (2* error >= deltax)
    add $t8, $zero, $zero  # reset $t8
    addi $t1, $zero, 1
    sll $s4, $t4, $t1       # $s4 = error * 2
    slt $t8, $t9, $s4       # $t8 = 1 if deltax < 2*error
    beq $t8, $zero false2TimesError
    add $t5, $t5, $t6       # y = y + ystep
    sub $t4, $t4, $t9       # error = error - deltax

    false2TimesError:

    addi $t7, $t7, 1        # x++
    j writeLoop

    exitWriteLoop:


    j exitProgram

    exitProgram:  


        # exit
	    li      $v0, 10
	    syscall
