module control;
    // input clk,
    // input wire [7:0] instruction,
    // output reg alu_enable, mem_enable, mem_rw, reg_enable,reg_rw,direct_imm,
    // output reg [2:0] alu_mode,  
    // output reg [1:0] rs_sel,rd_sel
// );
`define OP_LD  4'b0000
`define OP_ST  4'b0001
`define OP_MR  4'b0011
`define OP_MI  4'b0010
`define OP_SUM 4'b0100
`define OP_SMI 4'b1100
`define OP_SB  4'b0101
`define OP_SBI 4'b1101
`define OP_ANR 4'b0110
`define OP_ANI 4'b1110
`define OP_ORR 4'b1000
`define OP_ORI 4'b1001
`define OP_XRR 4'b1010
`define OP_XRI 4'b1011
`define OP_CM  4'b0111
`define OP_CMI 4'b1111

    // opcode decoding
    reg [3:0] opcode;
    reg [7:0] instruction;
    reg clk;
    reg [7:0] immediate_input;
    main main(clk, opcode, immediate_input);

    


    initial begin
        instruction = 8'b1100_0110;
        opcode = instruction[7:4];
        
        forever #20 clk=~clk;
    end

    initial begin
        #50
        case (opcode)
            `OP_LD : begin
                immediate_input[3:0] = instruction[3:0];
                immediate_input[7:4] = (immediate_input[3]) ? 4'b1111 : 4'b0000;
            end
             `OP_SMI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;
             end
        endcase

        $display("Input - %d", immediate_input);
    end
    


endmodule