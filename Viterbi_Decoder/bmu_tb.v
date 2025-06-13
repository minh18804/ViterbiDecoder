`timescale 1ns/1ps
`include "bmu.v"

module bmu_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg refresh;
    reg [1:0] bit_pair_input;
    reg [2:0] branch_metric_00;
    reg [2:0] branch_metric_01;
    reg [2:0] branch_metric_10;
    reg [2:0] branch_metric_11;
    reg valid_in;
    wire [3:0] branch_metric_00_0;
    wire [3:0] branch_metric_00_1;
    wire [3:0] branch_metric_01_0;
    wire [3:0] branch_metric_01_1;
    wire [3:0] branch_metric_10_0;
    wire [3:0] branch_metric_10_1;
    wire [3:0] branch_metric_11_0;
    wire [3:0] branch_metric_11_1;
    wire valid_out;

    // Instantiate bmu module
    bmu dut (
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
        .bit_pair_input(bit_pair_input),
        .branch_metric_00(branch_metric_00),
        .branch_metric_01(branch_metric_01),
        .branch_metric_10(branch_metric_10),
        .branch_metric_11(branch_metric_11),
        .valid_in(valid_in),
        .branch_metric_00_0(branch_metric_00_0),
        .branch_metric_00_1(branch_metric_00_1),
        .branch_metric_01_0(branch_metric_01_0),
        .branch_metric_01_1(branch_metric_01_1),
        .branch_metric_10_0(branch_metric_10_0),
        .branch_metric_10_1(branch_metric_10_1),
        .branch_metric_11_0(branch_metric_11_0),
        .branch_metric_11_1(branch_metric_11_1),
        .valid_out(valid_out)
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
            valid_in = 0;
            bit_pair_input = 2'b00;
            branch_metric_00 = 3'd0;
            branch_metric_01 = 3'd0;
            branch_metric_10 = 3'd0;
            branch_metric_11 = 3'd0;
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [1:0] bit_pair;
        input [2:0] bm_00;
        input [2:0] bm_01;
        input [2:0] bm_10;
        input [2:0] bm_11;
        input valid;
        input refresh_val;
        begin
            bit_pair_input = bit_pair;
            branch_metric_00 = bm_00;
            branch_metric_01 = bm_01;
            branch_metric_10 = bm_10;
            branch_metric_11 = bm_11;
            valid_in = valid;
            refresh = refresh_val;
            @(posedge clk);
            #1;
            
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("bmu_tb.vcd");
        $dumpvars(0, bmu_tb);

        $display("Starting BMU Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: Basic test with input 00, no refresh
        test_case(4'd1, 2'b00, 3'd0, 3'd0, 3'd0, 3'd0, 1'b1, 1'b0);
        #10;

        // Test Case 2: Test with input 01, with refresh
        test_case(4'd2, 2'b01, 3'd1, 3'd1, 3'd1, 3'd1, 1'b1, 1'b1);
        #10;

        // Test Case 3: Test with input 10, toggle refresh
        test_case(4'd3, 2'b10, 3'd2, 3'd0, 3'd2, 3'd0, 1'b1, 1'b0);
        #5 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 4: Test with input 11, with refresh
        test_case(4'd4, 2'b11, 3'd1, 3'd2, 3'd3, 3'd4, 1'b1, 1'b1);
        #10;

        // Test Case 5: Test maximum input metrics
        test_case(4'd5, 2'b00, 3'd7, 3'd7, 3'd7, 3'd7, 1'b1, 1'b0);
        #20;

        // Test Case 6: Test valid signal behavior
        test_case(4'd6, 2'b01, 3'd1, 3'd1, 3'd1, 3'd1, 1'b0, 1'b0);
        #10;
        test_case(4'd7, 2'b10, 3'd2, 3'd2, 3'd2, 3'd2, 1'b1, 1'b0);
        #10;

        // Test Case 7: Test refresh during valid output
        test_case(4'd8, 2'b11, 3'd3, 3'd3, 3'd3, 3'd3, 1'b1, 1'b0);
        #10 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 8: Test rapid refresh toggles
        test_case(4'd9, 2'b00, 3'd4, 3'd4, 3'd4, 3'd4, 1'b1, 1'b0);
        #2 refresh = 1;
        #3 refresh = 0;
        #2 refresh = 1;
        #3 refresh = 0;
        #10;

        // Test Case 9: Test reset and refresh interaction
        test_case(4'd10, 2'b01, 3'd5, 3'd5, 3'd5, 3'd5, 1'b1, 1'b1);
        #5 rst = 1;
        refresh = 1;
        #10 rst = 0;
        #5 refresh = 0;
        #10;

        // Test Case 10: Test different metric combinations
        test_case(4'd11, 2'b10, 3'd0, 3'd7, 3'd3, 3'd4, 1'b1, 1'b0);
        #10;

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b refresh=%b valid_in=%b bit_pair=%b metrics_in=%d,%d,%d,%d valid_out=%b",
            $time, rst, refresh, valid_in, bit_pair_input,
            branch_metric_00, branch_metric_01, branch_metric_10, branch_metric_11,
            valid_out);
    end

endmodule 