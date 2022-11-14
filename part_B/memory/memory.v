module memory(
    input wire [3:0] address_bus,
    input clk,
    input mem_enable,
    input read_write,
    input wire [7:0] data_bus_in,
    output wire [7:0] data_bus_out
);



reg [7:0] memory_store [15:0];
reg [7:0] temp_reg;

always @(posedge clk) begin
    if (mem_enable) begin
        case (read_write)
            1'b1: begin 
                temp_reg = memory_store[address_bus];     // read;

                $display("READ   - Address=%d, Memory_contents: %d", address_bus, memory_store[address_bus]);
            end
            1'b0: begin 
                memory_store[address_bus] = data_bus_in;     // write
                $display("WRITE   - Address=%d, Memory_contents: %d", address_bus, memory_store[address_bus]);
            end
            default: ;
        endcase
    end
end


assign data_bus_out = (read_write) ? temp_reg : 8'b0000_0000;



endmodule