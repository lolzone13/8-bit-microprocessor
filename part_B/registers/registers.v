module registers (
    input clk,
    input register_enable,
    input read_write,
    input [1:0] register_select_destination,
    input [1:0] register_select_source,
    input direct_immediate, // 1 - direct  
    input wire [7:0] data_bus_in,
    output wire [7:0] data_bus_out

);
    // do sum rd imm

    reg fz;
    reg fc;
    reg [7:0] temp_op;
    reg [7:0] register_array [1:0];

    reg temp_b;
    //alu alu (en, clk, mode, register_array[register_select_destination], temp_b, temp_op, fz, fc);
    
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


    assign temp_b = (direct_immediate) ? register_array[register_select_source] : data_bus_in;

    assign 


endmodule