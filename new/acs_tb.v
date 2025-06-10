`timescale 1ns/1ps
`include "acs.v"

module acs_tb;
    // Clock and reset signals
    reg clk;
    reg rst;

    // Signals for first_acs module
    reg valid_in_first;
    reg [3:0] bm_000, bm_001, bm_010, bm_011;
    reg [3:0] bm_100, bm_101, bm_110, bm_111;
    
    wire [3:0] new_bm_00_first, new_bm_01_first;
    wire [3:0] new_bm_10_first, new_bm_11_first;
    wire [2:0] path_00_first, path_01_first;
    wire [2:0] path_10_first, path_11_first;
    wire valid_out_first;

    // Signals for acs module
    reg valid_in_acs;
    reg [3:0] bm_00_0, bm_00_1, bm_01_0, bm_01_1;
    reg [3:0] bm_10_0, bm_10_1, bm_11_0, bm_11_1;
    reg [7:0] path_00, path_01, path_10, path_11;
    
    wire [3:0] new_bm_00, new_bm_01, new_bm_10, new_bm_11;
    wire [7:0] new_path_00, new_path_01, new_path_10, new_path_11;
    wire valid_out_acs;

    // Instantiate first_acs module
    first_acs first_acs_inst (
        .clk(clk),
        .rst(rst),
        .branch_metric_00_0(bm_000),
        .branch_metric_00_1(bm_001),
        .branch_metric_01_0(bm_010),
        .branch_metric_01_1(bm_011),
        .branch_metric_10_0(bm_100),
        .branch_metric_10_1(bm_101),
        .branch_metric_11_0(bm_110),
        .branch_metric_11_1(bm_111),
        .valid_in(valid_in_first),
        .new_branch_metric_00(new_bm_00_first),
        .new_branch_metric_01(new_bm_01_first),
        .new_branch_metric_10(new_bm_10_first),
        .new_branch_metric_11(new_bm_11_first),
        .selected_branch_at_00(path_00_first),
        .selected_branch_at_01(path_01_first),
        .selected_branch_at_10(path_10_first),
        .selected_branch_at_11(path_11_first),
        .valid_out(valid_out_first)
    );

    // Instantiate acs module
    acs acs_inst (
        .clk(clk),
        .rst(rst),
        .branch_metric_00_0(bm_00_0),
        .branch_metric_00_1(bm_00_1),
        .branch_metric_01_0(bm_01_0),
        .branch_metric_01_1(bm_01_1),
        .branch_metric_10_0(bm_10_0),
        .branch_metric_10_1(bm_10_1),
        .branch_metric_11_0(bm_11_0),
        .branch_metric_11_1(bm_11_1),
        .selected_branch_at_00(path_00),
        .selected_branch_at_01(path_01),
        .selected_branch_at_10(path_10),
        .selected_branch_at_11(path_11),
        .valid_in(valid_in_acs),
        .new_branch_metric_00(new_bm_00),
        .new_branch_metric_01(new_bm_01),
        .new_branch_metric_10(new_bm_10),
        .new_branch_metric_11(new_bm_11),
        .updated_selected_branch_at_00(new_path_00),
        .updated_selected_branch_at_01(new_path_01),
        .updated_selected_branch_at_10(new_path_10),
        .updated_selected_branch_at_11(new_path_11),
        .valid_out(valid_out_acs)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tasks for test setup and verification
    task reset_system;
        begin
            rst = 1;
            valid_in_first = 0;
            valid_in_acs = 0;
            
            // Initialize first_acs inputs
            {bm_000, bm_001, bm_010, bm_011} = {4'd0, 4'd0, 4'd0, 4'd0};
            {bm_100, bm_101, bm_110, bm_111} = {4'd0, 4'd0, 4'd0, 4'd0};
            
            // Initialize acs inputs
            {bm_00_0, bm_00_1, bm_01_0, bm_01_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            {bm_10_0, bm_10_1, bm_11_0, bm_11_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            {path_00, path_01, path_10, path_11} = {8'd0, 8'd0, 8'd0, 8'd0};
            
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_first_acs;
        input [3:0] test_case;
        begin
            valid_in_first = 1;
            case(test_case)
                4'd0: begin // Basic comparison test
                    bm_000 = 4'd1; bm_100 = 4'd2;  // 000 should be selected
                    bm_001 = 4'd3; bm_101 = 4'd1;  // 101 should be selected
                    bm_010 = 4'd2; bm_110 = 4'd2;  // 010 should be selected (equal case)
                    bm_011 = 4'd4; bm_111 = 4'd3;  // 111 should be selected
                end
                4'd1: begin // All equal metrics
                    bm_000 = 4'd2; bm_100 = 4'd2;
                    bm_001 = 4'd2; bm_101 = 4'd2;
                    bm_010 = 4'd2; bm_110 = 4'd2;
                    bm_011 = 4'd2; bm_111 = 4'd2;
                end
                4'd2: begin // Maximum difference
                    bm_000 = 4'd0; bm_100 = 4'd15;
                    bm_001 = 4'd15; bm_101 = 4'd0;
                    bm_010 = 4'd0; bm_110 = 4'd15;
                    bm_011 = 4'd15; bm_111 = 4'd0;
                end
                default: begin
                    bm_000 = 4'd0; bm_100 = 4'd0;
                    bm_001 = 4'd0; bm_101 = 4'd0;
                    bm_010 = 4'd0; bm_110 = 4'd0;
                    bm_011 = 4'd0; bm_111 = 4'd0;
                end
            endcase
            #10;
        end
    endtask

    task test_acs;
        input [3:0] test_case;
        begin
            valid_in_acs = 1;
            case(test_case)
                4'd0: begin // Test path history concatenation
                    bm_00_0 = 4'd1; bm_10_0 = 4'd2;
                    bm_00_1 = 4'd2; bm_10_1 = 4'd1;
                    bm_01_0 = 4'd3; bm_11_0 = 4'd2;
                    bm_01_1 = 4'd1; bm_11_1 = 4'd4;
                    path_00 = 8'b10101010;
                    path_01 = 8'b11001100;
                    path_10 = 8'b11110000;
                    path_11 = 8'b00001111;
                end
                4'd1: begin // Test with all zeros path history
                    bm_00_0 = 4'd3; bm_10_0 = 4'd2;
                    bm_00_1 = 4'd1; bm_10_1 = 4'd4;
                    bm_01_0 = 4'd2; bm_11_0 = 4'd3;
                    bm_01_1 = 4'd4; bm_11_1 = 4'd1;
                    path_00 = 8'b00000000;
                    path_01 = 8'b00000000;
                    path_10 = 8'b00000000;
                    path_11 = 8'b00000000;
                end
                default: begin
                    bm_00_0 = 4'd0; bm_10_0 = 4'd0;
                    bm_00_1 = 4'd0; bm_10_1 = 4'd0;
                    bm_01_0 = 4'd0; bm_11_0 = 4'd0;
                    bm_01_1 = 4'd0; bm_11_1 = 4'd0;
                    path_00 = 8'd0;
                    path_01 = 8'd0;
                    path_10 = 8'd0;
                    path_11 = 8'd0;
                end
            endcase
            #10;
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("acs_tb.vcd");
        $dumpvars(0, acs_tb);

        // Test sequence
        reset_system();

        // Test first_acs module
        $display("\nTesting first_acs module...");
        test_first_acs(4'd0);
        test_first_acs(4'd1);
        test_first_acs(4'd2);

        // Test acs module
        $display("\nTesting acs module...");
        test_acs(4'd0);
        test_acs(4'd1);

        // Test reset during operation
        $display("\nTesting reset during operation...");
        test_first_acs(4'd0);
        test_acs(4'd0);
        #5 rst = 1;
        #10 rst = 0;
        #10;

        // Test valid signal behavior
        $display("\nTesting valid signal behavior...");
        valid_in_first = 0;
        valid_in_acs = 0;
        #20;
        valid_in_first = 1;
        valid_in_acs = 1;
        #20;

        // End simulation
        #100;
        $display("\nSimulation completed successfully!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b\nfirst_acs: valid_in=%b valid_out=%b\nmetrics: %h %h %h %h\npaths: %b %b %b %b\nacs: valid_in=%b valid_out=%b\nnew_metrics: %h %h %h %h\nnew_paths: %h %h %h %h\n",
            $time, rst,
            valid_in_first, valid_out_first,
            new_bm_00_first, new_bm_01_first, new_bm_10_first, new_bm_11_first,
            path_00_first, path_01_first, path_10_first, path_11_first,
            valid_in_acs, valid_out_acs,
            new_bm_00, new_bm_01, new_bm_10, new_bm_11,
            new_path_00, new_path_01, new_path_10, new_path_11
        );
    end

endmodule

