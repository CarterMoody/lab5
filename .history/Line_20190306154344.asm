# Name:         Robert Hensley, Carter Moody
# Section:      09
# Description:  returns the quotient of a 64-bit integer (divisor must be a power of 2)

#   public static void Line (int x0, int y0, int x1, int y1) {
#     int st, temp, deltax, detlay, error, y, ystep;

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
#         y0 = t0;

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
#       for (int i = x0; x0 <= x1; i++) {
#           if (st == 1) {
#               plot(y,x);
#           } else {
#              plot(x,y);
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

.text

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
    # t7: Stores t0                     (t0)

    # s0: Stores Final X point value
    # s1: Stores Final Y point value

    move $t0, $zero
    move $t1, $zero
    move $t2, $zero
    move $t3, $zero                # Move Zero into $temps, clearing it
    move $t4, $zero
    move $t5, $zero
    move $t6, $zero
    move $t7, $zero

    
    line:
        # Break when for loop ends
        beq 

        j line                     # Jump back to 'line'

    exitLine:                                    
        # exit
	    li      $v0, 10
	    syscall
