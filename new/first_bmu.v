`ifndef FIRST_BMU_V
`define FIRST_BMU_V

module first_bmu(
    input wire [1:0] bit_pair_0, //cặp bit thứ nhất của input, 
    input wire clk,
    input wire rst,
    output reg [1:0] branch_metric_0, //khoảng cách Hamming của bit_pair_0 với 00, chuyển sang trạng thái 00 ứng với đầu ra 0
    output reg [1:0] branch_metric_1, //khoảng cách Hamming của bit_pair_0 với 11, chuyển sang trạng thái 01 ứng với đầu ra 1
    output reg valid_out
);
    reg [1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            branch_metric_0 <= 2'b00;
            branch_metric_1 <= 2'b00;
            valid_out <= 1'b0;
            count <= 2'd0;
        end
        else begin
            case ({bit_pair_0[1], bit_pair_0[0]})
                2'b00: begin
                    branch_metric_0 <= 2'd0;
                    branch_metric_1 <= 2'd2;
                end
                2'b01: begin
                    branch_metric_0 <= 2'd1;
                    branch_metric_1 <= 2'd1;
                end
                2'b10: begin
                    branch_metric_0 <= 2'd1;
                    branch_metric_1 <= 2'd1;
                end
                2'b11: begin
                    branch_metric_0 <= 2'd2;
                    branch_metric_1 <= 2'd0;
                end
            endcase
            
            if (count == 2'd1) begin
                valid_out <= 1'b1;
            end
            else if (!valid_out) begin
                count <= count + 1'b1;
            end
        end
    end
endmodule

module second_bmu(
    input wire [1:0] bit_pair_1,
    input wire clk,
    input wire rst,
    input wire [1:0] branch_metric_0,
    input wire [1:0] branch_metric_1,
    input wire valid_in,
    output reg [2:0] branch_metric_00, //khoảng cách Hamming của bit_pair_1 với 00, chuyển sang trạng thái 00 ứng với đầu ra 0
    output reg [2:0] branch_metric_01, //khoảng cách Hamming của bit_pair_1 với 11, chuyển sang trạng thái 01 ứng với đầu ra 1
    output reg [2:0] branch_metric_10, //khoảng cách Hamming của bit_pair_1 với 10, chuyển sang trạng thái 10 ứng với đầu ra 0
    output reg [2:0] branch_metric_11,  //khoảng cách Hamming của bit_pair_1 với 01, chuyển sang trạng thái 11 ứng với đầu ra 1
    output reg valid_out
);
    reg [1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            branch_metric_00 <= 3'b000;
            branch_metric_01 <= 3'b000;
            branch_metric_10 <= 3'b000;
            branch_metric_11 <= 3'b000;
            valid_out <= 1'b0;
            count <= 2'd0;
        end
        else if (valid_in) begin
            case ({bit_pair_1[1], bit_pair_1[0]})
                2'b00: begin
                    branch_metric_00 <= 3'd0 + branch_metric_0;
                    branch_metric_01 <= 3'd2 + branch_metric_0;
                    branch_metric_10 <= 3'd1 + branch_metric_1;
                    branch_metric_11 <= 3'd1 + branch_metric_1;
                end
                2'b01: begin
                    branch_metric_00 <= 3'd1 + branch_metric_0;
                    branch_metric_01 <= 3'd1 + branch_metric_0;
                    branch_metric_10 <= 3'd2 + branch_metric_1;
                    branch_metric_11 <= 3'd0 + branch_metric_1;
                end
                2'b10: begin
                    branch_metric_00 <= 3'd1 + branch_metric_0;
                    branch_metric_01 <= 3'd1 + branch_metric_0;
                    branch_metric_10 <= 3'd0 + branch_metric_1;
                    branch_metric_11 <= 3'd2 + branch_metric_1;
                end
                2'b11: begin
                    branch_metric_00 <= 3'd2 + branch_metric_0;
                    branch_metric_01 <= 3'd0 + branch_metric_0;
                    branch_metric_10 <= 3'd1 + branch_metric_1;
                    branch_metric_11 <= 3'd1 + branch_metric_1;
                end
            endcase

            if (count == 2'd1) begin
                valid_out <= 1'b1;
            end
            else if (!valid_out) begin
                count <= count + 1'b1;
            end
        end
        else begin
            valid_out <= 1'b0;
            count <= 2'd0;
        end
    end
endmodule

module bmu(
    input wire clk,
    input wire rst,
    input wire [1:0] bit_pair_input,
    input wire [2:0] branch_metric_00,
    input wire [2:0] branch_metric_01,
    input wire [2:0] branch_metric_10,
    input wire [2:0] branch_metric_11,
    input wire valid_in,
    output reg [3:0] branch_metric_000,
    output reg [3:0] branch_metric_001,
    output reg [3:0] branch_metric_010,
    output reg [3:0] branch_metric_011,
    output reg [3:0] branch_metric_100,
    output reg [3:0] branch_metric_101,
    output reg [3:0] branch_metric_110,
    output reg [3:0] branch_metric_111,
    output reg valid_out
);
    reg [1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            branch_metric_000 <= 4'b0000;
            branch_metric_001 <= 4'b0000;
            branch_metric_010 <= 4'b0000;
            branch_metric_011 <= 4'b0000;
            branch_metric_100 <= 4'b0000;
            branch_metric_101 <= 4'b0000;
            branch_metric_110 <= 4'b0000;
            branch_metric_111 <= 4'b0000;
            valid_out <= 1'b0;
            count <= 2'd0;
        end
        else if (valid_in) begin
            case ({bit_pair_input[1], bit_pair_input[0]})
                2'b00: begin
                    branch_metric_000 <= 4'd0 + branch_metric_00;
                    branch_metric_001 <= 4'd2 + branch_metric_00;
                    branch_metric_010 <= 4'd1 + branch_metric_01;
                    branch_metric_011 <= 4'd1 + branch_metric_01;
                    branch_metric_100 <= 4'd2 + branch_metric_10;
                    branch_metric_101 <= 4'd0 + branch_metric_10;
                    branch_metric_110 <= 4'd1 + branch_metric_11;
                    branch_metric_111 <= 4'd1 + branch_metric_11;
                end
                2'b01: begin
                    branch_metric_000 <= 4'd1 + branch_metric_00;
                    branch_metric_001 <= 4'd1 + branch_metric_00;
                    branch_metric_010 <= 4'd2 + branch_metric_01;
                    branch_metric_011 <= 4'd0 + branch_metric_01;
                    branch_metric_100 <= 4'd1 + branch_metric_10;
                    branch_metric_101 <= 4'd1 + branch_metric_10;
                    branch_metric_110 <= 4'd0 + branch_metric_11;
                    branch_metric_111 <= 4'd2 + branch_metric_11;
                end
                2'b10: begin
                    branch_metric_000 <= 4'd1 + branch_metric_00;
                    branch_metric_001 <= 4'd1 + branch_metric_00;
                    branch_metric_010 <= 4'd0 + branch_metric_01;
                    branch_metric_011 <= 4'd2 + branch_metric_01;
                    branch_metric_100 <= 4'd1 + branch_metric_10;
                    branch_metric_101 <= 4'd1 + branch_metric_10;
                    branch_metric_110 <= 4'd2 + branch_metric_11;
                    branch_metric_111 <= 4'd0 + branch_metric_11;
                end
                2'b11: begin
                    branch_metric_000 <= 4'd2 + branch_metric_00;
                    branch_metric_001 <= 4'd0 + branch_metric_00;
                    branch_metric_010 <= 4'd1 + branch_metric_01;
                    branch_metric_011 <= 4'd1 + branch_metric_01;
                    branch_metric_100 <= 4'd0 + branch_metric_10;
                    branch_metric_101 <= 4'd2 + branch_metric_10;
                    branch_metric_110 <= 4'd1 + branch_metric_11;
                    branch_metric_111 <= 4'd1 + branch_metric_11;
                end
            endcase

            if (count == 2'd1) begin
                valid_out <= 1'b1;
            end
            else if (!valid_out) begin
                count <= count + 1'b1;
            end
        end
        else begin
            valid_out <= 1'b0;
            count <= 2'd0;
        end
    end
endmodule

`endif