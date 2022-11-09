module program_counter_tb;


    reg clk, rst, pc_enable;

    wire [3:0] count;


    program_counter pc(clk, pc_enable, rst, count);


    initial begin
        clk=0;
        forever #20 clk = ~clk;

    end

    initial begin
        rst = 1;
        pc_enable = 1;
        #50

        rst = 0;
        pc_enable = 1;


    end


    initial begin 
        $monitor($time, "clk=%b, rst=%b, pc_enable=%b, count=%d", clk, rst, pc_enable, count);
    end


endmodule
