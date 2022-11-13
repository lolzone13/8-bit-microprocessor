module main(
    input clk,
    input wire [7:0] instruction,
    output wire [7:0] out

);
  `define MAIN_LD 4'b0000
  `define MAIN_ST 4'b0001
  `define MAIN_MR 4'b0011
  `define MAIN_SUM 4'b0100
  `define MAIN_SMI 4'b1100
    // smi

    reg enable;
    reg clk;

    reg carry_flag;
    reg zero_flag;

    reg mode;
    // sum rd rs
    memory memory (clk, enable, register_select, data_bus_in, data_bus_out);

    alu alu (enable ,clk, mode, in_a, data_bus_out, sum, zero_flag, carry_flag);

    always @(posedge clk) begin
        case(instruction)
            `MAIN_SUM: begin
                
            end
        endcase
    end




endmodule