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
    output reg renew
);
    // Temporary wires for comparison results
    wire [3:0] min_01 = (new_branch_metric_00 <= new_branch_metric_01) ? new_branch_metric_00 : new_branch_metric_01;
    wire [1:0] state_01 = (new_branch_metric_00 <= new_branch_metric_01) ? 2'b00 : 2'b01;
    
    wire [3:0] min_23 = (new_branch_metric_10 <= new_branch_metric_11) ? new_branch_metric_10 : new_branch_metric_11;
    wire [1:0] state_23 = (new_branch_metric_10 <= new_branch_metric_11) ? 2'b10 : 2'b11;

    // Final comparison results
    wire [3:0] min_metric = (min_01 <= min_23) ? min_01 : min_23;
    wire [1:0] selected_state = (min_01 <= min_23) ? state_01 : state_23;

    // Wire for selected path based on state
    wire [7:0] selected_path = (selected_state == 2'b00) ? updated_selected_branch_at_00 :
                              (selected_state == 2'b01) ? updated_selected_branch_at_01 :
                              (selected_state == 2'b10) ? updated_selected_branch_at_10 :
                                                         updated_selected_branch_at_11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 8'b00000000;
            renew <= 1'b0;
        end
        else if (valid_in) begin
            out <= selected_path;
            renew <= ~renew;  // Toggle renew signal when output is ready
        end
    end
endmodule

`endif