`timescale 1ns/1ps
`include "bmu.v"

module second_bmu_tb;
    // Testbench signals
    reg [1:0] bit_pair_1;
    reg clk;
    reg rst;
    reg refresh;
    reg [1:0] branch_metric_0;
    reg [1:0] branch_metric_1;
    reg valid_in;
    wire [2:0] branch_metric_00;
    wire [2:0] branch_metric_01;
    wire [2:0] branch_metric_10;
    wire [2:0] branch_metric_11;
    wire valid_out;

    // Instantiate second_bmu module
    second_bmu dut (
        .bit_pair_1(bit_pair_1),
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
        .branch_metric_0(branch_metric_0),
        .branch_metric_1(branch_metric_1),
        .valid_in(valid_in),
        .branch_metric_00(branch_metric_00),
        .branch_metric_01(branch_metric_01),
        .branch_metric_10(branch_metric_10),
        .branch_metric_11(branch_metric_11),
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
            bit_pair_1 = 2'b00;
            branch_metric_0 = 2'd0;
            branch_metric_1 = 2'd0;
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [1:0] bit_pair;
        input [1:0] bm_0;
        input [1:0] bm_1;
        input valid;
        input refresh_val;
        begin
            bit_pair_1 = bit_pair;
            branch_metric_0 = bm_0;
            branch_metric_1 = bm_1;
            valid_in = valid;
            refresh = refresh_val;
            @(posedge clk);
            #1;
            
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("second_bmu_tb.vcd");
        $dumpvars(0, second_bmu_tb);

        $display("Starting Second BMU Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: Basic test with input 00, no refresh
        test_case(4'd1, 2'b00, 2'd0, 2'd0, 1'b1, 1'b0);
        #10;

        // Test Case 2: Test with input 01, with refresh
        test_case(4'd2, 2'b01, 2'd1, 2'd1, 1'b1, 1'b1);
        #10;

        // Test Case 3: Test with input 10, toggle refresh
        test_case(4'd3, 2'b10, 2'd2, 2'd0, 1'b1, 1'b0);
        #5 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 4: Test with input 11, with refresh
        test_case(4'd4, 2'b11, 2'd1, 2'd2, 1'b1, 1'b1);
        #10;

        // Test Case 5: Test maximum input metrics
        test_case(4'd5, 2'b00, 2'd3, 2'd3, 1'b1, 1'b0);
        #20;

        // Test Case 6: Test valid signal behavior
        test_case(4'd6, 2'b01, 2'd1, 2'd1, 1'b0, 1'b0);
        #10;
        test_case(4'd7, 2'b10, 2'd2, 2'd2, 1'b1, 1'b0);
        #10;

        // Test Case 7: Test refresh during valid output
        test_case(4'd8, 2'b11, 2'd1, 2'd1, 1'b1, 1'b0);
        #10 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 8: Test rapid refresh toggles
        test_case(4'd9, 2'b00, 2'd2, 2'd2, 1'b1, 1'b0);
        #2 refresh = 1;
        #3 refresh = 0;
        #2 refresh = 1;
        #3 refresh = 0;
        #10;

        // Test Case 9: Test reset and refresh interaction
        test_case(4'd10, 2'b01, 2'd1, 2'd2, 1'b1, 1'b1);
        #5 rst = 1;
        refresh = 1;
        #10 rst = 0;
        #5 refresh = 0;
        #10;

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b refresh=%b valid_in=%b bit_pair=%b in_metrics=%d,%d out_metrics=%d,%d,%d,%d valid_out=%b",
            $time, rst, refresh, valid_in, bit_pair_1, branch_metric_0, branch_metric_1,
            branch_metric_00, branch_metric_01, branch_metric_10, branch_metric_11, valid_out);
    end

endmodule 