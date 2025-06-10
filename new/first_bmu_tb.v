`timescale 1ns/1ps
`include "first_bmu.v"

module bmu_full_tb();
    // Testbench signals
    reg [1:0] bit_pair_0;
    reg [1:0] bit_pair_1;
    reg [1:0] bit_pair_2;
    reg clk;
    reg rst;
    
    // Wires to connect first_bmu to second_bmu
    wire [1:0] branch_metric_0;
    wire [1:0] branch_metric_1;
    wire valid_1;  // Valid signal from first_bmu
    
    // Wires to connect second_bmu to third bmu
    wire [2:0] branch_metric_00;
    wire [2:0] branch_metric_01;
    wire [2:0] branch_metric_10;
    wire [2:0] branch_metric_11;
    wire valid_2;  // Valid signal from second_bmu

    // Final outputs from third bmu
    wire [3:0] branch_metric_000;
    wire [3:0] branch_metric_001;
    wire [3:0] branch_metric_010;
    wire [3:0] branch_metric_011;
    wire [3:0] branch_metric_100;
    wire [3:0] branch_metric_101;
    wire [3:0] branch_metric_110;
    wire [3:0] branch_metric_111;
    wire valid_3;  // Valid signal from third bmu

    // Instantiate all three modules
    first_bmu first_stage (
        .bit_pair_0(bit_pair_0),
        .clk(clk),
        .rst(rst),
        .branch_metric_0(branch_metric_0),
        .branch_metric_1(branch_metric_1),
        .valid_out(valid_1)
    );

    second_bmu second_stage (
        .bit_pair_1(bit_pair_1),
        .clk(clk),
        .rst(rst),
        .branch_metric_0(branch_metric_0),
        .branch_metric_1(branch_metric_1),
        .valid_in(valid_1),
        .branch_metric_00(branch_metric_00),
        .branch_metric_01(branch_metric_01),
        .branch_metric_10(branch_metric_10),
        .branch_metric_11(branch_metric_11),
        .valid_out(valid_2)
    );

    bmu third_stage (
        .bit_pair_input(bit_pair_2),
        .clk(clk),
        .rst(rst),
        .branch_metric_00(branch_metric_00),
        .branch_metric_01(branch_metric_01),
        .branch_metric_10(branch_metric_10),
        .branch_metric_11(branch_metric_11),
        .valid_in(valid_2),
        .branch_metric_000(branch_metric_000),
        .branch_metric_001(branch_metric_001),
        .branch_metric_010(branch_metric_010),
        .branch_metric_011(branch_metric_011),
        .branch_metric_100(branch_metric_100),
        .branch_metric_101(branch_metric_101),
        .branch_metric_110(branch_metric_110),
        .branch_metric_111(branch_metric_111),
        .valid_out(valid_3)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize waveform dump
        $dumpfile("bmu_full_tb.vcd");
        $dumpvars(0, bmu_full_tb);

        // Initialize inputs
        bit_pair_0 = 2'b00;
        bit_pair_1 = 2'b00;
        bit_pair_2 = 2'b00;
        rst = 1;
        #100;
        
        // Release rst
        rst = 0;
        #10;

        // Test Case 1: All zeros
        bit_pair_0 = 2'b00;  // Will give bm0=0, bm1=2
        bit_pair_1 = 2'b00;
        bit_pair_2 = 2'b00;
        #30;  // Wait for all stages to process

        // Test Case 2: Alternating 0s and 1s
        bit_pair_0 = 2'b01;  // Will give bm0=1, bm1=1
        bit_pair_1 = 2'b10;
        bit_pair_2 = 2'b01;
        #30;  // Wait for all stages to process

        // Test Case 3: All ones
        bit_pair_0 = 2'b11;  // Will give bm0=2, bm1=0
        bit_pair_1 = 2'b11;
        bit_pair_2 = 2'b11;
        #30;  // Wait for all stages to process

        // Test Case 4: Mixed pattern 1
        bit_pair_0 = 2'b10;  // Will give bm0=1, bm1=1
        bit_pair_1 = 2'b01;
        bit_pair_2 = 2'b11;
        #30;  // Wait for all stages to process

        // Test Case 5: Mixed pattern 2
        bit_pair_0 = 2'b01;
        bit_pair_1 = 2'b11;
        bit_pair_2 = 2'b00;
        #30;  // Wait for all stages to process

        // Test rst in middle of operation
        bit_pair_0 = 2'b10;
        bit_pair_1 = 2'b01;
        bit_pair_2 = 2'b11;
        #10;
        rst = 1;
        #20;
        rst = 0;
        #30;  // Wait for all stages to process

        // Test Case 6: After rst
        bit_pair_0 = 2'b11;
        bit_pair_1 = 2'b00;
        bit_pair_2 = 2'b10;
        #30;  // Wait for all stages to process

        // Test Case 7: Final test
        bit_pair_0 = 2'b01;
        bit_pair_1 = 2'b10;
        bit_pair_2 = 2'b11;
        #30;  // Wait for all stages to process

        // End simulation
        #100;
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: bit_pairs=%b %b %b | Valid=%b %b %b | bm0=%h,bm1=%h | bm00=%h,bm01=%h,bm10=%h,bm11=%h | bm000=%h,bm001=%h,bm010=%h,bm011=%h,bm100=%h,bm101=%h,bm110=%h,bm111=%h",
            $time, bit_pair_0, bit_pair_1, bit_pair_2,
            valid_1, valid_2, valid_3,
            branch_metric_0, branch_metric_1,
            branch_metric_00, branch_metric_01, branch_metric_10, branch_metric_11,
            branch_metric_000, branch_metric_001, branch_metric_010, branch_metric_011,
            branch_metric_100, branch_metric_101, branch_metric_110, branch_metric_111);
    end
endmodule 
