`timescale 1ns/1ps
`include "acs.v"

module first_acs_tb;
    // Clock and reset signals
    reg clk;
    reg rst;

    // Input signals
    reg valid_in;
    reg [3:0] bm_00_0, bm_00_1;
    reg [3:0] bm_01_0, bm_01_1;
    reg [3:0] bm_10_0, bm_10_1;
    reg [3:0] bm_11_0, bm_11_1;
    
    // Output signals
    wire [3:0] new_bm_00, new_bm_01, new_bm_10, new_bm_11;
    wire [7:0] path_00, path_01, path_10, path_11;
    wire [2:0] write_pointer;
    wire valid_out;

    // Instantiate first_acs module
    first_acs dut (
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
        .valid_in(valid_in),
        .new_branch_metric_00(new_bm_00),
        .new_branch_metric_01(new_bm_01),
        .new_branch_metric_10(new_bm_10),
        .new_branch_metric_11(new_bm_11),
        .selected_branch_at_00(path_00),
        .selected_branch_at_01(path_01),
        .selected_branch_at_10(path_10),
        .selected_branch_at_11(path_11),
        .write_pointer(write_pointer),
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
            valid_in = 0;
            {bm_00_0, bm_00_1, bm_01_0, bm_01_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            {bm_10_0, bm_10_1, bm_11_0, bm_11_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            #20;
            rst = 0;
            #10;
        end
    endtask

    task check_path_outputs;
        input [3:0] test_num;
        begin
            $display("\nTest Case %0d Results:", test_num);
            $display("Write Pointer = %0d (should be 3)", write_pointer);
            
            // Check path_00 format (should be 00000000 or 10000000)
            if (path_00 != 8'b00000000 && path_00 != 8'b10000000)
                $display("ERROR: path_00 = %b is invalid", path_00);
            
            // Check path_01 format (should be 00100000 or 10100000)
            if (path_01 != 8'b00100000 && path_01 != 8'b10100000)
                $display("ERROR: path_01 = %b is invalid", path_01);
            
            // Check path_10 format (should be 01000000 or 11000000)
            if (path_10 != 8'b01000000 && path_10 != 8'b11000000)
                $display("ERROR: path_10 = %b is invalid", path_10);
            
            // Check path_11 format (should be 01100000 or 11100000)
            if (path_11 != 8'b01100000 && path_11 != 8'b11100000)
                $display("ERROR: path_11 = %b is invalid", path_11);
            
            $display("Branch Metrics: %h %h %h %h %h %h %h %h", 
                    bm_00_0, bm_00_1, bm_01_0, bm_01_1,
                    bm_10_0, bm_10_1, bm_11_0, bm_11_1);
            $display("New Metrics: %h %h %h %h", 
                    new_bm_00, new_bm_01, new_bm_10, new_bm_11);
            $display("Path Selections: %b %b %b %b", 
                    path_00, path_01, path_10, path_11);
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [31:0] bm_values;     // 8 4-bit branch metrics
        begin
            valid_in = 1;
            {bm_00_0, bm_00_1, bm_01_0, bm_01_1, 
             bm_10_0, bm_10_1, bm_11_0, bm_11_1} = bm_values;
            @(posedge clk);
            #1; // Wait for outputs to stabilize
            check_path_outputs(test_num);
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("first_acs_tb.vcd");
        $dumpvars(0, first_acs_tb);

        $display("Starting First ACS Module Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: First path always wins (00_x < 10_x, 01_x < 11_x)
        test_case(4'd1, 
            {4'd1, 4'd1, 4'd1, 4'd1,    // 00_0, 00_1, 01_0, 01_1 
             4'd2, 4'd2, 4'd2, 4'd2}     // 10_0, 10_1, 11_0, 11_1
        );

        // Test Case 2: Second path always wins (00_x > 10_x, 01_x > 11_x)
        test_case(4'd2,
            {4'd2, 4'd2, 4'd2, 4'd2,    // 00_0, 00_1, 01_0, 01_1
             4'd1, 4'd1, 4'd1, 4'd1}     // 10_0, 10_1, 11_0, 11_1
        );

        // Test Case 3: Equal metrics (should select first path)
        test_case(4'd3,
            {4'd5, 4'd5, 4'd5, 4'd5,    // 00_0, 00_1, 01_0, 01_1
             4'd5, 4'd5, 4'd5, 4'd5}     // 10_0, 10_1, 11_0, 11_1
        );

        // Test Case 4: Alternating wins
        test_case(4'd4,
            {4'd1, 4'd2, 4'd1, 4'd2,    // 00_0, 00_1, 01_0, 01_1
             4'd2, 4'd1, 4'd2, 4'd1}     // 10_0, 10_1, 11_0, 11_1
        );

        // Test Case 5: Maximum difference
        test_case(4'd5,
            {4'd0, 4'd15, 4'd0, 4'd15,  // 00_0, 00_1, 01_0, 01_1
             4'd15, 4'd0, 4'd15, 4'd0}   // 10_0, 10_1, 11_0, 11_1
        );

        // Test valid signal behavior
        valid_in = 0;
        @(posedge clk);
        #1;
        $display("\nTesting invalid input (valid_in = 0)");
        $display("valid_out should be 0: %b", valid_out);

        // Test reset during operation
        test_case(4'd6,
            {4'd3, 4'd3, 4'd3, 4'd3,    // 00_0, 00_1, 01_0, 01_1
             4'd4, 4'd4, 4'd4, 4'd4}     // 10_0, 10_1, 11_0, 11_1
        );
        rst = 1;
        @(posedge clk);
        #1;
        $display("\nTesting reset");
        $display("All outputs should be 0:");
        $display("new_bm: %h %h %h %h", new_bm_00, new_bm_01, new_bm_10, new_bm_11);
        $display("paths: %b %b %b %b", path_00, path_01, path_10, path_11);
        $display("valid_out: %b", valid_out);

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b valid_in=%b valid_out=%b write_ptr=%0d",
            $time, rst, valid_in, valid_out, write_pointer);
    end

endmodule 