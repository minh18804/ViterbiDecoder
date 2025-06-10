module first_acs(
    input wire clk,
    input wire rst,
    input wire [3:0] branch_metric_00_0,
    input wire [3:0] branch_metric_00_1,
    input wire [3:0] branch_metric_01_0,
    input wire [3:0] branch_metric_01_1,
    input wire [3:0] branch_metric_10_0,
    input wire [3:0] branch_metric_10_1,
    input wire [3:0] branch_metric_11_0,
    input wire [3:0] branch_metric_11_1,

    input wire valid_in,

    output reg [3:0] new_branch_metric_00, //Khoảng cách Hamming nhỏ nhất giữa 2 đường đi có đầu ra tạm thời là 000 và 001
    output reg [3:0] new_branch_metric_01, //Khoảng cách Hamming nhỏ nhất giữa 2 đường đi có đầu ra tạm thời là 010 và 011
    output reg [3:0] new_branch_metric_10, //Khoảng cách Hamming nhỏ nhất giữa 2 đường đi có đầu ra tạm thời là 100 và 101
    output reg [3:0] new_branch_metric_11, //Khoảng cách Hamming nhỏ nhất giữa 2 đường đi có đầu ra tạm thời là 110 và 111

    output reg [2:0] selected_branch_at_00, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 00
    output reg [2:0] selected_branch_at_01, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 01
    output reg [2:0] selected_branch_at_10, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 10
    output reg [2:0] selected_branch_at_11, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 11
    output reg valid_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            new_branch_metric_00 <= 4'b0000;
            new_branch_metric_01 <= 4'b0000;
            new_branch_metric_10 <= 4'b0000;
            new_branch_metric_11 <= 4'b0000;
            selected_branch_at_00 <= 4'b0000;
            selected_branch_at_01 <= 4'b0000;
            selected_branch_at_10 <= 4'b0000;
            selected_branch_at_11 <= 4'b0000;
            valid_out <= 1'b0;
        end
        else if (valid_in) 
        begin
            valid_out <= 1'b1;
            //Xử lý trạng thái 00
            if (branch_metric_00_0 <= branch_metric_10_0) 
            begin
                new_branch_metric_00 <= branch_metric_00_0;
                selected_branch_at_00 <= 3'b000;
            end
            else 
            begin
                new_branch_metric_00 <= branch_metric_10_0;
                selected_branch_at_00 <= 3'b100;
            end

            //Xử lý trạng thái 01
            if (branch_metric_00_1 <= branch_metric_10_1) 
            begin
                new_branch_metric_01 <= branch_metric_00_1;
                selected_branch_at_01 <= 3'b001;
            end
            else 
            begin
                new_branch_metric_01 <= branch_metric_10_1;
                selected_branch_at_01 <= 3'b101;
            end

            //Xử lý trạng thái 10
            if (branch_metric_01_0 <= branch_metric_11_0) 
            begin
                new_branch_metric_10 <= branch_metric_01_0;
                selected_branch_at_10 <= 3'b010;
            end
            else 
            begin
                new_branch_metric_10 <= branch_metric_11_0;
                selected_branch_at_10 <= 3'b110;
            end

            //Xử lý trạng thái 11
            if (branch_metric_01_1 <= branch_metric_11_1) 
            begin
                new_branch_metric_11 <= branch_metric_01_1;
                selected_branch_at_11 <= 3'b011;
            end
            else 
            begin
                new_branch_metric_11 <= branch_metric_11_1;
                selected_branch_at_11 <= 3'b111;
            end
        end
    end
endmodule

module acs(
    input wire clk,
    input wire rst,
    input wire [3:0] branch_metric_00_0,
    input wire [3:0] branch_metric_00_1,
    input wire [3:0] branch_metric_01_0,
    input wire [3:0] branch_metric_01_1,
    input wire [3:0] branch_metric_10_0,
    input wire [3:0] branch_metric_10_1,
    input wire [3:0] branch_metric_11_0,
    input wire [3:0] branch_metric_11_1,
    input wire [7:0] selected_branch_at_00,
    input wire [7:0] selected_branch_at_01,
    input wire [7:0] selected_branch_at_10,
    input wire [7:0] selected_branch_at_11,
    input wire valid_in,
    output reg [3:0] new_branch_metric_00,
    output reg [3:0] new_branch_metric_01,
    output reg [3:0] new_branch_metric_10,
    output reg [3:0] new_branch_metric_11,
    output reg [7:0] updated_selected_branch_at_00,
    output reg [7:0] updated_selected_branch_at_01,
    output reg [7:0] updated_selected_branch_at_10,
    output reg [7:0] updated_selected_branch_at_11,
    output reg valid_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            new_branch_metric_00 <= 4'b0000;
            new_branch_metric_01 <= 4'b0000;
            new_branch_metric_10 <= 4'b0000;
            new_branch_metric_11 <= 4'b0000;
            selected_branch_at_00 <= 8'b00000000;
            selected_branch_at_01 <= 8'b00000000;
            selected_branch_at_10 <= 8'b00000000;
            selected_branch_at_11 <= 8'b00000000;
            valid_out <= 1'b0;
        end
        else if (valid_in) 
        begin
            valid_out <= 1'b1;
            //Xử lý trạng thái 00
            if (branch_metric_00_0 <= branch_metric_10_0) 
            begin
                new_branch_metric_00 <= branch_metric_00_0;
                updated_selected_branch_at_00 <= {selected_branch_at_00, 1'b0};
            end
            else 
            begin
                new_branch_metric_00 <= branch_metric_10_0;
                updated_selected_branch_at_00 <= {selected_branch_at_10, 1'b0};
            end

            //Xử lý trạng thái 01
            if (branch_metric_00_1 <= branch_metric_10_1) 
            begin
                new_branch_metric_01 <= branch_metric_00_1;
                updated_selected_branch_at_01 <= {selected_branch_at_00, 1'b1};
            end
            else 
            begin
                new_branch_metric_01 <= branch_metric_10_1;
                updated_selected_branch_at_01 <= {selected_branch_at_10, 1'b1};
            end

            //Xử lý trạng thái 10
            if (branch_metric_01_0 <= branch_metric_11_0) 
            begin
                new_branch_metric_10 <= branch_metric_01_0;
                updated_selected_branch_at_10 <= {selected_branch_at_01, 1'b0};
            end
            else 
            begin
                new_branch_metric_10 <= branch_metric_11_0;
                updated_selected_branch_at_10 <= {selected_branch_at_11, 1'b0};
            end

            //Xử lý trạng thái 11
            if (branch_metric_01_1 <= branch_metric_11_1) 
            begin
                new_branch_metric_11 <= branch_metric_01_1;
                updated_selected_branch_at_11 <= {selected_branch_at_01, 1'b1};
            end
            else 
            begin
                new_branch_metric_11 <= branch_metric_11_1;
                updated_selected_branch_at_11 <= {selected_branch_at_11, 1'b1};
            end
        end
    end
endmodule

`timescale 1ns/1ps
`include "acs.v"

module acs_tb;
    // Tín hiệu cho first_acs
    reg clk, rst, valid_in_first;
    reg [3:0] bm_000, bm_001, bm_010, bm_011;
    reg [3:0] bm_100, bm_101, bm_110, bm_111;
    
    wire [3:0] new_bm_00_first, new_bm_01_first;
    wire [3:0] new_bm_10_first, new_bm_11_first;
    wire [2:0] path_00_first, path_01_first;
    wire [2:0] path_10_first, path_11_first;
    wire valid_out_first;

    // Tín hiệu cho acs
    reg valid_in_acs;
    reg [3:0] bm_00_0, bm_00_1, bm_01_0, bm_01_1;
    reg [3:0] bm_10_0, bm_10_1, bm_11_0, bm_11_1;
    reg [7:0] path_00, path_01, path_10, path_11;
    
    wire [3:0] new_bm_00, new_bm_01, new_bm_10, new_bm_11;
    wire [7:0] new_path_00, new_path_01, new_path_10, new_path_11;
    wire valid_out_acs;

    // Khởi tạo module
    first_acs first_acs_inst (
        .clk(clk),
        .rst(rst),
        .branch_metric_000(bm_000),
        .branch_metric_001(bm_001),
        .branch_metric_010(bm_010),
        .branch_metric_011(bm_011),
        .branch_metric_100(bm_100),
        .branch_metric_101(bm_101),
        .branch_metric_110(bm_110),
        .branch_metric_111(bm_111),
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

    acs acs_inst (
        .clk(clk),
        .rst(rst),
        .bm_00_0(bm_00_0),
        .bm_00_1(bm_00_1),
        .bm_01_0(bm_01_0),
        .bm_01_1(bm_01_1),
        .bm_10_0(bm_10_0),
        .bm_10_1(bm_10_1),
        .bm_11_0(bm_11_0),
        .bm_11_1(bm_11_1),
        .path_00(path_00),
        .path_01(path_01),
        .path_10(path_10),
        .path_11(path_11),
        .valid_in(valid_in_acs),
        .new_bm_00(new_bm_00),
        .new_bm_01(new_bm_01),
        .new_bm_10(new_bm_10),
        .new_bm_11(new_bm_11),
        .new_path_00(new_path_00),
        .new_path_01(new_path_01),
        .new_path_10(new_path_10),
        .new_path_11(new_path_11),
        .valid_out(valid_out_acs)
    );

    // Tạo clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test vectors
    initial begin
        // Khởi tạo file dump cho GTKWave
        $dumpfile("acs_tb.vcd");
        $dumpvars(0, acs_tb);

        // Reset cả hai module
        rst = 1;
        valid_in_first = 0;
        valid_in_acs = 0;
        
        // Khởi tạo giá trị cho first_acs
        bm_000 = 0; bm_001 = 0; bm_010 = 0; bm_011 = 0;
        bm_100 = 0; bm_101 = 0; bm_110 = 0; bm_111 = 0;
        
        // Khởi tạo giá trị cho acs
        bm_00_0 = 0; bm_00_1 = 0; bm_01_0 = 0; bm_01_1 = 0;
        bm_10_0 = 0; bm_10_1 = 0; bm_11_0 = 0; bm_11_1 = 0;
        path_00 = 0; path_01 = 0; path_10 = 0; path_11 = 0;

        #100;  // Đợi reset
        rst = 0;
        
        // Test case 1: first_acs - So sánh đơn giản
        valid_in_first = 1;
        bm_000 = 4'd1; bm_100 = 4'd2;  // 000 nhỏ hơn 100
        bm_001 = 4'd2; bm_101 = 4'd1;  // 001 lớn hơn 101
        bm_010 = 4'd3; bm_110 = 4'd3;  // 010 bằng 110
        bm_011 = 4'd1; bm_111 = 4'd4;  // 011 nhỏ hơn 111
        #10;

        // Test case 2: acs - Path history test
        valid_in_acs = 1;
        bm_00_0 = 4'd1; bm_10_0 = 4'd2;
        bm_00_1 = 4'd2; bm_10_1 = 4'd1;
        bm_01_0 = 4'd3; bm_11_0 = 4'd3;
        bm_01_1 = 4'd1; bm_11_1 = 4'd4;
        path_00 = 8'b10101010;
        path_01 = 8'b11001100;
        path_10 = 8'b11110000;
        path_11 = 8'b00001111;
        #10;

        // Test case 3: Kiểm tra valid signals
        valid_in_first = 0;
        valid_in_acs = 0;
        #10;

        // Test case 4: Reset trong quá trình hoạt động
        valid_in_first = 1;
        valid_in_acs = 1;
        #5;
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Test case 5: Các giá trị metric khác
        valid_in_first = 1;
        valid_in_acs = 1;
        bm_000 = 4'd5; bm_100 = 4'd3;
        bm_001 = 4'd4; bm_101 = 4'd4;
        bm_010 = 4'd2; bm_110 = 4'd6;
        bm_011 = 4'd7; bm_111 = 4'd1;
        
        bm_00_0 = 4'd5; bm_10_0 = 4'd3;
        bm_00_1 = 4'd4; bm_10_1 = 4'd4;
        bm_01_0 = 4'd2; bm_11_0 = 4'd6;
        bm_01_1 = 4'd7; bm_11_1 = 4'd1;
        #10;

        // Kết thúc simulation
        #100;
        $finish;
    end

    // Monitor kết quả
    initial begin
        $monitor("Time=%0t rst=%b\n first_acs: valid_in=%b valid_out=%b\n metrics: %h %h %h %h\n paths: %b %b %b %b\n acs: valid_in=%b valid_out=%b\n new_metrics: %h %h %h %h\n new_paths: %b %b %b %b",
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

