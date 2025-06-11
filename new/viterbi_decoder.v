`include "selector.v"
`include "input_buffer.v"
`include "first_bmu.v"
`include "cs.v"

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

//First_bmu
	wire [1:0] branch_metric_0;
	wire [1:0] branch_metric_1;
	wire valid_out_first_bmu;

//Second_bmu
	wire [2:0] branch_metric_00;
	wire [2:0] branch_metric_01;
	wire [2:0] branch_metric_10;
	wire [2:0] branch_metric_11;
	wire valid_out_second_bmu;

//Third_bmu
	wire [3:0] branch_metric_000_3;
	wire [3:0] branch_metric_001_3;
	wire [3:0] branch_metric_010_3;
	wire [3:0] branch_metric_011_3;
	wire [3:0] branch_metric_100_3;
	wire [3:0] branch_metric_101_3;
	wire [3:0] branch_metric_110_3;
	wire [3:0] branch_metric_111_3;
	wire valid_out_third_bmu;

//Fourth_bmu	
	wire [3:0] branch_metric_000_4;
	wire [3:0] branch_metric_001_4;
	wire [3:0] branch_metric_010_4;
	wire [3:0] branch_metric_011_4;
	wire [3:0] branch_metric_100_4;
	wire [3:0] branch_metric_101_4;
	wire [3:0] branch_metric_110_4;
	wire [3:0] branch_metric_111_4;	
	wire valid_out_fourth_bmu;

//Fifth_bmu
	wire [3:0] branch_metric_000_5;
	wire [3:0] branch_metric_001_5;
	wire [3:0] branch_metric_010_5;
	wire [3:0] branch_metric_011_5;
	wire [3:0] branch_metric_100_5;
	wire [3:0] branch_metric_101_5;
	wire [3:0] branch_metric_110_5;
	wire [3:0] branch_metric_111_5;	
	wire valid_out_fifth_bmu;

//Sixth_bmu
	wire [3:0] branch_metric_000_6;
	wire [3:0] branch_metric_001_6;
	wire [3:0] branch_metric_010_6;
	wire [3:0] branch_metric_011_6;
	wire [3:0] branch_metric_100_6;
	wire [3:0] branch_metric_101_6;
	wire [3:0] branch_metric_110_6;
	wire [3:0] branch_metric_111_6;	
	wire valid_out_sixth_bmu;

//Seventh_bmu
	wire [3:0] branch_metric_000_7;
	wire [3:0] branch_metric_001_7;
	wire [3:0] branch_metric_010_7;
	wire [3:0] branch_metric_011_7;
	wire [3:0] branch_metric_100_7;
	wire [3:0] branch_metric_101_7;
	wire [3:0] branch_metric_110_7;
	wire [3:0] branch_metric_111_7;	
	wire valid_out_seventh_bmu;

//Eighth_bmu
	wire [3:0] branch_metric_000_8;
	wire [3:0] branch_metric_001_8;
	wire [3:0] branch_metric_010_8;
	wire [3:0] branch_metric_011_8;
	wire [3:0] branch_metric_100_8;
	wire [3:0] branch_metric_101_8;
	wire [3:0] branch_metric_110_8;
	wire [3:0] branch_metric_111_8;
	wire valid_out_eighth_bmu;

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

//Second_cs
	wire [3:0] new_branch_metric_00_4;
	wire [3:0] new_branch_metric_01_4;
	wire [3:0] new_branch_metric_10_4;
	wire [3:0] new_branch_metric_11_4;
	wire [7:0] updated_selected_branch_at_00_4;
	wire [7:0] updated_selected_branch_at_01_4;
	wire [7:0] updated_selected_branch_at_10_4;
	wire [7:0] updated_selected_branch_at_11_4;
	wire [2:0] write_pointer_out_second_cs;
	wire valid_out_second_cs;

//Third_cs
	wire [3:0] new_branch_metric_00_5;
	wire [3:0] new_branch_metric_01_5;
	wire [3:0] new_branch_metric_10_5;
	wire [3:0] new_branch_metric_11_5;
	wire [7:0] updated_selected_branch_at_00_5;
	wire [7:0] updated_selected_branch_at_01_5;
	wire [7:0] updated_selected_branch_at_10_5;
	wire [7:0] updated_selected_branch_at_11_5;
	wire [2:0] write_pointer_out_third_cs;
	wire valid_out_third_cs;

