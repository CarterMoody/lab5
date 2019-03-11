j main

circle:

    # $t0 - $t4 correspond to x, y, g, diagonalIn, rightInc respectively
    add     $t0, $0, $0     # x = 0
    add     $t1, $0, $a2    # y = r    

    sll     $t4, $a2, 1
    addi    $t2, $0, 3 
    sub     $t2, $t2, $t4   # g = 3 - 4 * r

    sll     $t4, $a2, 2
    addi    $t3, $0, 10 
    sub     $t3, $t3, $t4   # diagonalInc = 10 - 4 * r   

    addi    $t4, $0, 6     # rightInc = 6 

    plot:
        #check if plot loop ends
        slt     $t5, $t1, $t0   # break if y < x
        bne     $t5, $0, exit   

        #plot (xc+x, yc+y)
        add $t5, $a0, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+x, yc-y)
        add $t5, $a0, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-x, yc+y)
        sub $t5, $a0, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-x, yc-y)
        sub $t5, $a0, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+y, yc+x)
        add $t5, $a0, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+y, yc-x)
        add $t5, $a0, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-y, yc+x)
        sub $t5, $a0, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-y, yc-x)
        sub $t5, $a0, $t1
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t0
        sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        # if g >=  0
        if:
            # check condition
            slt     $t5, $0, $t2   # break if 0 < g
            beq     $t5, $0, else   

            add $t2, $t2, $t3   # g += diagonalInc
            addi $t3, $t3, 8    # diagonalInc += 8
            addi $t1, $t1, -1   # y -= 1
            j endIf
        else:
            add $t2, $t2, $t4   # g += rightInc
            addi $t3, $t3, 4    # diagonalInc += 4
        endIf:
        # end conditional statement

        addi $t4, $t4, 4        # rightInc += 4
        addi $t0, $t0, 1        # x += 1

        j plot

    exit:

    jr $ra

# end of circle function

# Line Function 

line:
    # Clear Registers
    add $t0, $0, $0
    add $t1, $0, $0
    add $t2, $0, $0
    add $t3, $0, $0                # add Zero into $temps, clearing it
    add $t4, $0, $0                # Might be more instructions than add rd, $0, $0
    add $t5, $0, $0
    add $t6, $0, $0
    add $t7, $0, $0
    add $t8, $0, $0
    add $t9, $0, $0


    # calculate Absolute Value of y1 - y0
    sub $t0, $a3, $a1       # Compute y1 - y0
    add $t1, $t0, $0     # Copy $t0 into $t1
    slt $t2, $t1, $0         # Is $t1 less than 0?
    beq $t2, $0, absContinue1    # Is $t1 less than 0?
    sub $t1, $0, $t0     # Negative minus Negative = Positive\

    absContinue1:               # $t1 contains the absolute value of y1 - y0
    # Calculate Absolute Value of x1 - x0
    sub $t3, $a2, $a0       # Compute x1 - x0
    add $t4, $t3, $0     # Copy $t3 into $t4
    slt $t5, $t4, $0         # Is $t4 less than 0?
    beq $t5, $0, absContinue2    # Is $t4 less than 0?
    sub $t4, $0, $t3     # Negative minus Negative = Positive

    absContinue2:               # $t4 contains the absolute value of x1 - x0
    sub $t5, $t1, $t4       # (Math.abs(y1 - y0) > Math.abs(x1 - x0)) 
    slt $t2, $t5, $0
    beq $t2, $0, absIf
    # else
    add $t0, $0, $0   # st = 0;
    j skipIfST              # Jump to after if(st==1)

    absIf:
    addi $t0, $0, 1      # st = 1
    # Swap x0 and y0
    add $t1, $0, $a0     # temp = x0
    add $a0, $0, $a1     # x0 = y0
    add $a1, $0, $t1     # y0 = temp

    # Swap x1 and y1
    add $t1, $a2, $0        # temp = x1
    add $a2, $0, $a3     # x1 = y1
    add $a3, $0, $t1     # y1 = temp

    skipIfST:
    # if (x0 > x1)
    slt $t7, $a2, $a0       # $t7 will be 1 if x1 < x0
    beq $t7, $0, falseSwap
    # swap x0 and x1
    add $t1, $0, $a0     # temp = x0
    add $a0, $0, $a2     # x0 = x1
    add $a2, $0, $t1     # x1 = temp
    # swap y0 and y1
    add $t1, $0, $a1     # temp = y0
    add $a1, $0, $a3     # y0 = y1
    add $a3, $0, $t1     # y1 = temp

    falseSwap:
    sub $t9, $a2, $a0       # deltax = x1 - x0
    # calculate Absolute Value of y1 - y0
    sub $t7, $a3, $a1              # Compute y1 - y0
    add $t1, $t7, $0                # Copy $t0 into $t1
    slt $t2, $t1, $0            # Is $t1 less than 0?
    beq $t2, $0, absContinue3   # Is $t1 less than 0?
    sub $t1, $0, $t7            # Negative minus Negative = Positive
    
    absContinue3:               # $t1 contains the absolute value of y1 - y0
    add $t3, $t1, $0        # deltay = Math.abs(y1 - y0) from earlier
    add $t4, $0, $0   # error = 0
    add $t5, $0, $a1     # y = y0
    slt $t7, $a1, $a3       # $t7 will be 1 if y0 < y1
    beq $t7, $0, falseYStep
    addi $t6, $0, 1      # ystep = 1
    j skipfalseYStep

    falseYStep:
    addi $t6, $0, -1     # ystep = -1

    skipfalseYStep:
    # for (int x = x0; x <= x1; x++) {
    add $t7, $0, $a0     # x = x0
    add $s5, $0, $a2     # $s5 contains copy of x1
    addi $s5, $s5, 1        # add 1 to $s5 for loop beq condition

    writeLoop:
    beq $t7, $s5, exitWriteLoop     # break on x > x1
    beq $t0, $0, elseSTZero      # is ST==0?
    # out.write((y) + "," + (x) + "\n");
    add $s2, $0, $t5     # $s2 contains y
    add $s3, $0, $t7     # $s3 contains x
    j skipElseSTZero

    elseSTZero:             # ST == 0
    # out.write((x) + "," + (y) + "\n");
    # #t5 contains y
    # $t7 contains x
    add $s2, $0, $t7     # $s2 contains x
    add $s3, $0, $t5     # $s3 contains y

    skipElseSTZero:
    # jal writePointsToCSV      # Calls function to write $s2 then ',' then $s3 then '\n' to file
    # Write Points to Memory
    sw $s2, 0($s0)              # Write $s2 to memory
    addi $s0, $s0, 1            # increment stack pointer (memory pointer)
    sw $s3, 0($s0)              # Write $s3 to memory
    addi $s0, $s0, 1            # increment stack pointer
    add $t4, $t4, $t3       # error = error + deltay

    # if (2* error >= deltax)
    add $t8, $0, $0  # reset $t8
    addi $t1, $0, 1
    sll $s4, $t4, $t1       # $s4 = error * 2
    slt $t8, $t9, $s4       # $t8 = 1 if deltax < 2*error
    beq $t8, $0 false2TimesError
    add $t5, $t5, $t6       # y = y + ystep
    sub $t4, $t4, $t9       # error = error - deltax

    false2TimesError:
    addi $t7, $t7, 1        # x++
    j writeLoop

    exitWriteLoop:

    jr $ra                  # return

