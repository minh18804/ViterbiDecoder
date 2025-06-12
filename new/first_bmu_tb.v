`timescale 1ns/1ps
`include "bmu.v"

module first_bmu_tb;
    // Testbench signals
    reg [1:0] bit_pair_0;
    reg clk;
    reg rst;
    reg refresh;
    wire [1:0] branch_metric_0;
    wire [1:0] branch_metric_1;
    wire valid_out;

    // Instantiate first_bmu module
    first_bmu dut (
        .bit_pair_0(bit_pair_0),
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
        .branch_metric_0(branch_metric_0),
        .branch_metric_1(branch_metric_1),
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
            bit_pair_0 = 2'b00;
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [1:0] bit_pair;
        input refresh_val;
        begin
            bit_pair_0 = bit_pair;
            refresh = refresh_val;
            @(posedge clk);
            #1;
            
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("first_bmu_tb.vcd");
        $dumpvars(0, first_bmu_tb);

        $display("Starting First BMU Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: Input 00, no refresh
        test_case(4'd1, 2'b00, 1'b0);
        #10;

        // Test Case 2: Input 01, with refresh
        test_case(4'd2, 2'b01, 1'b1);
        #10;

        // Test Case 3: Input 10, toggle refresh
        test_case(4'd3, 2'b10, 1'b0);
        #5 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 4: Input 11, with refresh
        test_case(4'd4, 2'b11, 1'b1);
        #10;

        // Test Case 5: Test valid signal generation
        test_case(4'd5, 2'b00, 1'b0);
        #20; // Wait for valid signal
        
        // Test Case 6: Test refresh during valid output
        test_case(4'd6, 2'b01, 1'b0);
        #10 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 7: Test rapid refresh toggles
        test_case(4'd7, 2'b10, 1'b0);
        #2 refresh = 1;
        #3 refresh = 0;
        #2 refresh = 1;
        #3 refresh = 0;
        #10;

        // Test Case 8: Test reset and refresh interaction
        test_case(4'd8, 2'b11, 1'b1);
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
        $monitor("Time=%0t rst=%b refresh=%b bit_pair=%b metrics=%d,%d valid=%b",
            $time, rst, refresh, bit_pair_0, branch_metric_0, branch_metric_1, valid_out);
    end

endmodule 