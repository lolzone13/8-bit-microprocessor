// `include "registers/registers.v";
// `include "alu/alu.v";

module registers(
    // input wire [1:0] register_select,
    // input clk,
    // input mem_enable,
    // input read_write,
    // input wire [7:0] data_bus_in,
    // output wire [7:0] data_bus_out\

    // imm store daala hain bhai

    temp, rb_out, temp_rw, temp_e, rb_sel, rb_e, rb_rw, clk, data_in, imm, immLD, four_bit_bus,alu_output_st,mov_inst, read_write_memory
);
input clk;
input read_write_memory;
input temp_rw, temp_e, rb_e, rb_rw,mov_inst,alu_output_st;
output [7:0] temp, rb_out;
input [1:0]rb_sel;
input [7:0] data_in; 
wire [7:0] dout;
reg [7:0] din;
reg [7:0] register_array [3:0]; // 4 registers
reg [7:0] temp_reg, temp_rb_out;
wire [1:0] mov_temp;
input [3:0]four_bit_bus;
input immLD;
input imm;

initial begin
    if (immLD) din = register_array[0];
end
external_ram external_ram(sign_extended_imm_value_LDST, clk, din, dout,read_write_memory);


initial
begin
  register_array[0] = 1;
  register_array[1] = 0;
  register_array[2] = 0;
  register_array[3] = 0;
end

always @(posedge clk) begin
    if (rb_e) begin
        case (~rb_rw)
            1'b1: begin 
                temp_rb_out = register_array[rb_sel];     // read;
                temp_reg =(temp_rw)?(temp_rb_out):(temp_reg);
                if (immLD) din = register_array[0];
                $display("READ   - Address=%d, temp: %d, rb: %d", rb_sel, temp_reg, temp_rb_out);

            end
            1'b0: begin 
                if(alu_output_st) register_array[rb_sel] = data_in;     // write
                if(immLD) register_array[0] = dout;                
                if(mov_inst) register_array[rb_sel] = (imm)?mov_imm_val:register_array[four_bit_bus[1:0]];
                $display("WRITE   - Address=%d, Register_contents: %d", rb_sel, register_array[rb_sel]);
            end
            default: ;
        endcase
    end