# end of line function

main:

    # s0 -> index in memory
    add $s0, $0, $0

    # Circle(30,100,20) (head)

    addi $a0, $0, 30    # xc
    addi $a1, $0, 100   # yc
    addi $a2, $0, 20    # r

    jal circle

    # Line(30,80,30,30) (body)

    addi $a0, $0, 30    # x0
    addi $a1, $0, 80    # y0
    addi $a2, $0, 30    # x1
    addi $a3, $0, 30    # y1

    jal line

    # Line(20,1,30,30) (left leg)

    addi $a0, $0, 20    # x0
    addi $a1, $0, 1     # y0
    addi $a2, $0, 30    # x1
    addi $a3, $0, 30    # y1

    jal line

	# Line(40,1,30,30) (right leg)

    addi $a0, $0, 40    # x0
    addi $a1, $0, 1     # y0
    addi $a2, $0, 30    # x1
    addi $a3, $0, 30    # y1

    jal line

	# Line(15,60,30,50) (left arm)

    addi $a0, $0, 15    # x0
    addi $a1, $0, 60    # y0
    addi $a2, $0, 30    # x1
    addi $a3, $0, 50    # y1

    jal line

	# Line(30,50,45,60) (right arm)

    addi $a0, $0, 30    # x0
    addi $a1, $0, 50    # y0
    addi $a2, $0, 45    # x1
    addi $a3, $0, 60    # y1

    jal line

    # Circle(24,105,3) (left eye)

    addi $a0, $0, 24    # xc
    addi $a1, $0, 105   # yc
    addi $a2, $0, 3     # r

    jal circle

    # Circle(36,105,3) (right eye)

    addi $a0, $0, 36    # xc
    addi $a1, $0, 105   # yc
    addi $a2, $0, 3     # r

    jal circle

    # Line(25,90,35,90) (mouth center)

    addi $a0, $0, 25    # x0
    addi $a1, $0, 90    # y0
    addi $a2, $0, 35    # x1
    addi $a3, $0, 90    # y1

    jal line

	# Line(25,90,20,95) (mouth left)

    addi $a0, $0, 25    # x0
    addi $a1, $0, 90    # y0
    addi $a2, $0, 20    # x1
    addi $a3, $0, 95    # y1

    jal line

	# Line(35,90,40,95) (mouth right)

    addi $a0, $0, 35    # x0
    addi $a1, $0, 90    # y0
    addi $a2, $0, 40    # x1
    addi $a3, $0, 95    # y1

    jal line
