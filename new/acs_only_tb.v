`timescale 1ns/1ps
`include "acs.v"

module acs_only_tb;
    // Clock and reset signals
    reg clk;
    reg rst;

    // Input signals
    reg valid_in;
    reg [3:0] bm_00_0, bm_00_1;
    reg [3:0] bm_01_0, bm_01_1;
    reg [3:0] bm_10_0, bm_10_1;
    reg [3:0] bm_11_0, bm_11_1;
    reg [7:0] path_00, path_01, path_10, path_11;
    reg [2:0] write_pointer_in;
    
    // Output signals
    wire [3:0] new_bm_00, new_bm_01, new_bm_10, new_bm_11;
    wire [7:0] updated_path_00, updated_path_01;
    wire [7:0] updated_path_10, updated_path_11;
    wire [2:0] write_pointer_out;
    wire valid_out;

    // Instantiate acs module
    acs dut (
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
        .write_pointer_in(write_pointer_in),
        .valid_in(valid_in),
        .new_branch_metric_00(new_bm_00),
        .new_branch_metric_01(new_bm_01),
        .new_branch_metric_10(new_bm_10),
        .new_branch_metric_11(new_bm_11),
        .updated_selected_branch_at_00(updated_path_00),
        .updated_selected_branch_at_01(updated_path_01),
        .updated_selected_branch_at_10(updated_path_10),
        .updated_selected_branch_at_11(updated_path_11),
        .write_pointer_out(write_pointer_out),
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
            write_pointer_in = 0;
            {bm_00_0, bm_00_1, bm_01_0, bm_01_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            {bm_10_0, bm_10_1, bm_11_0, bm_11_1} = {4'd0, 4'd0, 4'd0, 4'd0};
            {path_00, path_01, path_10, path_11} = {8'd0, 8'd0, 8'd0, 8'd0};
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [31:0] bm_values;     // 8 4-bit branch metrics
        input [31:0] path_values;   // 4 8-bit path histories
        input [2:0] write_ptr;      // Write pointer value
        begin
            valid_in = 1;
            write_pointer_in = write_ptr;
            {bm_00_0, bm_00_1, bm_01_0, bm_01_1, bm_10_0, bm_10_1, bm_11_0, bm_11_1} = bm_values;
            {path_00, path_01, path_10, path_11} = path_values;
            #10;
            
            // Print test results
            $display("\nTest Case %0d Results:", test_num);
            $display("Write Pointer: in=%0d out=%0d", write_ptr, write_pointer_out);
            $display("Branch Metrics In: %h %h %h %h %h %h %h %h", 
                    bm_00_0, bm_00_1, bm_01_0, bm_01_1, bm_10_0, bm_10_1, bm_11_0, bm_11_1);
            $display("Path History In: %b %b %b %b", path_00, path_01, path_10, path_11);
            $display("New Branch Metrics: %h %h %h %h", new_bm_00, new_bm_01, new_bm_10, new_bm_11);
            $display("Updated Paths: %b %b %b %b", 
                    updated_path_00, updated_path_01, updated_path_10, updated_path_11);
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("acs_only_tb.vcd");
        $dumpvars(0, acs_only_tb);

        // Test sequence
        $display("Starting ACS tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: Basic test with write_pointer = 0
        test_case(4'd1, 
            {4'd1, 4'd2, 4'd3, 4'd4, 4'd2, 4'd1, 4'd4, 4'd3}, // Branch metrics
            {8'b10100000, 8'b11000000, 8'b11100000, 8'b00000000}, // Path histories
            3'd3 // Write pointer
        );
        #10;

        // Test Case 2: Test with write_pointer = 3
        test_case(4'd2,
            {4'd2, 4'd3, 4'd1, 4'd4, 4'd3, 4'd2, 4'd4, 4'd1}, // Branch metrics
            {8'b00000000, 8'b11110000, 8'b10110000, 8'b01010000}, // Path histories
            3'd4 // Write pointer
        );
        #10;

        // Test Case 3: Test with write_pointer = 7 (maximum)
        test_case(4'd3,
            {4'd1, 4'd4, 4'd4, 4'd1, 4'd2, 4'd3, 4'd3, 4'd2}, // Branch metrics
            {8'b11111111, 8'b00000000, 8'b10101010, 8'b01010101}, // Path histories
            3'd7 // Write pointer
        );
        #10;

        // Test Case 4: Test write_pointer wraparound
        test_case(4'd4,
            {4'd0, 4'd15, 4'd15, 4'd0, 4'd0, 4'd15, 4'd15, 4'd0}, // Branch metrics
            {8'b10101010, 8'b01010101, 8'b11001100, 8'b00110011}, // Path histories
            3'd6 // Write pointer (should wrap to 0)
        );
        #10;

        // Test Case 5: Reset during operation
        test_case(4'd5,
            {4'd3, 4'd1, 4'd4, 4'd2, 4'd5, 4'd3, 4'd6, 4'd4}, // Branch metrics
            {8'b11110000, 8'b00001111, 8'b10101010, 8'b01010101}, // Path histories
            3'd2 // Write pointer
        );
        #5 rst = 1;
        #10 rst = 0;
        #10;

        // Test Case 6: Valid signal test
        valid_in = 0;
        #20;
        test_case(4'd6,
            {4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8}, // Branch metrics
            {8'b11001100, 8'b00110011, 8'b10101010, 8'b01010101}, // Path histories
            3'd4 // Write pointer
        );
        #20;
        valid_in = 0;
        #20;

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b valid_in=%b valid_out=%b write_ptr_in=%0d write_ptr_out=%0d",
            $time, rst, valid_in, valid_out, write_pointer_in, write_pointer_out);
    end

endmodule 