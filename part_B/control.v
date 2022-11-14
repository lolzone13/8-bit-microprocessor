module control(
    input clk,
    input wire [7:0] instruction,
    output reg alu_enable, mem_enable, mem_rw, reg_enable,reg_rw,direct_imm,
    output reg [2:0] alu_mode,  
    output reg [1:0] rs_sel,rd_sel
);
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

    reg [3:0] opcode;
    initial begin
            opcode = instruction[7:4];
            alu_enable =1'b0;
            mem_enable =1'b0;
            reg_enable = 1'b0;
            mem_rw=1'b0;
            reg_rw=1'b0;
            direct_imm=1'b0;

    end
    always@(*)
    begin
        case(opcode)
            `OP_SUM : begin
                alu_enable = 1'b1;
                reg_enable = 1'b1;
                reg_rw= 1'b1;
                direct_imm= 1'b1;
                rd_sel = instruction[3:2];
                rs_sel = instruction[1:0];
            end
            `OP_SMI : begin
                alu_enable = 1'b1;
                reg_enable = 1'b1;
                reg_rw= 1'b1;
                direct_imm= 1'b0;
                rd_sel = instruction[3:2];
                rs_sel = instruction[1:0];
            end
    endcase
    end

endmodule