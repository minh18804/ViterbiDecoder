`timescale 1ns/1ps
`include "selector.v"

module selector_tb;
    // Clock and reset signals
    reg clk;
    reg rst;
    reg valid_in;

    // Input signals
    reg [7:0] path_00, path_01, path_10, path_11;
    reg [3:0] metric_00, metric_01, metric_10, metric_11;
    reg [2:0] write_pointer;

    // Output signal
    wire [7:0] selected_path;

    // Instantiate selector module
    selector dut (
        .clk(clk),
        .rst(rst),
        .updated_selected_branch_at_00(path_00),
        .updated_selected_branch_at_01(path_01),
        .updated_selected_branch_at_10(path_10),
        .updated_selected_branch_at_11(path_11),
        .new_branch_metric_00(metric_00),
        .new_branch_metric_01(metric_01),
        .new_branch_metric_10(metric_10),
        .new_branch_metric_11(metric_11),
        .write_pointer_in(write_pointer),
        .valid_in(valid_in),
        .out(selected_path)
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
            valid_in = 0;
            write_pointer = 0;
            {path_00, path_01, path_10, path_11} = {8'h00, 8'h00, 8'h00, 8'h00};
            {metric_00, metric_01, metric_10, metric_11} = {4'h0, 4'h0, 4'h0, 4'h0};
            #20;
            rst = 0;
            #10;
        end
    endtask

    task check_result;
        input [3:0] test_num;
        input [3:0] expected_min;
        input [7:0] expected_path;
        begin
            @(posedge clk);
            #1; // Wait for outputs to stabilize
            
            $display("\nTest Case %0d Results:", test_num);
            $display("Branch Metrics: %h %h %h %h", 
                    metric_00, metric_01, metric_10, metric_11);
            $display("Input Paths: %h %h %h %h",
                    path_00, path_01, path_10, path_11);
            $display("Selected Path: %h (Expected: %h)", 
                    selected_path, expected_path);
            
            if (selected_path !== expected_path)
                $display("ERROR: Path selection mismatch!");
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("selector_tb.vcd");
        $dumpvars(0, selector_tb);

        $display("Starting Selector Module Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: First state (00) has minimum metric
        valid_in = 1;
        {metric_00, metric_01, metric_10, metric_11} = {4'd1, 4'd5, 4'd7, 4'd9};
        {path_00, path_01, path_10, path_11} = {8'hA0, 8'hB0, 8'hC0, 8'hD0};
        check_result(1, 4'd1, 8'hA0);

        // Test Case 2: Second state (01) has minimum metric
        {metric_00, metric_01, metric_10, metric_11} = {4'd8, 4'd2, 4'd6, 4'd7};
        {path_00, path_01, path_10, path_11} = {8'hA1, 8'hB1, 8'hC1, 8'hD1};
        check_result(2, 4'd2, 8'hB1);

        // Test Case 3: Third state (10) has minimum metric
        {metric_00, metric_01, metric_10, metric_11} = {4'd9, 4'd8, 4'd3, 4'd7};
        {path_00, path_01, path_10, path_11} = {8'hA2, 8'hB2, 8'hC2, 8'hD2};
        check_result(3, 4'd3, 8'hC2);

        // Test Case 4: Fourth state (11) has minimum metric
        {metric_00, metric_01, metric_10, metric_11} = {4'd9, 4'd8, 4'd7, 4'd4};
        {path_00, path_01, path_10, path_11} = {8'hA3, 8'hB3, 8'hC3, 8'hD3};
        check_result(4, 4'd4, 8'hD3);

        // Test Case 5: Equal metrics (should select first occurrence)
        {metric_00, metric_01, metric_10, metric_11} = {4'd5, 4'd5, 4'd5, 4'd5};
        {path_00, path_01, path_10, path_11} = {8'hA4, 8'hB4, 8'hC4, 8'hD4};
        check_result(5, 4'd5, 8'hA4);

        // Test Case 6: Test with maximum metric values
        {metric_00, metric_01, metric_10, metric_11} = {4'hF, 4'hF, 4'hF, 4'h0};
        {path_00, path_01, path_10, path_11} = {8'hA5, 8'hB5, 8'hC5, 8'hD5};
        check_result(6, 4'h0, 8'hD5);

        // Test Case 7: Test valid signal
        valid_in = 0;
        {metric_00, metric_01, metric_10, metric_11} = {4'd1, 4'd2, 4'd3, 4'd4};
        {path_00, path_01, path_10, path_11} = {8'hA6, 8'hB6, 8'hC6, 8'hD6};
        check_result(7, 4'h0, 8'h00); // Should maintain reset value when not valid

        // Test Case 8: Reset during operation
        valid_in = 1;
        {metric_00, metric_01, metric_10, metric_11} = {4'd4, 4'd3, 4'd2, 4'd1};
        {path_00, path_01, path_10, path_11} = {8'hA7, 8'hB7, 8'hC7, 8'hD7};
        #5 rst = 1;
        check_result(8, 4'hF, 8'h00); // Should reset to initial values

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b valid=%b metrics=%h %h %h %h selected=%h",
            $time, rst, valid_in, 
            metric_00, metric_01, metric_10, metric_11,
            selected_path);
    end

endmodule 