`ifndef PMPS_V
`define PMPS_V

`include "bmu.v"
`include "cs.v"


module pmps(
    input wire clk,
    input wire rst,
    input wire refresh,
    input wire [1:0] bit_pair_input,
    input wire [3:0] branch_metric_00,
    input wire [3:0] branch_metric_01,
    input wire [3:0] branch_metric_10,
    input wire [3:0] branch_metric_11,
    input wire valid_in,
    input wire [2:0] write_pointer_in,
    input wire [7:0] selected_branch_at_00,
    input wire [7:0] selected_branch_at_01,
    input wire [7:0] selected_branch_at_10,
    input wire [7:0] selected_branch_at_11,
    output wire [3:0] new_branch_metric_00,
    output wire [3:0] new_branch_metric_01,
    output wire [3:0] new_branch_metric_10,
    output wire [3:0] new_branch_metric_11,
    output wire [7:0] updated_selected_branch_at_00,
    output wire [7:0] updated_selected_branch_at_01,
    output wire [7:0] updated_selected_branch_at_10,
    output wire [7:0] updated_selected_branch_at_11,
    output wire [2:0] write_pointer_out,
    output wire valid_out
);

    wire [3:0] branch_metric_00_0;
    wire [3:0] branch_metric_00_1;
    wire [3:0] branch_metric_01_0;
    wire [3:0] branch_metric_01_1;
    wire [3:0] branch_metric_10_0;
    wire [3:0] branch_metric_10_1;
    wire [3:0] branch_metric_11_0;
    wire [3:0] branch_metric_11_1;

    wire valid_out_bmu;

bmu bmu_inst(
    .clk(clk),
    .rst(rst),
    .refresh(refresh),
    .bit_pair_input(bit_pair_input),
    .branch_metric_00(branch_metric_00),
    .branch_metric_01(branch_metric_01),
    .branch_metric_10(branch_metric_10),
    .branch_metric_11(branch_metric_11),
    .valid_in(valid_in),
    .branch_metric_00_0(branch_metric_00_0),
    .branch_metric_00_1(branch_metric_00_1),
    .branch_metric_01_0(branch_metric_01_0),
    .branch_metric_01_1(branch_metric_01_1),
    .branch_metric_10_0(branch_metric_10_0),
    .branch_metric_10_1(branch_metric_10_1),
    .branch_metric_11_0(branch_metric_11_0),
    .branch_metric_11_1(branch_metric_11_1),
    .valid_out(valid_out_bmu)
);

cs cs_inst(
    .clk(clk),
    .rst(rst),
    .refresh(refresh),
    .branch_metric_00_0(branch_metric_00_0),
    .branch_metric_00_1(branch_metric_00_1),
    .branch_metric_01_0(branch_metric_01_0),
    .branch_metric_01_1(branch_metric_01_1),
    .branch_metric_10_0(branch_metric_10_0),
    .branch_metric_10_1(branch_metric_10_1),
    .branch_metric_11_0(branch_metric_11_0),
    .branch_metric_11_1(branch_metric_11_1),
    .selected_branch_at_00(selected_branch_at_00),
    .selected_branch_at_01(selected_branch_at_01),
    .selected_branch_at_10(selected_branch_at_10),
    .selected_branch_at_11(selected_branch_at_11),
    .write_pointer_in(write_pointer_in),
    .valid_in(valid_out_bmu),
    .new_branch_metric_00(new_branch_metric_00),
    .new_branch_metric_01(new_branch_metric_01),
    .new_branch_metric_10(new_branch_metric_10),
    .new_branch_metric_11(new_branch_metric_11),
    .updated_selected_branch_at_00(updated_selected_branch_at_00),
    .updated_selected_branch_at_01(updated_selected_branch_at_01),
    .updated_selected_branch_at_10(updated_selected_branch_at_10),
    .updated_selected_branch_at_11(updated_selected_branch_at_11),
    .write_pointer_out(write_pointer_out),
    .valid_out(valid_out)
);
endmodule

`endif