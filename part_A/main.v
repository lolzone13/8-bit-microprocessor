module binomial_transform (
    input_number,
    floating_point
);
  input [16*10 - 1:0] input_number;
    output [15:0] floating_point;
    reg [15:0] temp [9:0];
  reg [15:0] input_store [9:0];
    integer i;
    integer j;
    initial begin
        for(i = 9; i>0; i--) begin
            for(j = 0; j<i; j++ ) begin
                assign input_number[j] = input_number[j+1] - input_number[j];
            end
        end

    end

    assign floating_point = input_number[0];



    
endmodule