//Fourth_cs
	wire [3:0] new_branch_metric_00_6;
	wire [3:0] new_branch_metric_01_6;
	wire [3:0] new_branch_metric_10_6;
	wire [3:0] new_branch_metric_11_6;
	wire [7:0] updated_selected_branch_at_00_6;
	wire [7:0] updated_selected_branch_at_01_6;
	wire [7:0] updated_selected_branch_at_10_6;
	wire [7:0] updated_selected_branch_at_11_6;
	wire [2:0] write_pointer_out_fourth_cs;
	wire valid_out_fourth_cs;

//Fifth_cs
	wire [3:0] new_branch_metric_00_7;
	wire [3:0] new_branch_metric_01_7;
	wire [3:0] new_branch_metric_10_7;
	wire [3:0] new_branch_metric_11_7;
	wire [7:0] updated_selected_branch_at_00_7;
	wire [7:0] updated_selected_branch_at_01_7;
	wire [7:0] updated_selected_branch_at_10_7;
	wire [7:0] updated_selected_branch_at_11_7;
	wire [2:0] write_pointer_out_fifth_cs;
	wire valid_out_fifth_cs;

//Sixth_cs
	wire [3:0] new_branch_metric_00_8;
	wire [3:0] new_branch_metric_01_8;
	wire [3:0] new_branch_metric_10_8;
	wire [3:0] new_branch_metric_11_8;
	wire [7:0] updated_selected_branch_at_00_8;
	wire [7:0] updated_selected_branch_at_01_8;
	wire [7:0] updated_selected_branch_at_10_8;
	wire [7:0] updated_selected_branch_at_11_8;
	wire [2:0] write_pointer_out_sixth_cs;
	wire valid_out_sixth_cs;

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
	.bit_pair_7(bit_pair_7)
);

first_bmu first_bmu_inst(
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_0(bit_pair_0),
	.branch_metric_0(branch_metric_0),
	.branch_metric_1(branch_metric_1),
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
	.branch_metric_000(branch_metric_000_3),
	.branch_metric_001(branch_metric_001_3),
	.branch_metric_010(branch_metric_010_3),
	.branch_metric_011(branch_metric_011_3),
	.branch_metric_100(branch_metric_100_3),
	.branch_metric_101(branch_metric_101_3),
	.branch_metric_110(branch_metric_110_3),
	.branch_metric_111(branch_metric_111_3),
	.valid_out(valid_out_third_bmu)
);

first_cs first_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_000_3),
	.branch_metric_00_1(branch_metric_001_3),
	.branch_metric_01_0(branch_metric_010_3),
	.branch_metric_01_1(branch_metric_011_3),
	.branch_metric_10_0(branch_metric_100_3),
	.branch_metric_10_1(branch_metric_101_3),
	.branch_metric_11_0(branch_metric_110_3),
	.branch_metric_11_1(branch_metric_111_3),
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

bmu fourth_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_3),
	.branch_metric_00(new_branch_metric_00_3),
	.branch_metric_01(new_branch_metric_01_3),
	.branch_metric_10(new_branch_metric_10_3),
	.branch_metric_11(new_branch_metric_11_3),
	.valid_in(valid_out_first_cs),
	//Outputs
	.branch_metric_000(branch_metric_000_4),
	.branch_metric_001(branch_metric_001_4),
	.branch_metric_010(branch_metric_010_4),
	.branch_metric_011(branch_metric_011_4),
	.branch_metric_100(branch_metric_100_4),
	.branch_metric_101(branch_metric_101_4),
	.branch_metric_110(branch_metric_110_4),
	.branch_metric_111(branch_metric_111_4),
	.valid_out(valid_out_fourth_bmu)
);

cs second_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_000_4),
	.branch_metric_00_1(branch_metric_001_4),
	.branch_metric_01_0(branch_metric_010_4),
	.branch_metric_01_1(branch_metric_011_4),
	.branch_metric_10_0(branch_metric_100_4),
	.branch_metric_10_1(branch_metric_101_4),
	.branch_metric_11_0(branch_metric_110_4),
	.branch_metric_11_1(branch_metric_111_4),
	.valid_in(valid_out_fourth_bmu),
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
	.write_pointer_out(write_pointer_out_second_cs),
	.valid_out(valid_out_second_cs)
);

