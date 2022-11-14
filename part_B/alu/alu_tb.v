module alu_tb;

  reg [7:0] in_a;
  reg [7:0] in_b;
  reg en;
  reg clk;
  wire [7:0] sum;
  reg [2:0] mode;
  wire fz,fc;
  alu alu (en,clk,mode, in_a, in_b, sum,fz,fc);
  initial begin
    en=1;
    clk=0;
    mode=3'b000;
    in_a=8'b0000_0000;
    in_b=8'b0000_0000;
    
    forever #20 clk=~clk;
  end
  initial begin
    #5 mode = 3'b000;
    #5 in_a = 8'b0000_0101; in_b = 8'b0000_1101;
  end

  initial begin
    $monitor("time = %2d, A = %d, B = %d, SUM = %b, zero_flag = %b, carry_flag = %b", $time, in_a, in_b, sum, fz, fc);
  end

endmodule