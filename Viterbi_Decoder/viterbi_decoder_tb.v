`timescale 1ns/1ps
`include "viterbi_decoder.v"

module viterbi_decoder_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg [15:0] data_in;
    wire [7:0] data_out;
    
    // File handling
    integer file;
    integer scan_file;
    reg [15:0] captured_data;
    reg [4:0] clock_counter;  // Changed to 5 bits to count up to 23
    reg file_end;
    reg [15:0] binary_data;

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

    // Reset task
    task reset_system;
        begin
            rst = 1;
            data_in = 16'h0000;
            clock_counter = 0;
            file_end = 0;
            #20;
            rst = 0;
        end
    endtask

    // Main test sequence
    initial begin
        // Open input file
        file = $fopen("input.txt", "r");
        if (file == 0) begin
            $display("Error: Could not open input.txt");
            $finish;
        end

        // Initial reset
        reset_system();

        // Read and process data
        while (!file_end) begin
            @(posedge clk);
            if (clock_counter == 5'd25) begin  // Changed to 25 (26 clock cycles)
                $fscanf(file, "%b", binary_data);
                if (binary_data == 16'b1101101010100110) begin
                    file_end = 1;
                    $display("\nEnd of file reached!");
                    $display("Closing file and ending simulation...");
                    $fclose(file);
                    #100; // Wait for last data to be processed
                    $display("Simulation completed!");
                    $finish;
                end else begin
                    data_in = binary_data;
                    $display("Time=%0t: Reading new data: %b", $time, binary_data);
                end
            end
            clock_counter = clock_counter + 1;
        end
    end

    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b data_in=%b data_out=%b",
                 $time, rst, data_in, data_out);
    end

endmodule 