bmu fifth_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_4),
	.branch_metric_00(new_branch_metric_00_4),
	.branch_metric_01(new_branch_metric_01_4),
	.branch_metric_10(new_branch_metric_10_4),
	.branch_metric_11(new_branch_metric_11_4),
	.valid_in(valid_out_second_cs),
	//Outputs
	.branch_metric_000(branch_metric_000_5),
	.branch_metric_001(branch_metric_001_5),
	.branch_metric_010(branch_metric_010_5),
	.branch_metric_011(branch_metric_011_5),
	.branch_metric_100(branch_metric_100_5),
	.branch_metric_101(branch_metric_101_5),
	.branch_metric_110(branch_metric_110_5),
	.branch_metric_111(branch_metric_111_5),
	.valid_out(valid_out_fifth_bmu)
);

cs third_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_000_5),
	.branch_metric_00_1(branch_metric_001_5),
	.branch_metric_01_0(branch_metric_010_5),
	.branch_metric_01_1(branch_metric_011_5),
	.branch_metric_10_0(branch_metric_100_5),
	.branch_metric_10_1(branch_metric_101_5),
	.branch_metric_11_0(branch_metric_110_5),
	.branch_metric_11_1(branch_metric_111_5),
	.valid_in(valid_out_fifth_bmu),
	.selected_branch_at_00(updated_selected_branch_at_00_4),
	.selected_branch_at_01(updated_selected_branch_at_01_4),
	.selected_branch_at_10(updated_selected_branch_at_10_4),
	.selected_branch_at_11(updated_selected_branch_at_11_4),
	.write_pointer_in(write_pointer_out_second_cs),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_5),
	.new_branch_metric_01(new_branch_metric_01_5),
	.new_branch_metric_10(new_branch_metric_10_5),
	.new_branch_metric_11(new_branch_metric_11_5),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_5),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_5),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_5),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_5),
	.write_pointer_out(write_pointer_out_third_cs),
	.valid_out(valid_out_third_cs)
);

bmu sixth_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_5),
	.branch_metric_00(new_branch_metric_00_5),
	.branch_metric_01(new_branch_metric_01_5),
	.branch_metric_10(new_branch_metric_10_5),
	.branch_metric_11(new_branch_metric_11_5),
	.valid_in(valid_out_third_cs),
	//Outputs
	.branch_metric_000(branch_metric_000_6),
	.branch_metric_001(branch_metric_001_6),
	.branch_metric_010(branch_metric_010_6),
	.branch_metric_011(branch_metric_011_6),
	.branch_metric_100(branch_metric_100_6),
	.branch_metric_101(branch_metric_101_6),
	.branch_metric_110(branch_metric_110_6),
	.branch_metric_111(branch_metric_111_6),
	.valid_out(valid_out_sixth_bmu)
);

cs fourth_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_000_6),
	.branch_metric_00_1(branch_metric_001_6),
	.branch_metric_01_0(branch_metric_010_6),
	.branch_metric_01_1(branch_metric_011_6),
	.branch_metric_10_0(branch_metric_100_6),
	.branch_metric_10_1(branch_metric_101_6),
	.branch_metric_11_0(branch_metric_110_6),
	.branch_metric_11_1(branch_metric_111_6),
	.valid_in(valid_out_sixth_bmu),
	.selected_branch_at_00(updated_selected_branch_at_00_5),
	.selected_branch_at_01(updated_selected_branch_at_01_5),
	.selected_branch_at_10(updated_selected_branch_at_10_5),
	.selected_branch_at_11(updated_selected_branch_at_11_5),
	.write_pointer_in(write_pointer_out_third_cs),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_6),
	.new_branch_metric_01(new_branch_metric_01_6),
	.new_branch_metric_10(new_branch_metric_10_6),
	.new_branch_metric_11(new_branch_metric_11_6),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_6),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_6),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_6),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_6),
	.write_pointer_out(write_pointer_out_fourth_cs),
	.valid_out(valid_out_fourth_cs)
);

bmu seventh_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_6),
	.branch_metric_00(new_branch_metric_00_6),
	.branch_metric_01(new_branch_metric_01_6),
	.branch_metric_10(new_branch_metric_10_6),
	.branch_metric_11(new_branch_metric_11_6),
	.valid_in(valid_out_fourth_cs),
	//Outputs
	.branch_metric_000(branch_metric_000_7),
	.branch_metric_001(branch_metric_001_7),
	.branch_metric_010(branch_metric_010_7),
	.branch_metric_011(branch_metric_011_7),
	.branch_metric_100(branch_metric_100_7),
	.branch_metric_101(branch_metric_101_7),
	.branch_metric_110(branch_metric_110_7),
	.branch_metric_111(branch_metric_111_7),
	.valid_out(valid_out_seventh_bmu)
);

