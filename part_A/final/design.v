// m@nish

`timescale 1ns/100ps


module BT(clk, start_calculation);
  input clk, start_calculation;
  parameter WORD_SIZE = 16;
  parameter N_1 = 5;
  reg [3:0]N = 5; //set it to N-1
  reg [WORD_SIZE - 1:0]data[N_1:0];
  
  initial begin
    // test integers data
//     data[0] = 9;
//     data[1] = 25;
//     data[2] = 60;
//     data[3] = 220;
//     data[4] = 450;
//     data[5] = 1600;
//     data[6] = 6840;
    
    //gives precision lost
//     data[0] = 16'h4880;//9
//     data[1] = 16'h4e40;//25
//     data[2] = 16'h5380;//60;
//     data[3] = 16'h5ae0;//220;
//     data[4] = 16'h5f08;//450;
//     data[5] = 16'h6640;//1600;
//     data[6] = 16'h6eae;//6840;
    
    data[0] = 16'h0000;//0
    data[1] = 16'h3c00;//1
    data[2] = 16'h4900;//10;
    data[3] = 16'h53e0;//63;
    data[4] = 16'h5d10;//324;
    data[5] = 16'h65cd;//1485;
  end
  
  //call counter
  // it counts the index
  wire [3:0]count;
  wire running;
  modNcounter CNTR(count,clk, N, start_calculation, running);
  
  // call adder
  wire [15:0]adder_result;
  reg [15:0]num1 =0;
  reg [15:0]num2 =0;
  wire overflow, zero, NaN, precisionLost;
  
  float_adder ADDR(num1, num2, adder_result, overflow, zero, NaN, precisionLost);
//   integer_adder ADDR(num1, num2, adder_result);
  
  always @(posedge clk)
    begin
      // here count will go from 0 to N-1
      if(running)
        begin
          num1 <= data[count+1];
          // make num2 negative
          num2 <= data_cnt_neg; //for ieee754 hp
//           num2 = ~data[count]+1; //for normal integers 2's compli
          //           data[count] = adder_result; //dont assign here
//       	  data[count] = data[count+1] - data[count];
        end
    end
  //assign values at neg edge
  always @(negedge clk)
    begin
      if(running)
        begin
          data[count] = adder_result;
        end
    end
  
  wire [15:0]data_cnt_neg;
  assign data_cnt_neg = data[count]^(16'b1000_0000_0000_0000);
  
  
  initial begin
    $monitor($time, " data0 = %h, data1 = %h, data2 = %h, data3 = %h, data4 = %h, data5 = %h", data[0], data[1], data[2], data[3], data[4], data[5]);
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





module integer_adder(num1, num2, result);
  	// num1 num2 and result in ieee754 format half precision
  input [15:0] num1;
  input [15:0] num2;
  	output [15:0] result;
  
  	assign result = num1 + num2;
endmodule
  


module float_adder(num1, num2, result, overflow, zero, NaN, precisionLost);
  //Ports
  input [15:0] num1, num2;
  output [15:0] result;
  output overflow; //overflow flag
  output zero; //zero flag
  output NaN; //Not a Number flag
  output reg precisionLost;
  //Reassing numbers as big and small
  reg [15:0] bigNum, smallNum; //to seperate big and small numbers
  //Decode big and small number
  wire [9:0] big_fra, small_fra; //to hold fraction part
  wire [4:0] big_ex_pre, small_ex_pre;
  wire [4:0] big_ex, small_ex; //to hold exponent part
  wire big_sig, small_sig; //to hold signs
  wire [10:0] big_float, small_float; //to hold as float number with integer
  reg [10:0] sign_small_float, shifted_small_float; //preparing small float
  wire [4:0] ex_diff; //difrence between exponentials
  reg [9:0] sum_shifted; //Shift fraction part of sum
  reg [3:0] shift_am;
  wire neg_exp;
  //Extensions for higher precision
  reg [9:0] small_extension;
  wire [9:0] sum_extension;

  wire [10:0] sum; //sum of numbers with integer parts
  wire sum_carry;
  wire sameSign;
  wire zeroSmall;
  wire inf_num; //at least on of the operands is inf.

  wire [4:0] res_exp_same_s, res_exp_diff_s;
  
  //Flags
  assign zero = (num1[14:0] == num2[14:0]) & (~num1[15] == num2[15]);
  assign overflow = ((&big_ex[4:1] & ~big_ex[0]) & sum_carry & sameSign) | inf_num;
  assign NaN = (&num1[14:10] & |num1[9:0]) | (&num2[14:10] & |num2[9:0]);
  assign inf_num = (&num1[14:10] & ~|num1[9:0]) | (&num2[14:10] & ~|num2[9:0]); //check for infinate number
  //Get result
  assign result[15] = big_sig; //result sign same as big sign
  assign res_exp_same_s = big_ex + {4'd0, (~zeroSmall & sum_carry & sameSign)} - {4'd0,({1'b0,result[9:0]} == sum)};
  assign res_exp_diff_s = (neg_exp | (shift_am == 4'd10)) ? 5'd0 : (~shift_am + big_ex + 5'd1);
  assign result[14:10] = ((sameSign) ? res_exp_same_s : res_exp_diff_s) | {5{overflow}}; //result exponent
  assign result[9:0] = ((zeroSmall) ? big_fra : ((sameSign) ? ((sum_carry) ? sum[10:1] : sum[9:0]) : ((neg_exp) ? 10'd0 : sum_shifted))) & {10{~overflow}};

  //decode numbers
  assign {big_sig, big_ex_pre, big_fra} = bigNum;
  assign {small_sig, small_ex_pre, small_fra} = smallNum;
  assign sameSign = (big_sig == small_sig);
  assign zeroSmall = ~(|small_ex | |small_fra);
  assign big_ex = big_ex_pre + {4'd0, ~|big_ex_pre};
  assign small_ex = small_ex_pre + {4'd0, ~|small_ex_pre};

  //add integer parts
  assign big_float = {|big_ex_pre, big_fra};
  assign small_float = {|small_ex_pre, small_fra};
  assign ex_diff = big_ex - small_ex; //diffrence between exponents
  assign {sum_carry, sum} = sign_small_float + big_float; //add numbers
  assign sum_extension = small_extension;

  //Get shift amount for subtraction
  assign neg_exp = (big_ex < shift_am);
  always@*
    begin
      casex(sum)
        11'b1xxxxxxxxxx: shift_am = 4'd0;
        11'b01xxxxxxxxx: shift_am = 4'd1;
        11'b001xxxxxxxx: shift_am = 4'd2;
        11'b0001xxxxxxx: shift_am = 4'd3;
        11'b00001xxxxxx: shift_am = 4'd4;
        11'b000001xxxxx: shift_am = 4'd5;
        11'b0000001xxxx: shift_am = 4'd6;
        11'b00000001xxx: shift_am = 4'd7;
        11'b000000001xx: shift_am = 4'd8;
        11'b0000000001x: shift_am = 4'd9;
        default: shift_am = 4'd10;
      endcase
    end

  //Shift result for sub.
  always@* 
    begin
      case (shift_am)
        4'd0: sum_shifted =  sum[9:0];
        4'd1: sum_shifted = {sum[8:0],sum_extension[9]};
        4'd2: sum_shifted = {sum[7:0],sum_extension[9:8]};
        4'd3: sum_shifted = {sum[6:0],sum_extension[9:7]};
        4'd4: sum_shifted = {sum[5:0],sum_extension[9:6]};
        4'd5: sum_shifted = {sum[4:0],sum_extension[9:5]};
        4'd6: sum_shifted = {sum[3:0],sum_extension[9:4]};
        4'd7: sum_shifted = {sum[2:0],sum_extension[9:3]};
        4'd8: sum_shifted = {sum[1:0],sum_extension[9:2]};
        4'd9: sum_shifted = {sum[0],  sum_extension[9:1]};
        default: sum_shifted = sum_extension;
      endcase
      case (shift_am)
        4'd0: precisionLost = |sum_extension;
        4'd1: precisionLost = |sum_extension[8:0];
        4'd2: precisionLost = |sum_extension[7:0];
        4'd3: precisionLost = |sum_extension[6:0];
        4'd4: precisionLost = |sum_extension[5:0];
        4'd5: precisionLost = |sum_extension[4:0];
        4'd6: precisionLost = |sum_extension[3:0];
        4'd7: precisionLost = |sum_extension[2:0];
        4'd8: precisionLost = |sum_extension[1:0];
        4'd9: precisionLost = |sum_extension[0];
        default: precisionLost = 1'b0;
      endcase
    end

  //take small number to exponent of big number
  always@* 
    begin
      case (ex_diff)
        5'h0: {shifted_small_float,small_extension} = {small_float,10'd0};
        5'h1: {shifted_small_float,small_extension} = {small_float,9'd0};
        5'h2: {shifted_small_float,small_extension} = {small_float,8'd0};
        5'h3: {shifted_small_float,small_extension} = {small_float,7'd0};
        5'h4: {shifted_small_float,small_extension} = {small_float,6'd0};
        5'h5: {shifted_small_float,small_extension} = {small_float,5'd0};
        5'h6: {shifted_small_float,small_extension} = {small_float,4'd0};
        5'h7: {shifted_small_float,small_extension} = {small_float,3'd0};
        5'h8: {shifted_small_float,small_extension} = {small_float,2'd0};
        5'h9: {shifted_small_float,small_extension} = {small_float,1'd0};
        5'ha: {shifted_small_float,small_extension} = small_float;
        5'hb: {shifted_small_float,small_extension} = small_float[10:1];
        5'hc: {shifted_small_float,small_extension} = small_float[10:2];
        5'hd: {shifted_small_float,small_extension} = small_float[10:3];
        5'he: {shifted_small_float,small_extension} = small_float[10:4];
        5'hf: {shifted_small_float,small_extension} = small_float[10:5];
        5'h10: {shifted_small_float,small_extension} = small_float[10:5];
        5'h11: {shifted_small_float,small_extension} = small_float[10:6];
        5'h12: {shifted_small_float,small_extension} = small_float[10:7];
        5'h13: {shifted_small_float,small_extension} = small_float[10:8];
        5'h14: {shifted_small_float,small_extension} = small_float[10:9];
        5'h15: {shifted_small_float,small_extension} = small_float[10];
        5'h16: {shifted_small_float,small_extension} = 0;
      endcase
    end

  always@* //if signs are diffrent take 2s compliment of small number
    begin
      if(sameSign)
        begin
          sign_small_float = shifted_small_float;
        end
      else
        begin
          sign_small_float = ~shifted_small_float + 11'b1;
        end
    end

  always@* //determine big number
    begin
      if(num2[14:10] > num1[14:10])
        begin
          bigNum = num2;
          smallNum = num1;
        end
      else if(num2[14:10] == num1[14:10])
        begin
          if(num2[9:0] > num1[9:0])
            begin
              bigNum = num2;
              smallNum = num1;
            end
          else
            begin
              bigNum = num1;
              smallNum = num2;
            end
        end
      else
        begin
          bigNum = num1;
          smallNum = num2;
        end
    end
endmodule