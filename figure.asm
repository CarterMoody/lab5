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
    
    #j plotTest  # testing plots without store for qtspim

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

        j plotTestEnd

    plotTest:
        #check if plot loop ends
        slt     $t5, $t1, $t0   # break if y < x
        bne     $t5, $0, exit   

        #plot (xc+x, yc+y)
        add $t5, $a0, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+x, yc-y)
        add $t5, $a0, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-x, yc+y)
        sub $t5, $a0, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-x, yc-y)
        sub $t5, $a0, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+y, yc+x)
        add $t5, $a0, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc+y, yc-x)
        add $t5, $a0, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-y, yc+x)
        sub $t5, $a0, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        add $t5, $a1, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        #plot (xc-y, yc-x)
        sub $t5, $a0, $t1
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1

        sub $t5, $a1, $t0
        #sw   $t5,  0($s0) 
        addi $s0, $s0, 1
    
    plotTestEnd:

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

line:

    # initialize all values to 0
    # reserved variables are $t0 - $t4
    add $t0, $0, $0     # st
    add $t1, $0, $0     # deltax
    add $t2, $0, $0     # deltay
    add $t3, $0, $0     # error
    add $t4, $0, $0     # ystep

    # abs(y1 - y0) > abs(x1 - x0)

        # abs(y1 - y0)
        sub $t5, $a3, $a1
        slt $t6, $t5, $0     
        beq $t6, $0, absSkip1  
        sub $t5, $0, $t5      
        absSkip1:

        # abs(x1 - x0)
        sub $t6, $a2, $a0
        slt $t7, $t6, $0     
        beq $t7, $0, absSkip2  
        sub $t6, $0, $t6      
        absSkip2:

        # $t5 > t6 ???
        slt $t5, $t5, $t6
        bne $t5, $0, absElse
        addi $t0, $0, 1
        absElse:

    lineLoop:

    jr $ra

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
