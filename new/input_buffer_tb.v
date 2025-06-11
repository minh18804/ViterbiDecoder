module input_buffer_tb;
    // Định nghĩa các tín hiệu test
    reg clk;
    reg rst;
    reg renew;
    reg [15:0] data_in;
    wire [1:0] bit_pair_0;
    wire [1:0] bit_pair_1;
    wire [1:0] bit_pair_2;
    wire [1:0] bit_pair_3;
    wire [1:0] bit_pair_4;
    wire [1:0] bit_pair_5;
    wire [1:0] bit_pair_6;
    wire [1:0] bit_pair_7;

    // Khởi tạo DUT (Device Under Test)
    input_buffer dut (
        .clk(clk),
        .rst(rst),
        .renew(renew),
        .data_in(data_in),
        .bit_pair_0(bit_pair_0),
        .bit_pair_1(bit_pair_1),
        .bit_pair_2(bit_pair_2),
        .bit_pair_3(bit_pair_3),
        .bit_pair_4(bit_pair_4),
        .bit_pair_5(bit_pair_5),
        .bit_pair_6(bit_pair_6),
        .bit_pair_7(bit_pair_7)
    );

    // Tạo clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock 100MHz
    end

    // Các test case
    initial begin
        // Khởi tạo waveform file
        $dumpfile("input_buffer_tb.vcd");
        $dumpvars(0, input_buffer_tb);

        // Test case 1: Reset
        rst = 1;
        renew = 0;
        data_in = 16'h0000;
        #20;
        rst = 0;
        #10;

        // Test case 2: Gửi dữ liệu đầu tiên
        data_in = 16'hA5A5;  // 1010 0101 1010 0101
        #10;
        // Kiểm tra các bit pair
        if (bit_pair_7 !== 2'b10) $display("Error: bit_pair_7 = %b, expected 10", bit_pair_7);
        if (bit_pair_6 !== 2'b10) $display("Error: bit_pair_6 = %b, expected 10", bit_pair_6);
        if (bit_pair_5 !== 2'b01) $display("Error: bit_pair_5 = %b, expected 01", bit_pair_5);
        if (bit_pair_4 !== 2'b01) $display("Error: bit_pair_4 = %b, expected 01", bit_pair_4);

        // Test case 3: Gửi dữ liệu thứ hai khi đang giải mã
        data_in = 16'h5A5A;  // 0101 1010 0101 1010
        #10;
        
        // Test case 4: Hoàn thành giải mã gói đầu tiên
        renew = 1;
        #10;
        renew = 0;
        #10;
        // Kiểm tra xem dữ liệu thứ hai có được load không
        if (bit_pair_7 !== 2'b01) $display("Error: bit_pair_7 = %b, expected 01", bit_pair_7);
        if (bit_pair_6 !== 2'b01) $display("Error: bit_pair_6 = %b, expected 01", bit_pair_6);
        if (bit_pair_5 !== 2'b10) $display("Error: bit_pair_5 = %b, expected 10", bit_pair_5);
        if (bit_pair_4 !== 2'b10) $display("Error: bit_pair_4 = %b, expected 10", bit_pair_4);

        // Test case 5: Gửi dữ liệu khi FIFO đầy
        data_in = 16'hFFFF;
        #10;
        data_in = 16'h0000;  // Dữ liệu này sẽ bị bỏ qua vì FIFO đầy
        #10;

        // Test case 6: Reset trong khi đang giải mã
        rst = 1;
        #20;
        rst = 0;
        #10;

        // Kết thúc mô phỏng
        #100;
        $display("Test completed");
        $finish;
    end

    // Monitor để theo dõi các tín hiệu
    initial begin
        $monitor("Time=%0t rst=%b renew=%b data_in=%h bit_pairs=%b%b%b%b_%b%b%b%b",
                 $time, rst, renew, data_in,
                 bit_pair_7, bit_pair_6, bit_pair_5, bit_pair_4,
                 bit_pair_3, bit_pair_2, bit_pair_1, bit_pair_0);
    end
endmodule