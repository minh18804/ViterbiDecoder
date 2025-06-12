`timescale 1ns/1ps
`include "selector.v"

module selector_tb;
    // Clock and reset signals
    reg clk;
    reg rst;
    reg refresh;
    reg valid_in;

    // Input signals
    reg [7:0] path_00, path_01, path_10, path_11;
    reg [3:0] metric_00, metric_01, metric_10, metric_11;
    reg [2:0] write_pointer;

    // Output signals
    wire [7:0] selected_path;
    wire [2:0] write_pointer_out;
    wire valid_out;

    // Instantiate selector module
    selector dut (
        .clk(clk),
        .rst(rst),
        .refresh(refresh),
        .valid_in(valid_in),
        .updated_selected_branch_at_00(path_00),
        .updated_selected_branch_at_01(path_01),
        .updated_selected_branch_at_10(path_10),
        .updated_selected_branch_at_11(path_11),
        .new_branch_metric_00(metric_00),
        .new_branch_metric_01(metric_01),
        .new_branch_metric_10(metric_10),
        .new_branch_metric_11(metric_11),
        .write_pointer_in(write_pointer),
        .selected_path(selected_path),
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
            refresh = 0;
            valid_in = 0;
            write_pointer = 0;
            {path_00, path_01, path_10, path_11} = {8'd0, 8'd0, 8'd0, 8'd0};
            {metric_00, metric_01, metric_10, metric_11} = {4'd0, 4'd0, 4'd0, 4'd0};
            #20;
            rst = 0;
            #10;
        end
    endtask

    task test_case;
        input [3:0] test_num;
        input [31:0] path_values;    // 4 8-bit paths
        input [15:0] metric_values;  // 4 4-bit metrics
        input [2:0] write_ptr;
        input valid;
        input refresh_val;
        begin
            {path_00, path_01, path_10, path_11} = path_values;
            {metric_00, metric_01, metric_10, metric_11} = metric_values;
            write_pointer = write_ptr;
            valid_in = valid;
            refresh = refresh_val;
            @(posedge clk);
            #1;
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("selector_tb.vcd");
        $dumpvars(0, selector_tb);

        $display("Starting Selector Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: Basic path selection, no refresh
        test_case(4'd1,
            {8'b10101010, 8'b11001100, 8'b11110000, 8'b00001111}, // Paths
            {4'd1, 4'd2, 4'd3, 4'd4},                             // Metrics
            3'd0,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #10;

        // Test Case 2: Equal metrics with refresh
        test_case(4'd2,
            {8'b00001111, 8'b11110000, 8'b10101010, 8'b01010101}, // Paths
            {4'd2, 4'd2, 4'd2, 4'd2},                             // Equal metrics
            3'd1,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b1                                                  // Refresh
        );
        #10;

        // Test Case 3: Maximum metric difference, toggle refresh
        test_case(4'd3,
            {8'b11111111, 8'b00000000, 8'b10101010, 8'b01010101}, // Paths
            {4'd0, 4'd15, 4'd7, 4'd8},                            // Metrics
            3'd2,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #5 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 4: Write pointer wraparound with refresh
        test_case(4'd4,
            {8'b00110011, 8'b11001100, 8'b10101010, 8'b01010101}, // Paths
            {4'd5, 4'd6, 4'd7, 4'd8},                             // Metrics
            3'd7,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b1                                                  // Refresh
        );
        #10;

        // Test Case 5: Valid signal behavior
        test_case(4'd5,
            {8'b11110000, 8'b00001111, 8'b11001100, 8'b00110011}, // Paths
            {4'd1, 4'd2, 4'd3, 4'd4},                             // Metrics
            3'd3,                                                  // Write pointer
            1'b0,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #20;

        // Test Case 6: Refresh during operation
        test_case(4'd6,
            {8'b10101010, 8'b01010101, 8'b11001100, 8'b00110011}, // Paths
            {4'd9, 4'd10, 4'd11, 4'd12},                          // Metrics
            3'd4,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #10 refresh = 1;
        #5 refresh = 0;
        #10;

        // Test Case 7: Rapid refresh toggles
        test_case(4'd7,
            {8'b11111111, 8'b00000000, 8'b10101010, 8'b01010101}, // Paths
            {4'd13, 4'd14, 4'd15, 4'd0},                          // Metrics
            3'd5,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #2 refresh = 1;
        #3 refresh = 0;
        #2 refresh = 1;
        #3 refresh = 0;
        #10;

        // Test Case 8: Reset and refresh interaction
        test_case(4'd8,
            {8'b10101010, 8'b11001100, 8'b11110000, 8'b00001111}, // Paths
            {4'd4, 4'd3, 4'd2, 4'd1},                             // Metrics
            3'd6,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b1                                                  // Refresh
        );
        #5 rst = 1;
        refresh = 1;
        #10 rst = 0;
        #5 refresh = 0;
        #10;

        // Test Case 9: All paths same, different metrics
        test_case(4'd9,
            {8'b11111111, 8'b11111111, 8'b11111111, 8'b11111111}, // Same paths
            {4'd1, 4'd2, 4'd3, 4'd4},                             // Different metrics
            3'd0,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b0                                                  // Refresh
        );
        #10;

        // Test Case 10: All metrics same, different paths
        test_case(4'd10,
            {8'b00000000, 8'b11111111, 8'b10101010, 8'b01010101}, // Different paths
            {4'd5, 4'd5, 4'd5, 4'd5},                             // Same metrics
            3'd1,                                                  // Write pointer
            1'b1,                                                 // Valid
            1'b1                                                  // Refresh
        );
        #10;

        // End simulation
        #100;
        $display("\nSimulation completed!");
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b refresh=%b valid_in=%b wp_in=%0d wp_out=%0d selected=%h",
            $time, rst, refresh, valid_in, write_pointer, write_pointer_out, selected_path);
    end

endmodule 