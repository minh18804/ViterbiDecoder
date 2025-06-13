`timescale 1ns/1ps
`include "bmu.v"

module bmu_full_tb();
    // Testbench signals
    reg [1:0] bit_pair_0;
    reg [1:0] bit_pair_1;
    reg [1:0] bit_pair_2;
    reg clk;
    reg rst;
    reg refresh;
    
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
    wire [3:0] branch_metric_00_0;
    wire [3:0] branch_metric_00_1;
    wire [3:0] branch_metric_01_0;
    wire [3:0] branch_metric_01_1;
    wire [3:0] branch_metric_10_0;
    wire [3:0] branch_metric_10_1;
    wire [3:0] branch_metric_11_0;
    wire [3:0] branch_metric_11_1;
    wire valid_3;  // Valid signal from third bmu

    // Instantiate all three modules
    first_bmu first_stage (
        .bit_pair_0(bit_pair_0),
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
        .branch_metric_0(branch_metric_0),
        .branch_metric_1(branch_metric_1),
        .valid_out(valid_1)
    );

    second_bmu second_stage (
        .bit_pair_1(bit_pair_1),
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
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
        .refresh(refresh),
        .branch_metric_00(branch_metric_00),
        .branch_metric_01(branch_metric_01),
        .branch_metric_10(branch_metric_10),
        .branch_metric_11(branch_metric_11),
        .valid_in(valid_2),
        .branch_metric_00_0(branch_metric_00_0),
        .branch_metric_00_1(branch_metric_00_1),
        .branch_metric_01_0(branch_metric_01_0),
        .branch_metric_01_1(branch_metric_01_1),
        .branch_metric_10_0(branch_metric_10_0),
        .branch_metric_10_1(branch_metric_10_1),
        .branch_metric_11_0(branch_metric_11_0),
        .branch_metric_11_1(branch_metric_11_1),
        .valid_out(valid_3)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test tasks
    task reset_system;
        begin
            rst = 1;
            refresh = 0;
            bit_pair_0 = 2'b00;
            bit_pair_1 = 2'b00;
            bit_pair_2 = 2'b00;
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [1:0] bp0;
        input [1:0] bp1;
        input [1:0] bp2;
        begin
            bit_pair_0 = bp0;
            bit_pair_1 = bp1;
            bit_pair_2 = bp2;
            #30;  // Wait for all stages to process
            
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize waveform dump
        $dumpfile("bmu_full_tb.vcd");
        $dumpvars(0, bmu_full_tb);

        $display("Starting BMU Full Chain Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: All zeros
        test_case(4'd1, 2'b00, 2'b00, 2'b00);

        // Test Case 2: All ones
        test_case(4'd2, 2'b11, 2'b11, 2'b11);

        // Test Case 3: Alternating pattern
        test_case(4'd3, 2'b01, 2'b10, 2'b01);

        // Test Case 4: Test refresh signal
        test_case(4'd4, 2'b10, 2'b01, 2'b11);
        refresh = 1;
        #10;
        refresh = 0;
        #20;

        // Test Case 5: Test after refresh
        test_case(4'd5, 2'b11, 2'b00, 2'b10);

        // Test Case 6: Test reset during operation
        test_case(4'd6, 2'b01, 2'b10, 2'b11);
        rst = 1;
        #20;
        rst = 0;
        #20;

        // Test Case 7: Test after reset
        test_case(4'd7, 2'b10, 2'b10, 2'b10);

        // Test Case 8: Test refresh and reset interaction
        test_case(4'd8, 2'b11, 2'b11, 2'b00);
        refresh = 1;
        rst = 1;
        #10;
        refresh = 0;
        #10;
        rst = 0;
        #20;

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b refresh=%b bit_pairs=%b_%b_%b valid=%b_%b_%b",
            $time, rst, refresh, bit_pair_0, bit_pair_1, bit_pair_2,
            valid_1, valid_2, valid_3);
    end
endmodule 