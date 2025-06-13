`ifndef PMU_V
`define PMU_V

`include "pmps.v"

module pmu (
    input clk,
    input rst,
    input wire refresh,
    input wire [1:0] bit_pair_3,
    input wire [1:0] bit_pair_4,
    input wire [1:0] bit_pair_5,
    input wire [1:0] bit_pair_6,
    input wire [1:0] bit_pair_7,
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

//First_pmps
	wire [3:0] new_branch_metric_00_0;
	wire [3:0] new_branch_metric_01_0;
	wire [3:0] new_branch_metric_10_0;
	wire [3:0] new_branch_metric_11_0;
	wire [7:0] updated_selected_branch_at_00_0;
	wire [7:0] updated_selected_branch_at_01_0;
	wire [7:0] updated_selected_branch_at_10_0;
	wire [7:0] updated_selected_branch_at_11_0;
	wire [2:0] write_pointer_out_0;
	wire valid_out_0;

//Second_pmps
	wire [3:0] new_branch_metric_00_1;
	wire [3:0] new_branch_metric_01_1;
	wire [3:0] new_branch_metric_10_1;
	wire [3:0] new_branch_metric_11_1;
	wire [7:0] updated_selected_branch_at_00_1;
	wire [7:0] updated_selected_branch_at_01_1;
	wire [7:0] updated_selected_branch_at_10_1;
	wire [7:0] updated_selected_branch_at_11_1;
	wire [2:0] write_pointer_out_1;
	wire valid_out_1;

//Third_pmps
	wire [3:0] new_branch_metric_00_2;
	wire [3:0] new_branch_metric_01_2;
	wire [3:0] new_branch_metric_10_2;
	wire [3:0] new_branch_metric_11_2;
	wire [7:0] updated_selected_branch_at_00_2;
	wire [7:0] updated_selected_branch_at_01_2;
	wire [7:0] updated_selected_branch_at_10_2;
	wire [7:0] updated_selected_branch_at_11_2;
	wire [2:0] write_pointer_out_2;
	wire valid_out_2;

//Fourth_pmps
	wire [3:0] new_branch_metric_00_3;
	wire [3:0] new_branch_metric_01_3;
	wire [3:0] new_branch_metric_10_3;
	wire [3:0] new_branch_metric_11_3;
	wire [7:0] updated_selected_branch_at_00_3;
	wire [7:0] updated_selected_branch_at_01_3;
	wire [7:0] updated_selected_branch_at_10_3;
	wire [7:0] updated_selected_branch_at_11_3;
	wire [2:0] write_pointer_out_3;
	wire valid_out_3;

pmps first_pmps_inst(
	//Inputs
    .clk(clk),
    .rst(rst),
    .refresh(refresh),
    .bit_pair_input(bit_pair_3),
    .branch_metric_00(branch_metric_00),
	.branch_metric_01(branch_metric_01),
	.branch_metric_10(branch_metric_10),
	.branch_metric_11(branch_metric_11),
	.valid_in(valid_in),
	.selected_branch_at_00(selected_branch_at_00),
	.selected_branch_at_01(selected_branch_at_01),
	.selected_branch_at_10(selected_branch_at_10),
	.selected_branch_at_11(selected_branch_at_11),
	.write_pointer_in(write_pointer_in),
    //Outputs
	.new_branch_metric_00(new_branch_metric_00_0),
	.new_branch_metric_01(new_branch_metric_01_0),
	.new_branch_metric_10(new_branch_metric_10_0),
	.new_branch_metric_11(new_branch_metric_11_0),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_0),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_0),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_0),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_0),
	.write_pointer_out(write_pointer_out_0),
	.valid_out(valid_out_0)
);

pmps second_pmps_inst(
	//Inputs
    .clk(clk),
    .rst(rst),
    .refresh(refresh),
    .bit_pair_input(bit_pair_4),
    .branch_metric_00(new_branch_metric_00_0),
	.branch_metric_01(new_branch_metric_01_0),
	.branch_metric_10(new_branch_metric_10_0),
	.branch_metric_11(new_branch_metric_11_0),
	.valid_in(valid_out_0),
	.selected_branch_at_00(updated_selected_branch_at_00_0),
	.selected_branch_at_01(updated_selected_branch_at_01_0),
	.selected_branch_at_10(updated_selected_branch_at_10_0),
	.selected_branch_at_11(updated_selected_branch_at_11_0),
	.write_pointer_in(write_pointer_out_0),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_1),
	.new_branch_metric_01(new_branch_metric_01_1),
	.new_branch_metric_10(new_branch_metric_10_1),
	.new_branch_metric_11(new_branch_metric_11_1),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_1),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_1),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_1),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_1),
	.write_pointer_out(write_pointer_out_1),
	.valid_out(valid_out_1)
);

pmps third_pmps_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_5),
	.branch_metric_00(new_branch_metric_00_1),
	.branch_metric_01(new_branch_metric_01_1),
	.branch_metric_10(new_branch_metric_10_1),
	.branch_metric_11(new_branch_metric_11_1),
	.valid_in(valid_out_1),
	.selected_branch_at_00(updated_selected_branch_at_00_1),
	.selected_branch_at_01(updated_selected_branch_at_01_1),
	.selected_branch_at_10(updated_selected_branch_at_10_1),
	.selected_branch_at_11(updated_selected_branch_at_11_1),
	.write_pointer_in(write_pointer_out_1),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_2),
	.new_branch_metric_01(new_branch_metric_01_2),
	.new_branch_metric_10(new_branch_metric_10_2),
	.new_branch_metric_11(new_branch_metric_11_2),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_2),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_2),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_2),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_2),
	.write_pointer_out(write_pointer_out_2),
	.valid_out(valid_out_2)
);

pmps fourth_pmps_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_6),
	.branch_metric_00(new_branch_metric_00_2),
	.branch_metric_01(new_branch_metric_01_2),
	.branch_metric_10(new_branch_metric_10_2),
	.branch_metric_11(new_branch_metric_11_2),
	.valid_in(valid_out_2),
	.selected_branch_at_00(updated_selected_branch_at_00_2),
	.selected_branch_at_01(updated_selected_branch_at_01_2),
	.selected_branch_at_10(updated_selected_branch_at_10_2),
	.selected_branch_at_11(updated_selected_branch_at_11_2),
	.write_pointer_in(write_pointer_out_2),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_3),
	.new_branch_metric_01(new_branch_metric_01_3),
	.new_branch_metric_10(new_branch_metric_10_3),
	.new_branch_metric_11(new_branch_metric_11_3),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_3),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_3),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_3),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_3),
	.write_pointer_out(write_pointer_out_3),
	.valid_out(valid_out_3)
);

pmps fifth_pmps_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_7),
	.branch_metric_00(new_branch_metric_00_3),
	.branch_metric_01(new_branch_metric_01_3),
	.branch_metric_10(new_branch_metric_10_3),
	.branch_metric_11(new_branch_metric_11_3),
	.valid_in(valid_out_3),
	.selected_branch_at_00(updated_selected_branch_at_00_3),
	.selected_branch_at_01(updated_selected_branch_at_01_3),
	.selected_branch_at_10(updated_selected_branch_at_10_3),
	.selected_branch_at_11(updated_selected_branch_at_11_3),
	.write_pointer_in(write_pointer_out_3),
	//Outputs
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