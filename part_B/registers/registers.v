module registers (
    input clk,
    input register_enable,
    input read_write,
    input [1:0] register_select,
    input wire [7:0] data_bus_in,
    output wire [7:0] data_bus_out

);

    // do sum rd imm

    reg [7:0] register_array [1:0];
    // alu alu (en, clk, mode, in_a, in_b, sum, fz, fc);
    
    reg [7:0] temp_reg;
    always @(posedge clk) begin
        if (register_enable) begin
            if (read_write) begin
                temp_reg =  register_array[register_select];
            end
            else begin
                register_array[register_select] = data_bus_in;
                
            end
        end

    end


    assign data_bus_out = (read_write) ? temp_reg : 8'b0000_0000;


endmodule