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

    reg clk;
    reg pc_clk;
    reg [7:0] immediate_input;
    reg [1:0] register_select;

    reg [1:0] temp_reg;

    reg mem_enable;
    reg alu_enable;
    reg [7:0] data_bus_in;
    wire [7:0] data_bus_out;
    wire carry_flag;
    wire zero_flag;
    wire [7:0] sum;
    reg [3:0] opcode;
    reg [2:0] mode;
    reg [3:0] address_bus;
    reg [7:0] instruction;
    reg read_write;

    // sum rd rs
    registers registers (register_select, clk, mem_enable, read_write, data_bus_in, data_bus_out);

    alu alu (alu_enable ,clk, mode, immediate_input, data_bus_out, sum, zero_flag, carry_flag);



    initial begin
        clk=0;
        pc_clk=0;
        instruction = 8'b1100_0010;

        //#300 instruction

        mem_enable=0;
                
                //address_bus=4'b0000;
        alu_enable=0;
                //register_select=instruction[3:2];


        forever #20 clk<=~clk;
        //forever #200 pc_clk <= ~pc_clk;
    end

    initial begin
    //always @(posedge pc_clk ) begin
        

        opcode = instruction[7:4];
        case(opcode)
            `OP_SMI: begin      
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];      
                $display("Addition");
                #10 mem_enable=1; read_write=0; alu_enable=0; register_select=2'b00; data_bus_in=8'b0010_1001; mode=3'b000; // writes the instruction, remove later
                #40 read_write=1; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                //$display("Entered Adder Block");
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;

                $display("Execution of addition complete!");

            end
            `OP_SBI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];      
                $display("Subtraction");
                #10 mem_enable=1; read_write=0; register_select=2'b00; alu_enable=0; data_bus_in=8'b1111_1110; mode=3'b001;
                #40 read_write=1; register_select=2'b00; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;
            end
            `OP_ANI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];      

                #10 mem_enable=1; read_write=0; register_select=2'b00; alu_enable=0; data_bus_in=8'b0010_1001; mode=3'b100;
                #40 read_write=1; register_select=2'b00; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;
            end

            `OP_ORI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];     

                #10 mem_enable=1; read_write=0; register_select=2'b00; alu_enable=0; data_bus_in=8'b0010_1001; mode=3'b101;
                #40 read_write=1; register_select=2'b00; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;
            end

            `OP_XRI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];      

                #10 mem_enable=1; read_write=0; register_select=2'b00; alu_enable=0; data_bus_in=8'b0010_1001; mode=3'b110;
                #40 read_write=1; register_select=2'b00; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;
            end
            `OP_CMI: begin
                immediate_input[1:0] = instruction[1:0];
                immediate_input[7:2] = (immediate_input[1]) ? 6'b111111 : 6'b000000;    
                temp_reg=instruction[3:2];      


                #10 mem_enable=1; read_write=0; register_select=2'b00; alu_enable=0; data_bus_in=8'b0010_1001; mode=3'b111;
                #40 read_write=1; register_select=2'b00; alu_enable=1;
                #40 mem_enable=0;
                #40 alu_enable=0;
                #40 mem_enable=1; read_write=0; register_select=temp_reg; data_bus_in=sum;
                #40 read_write=1; register_select=temp_reg;
                #40 mem_enable=0;
            end
        endcase


        #2000 $finish;

    end

    //always @(posedge clk) begin
        // case(opcode)
        //     `OP_SUM: begin
        //         assign enable=1'b1;
                
        //     end
        // endcase
    // end
    initial begin

        $monitor("time = %2d, instruction = %b, A = %d, data_bus_out = %d, SUM = %b, zero_flag = %b, carry_flag = %b", $time, instruction, immediate_input, data_bus_out, sum, zero_flag, carry_flag);
    end




endmodule