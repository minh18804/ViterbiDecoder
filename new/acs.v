`ifndef ACS_V
`define ACS_V

// done
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

    output reg [7:0] selected_branch_at_00, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 00
    output reg [7:0] selected_branch_at_01, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 01
    output reg [7:0] selected_branch_at_10, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 10
    output reg [7:0] selected_branch_at_11, //Đầu ra của branch có metric nhỏ nhất tại trạng thái 11
    output reg valid_out,

    output reg [2:0] write_pointer_out
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
            write_pointer_out <= 3'd0;
        end
        else if (valid_in) 
        begin
            valid_out <= 1'b1;
            write_pointer_out <= 3'd3;

            //Xử lý trạng thái 00
            if (branch_metric_00_0 <= branch_metric_10_0) 
            begin
                new_branch_metric_00 <= branch_metric_00_0;
                selected_branch_at_00 <= 8'b00000000;
            end
            else 
            begin
                new_branch_metric_00 <= branch_metric_10_0;
                selected_branch_at_00 <= 8'b10000000;
            end

            //Xử lý trạng thái 01
            if (branch_metric_00_1 <= branch_metric_10_1) 
            begin
                new_branch_metric_01 <= branch_metric_00_1;
                selected_branch_at_01 <= 8'b00100000;
            end
            else 
            begin
                new_branch_metric_01 <= branch_metric_10_1;
                selected_branch_at_01 <= 8'b10100000;
            end

            //Xử lý trạng thái 10
            if (branch_metric_01_0 <= branch_metric_11_0) 
            begin
                new_branch_metric_10 <= branch_metric_01_0;
                selected_branch_at_10 <= 8'b01000000;
            end
            else 
            begin
                new_branch_metric_10 <= branch_metric_11_0;
                selected_branch_at_10 <= 8'b11000000;
            end

            //Xử lý trạng thái 11
            if (branch_metric_01_1 <= branch_metric_11_1) 
            begin
                new_branch_metric_11 <= branch_metric_01_1;
                selected_branch_at_11 <= 8'b01100000;
            end
            else 
            begin
                new_branch_metric_11 <= branch_metric_11_1;
                selected_branch_at_11 <= 8'b11100000;
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

    input wire [2:0] write_pointer_in,
    input wire valid_in,

    output reg [3:0] new_branch_metric_00,
    output reg [3:0] new_branch_metric_01,
    output reg [3:0] new_branch_metric_10,
    output reg [3:0] new_branch_metric_11,
    output reg [7:0] updated_selected_branch_at_00,
    output reg [7:0] updated_selected_branch_at_01,
    output reg [7:0] updated_selected_branch_at_10,
    output reg [7:0] updated_selected_branch_at_11,

    output reg [2:0] write_pointer_out,
    output reg valid_out
);

    always @(write_pointer_in) begin    
        write_pointer_out <= write_pointer_in + 1'b1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            new_branch_metric_00 <= 4'b0000;
            new_branch_metric_01 <= 4'b0000;
            new_branch_metric_10 <= 4'b0000;
            new_branch_metric_11 <= 4'b0000;
            updated_selected_branch_at_00 <= 8'b00000000;
            updated_selected_branch_at_01 <= 8'b00000000;
            updated_selected_branch_at_10 <= 8'b00000000;
            updated_selected_branch_at_11 <= 8'b00000000;
            write_pointer_out <= 3'd0;
            valid_out <= 1'b0;
        end
        else if (valid_in) 
        begin
            valid_out <= 1'b1;

            //Xử lý trạng thái 00
            if (branch_metric_00_0 <= branch_metric_10_0) 
            begin
                new_branch_metric_00 <= branch_metric_00_0;
                updated_selected_branch_at_00 <= (selected_branch_at_00 ^ (1'b0 << (7'd7 - write_pointer_in)));
            end
            else 
            begin
                new_branch_metric_00 <= branch_metric_10_0;
                updated_selected_branch_at_00 <= (selected_branch_at_10 ^ (1'b0 << (7'd7 - write_pointer_in)));
            end

            //Xử lý trạng thái 01
            if (branch_metric_00_1 <= branch_metric_10_1) 
            begin
                new_branch_metric_01 <= branch_metric_00_1;
                updated_selected_branch_at_01 <= (selected_branch_at_00 ^ (1'b1 << (7'd7 - write_pointer_in)));
            end
            else 
            begin
                new_branch_metric_01 <= branch_metric_10_1;
                updated_selected_branch_at_01 <= (selected_branch_at_10 ^ (1'b1 << (7'd7 - write_pointer_in)));
            end

            //Xử lý trạng thái 10
            if (branch_metric_01_0 <= branch_metric_11_0) 
            begin
                new_branch_metric_10 <= branch_metric_01_0;
                updated_selected_branch_at_10 <= (selected_branch_at_01 ^ (1'b0 << (7'd7 - write_pointer_in)));
            end
            else 
            begin
                new_branch_metric_10 <= branch_metric_11_0;
                updated_selected_branch_at_10 <= (selected_branch_at_11 ^ (1'b0 << (7'd7 - write_pointer_in)));
            end

            //Xử lý trạng thái 11
            if (branch_metric_01_1 <= branch_metric_11_1) 
            begin
                new_branch_metric_11 <= branch_metric_01_1;
                updated_selected_branch_at_11 <= (selected_branch_at_01 ^ (1'b1 << (7'd7 - write_pointer_in)));
            end
            else 
            begin
                new_branch_metric_11 <= branch_metric_11_1;
                updated_selected_branch_at_11 <= (selected_branch_at_11 ^ (1'b1 << (7'd7 - write_pointer_in)));
            end
        end
    end
endmodule

`endif
