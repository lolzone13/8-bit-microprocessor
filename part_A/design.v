`timescale 1ns/100ps


module BT(clk, start_calculation);
  input clk, start_calculation;
  
  reg [7:0]data[3:0];
  
  initial begin
    data[0] = 9;
    data[1] = 25;
    data[2] = 60;
    data[3] = 220;
  end
  
  
  
  always @(posedge clk)
    begin
      // here count will go from 0 to N-1
      if(running)
        begin
      		data[count] = data[count+1] - data[count];
        end
    end
  
  //call counter
  reg [3:0]N = 4'b0011; //set it to N-1
  wire [3:0]count;
  wire running;
  modNcounter CNTR(count,clk, N, start_calculation, running);
  
  initial begin
    $monitor($time, " data0 = %d, data1 = %d, data2 = %d, data3 = %d", data[0], data[1], data[2], data[3]);
  end
endmodule










// eg 4 bit counter count 01230123...
module modNcounter(out, clk, N, enable_cntr, running);
  	output [3:0]out;
  	output running;
  	input clk, enable_cntr;
  	input [3:0] N;
  	reg running;
  reg [3:0]NN = 4'b1111;
  	// initialize out as 0
  	reg out = 0;
	
//   initial
//     begin
//       NN = N;
//     end
  // set NN value
  always @ (posedge clk)
    begin
      if(NN == 4'b1111)
        begin
      		NN <= N;
        end
    end
  //set running
  always @ (posedge enable_cntr)
    begin
      running <=1;
    end
  always @ (negedge clk)
      begin
        
        if(!enable_cntr || NN == 1)
          begin
            out <= 0;
            running <= 0;
          end
        else
          begin
            running <= 1;
            if (out == NN-1)
              begin
              	out <= 0;
                NN <= NN-1;
              end
      		else
              begin
        		out <= out + 1; 
              end
          end  
      end
  
endmodule