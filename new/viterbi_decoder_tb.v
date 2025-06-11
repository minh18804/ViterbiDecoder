`timescale 1ns/1ps
`include "viterbi_decoder.v"

module viterbi_decoder_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg [15:0] data_in;
    wire [7:0] data_out;

    // Instantiate the viterbi_decoder_top
    viterbi_decoder_top dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
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
            data_in = 16'h0000;
            #20;
            rst = 0;
        end
    endtask

    task send_data;
        input [15:0] test_data;
        begin
            @(posedge clk);
            data_in = test_data;
            #10;
        end
    endtask

    task check_output;
        input [7:0] expected_out;
        input [31:0] test_case;
        begin
            @(posedge clk);
            #1; // Wait for outputs to stabilize
            if (data_out !== expected_out) begin
                $display("Error in test case %0d!", test_case);
                $display("Expected output: %b", expected_out);
                $display("Actual output: %b", data_out);
            end else begin
                $display("Test case %0d passed!", test_case);
                $display("Output: %b", data_out);
            end
        end
    endtask

    // Main test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("viterbi_decoder_tb.vcd");
        $dumpvars(0, viterbi_decoder_tb);

        $display("Starting Viterbi Decoder Tests...");
        
        // Initial reset
        reset_system();

        // Test Case 1: All zeros input
//        $display("\nTest Case 1: All zeros input");
//        send_data(16'h0000);
//        check_output(8'h00, 1);

        // Test Case 2: All ones input
        $display("\nTest Case 2: All ones input");
        send_data(16'hFFFF);
        check_output(8'hFF, 2);

//        // Test Case 3: Alternating bits
//        $display("\nTest Case 3: Alternating bits");
//        send_data(16'hAAAA);
//        check_output(8'hAA, 3);

//        // Test Case 4: Random pattern 1
//        $display("\nTest Case 4: Random pattern 1");
//        send_data(16'h5555);
//        check_output(8'h55, 4);

//        // Test Case 5: Random pattern 2
//        $display("\nTest Case 5: Random pattern 2");
//        send_data(16'h1234);
//        check_output(8'h12, 5);

//        // Test Case 6: Random pattern 3
//        $display("\nTest Case 6: Random pattern 3");
//        send_data(16'h9876);
//        check_output(8'h98, 6);

//        // Test Case 7: Edge pattern 1
//        $display("\nTest Case 7: Edge pattern 1");
//        send_data(16'h0F0F);
//        check_output(8'h0F, 7);

//        // Test Case 8: Edge pattern 2
//        $display("\nTest Case 8: Edge pattern 2");
//        send_data(16'hF0F0);
//        check_output(8'hF0, 8);

        // Add delay to observe final outputs
        #100;

        // End simulation
        $display("\nViterbi Decoder Testing Complete!");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t rst=%b data_in=%h data_out=%h",
                 $time, rst, data_in, data_out);
    end

endmodule 