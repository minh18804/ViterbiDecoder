module input_buffer(
    input wire clk,
    input wire rst,
    input wire [15:0] data_in,
    output reg [1:0] bit_pair_0,
    output reg [1:0] bit_pair_1,
    output reg [1:0] bit_pair_2,
    output reg [1:0] bit_pair_3,
    output reg [1:0] bit_pair_4,
    output reg [1:0] bit_pair_5,
    output reg [1:0] bit_pair_6,
    output reg [1:0] bit_pair_7
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
        begin
            bit_pair_0 <= 2'b00;
            bit_pair_1 <= 2'b00;
            bit_pair_2 <= 2'b00;
            bit_pair_3 <= 2'b00;
            bit_pair_4 <= 2'b00;
            bit_pair_5 <= 2'b00;
            bit_pair_6 <= 2'b00;
            bit_pair_7 <= 2'b00;
        end 
        else
        begin
            bit_pair_0 <= data_in[15:14];
            bit_pair_1 <= data_in[13:12];
            bit_pair_2 <= data_in[11:10];
            bit_pair_3 <= data_in[9:8];
            bit_pair_4 <= data_in[7:6];
            bit_pair_5 <= data_in[5:4];
            bit_pair_6 <= data_in[3:2];
            bit_pair_7 <= data_in[1:0];
        end
    end
endmodule



// module input_buffer_tb;
//     reg clk;
//     reg rst;
//     reg [15:0] input;
//     wire [2:0] bit_pair_0;
//     wire [2:0] bit_pair_1;
//     wire [2:0] bit_pair_2;
//     wire [2:0] bit_pair_3;
//     wire [2:0] bit_pair_4;
//     wire [2:0] bit_pair_5;
//     wire [2:0] bit_pair_6;
//     wire [2:0] bit_pair_7;

//     input_buffer uut(
//         .clk(clk),
//         .rst(rst),
//         .input(input),
//     );
// endmodule