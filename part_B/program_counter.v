

module program_counter
(
    input clk,
    input pc_enable,
    input rst,
    output reg [3:0] memory_address
);


    parameter MEMORY_ADDRESS_WIDTH = 4;

    always @ (posedge clk)
        begin
            if (pc_enable)
                memory_address <= memory_address + 1;
            if (rst) 
                memory_address <= 0;
            
        end
    
endmodule




