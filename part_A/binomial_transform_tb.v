module binomial_transform_tb();

 
  reg [159:0] array_val;
  reg [15:0] output_val;
  

  
  array_val[159-:16] = 16'd23;
  array_val[143-:16] = 16'd12;
  array_val[127-:16] = 16'd33;
  array_val[111-:16] = 16'd15;
  array_val[95-:16] = 16'd53;
  array_val[79-:16] = 16'd02;
  array_val[63-:16] = 16'd06;
  array_val[47-:16] = 16'd07;
  array_val[31-:16] = 16'd04;
  array_val[15-:16] = 16'd01;
  binomial_transform MM (array_val, output_val);
   initial
     begin
       $dumpfile("plot.vcd")
       $dumpvars(1, binomial_transform_tb);

     end
  	
  
  initial begin
    $display("Output");
    $monitor("%d", output_val); 

 
  
  end
 
endmodule