module memory_tb;

    wire clk,
    wire register_enable,
    wire read_write,
    wire [1:0] register_select,
    wire [7:0] data_bus_in,
    wire [7:0] data_bus_out


  memory memory (address_bus, clk, mem_enable, read_write, data_bus_in, data_bus_out);

  assign data_bus_in = temp_reg;

  initial begin
    mem_enable=0;
    clk=0;
    read_write=1;
    address_bus=4'b0000;
    temp_reg=8'b0000_0000;
    
    forever #20 clk=~clk;
  end

  initial begin
    #5 address_bus = 4'b0101; mem_enable = 1; read_write = 1;
    #25 address_bus = 4'b0101; read_write = 0; temp_reg = 8'b0000_1111;
    #50 address_bus = 4'b0101; read_write = 1;
  end

  initial begin
    $monitor("time = %2d, address = %d, databus_in = %d, databus_out = %d, read/write = %b", $time, address_bus, data_bus_in, data_bus_out, read_write);
  end

endmodule