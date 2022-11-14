module registers(
    input wire [1:0] register_select,
    input clk,
    input mem_enable,
    input read_write,
    input wire [7:0] data_bus_in,
    output wire [7:0] data_bus_out
);



reg [7:0] register_array [1:0];
reg [7:0] temp_reg;

always @(posedge clk) begin
    if (mem_enable) begin
        case (read_write)
            1'b1: begin 
                temp_reg = register_array[register_select];     // read;

                $display("READ   - Address=%d, Register_contents: %d", register_select, register_array[register_select]);
            end
            1'b0: begin 
                register_array[register_select] = data_bus_in;     // write
                $display("WRITE   - Address=%d, Register_contents: %d", register_select, register_array[register_select]);
            end
            default: ;
        endcase
    end
end


assign data_bus_out = (read_write) ? temp_reg : 8'b0000_0000;



endmodule