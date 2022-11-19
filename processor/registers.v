module registers(
    // input wire [1:0] register_select,
    // input clk,
    // input mem_enable,
    // input read_write,
    // input wire [7:0] data_bus_in,
    // output wire [7:0] data_bus_out\

    // imm store daala hain bhai

    temp, rb_out, temp_rw, temp_e, rb_sel, rb_e, rb_rw, clk, data_in, imm, immLD, immST, four_bit_bus,alu_output_st,mov_inst, read_write_memory
);
input clk;
input read_write_memory;
input temp_rw, temp_e, rb_e, rb_rw,mov_inst,alu_output_st;
output [7:0] temp, rb_out;
input [1:0]rb_sel;
input [7:0] data_in; 
reg [7:0] dout;
reg [7:0] din;
reg [7:0] register_array [3:0]; // 4 registers
reg [7:0] temp_reg, temp_rb_out;
wire [1:0] mov_temp;
input [3:0]four_bit_bus;
input immLD;
input immST;
input imm;

external_ram external_ram(sign_extended_imm_value_LDST, clk, din, dout, we);


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
                
                $display("READ   - Address=%d, temp: %d, rb: %d", rb_sel, temp_reg, temp_rb_out);

            end
            1'b0: begin 
                if(alu_output_st) register_array[rb_sel] = data_in;     // write
                if(immLD) register_array[0] = dout;
                if (immST) din = register_array[0];
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