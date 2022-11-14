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
  `define ALU_ADD 3'b000
  `define ALU_SUB 3'b001
  `define ALU_INC 3'b010
  `define ALU_DEC 3'b011
  `define ALU_AND 3'b100
  `define ALU_OR  3'b101
  `define ALU_XOR 3'b110
  `define ALU_CMP 3'b111

  reg [N-1:0] buf_out;
  reg [N-1:0] temp_reg;

  initial begin

    flag_carry = 0;
    flag_zero = 0;
    temp_reg = 0;


  end

  always @(posedge clk) begin
    if (enable) begin
      case (mode)
        `ALU_ADD: {flag_carry, buf_out} = in_a + in_b;
        `ALU_CMP: {flag_carry, temp_reg} = in_a - in_b;
        `ALU_SUB: {flag_carry, buf_out} = in_a - in_b;
        `ALU_INC: {flag_carry, buf_out} = in_a + 1;
        `ALU_DEC: {flag_carry, buf_out} = in_a - 1;
        `ALU_AND: buf_out = in_a & in_b;
        `ALU_OR:  buf_out = in_a | in_b;
        `ALU_XOR: buf_out = in_a ^ in_b;
        default:  buf_out = 'hxx;
      endcase
      $display("Operation Complete!");
      flag_zero = (buf_out == 0 || temp_reg == 0) ? 1 : 0;

    end
  end

  assign out = buf_out;

endmodule