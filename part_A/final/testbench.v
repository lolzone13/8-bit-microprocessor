// m@nish

`timescale 1ns/100ps

module TB;
  reg clk, start;
//   parameter N = 4;
  BT UUT(clk, start);
  
  initial
    begin
      clk = 0;
      start = 0;
      // start it before posedge
      #0.5 start = 1;
    end
  
  initial
    begin
      #50 $finish;
    end
  
  //clock with T = 2ns
  always #1 clk = ~clk;
  
  initial
    begin
      $dumpfile("plot.vcd");
      $dumpvars(0, TB);
    end
endmodule