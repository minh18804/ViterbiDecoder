`ifndef SELECTOR_V
`define SELECTOR_V

module selector(
    input wire clk,
    input wire rst,
    input wire [7:0] updated_selected_branch_at_00,
    input wire [7:0] updated_selected_branch_at_01,
    input wire [7:0] updated_selected_branch_at_10,
    input wire [7:0] updated_selected_branch_at_11,
    input wire [3:0] new_branch_metric_00,
    input wire [3:0] new_branch_metric_01,
    input wire [3:0] new_branch_metric_10,
    input wire [3:0] new_branch_metric_11,
    input wire [2:0] write_pointer_in,
    input wire valid_in,
    output reg [7:0] out,
    output reg refresh
);
    reg [3:0] min_01;
    reg [3:0] min_23;
    reg [1:0] state_01;
    reg [1:0] state_23;
    reg [3:0] min_metric;
    reg [1:0] selected_state;
    reg [7:0] prev_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 8'b0;
            refresh <= 1'b0;
            min_01 <= 4'b0;
            min_23 <= 4'b0;
            state_01 <= 2'b0;
            state_23 <= 2'b0;
            min_metric <= 4'b0;
            selected_state <= 2'b0;
            prev_out <= 8'b0;
        end
        else if (valid_in) begin
            // First level comparison
            if (new_branch_metric_00 <= new_branch_metric_01) begin
                min_01 <= new_branch_metric_00;
                state_01 <= 2'b00;
            end else begin
                min_01 <= new_branch_metric_01;
                state_01 <= 2'b01;
            end

            if (new_branch_metric_10 <= new_branch_metric_11) begin
                min_23 <= new_branch_metric_10;
                state_23 <= 2'b10;
            end else begin
                min_23 <= new_branch_metric_11;
                state_23 <= 2'b11;
            end

            // Second level comparison
            if (min_01 <= min_23) begin
                min_metric <= min_01;
                selected_state <= state_01;
            end else begin
                min_metric <= min_23;
                selected_state <= state_23;
            end

            // Path selection
            case (selected_state)
                2'b00: out <= updated_selected_branch_at_00;
                2'b01: out <= updated_selected_branch_at_01;
                2'b10: out <= updated_selected_branch_at_10;
                2'b11: out <= updated_selected_branch_at_11;
            endcase

            // Check if output is same as previous
            if (out == prev_out) begin
                refresh <= 1'b1;
            end else begin
                refresh <= 1'b0;
            end

            // Update previous value
            prev_out <= out;
        end
        else begin
            refresh <= 1'b0;
        end
    end

endmodule

`endif