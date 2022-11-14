module main;

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
    // smi
    // read two things from memory, add them and store it in memory
    reg mem_enable;
    reg alu_enable;
    reg clk;
    reg [7:0] data_bus_in;
    wire [7:0] data_bus_out;
    wire carry_flag;
    wire zero_flag;
    wire [7:0] sum;
    reg [7:0] immediate_input;
    reg [2:0] mode;
    reg [3:0] address_bus;
    reg read_write;
    // sum rd rs
    memory memory (address_bus, clk, mem_enable, read_write, data_bus_in, data_bus_out);

    alu alu (alu_enable ,clk, mode, immediate_input, data_bus_out, sum, zero_flag, carry_flag);

    wire [3:0] opcode;

    initial begin
        // opcode = instruction[7:4];
        mem_enable=0;
        clk=0;
        read_write=1; // 1 for read
        address_bus=4'b0000;
        alu_enable=0;
        mode=3'b000;
        data_bus_in=8'b0000_0000;
        immediate_input=8'b0000_0101;
        forever #20 clk=~clk;
    end

    initial begin
        #10 mem_enable=1; read_write=0; address_bus=4'b0101; alu_enable=0; data_bus_in=8'b0000_1001;
        #40 read_write=1; address_bus=4'b0101; alu_enable=1;
        #40 mem_enable=0;
        #40 alu_enable=0;
        #40 mem_enable=1; read_write=0; address_bus=4'b0001; data_bus_in=sum;
        #40 read_write=1; address_bus=4'b0001;
        #40 mem_enable=0;

    end

    //always @(posedge clk) begin
        // case(opcode)
        //     `OP_SUM: begin
        //         assign enable=1'b1;
                
        //     end
        // endcase
    // end
    initial begin

        $monitor("time = %2d, A = %d, data_bus_out = %d, SUM = %b, zero_flag = %b, carry_flag = %b", $time, immediate_input, data_bus_out, sum, zero_flag, carry_flag);
    end




endmodule