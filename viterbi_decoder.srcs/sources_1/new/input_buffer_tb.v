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
            bit_pair_0 <= data_in[1:0];
            bit_pair_1 <= data_in[3:2];
            bit_pair_2 <= data_in[5:4];
            bit_pair_3 <= data_in[7:6];
            bit_pair_4 <= data_in[9:8];
            bit_pair_5 <= data_in[11:10];
            bit_pair_6 <= data_in[13:12];
            bit_pair_7 <= data_in[15:14];
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

`timescale 1ns / 1ps

module input_buffer_tb;
    // Inputs
    reg clk;
    reg rst;
    reg [15:0] data_in;
    
    // Outputs
    wire [1:0] bit_pair_0;
    wire [1:0] bit_pair_1;
    wire [1:0] bit_pair_2;
    wire [1:0] bit_pair_3;
    wire [1:0] bit_pair_4;
    wire [1:0] bit_pair_5;
    wire [1:0] bit_pair_6;
    wire [1:0] bit_pair_7;

    // Instantiate the Unit Under Test (UUT)
    input_buffer uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .bit_pair_0(bit_pair_0),
        .bit_pair_1(bit_pair_1),
        .bit_pair_2(bit_pair_2),
        .bit_pair_3(bit_pair_3),
        .bit_pair_4(bit_pair_4),
        .bit_pair_5(bit_pair_5),
        .bit_pair_6(bit_pair_6),
        .bit_pair_7(bit_pair_7)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        data_in = 16'h0000;
        
        // Wait for 100 ns
        #100;
        
        // Release reset
        rst = 0;
        
        // Test case 1: All bits set to 1
        data_in = 16'hFFFF;
        #10;
        
        // Test case 2: Alternating bits
        data_in = 16'hAAAA;
        #10;
        
        // Test case 3: Random pattern
        data_in = 16'h1234;
        #10;
        
        // Test case 4: Another pattern
        data_in = 16'h5678;
        #10;
        
        // End simulation
        #100 $finish;
    end
    
    // Monitoring
    initial begin
        $monitor("Time=%0t rst=%b data_in=%h bit_pairs=%b %b %b %b %b %b %b %b",
                 $time, rst, data_in, 
                 bit_pair_0, bit_pair_1, bit_pair_2, bit_pair_3,
                 bit_pair_4, bit_pair_5, bit_pair_6, bit_pair_7);
    end

endmodule
