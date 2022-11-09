module memory(
    input wire [3:0] address_bus,
    input clk,
    input mem_enable,
    input read_write,
    inout wire [7:0] data_bus
);



reg [7:0] memory_store [0:15];
reg [7:0] temp_reg;

always @(posedge clk) begin
    if (mem_enable) begin
        case (read_write)
            1'b1: temp_reg = memory_store[address_bus];     // read;
            1'b0: memory_store[address_bus] = data_bus;     // write
            default: ;
        endcase
    end
end


assign data_bus = (read_write) ? temp_reg : 8'b0000_0000;



endmodule