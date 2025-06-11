`ifndef INPUT_BUFFER_V
`define INPUT_BUFFER_V

module input_buffer(
    input wire clk,
    input wire rst,
    input wire renew,
    input wire [15:0] data_in,
    output reg [1:0] bit_pair_0,
    output reg [1:0] bit_pair_1,
    output reg [1:0] bit_pair_2,
    output reg [1:0] bit_pair_3,
    output reg [1:0] bit_pair_4,
    output reg [1:0] bit_pair_5,
    output reg [1:0] bit_pair_6,
    output reg [1:0] bit_pair_7
);

// 2 ngăn FIFO và các tín hiệu điều khiển
reg [15:0] data_reg [1:0];    // 2 ngăn FIFO
reg decoding;                  // Đánh dấu đang trong quá trình giải mã
reg [15:0] decoding_data;      // Dữ liệu đưa ra đầu ra
reg has_new_data;             // Đánh dấu có dữ liệu mới
reg [15:0] prev_data;         // Lưu giá trị data_in trước đó để so sánh với data_in hiện tại

// Kiểm tra dữ liệu vào
always @(data_in or posedge rst) begin
    if (rst) begin
        has_new_data <= 1'b0; //Xử lý khi reset
    end
    else begin
        if (data_in != 16'b0) begin
            has_new_data <= 1'b1;       //Nếu dữ liệu đầu vào khác 0 thì đẩy cờ has_new_data lên 1
        end
        else begin
            has_new_data <= 1'b0;       //Nếu dữ liệu đầu vào bằng 0 thì đẩy cờ has_new_data xuống 0
        end
    end
end

// Xử lý FIFO và dữ liệu
always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_reg[0] <= 16'b0;
        data_reg[1] <= 16'b0;
        decoding_data <= 16'b0;
        prev_data <= 16'b0;
        decoding <= 1'b0;
    end
    else begin
        if (renew) begin
            // Khi hoàn thành giải mã một gói
            if (data_reg[1] != 16'b0) begin
                // Nếu có dữ liệu trong ngăn 1, chuyển sang xử lý
                decoding_data <= data_reg[0];
                data_reg[0] <= data_reg[1];  // Dịch dữ liệu
                data_reg[1] <= 16'b0;        // Xóa ngăn 0
                decoding <= 1'b1;
            end
            else if (data_reg[0] != 16'b0) begin
                // Nếu chỉ có dữ liệu trong ngăn 0
                decoding_data <= data_reg[0];
                data_reg[0] <= 16'b0;
                decoding <= 1'b1;
            end
            else begin
                decoding <= 1'b0;
            end
        end
        else if (has_new_data) begin
            if (!decoding) begin
                // Nếu không trong quá trình giải mã, xử lý ngay
                decoding_data <= data_in;
                decoding <= 1'b1;
            end
            else if (data_reg[0] == 16'b0) begin
                // Lưu vào ngăn 0 nếu trống
                prev_data <= data_in;
                if (decoding_data != prev_data) begin
                    data_reg[0] <= data_in;
                end
            end
            else if (data_reg[1] == 16'b0) begin
                // Lưu vào ngăn 1 nếu trống
                prev_data <= data_in;   
                if (data_reg[0] != prev_data) begin
                    data_reg[1] <= data_in;
                end
            end
            // Nếu cả hai ngăn đều đầy, bỏ qua dữ liệu mới
        end
    end
end

// Xuất các cặp bit
always @(*) begin
    bit_pair_0 = decoding_data[1:0];
    bit_pair_1 = decoding_data[3:2];
    bit_pair_2 = decoding_data[5:4];
    bit_pair_3 = decoding_data[7:6];
    bit_pair_4 = decoding_data[9:8];
    bit_pair_5 = decoding_data[11:10];
    bit_pair_6 = decoding_data[13:12];
    bit_pair_7 = decoding_data[15:14];
end

endmodule



`endif