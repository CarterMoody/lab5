import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.*;

class Sample {

    // xc = center x coordinate, yc = center y coordinate, r = radius
    public static void circle(int xc, int yc, int r) { 
      int x = 0;
      int y = r;
      int g = 3 - 2*r;
      int diagonalInc = 10 - 4*r;
      int rightInc = 6;

      try {
          final FileWriter fw = new FileWriter("outfilename.csv");
          final BufferedWriter out = new BufferedWriter(fw);

          while (x <= y) {
        
              //plot the 8 different points to construct the circle
              out.write((xc + x) + "," + (yc + y) + "\n");
              out.write((xc + x) + "," + (yc - y) + "\n");
              out.write((xc - x) + "," + (yc + y) + "\n");
              out.write((xc - x) + "," + (yc - y) + "\n");
              out.write((xc + y) + "," + (yc + x) + "\n");
              out.write((xc + y) + "," + (yc - x) + "\n");
              out.write((xc - y) + "," + (yc + x) + "\n");
              out.write((xc - y) + "," + (yc - x) + "\n");
          
              if (g >=  0) {
                g += diagonalInc;
                diagonalInc += 8;
                y -= 1;
              } else {
                g += rightInc;
                diagonalInc += 4;
              }
          
              rightInc += 4;
              x += 1;
          
            }  //end while loop

            out.close();
            fw.close();

      } catch (IOException e) {
  
      }

  }  //end BresenhamCircle

  
  public static void Line (int x0, int y0, int x1, int y1) {
    int st, temp, deltax, deltay, error, y, ystep;

    if (Math.abs(y1 - y0) > Math.abs(x1 - x0)) 
    {
      st = 1;
    } else {
      st = 0;
    }
  
    if (st == 1) {
        // swap x0 and y0
        temp = x0;
        x0 = y0;
        y0 = temp;

        // swap x1 and y1
        temp = x1;
        x1 = y1;
        y1 = temp;
    }
   
    if (x0 > x1) {
  
        // swap x0 and x1
        temp = x1;
        x1 = x0;
        x0 = x1;

        // swap y0 and y1
        temp = y0;
        y0 = y1;
        y1 = y0;

    }
  
    deltax = x1 - x0;
    deltay = Math.abs(y1 - y0);
    error = 0;
    y = y0;
   
    if (y0 < y1) {
      ystep = 1;
    } else {
      ystep = -1;
    }
   
    // Setup Buffer Writing to File
    try {
      final FileWriter fw = new FileWriter("outfilename.csv");
      final BufferedWriter out = new BufferedWriter(fw);
      for (int x = x0; x <= x1; x++) {
          if (st == 1) {
              //plot(y,x);
              out.write((y) + "," + (x) + "\n");
          } else {
             //plot(x,y);\
             out.write((x) + "," + (y) + "\n");

          }
  
          error = error + deltay;
  
          if (2*error >= deltax) {
              y = y + ystep;
              error = error - deltax;
          } //end if
      }  //end for loop
    } catch (IOException e) {

    }
    
} //end function



  public static void main(String args[]) {
    
        //out = new BufferedWriter(new FileWriter("outfilename"));

        // call circle
        circle(1, 2, 3);
    }
}