end
wire [7:0]sign_extended_imm_value,mov_imm_val;
sign_extn SGN_0 (rb_sel, sign_extended_imm_value);
assign rb_out = (~temp_rw)?((imm)?(sign_extended_imm_value):(temp_rb_out)):(8'b0000_0000);
assign temp = (~temp_rw) ? temp_reg : 8'b0000_0000;

assign mov_temp=four_bit_bus[1:0];

wire [7:0]sign_extended_imm_value_LDST;
sign_extn_LDST SGN_1 (four_bit_bus, sign_extended_imm_value_LDST);
sign_extn SGN_2 (mov_temp, mov_imm_val);

endmodule

module sign_extn(inp, out);
    input [1:0] inp;
    output [7:0] out;

    assign out = (inp[1])?({6'b111111,inp}):({6'b000000,inp});
endmodule


module sign_extn_LDST(inp, out);
    input [3:0] inp;
    output [7:0] out;

    assign out = (inp[1])?({6'b1111,inp}):({6'b0000,inp});
endmodule 


module PC(PC_out,PC_clk,PC_inc
    );
	
	output[3:0] PC_out;
	input PC_clk;
	input PC_inc;
	
	reg[3:0] PC_out = 4'b0000;
	
	always @(posedge PC_clk)
	begin
        if(PC_inc) begin
            PC_out <= PC_out + 1;    
        end
	end

    assign PC_next =  4'b0001;
	
endmodule

// module tb;
//     wire[3:0] PC_out;
// 	reg clk;
// 	reg PC_inc;
// 	wire [7 : 0] dout;

//     initial begin
//         clk = 0; PC_inc=0;
//         #10 PC_inc = 1;

//         #500 $finish;
//     end

//     PC pc(PC_out,clk,PC_inc);
//     ram ram(PC_out,clk,8'b00000000,dout,1'b0);

//     initial
//     begin
//         $monitor($time, " PC_inc = %b PC_out = %d dout = %b",PC_inc, PC_out, dout);
//     end

//     always #5 clk = ~clk;


// endmodule


module external_ram (addr, clk, din, dout, we);

    
    
	input [7 : 0] din;
	input [7 : 0] addr;
	input clk, we; //initially 0
	output [7 : 0] dout;
	
	reg [7:0] memory[255:0];
	// reg [7:0] extended_address;
    // initial begin
    //     if (addr[3] == 1) begin
    //         extended_address= {4'b1111,addr};
    //     end
    //     else begin
    //         extended_address= {4'b0000,addr};
    //     end
    // end

    initial begin
        memory[8'b00000001] <= 8'b00000100; 	
		memory[8'b00000010] <= 8'b00100110; 	
		memory[8'b00000011] <= 8'b01000001;
    end

	always @(posedge clk)
	begin
		if (we)
			memory[addr] = din;
	end
	
	assign dout = memory[addr];
    
endmodule


module ram (addr, clk, din, dout, we);

	input [7 : 0] din;
	input [3 : 0] addr;
	input clk, we; //initially 0
	output [7 : 0] dout;
	
	reg [7:0] memory[15:0];
	
	initial
	begin
		memory[4'b0001] <= 8'b00000001; 	
		memory[4'b0010] <= 8'b11000001; 	
		memory[4'b0011] <= 8'b00010011;
        memory[4'b0100] <= 8'b00000011;
        memory[4'b0101] <= 8'b00000000;
	end

	always @(posedge clk)
	begin
		if (we)
			memory[addr] <= din;
	end
	
	assign dout = memory[addr];

endmodule



module alu(
  input wire enable,
  input wire clk,
  input wire [2:0] mode,
  input wire [N-1:0] in_a,
  input wire [N-1:0] in_b,
  output wire [N-1:0] out,
  output reg flag_zero,
  output reg flag_carry
);
  parameter N = 8;
  `define ALU_ADD 3'b100
  `define ALU_SUB 3'b101
  `define ALU_AND 3'b110
  `define ALU_CMP 3'b111
  `define ALU_OR  3'b001
  `define ALU_XOR 3'b011

  reg [N-1:0] buf_out;
  reg [N-1:0] temp_reg;

  initial begin

    flag_carry = 0;
    flag_zero = 0;
    temp_reg = 0;
    // $display("Entered ALU");
    $monitor("alu mode = %b", mode);
  end

  always @(posedge clk) begin
    if (enable) begin
      // $display("Mode Check");
      case (mode)
        `ALU_ADD: {flag_carry, buf_out} = in_a + in_b;
        `ALU_CMP: {flag_carry, temp_reg} = in_a - in_b;
        `ALU_SUB: {flag_carry, buf_out} = in_a - in_b;
        `ALU_AND: buf_out = in_a & in_b;
        `ALU_OR:  buf_out = in_a | in_b;
        `ALU_XOR: buf_out = in_a ^ in_b;
        default:  buf_out = 'hxx;
      endcase
    //   $display("Operation Complete!");
      flag_zero = (buf_out == 0 || temp_reg == 0) ? 1 : 0;

    end
  end

  assign out = buf_out;

endmodule



module CU(instruction,clk,rb_e,rb_rw,rb_select,temp_e,temp_rw,alu_e,alu_mode,imm_instr,State,immLD,four_bit_bus,alu_output_st,mov_inst,PC_inc,read_write_memory
    );
	

	input [7:0] instruction; //PC se laana hai
	output rb_e,rb_rw,temp_e,temp_rw,alu_e,imm_instr,immLD,alu_output_st,mov_inst,PC_inc,read_write_memory;
	output[2:0] alu_mode;
	output[1:0] rb_select;
	input clk;
	output[7:0] State;
    output[3:0] four_bit_bus;
	
	reg rb_e,rb_rw,temp_e,temp_rw,alu_e,imm_instr, immLD,alu_output_st,mov_inst,PC_inc,read_write_memory;
	reg[2:0] alu_mode;
	reg[1:0] rb_select;
	reg[7:0] State,nextstate;
    reg [3:0] four_bit_bus;

	
	parameter s0=0, s1=1, s2=2, s3=3, s4=4, s5=5, s6=6, s7=7, s8=8, s9=9, s10=10, s11=11, s12=12, s13=13, s14=14, s15=15,
					s16=16, s17=17, s18=18, s19=19, s20=20, s21=21, s22=22, s23=23, s24=24, s25=25,s26=26,s27=27;
  initial
  begin
    nextstate = s0;
    
  end
	
	always @(posedge clk)
	begin
		State <= nextstate;	
	end

	always @(State)
	begin
	 case(State)
		s0: 
			begin
				rb_e=0;
				rb_rw=0;
				temp_e=0;
				rb_select=2'b00;
				temp_rw=0;
				alu_e=0;
				alu_mode=3'b000;
                immLD=0;
                four_bit_bus=4'b0000;
				imm_instr=0;
                alu_output_st=0;
                mov_inst=0;
				nextstate = s1; 
                PC_inc=1;
                read_write_memory=0;
			end
		s1:
			begin
				
				PC_inc=0;
			
				nextstate = s2;
			end
		s2:
			begin

                PC_inc=0;
				nextstate=s3;
			end	
		s3: 
			begin
		
			if( instruction[7:6] == 2'b00)
				begin
					if(instruction[5:4]==2'b00)
                        if(instruction[3:0]==4'b0000)nextstate= s24;
                        else nextstate = s12; 
					else if(instruction[5:4]==2'b01)
						nextstate = s13; 
					else if(instruction[5:4]== 2'b10)
						nextstate = s15;
					else
						nextstate = s14;
				end
			else if(instruction[7:6] == 2'b01) 
                nextstate=s4;					
			else if(instruction[7:6] == 2'b11) 
				nextstate=s8;
			else
				begin
					begin
					if(instruction[4]==0)
						nextstate = s16; 
					else
						nextstate = s17; 
				end
				end
			end
		s4:
			begin
                rb_e=1;
				rb_rw=0;
                rb_select= instruction[3:2];
                temp_e=1;
                temp_rw=1;
                nextstate=s5;

			end
		s5:
			begin
                temp_rw=0;
                rb_select= instruction[1:0];
                nextstate=s6;
            end
       s6:
			begin
                alu_e = 1;
              alu_mode = instruction[6:4];
                nextstate=s7;
            end

		s7: 			
			begin
                alu_e=1;
                alu_output_st=1;
                temp_e=0;
                rb_rw=1;
                rb_select= instruction[3:2];
                nextstate=s0;
            end
		s8:		
			begin
				rb_e=1;
				rb_rw=0;
                rb_select= instruction[3:2];
                temp_e=1;
                temp_rw=1;
                nextstate=s9;
			end
		s9:				
			begin
                temp_rw=0;
                rb_select= instruction[1:0];
				imm_instr=1;
                nextstate=s10;
			end
       s10:			
			begin
				alu_e=1;
                alu_mode = instruction[6:4];
                nextstate=s11;
			end
		
		s11:			
			begin
				alu_e=0;
                temp_e=0;
                rb_rw=1;
                alu_output_st=1;
				imm_instr=0;
                rb_e=1;
                rb_select= instruction[3:2];
                nextstate=s0;
			end
        s12:
			begin
                rb_e=0;
				rb_rw=1;
                rb_select = 2'b00;
                read_write_memory=0;
                immLD = 1;
                four_bit_bus = instruction[3:0];                
                nextstate=s13;

			end
        s13: 
			begin
                rb_e=1;                
                nextstate=s0;

			end
        s14:
			begin
                rb_e=1;
				rb_rw=1;
                rb_select = instruction[3:2];
                mov_inst = 1;
                imm_instr=0;
                four_bit_bus = instruction[3:0];                
                nextstate=s0;

			end
        s15:
			begin
                rb_e=1;
				rb_rw=1;
                rb_select = instruction[3:2];
                mov_inst = 1;
                imm_instr=1;
                four_bit_bus = instruction[3:0];                
                nextstate=s0;

			end
        s16:
			begin
                rb_e=1;
				rb_rw=0;
                rb_select= instruction[3:2];
                temp_e=1;
                temp_rw=1;
                nextstate=s17;

			end
		s17:
			begin
                temp_rw=0;
                rb_select= instruction[1:0];
                nextstate=s18;
            end
       s18:
			begin
                alu_e = 1;
                alu_mode = {instruction[6:5],1'b1};
                nextstate=s19;
            end

		s19: 	
			begin
                alu_e=0;
                alu_output_st=1;
                temp_e=0;
                rb_rw=1;
                rb_select= instruction[3:2];
                nextstate=s0;
            end
        s20:		
			begin
				rb_e=1;
				rb_rw=0;
                rb_select= instruction[3:2];
                temp_e=1;
                temp_rw=1;
                nextstate=s21;
			end
		s21:				
			begin
                temp_rw=0;
                rb_select= instruction[1:0];
				imm_instr=1;
                nextstate=s22;
			end
       s22:				
			begin
				alu_e=1;
                alu_mode = {instruction[6:5],1'b1};
                nextstate=s23;
			end
		
		s23:			
			begin
				alu_e=0;
                temp_e=0;
                rb_rw=1;
                alu_output_st=1;
				imm_instr=0;
                rb_e=1;
                rb_select= instruction[3:2];
                nextstate=s0;
			end
        s24:			
			begin
                nextstate=s24;
			end
        s25:			
			begin
				rb_e=1;
				rb_rw=0;
                rb_select = 2'b00;
                read_write_memory=1;             
                nextstate=s0;
                immLD = 1;
                four_bit_bus = instruction[3:0];
			end
        s26:			
			begin
                read_write_memory=1;             
                nextstate=s0;
			end
		
		endcase	
	end


endmodule



module TB;
	// for regs
    reg clk;
    wire temp_rw, temp_e, rb_e, rb_rw,alu_output_st,mov_inst, PC_inc,ext_we;
    wire [1:0]rb_sel; 
    wire [7:0]temp, rb_out;
    reg [7:0] data_in;
    wire imm;
    wire immLD;
    wire [3:0]four_bit_bus,ext_addr;
    wire [3:0]addr;
    //for alu
    wire alu_en;
    wire [2:0] alu_mode;
    wire [7:0] alu_out,State;
    wire flag_zero, flag_carry;
    //for cu
    wire [7:0] instruction,ext_din, ext_dout;


    initial
    begin
        $monitor("alu_out = %d",alu_out);
    end
	initial
	begin
		clk = 0;
		#300 $finish;
	end

	always #5 clk = ~clk;

	registers UUT_0(temp, rb_out, temp_rw, temp_e, rb_sel, rb_e, rb_rw, clk, alu_out, imm,immLD, four_bit_bus,alu_output_st,mov_inst,read_write_memory);
	alu UUT_1(alu_en, clk, alu_mode, temp, rb_out, alu_out, flag_zero, flag_carry);
    CU UUT_2(instruction,clk,rb_e,rb_rw,rb_sel,temp_e,temp_rw,alu_en,alu_mode,imm,State,immLD,four_bit_bus,alu_output_st,mov_inst,PC_inc,read_write_memory);
    PC UUT_3(addr,clk,PC_inc);
    ram UUT_4(addr, clk, 8'b00000000, instruction, 1'b0);
    // external_ram UUT_5(ext_addr, clk, ext_din, ext_dout,ext_we);


    initial
	begin
      $monitor($time, " State=%d, rb_e = %d, rb_rw = %d ,temp_e = %d, temp_rw =%d, alu_e = %d, imm_instr=%d ,alu_mode= %d, rb_sel = %d alu_out = %d PC_inc = %b instruction = %b addr = %b",State, rb_e, rb_rw, temp_e, temp_rw, alu_en, imm, alu_mode, rb_sel,alu_out, PC_inc, instruction, addr);
	end

endmodule
