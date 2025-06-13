`include "selector.v"
`include "input_buffer.v"
`include "bmu.v"
`include "cs.v"
`include "pmu.v"

module viterbi_decoder_top(
	input wire clk,
	input wire rst,
	input wire [15:0] data_in,
	output wire [7:0] data_out
);

//Input_buffer
	wire [1:0] bit_pair_0;
	wire [1:0] bit_pair_1;
	wire [1:0] bit_pair_2;
	wire [1:0] bit_pair_3;
	wire [1:0] bit_pair_4;
	wire [1:0] bit_pair_5;
	wire [1:0] bit_pair_6;
	wire [1:0] bit_pair_7;	
	wire valid_out_input_buffer;

//First_bmu

	wire [1:0] branch_metric_0;
	wire [1:0] branch_metric_1;
	wire valid_out_first_bmu;

//Second_bmu
	wire [3:0] branch_metric_00;
	wire [3:0] branch_metric_01;
	wire [3:0] branch_metric_10;
	wire [3:0] branch_metric_11;
	wire valid_out_second_bmu;

//Third_bmu
	wire [3:0] branch_metric_00_0_3;
	wire [3:0] branch_metric_00_1_3;
	wire [3:0] branch_metric_01_0_3;
	wire [3:0] branch_metric_01_1_3;
	wire [3:0] branch_metric_10_0_3;
	wire [3:0] branch_metric_10_1_3;
	wire [3:0] branch_metric_11_0_3;
	wire [3:0] branch_metric_11_1_3;
	wire valid_out_third_bmu;

//First_cs	
	wire [3:0] new_branch_metric_00_3;
	wire [3:0] new_branch_metric_01_3;
	wire [3:0] new_branch_metric_10_3;
	wire [3:0] new_branch_metric_11_3;
	wire [7:0] selected_branch_at_00_3;
	wire [7:0] selected_branch_at_01_3;
	wire [7:0] selected_branch_at_10_3;
	wire [7:0] selected_branch_at_11_3;
	wire [2:0] write_pointer_out_first_cs;
	wire valid_out_first_cs;

//pmu
	wire [3:0] new_branch_metric_00_4;
	wire [3:0] new_branch_metric_01_4;
	wire [3:0] new_branch_metric_10_4;
	wire [3:0] new_branch_metric_11_4;
	wire [7:0] updated_selected_branch_at_00_4;
	wire [7:0] updated_selected_branch_at_01_4;
	wire [7:0] updated_selected_branch_at_10_4;
	wire [7:0] updated_selected_branch_at_11_4;
	wire [2:0] write_pointer_out_second_pmps;
	wire valid_out_second_pmps;

//Selector
	wire [7:0] selected_branch_at_00;
	wire [7:0] selected_branch_at_01;
	wire [7:0] selected_branch_at_10;
	wire [7:0] selected_branch_at_11;
	wire valid_out_selector;
	wire refresh;

input_buffer input_buffer_inst(
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.data_in(data_in),
	.bit_pair_0(bit_pair_0),
	.bit_pair_1(bit_pair_1),
	.bit_pair_2(bit_pair_2),
	.bit_pair_3(bit_pair_3),
	.bit_pair_4(bit_pair_4),
	.bit_pair_5(bit_pair_5),
	.bit_pair_6(bit_pair_6),
	.bit_pair_7(bit_pair_7),
	.valid_out(valid_out_input_buffer)
);

first_bmu first_bmu_inst(
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_0(bit_pair_0),
	.branch_metric_0(branch_metric_0),
	.branch_metric_1(branch_metric_1),
	.valid_in(valid_out_input_buffer),
	.valid_out(valid_out_first_bmu)
);

second_bmu second_bmu_inst(
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_1(bit_pair_1),
	.branch_metric_0(branch_metric_0),
	.branch_metric_1(branch_metric_1),
	.valid_in(valid_out_first_bmu),
	.branch_metric_00(branch_metric_00),
	.branch_metric_01(branch_metric_01),
	.branch_metric_10(branch_metric_10),
	.branch_metric_11(branch_metric_11),
	.valid_out(valid_out_second_bmu)
);

bmu third_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_2),
	.branch_metric_00(branch_metric_00),
	.branch_metric_01(branch_metric_01),
	.branch_metric_10(branch_metric_10),
	.branch_metric_11(branch_metric_11),
	.valid_in(valid_out_second_bmu),
	//Outputs
	.branch_metric_00_0(branch_metric_00_0_3),
	.branch_metric_00_1(branch_metric_00_1_3),
	.branch_metric_01_0(branch_metric_01_0_3),
	.branch_metric_01_1(branch_metric_01_1_3),
	.branch_metric_10_0(branch_metric_10_0_3),
	.branch_metric_10_1(branch_metric_10_1_3),
	.branch_metric_11_0(branch_metric_11_0_3),
	.branch_metric_11_1(branch_metric_11_1_3),
	.valid_out(valid_out_third_bmu)
);

first_cs first_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_00_0_3),
	.branch_metric_00_1(branch_metric_00_1_3),
	.branch_metric_01_0(branch_metric_01_0_3),
	.branch_metric_01_1(branch_metric_01_1_3),
	.branch_metric_10_0(branch_metric_10_0_3),
	.branch_metric_10_1(branch_metric_10_1_3),
	.branch_metric_11_0(branch_metric_11_0_3),
	.branch_metric_11_1(branch_metric_11_1_3),
	.valid_in(valid_out_third_bmu),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_3),
	.new_branch_metric_01(new_branch_metric_01_3),
	.new_branch_metric_10(new_branch_metric_10_3),
	.new_branch_metric_11(new_branch_metric_11_3),
	.selected_branch_at_00(selected_branch_at_00_3),
	.selected_branch_at_01(selected_branch_at_01_3),
	.selected_branch_at_10(selected_branch_at_10_3),
	.selected_branch_at_11(selected_branch_at_11_3),
	.write_pointer_out(write_pointer_out_first_cs),
	.valid_out(valid_out_first_cs)
);

pmu pmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_3(bit_pair_3),
	.bit_pair_4(bit_pair_4),
	.bit_pair_5(bit_pair_5),
	.bit_pair_6(bit_pair_6),
	.bit_pair_7(bit_pair_7),
	.branch_metric_00(new_branch_metric_00_3),
	.branch_metric_01(new_branch_metric_01_3),
	.branch_metric_10(new_branch_metric_10_3),
	.branch_metric_11(new_branch_metric_11_3),
	.valid_in(valid_out_first_cs),
	.selected_branch_at_00(selected_branch_at_00_3),
	.selected_branch_at_01(selected_branch_at_01_3),
	.selected_branch_at_10(selected_branch_at_10_3),
	.selected_branch_at_11(selected_branch_at_11_3),
	.write_pointer_in(write_pointer_out_first_cs),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_4),
	.new_branch_metric_01(new_branch_metric_01_4),
	.new_branch_metric_10(new_branch_metric_10_4),
	.new_branch_metric_11(new_branch_metric_11_4),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_4),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_4),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_4),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_4),
	.write_pointer_out(write_pointer_out_second_pmps),
	.valid_out(valid_out_second_pmps)
);

selector selector_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_4),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_4),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_4),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_4),
	.new_branch_metric_00(new_branch_metric_00_4),
	.new_branch_metric_01(new_branch_metric_01_4),
	.new_branch_metric_10(new_branch_metric_10_4),
	.new_branch_metric_11(new_branch_metric_11_4),
	.write_pointer_in(write_pointer_out_second_pmps),
	.valid_in(valid_out_second_pmps),
	//Outputs	
	.out(data_out),
	.refresh(refresh)
);
endmodule