cs fifth_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.branch_metric_00_0(branch_metric_000_7),
	.branch_metric_00_1(branch_metric_001_7),
	.branch_metric_01_0(branch_metric_010_7),
	.branch_metric_01_1(branch_metric_011_7),
	.branch_metric_10_0(branch_metric_100_7),
	.branch_metric_10_1(branch_metric_101_7),
	.branch_metric_11_0(branch_metric_110_7),
	.branch_metric_11_1(branch_metric_111_7),
	.valid_in(valid_out_seventh_bmu),
	.selected_branch_at_00(updated_selected_branch_at_00_6),
	.selected_branch_at_01(updated_selected_branch_at_01_6),
	.selected_branch_at_10(updated_selected_branch_at_10_6),
	.selected_branch_at_11(updated_selected_branch_at_11_6),
	.write_pointer_in(write_pointer_out_fourth_cs),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_7),
	.new_branch_metric_01(new_branch_metric_01_7),
	.new_branch_metric_10(new_branch_metric_10_7),
	.new_branch_metric_11(new_branch_metric_11_7),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_7),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_7),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_7),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_7),
	.write_pointer_out(write_pointer_out_fifth_cs),
	.valid_out(valid_out_fifth_cs)
);

bmu eighth_bmu_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),
	.bit_pair_input(bit_pair_7),
	.branch_metric_00(new_branch_metric_00_7),
	.branch_metric_01(new_branch_metric_01_7),	
	.branch_metric_10(new_branch_metric_10_7),
	.branch_metric_11(new_branch_metric_11_7),
	.valid_in(valid_out_fifth_cs),
	//Outputs
	.branch_metric_000(branch_metric_000_8),
	.branch_metric_001(branch_metric_001_8),	
	.branch_metric_010(branch_metric_010_8),
	.branch_metric_011(branch_metric_011_8),
	.branch_metric_100(branch_metric_100_8),
	.branch_metric_101(branch_metric_101_8),
	.branch_metric_110(branch_metric_110_8),
	.branch_metric_111(branch_metric_111_8),	
	.valid_out(valid_out_eighth_bmu)
);

cs sixth_cs_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.refresh(refresh),	
	.branch_metric_00_0(branch_metric_000_8),
	.branch_metric_00_1(branch_metric_001_8),
	.branch_metric_01_0(branch_metric_010_8),
	.branch_metric_01_1(branch_metric_011_8),
	.branch_metric_10_0(branch_metric_100_8),
	.branch_metric_10_1(branch_metric_101_8),	
	.branch_metric_11_0(branch_metric_110_8),
	.branch_metric_11_1(branch_metric_111_8),
	.valid_in(valid_out_eighth_bmu),
	.selected_branch_at_00(updated_selected_branch_at_00_7),
	.selected_branch_at_01(updated_selected_branch_at_01_7),
	.selected_branch_at_10(updated_selected_branch_at_10_7),	
	.selected_branch_at_11(updated_selected_branch_at_11_7),
	.write_pointer_in(write_pointer_out_fifth_cs),
	//Outputs
	.new_branch_metric_00(new_branch_metric_00_8),
	.new_branch_metric_01(new_branch_metric_01_8),
	.new_branch_metric_10(new_branch_metric_10_8),
	.new_branch_metric_11(new_branch_metric_11_8),	
	.updated_selected_branch_at_00(updated_selected_branch_at_00_8),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_8),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_8),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_8),
	.write_pointer_out(write_pointer_out_sixth_cs),
	.valid_out(valid_out_sixth_cs)
);
selector selector_inst(
	//Inputs
	.clk(clk),
	.rst(rst),
	.updated_selected_branch_at_00(updated_selected_branch_at_00_8),
	.updated_selected_branch_at_01(updated_selected_branch_at_01_8),
	.updated_selected_branch_at_10(updated_selected_branch_at_10_8),
	.updated_selected_branch_at_11(updated_selected_branch_at_11_8),
	.new_branch_metric_00(new_branch_metric_00_8),
	.new_branch_metric_01(new_branch_metric_01_8),
	.new_branch_metric_10(new_branch_metric_10_8),
	.new_branch_metric_11(new_branch_metric_11_8),
	.write_pointer_in(write_pointer_out_sixth_cs),
	.valid_in(valid_out_sixth_cs),
	//Outputs	
	.out(data_out),
	.refresh(refresh)
);
endmodule