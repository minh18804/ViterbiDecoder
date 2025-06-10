// Input buffer module to receive and store 16 bits of input data
module input_buffer (
    input wire in_clk,           // Input clock for receiving data
    input wire sys_clk,          // System clock for outputting data
    input wire reset,            // Reset signal
    input wire [1:0] data_in,    // 2-bit input data
    input wire data_valid,       // Input data valid signalS
    output reg [15:0] data_out,  // 16-bit output data (8 pairs)
    output reg data_ready        // Indicates when data is ready to be processed
);

    // Buffer to store 8 pairs of inputs (16 bits total)
    reg [15:0] buffer;
    reg [2:0] write_ptr;         // Points to next write position (0-7)
    reg buffer_full;             // Indicates when buffer has 8 pairs
    reg reading_enabled;         // Controls when to start reading

    // Write process - on input clock domain
    always @(posedge in_clk or posedge reset) begin
        if (reset) 
		begin
            write_ptr <= 3'd0;
            buffer <= 16'd0;
            buffer_full <= 1'b0;
            reading_enabled <= 1'b0;
            data_ready <= 1'b0;
            data_out <= 16'd0;
        end 
		else if (data_valid && !buffer_full) 
		begin
            // Store new data at current write position
            buffer[write_ptr*2 +: 2] <= data_in;
            
            if (write_ptr == 3'd7) begin
                write_ptr <= 3'd0;
                buffer_full <= 1'b1;
                data_out <= buffer;  // Transfer complete buffer to output
                data_ready <= 1'b1;  // Signal data is ready
            end 
			else 
			begin
                write_ptr <= write_ptr + 1;
            end
        end 
		else if (buffer_full) 
		begin
            // Reset buffer_full after one clock cycle to allow new data
            buffer_full <= 1'b0;
            data_ready <= 1'b0;
        end
    end

endmodule

// Branch metric unit
module bmu (
   // outputs
   output [1:0] bm0, bm1, bm2, bm3, bm4, bm5, bm6, bm7,

   // inputs
   input [15:0] data_in,  // 16-bit input data (8 pairs)
   input clk, reset
);

   // registers
   reg [1:0] bm0, bm1, bm2, bm3, bm4, bm5, bm6, bm7;
   
   // Extract individual pairs from data_in
   wire [1:0] cx0 = data_in[1:0];
   wire [1:0] cx1 = data_in[3:2];
   wire [1:0] cx2 = data_in[5:4];
   wire [1:0] cx3 = data_in[7:6];
   wire [1:0] cx4 = data_in[9:8];
   wire [1:0] cx5 = data_in[11:10];
   wire [1:0] cx6 = data_in[13:12];
   wire [1:0] cx7 = data_in[15:14];

   always@ (posedge clk)
     begin
        if (reset)
          begin
            bm0 <= 2'd0;
            bm1 <= 2'd0;
            bm2 <= 2'd0;
            bm3 <= 2'd0;
            bm4 <= 2'd0;
            bm5 <= 2'd0;
            bm6 <= 2'd0;
            bm7 <= 2'd0;
          end
        else
          begin
            // Process first pair (cx0)
            case ({cx0[1], cx0[0]})
              2'b00: begin
                bm0 <= 2'd0; // this is going from 00 to 00
                bm1 <= 2'd2; // this is going from 00 to 10
                bm2 <= 2'd2; // this is going from 01 to 00
                bm3 <= 2'd0; // this is going from 01 to 10
                bm4 <= 2'd1; // this is going from 10 to 01
                bm5 <= 2'd1; // this is going from 10 to 11
                bm6 <= 2'd1; // this is going from 11 to 01
                bm7 <= 2'd1; // this is going from 11 to 11
              end
              2'b01: begin
                bm0 <= 2'd1; // this is going from 00 to 00
                bm1 <= 2'd1; // this is going from 00 to 10
                bm2 <= 2'd1; // this is going from 01 to 00
                bm3 <= 2'd1; // this is going from 01 to 10
                bm4 <= 2'd2; // this is going from 10 to 01
                bm5 <= 2'd0; // this is going from 10 to 11
                bm6 <= 2'd0; // this is going from 11 to 01
                bm7 <= 2'd2; // this is going from 11 to 11
              end
              2'b10: begin
                bm0 <= 2'd1; // this is going from 00 to 00
                bm1 <= 2'd1; // this is going from 00 to 10
                bm2 <= 2'd1; // this is going from 01 to 00
                bm3 <= 2'd1; // this is going from 01 to 10
                bm4 <= 2'd0; // this is going from 10 to 01
                bm5 <= 2'd2; // this is going from 10 to 11
                bm6 <= 2'd2; // this is going from 11 to 01
                bm7 <= 2'd0; // this is going from 11 to 11
              end
              2'b11: begin
                bm0 <= 2'd2; // this is going from 00 to 00
                bm1 <= 2'd0; // this is going from 00 to 10
                bm2 <= 2'd0; // this is going from 01 to 00
                bm3 <= 2'd2; // this is going from 01 to 10
                bm4 <= 2'd1; // this is going from 10 to 01
                bm5 <= 2'd1; // this is going from 10 to 11
                bm6 <= 2'd1; // this is going from 11 to 01
                bm7 <= 2'd1; // this is going from 11 to 11
              end
            endcase
          end
     end
endmodule

/**
 * This is written by Zhiyang Ong 
 * and Andrew Mattheisen 
 */
module add_compare_select (npm, d, pm1, bm1, pm2, bm2);
	/**
	 * WARNING TO DEVELOPER(S)!!!
	 *
	 * CHECK/VERIFY THAT THE WIDTH OF ALL THE PATH METRIC BUSES
	 * ARE THE SAME
	 *
	 * SUCH BUSES INCLUDE npm, pm1, pm2, add1, and add2
	 *
	 * THE FOLLOWING BUSES ARE NOT INCLUDED: bm1, bm2, add_temp1,
	 * and add_temp2
	 *
	 * NOTE THAT THE WIDTHS OF add_temp1 AND add_temp2 ARE ONE GREATER
	 * THAN THOSE OF THE PATH METRIC BUSES
	 */


	
	// Output signals for the design module
	/**
	 * New path metric - It keeps growing, so reasonable number
	 * of bits have to be chosen so that npm is unlikely to overflow
	 * Number of bits chosen = 4
	 *
	 * To handle overflows, I have decided to saturate the result
	 * of the computation at 2^n - 1 = 2^4 - 1 = 15
	 */
	output [3:0] npm;
	// Decision bit from the add-compare-select unit
	output d;
	
	
	// Input signals for the design module
	// Current path metric #1 for a set of addition
	input [3:0] pm1;
	// Branch metric #1 for a set of addition
	input [1:0] bm1;
	// Current path metric #2 for another set of addition
	input [3:0] pm2;
	// Branch metric #2 for another set of addition
	input [1:0] bm2;
	
	// Declare "reg" signals... that will be assigned values
	reg [3:0] npm;
	reg d;
	/**
	 * Result of the additions in the first stage of the
	 * add-compare-select unit
	 */
	// Result of a set of addition
	reg [3:0] add1;
	// Result of another set of addition
	reg [3:0] add2;
	// Temporary storage for a set of addition to check for overflow
	reg [4:0] add_temp1;
	// Temporary storage for another set of addition to check for overflow
	reg [4:0] add_temp2;



	
	// Declare "wire" signals...
	// Defining constants: parameter [name_of_constant] = value;
	// Maximum value that can be stored in a 4-bit bus
	parameter max_add = 4'd15;


	/**
	 * Perform the addition stage of the add-compare-select unit
	 * Result of a set of addition
	 */
	always @ (pm1 or bm1)
	begin
		// Add the operands and temporary store them
		add_temp1 = pm1 + bm1;
		// Did the (temporary) addition cause an overflow
		if(add_temp1 > max_add)
		begin
			/**
			 * Yes... An overflow has occurred.
			 * Saturate the addition to max_add
			 */
			add1 = max_add;
		end
		else
		begin
			/**
			 * An overflow did not occur with the addition of 2
			 * numbers. Hence, the result of the addition is the
			 * sum of the 2 numbers.
			 */
			add1 = pm1 + bm1;
		end
	end
	
	/**
	 * Perform the addition stage of the add-compare-select unit
	 * Result of another set of addition
	 */
	always @ (pm2 or bm2)
	begin
		// Add the operands and temporary store them
		add_temp2 = pm2 + bm2;
		// Did the (temporary) addition cause an overflow
		if(add_temp2 > max_add)
		begin
			/**
			 * Yes... An overflow has occurred.
			 * Saturate the addition to max_add
			 */
			add2 = max_add;
		end
		else
		begin
			/**
			 * An overflow did not occur with the addition of 2
			 * numbers. Hence, the result of the addition is the
			 * sum of the 2 numbers.
			 */
			add2 = pm2 + bm2;
		end
	end
	
	// ========================================================
	
	// Perform the compare stage of the add-compare-select unit
	always @ (add1 or add2)
	begin
		if(add1 <= add2)
		begin
			// Select path 1 ==> d=0
			d = 1'b0;
		end
		else
		begin
			// Select path 2 ==> d=1
			d = 1'b1;
		end
	end
	
	// ========================================================
	
	// Perform the select stage of the add-compare-select unit
	always @ (d or add1 or add2)
	begin
		if(d)
		begin
			// Select path 2... add1 < add2
			npm = add2;
		end
		else
		begin
			// Select path 1... add1 >= add2
			npm = add1;
		end
	end
	
	
	
endmodule

//survivor path decision unit
module spdu (in0, in1, in2, in3, d0, d1, d2, d3,
    	       out0, out1, out2, out3, clk, reset);

   // outputs
   output  	out0, out1, out2, out3;
   
   // inputs
   input  	in0, in1, in2, in3;
   input 	d0, d1, d2, d3; 
   input 	clk, reset;
   
   // registers
   reg   	w0, w1, w2, w3;
   reg		out0, out1, out2, out3;

   always @ (d0 or d1 or d2 or d3 or in0 or in1 or in2 or in3)
	 begin
		w0  <= d0?in1:in0; // select 0 or 1
		w1  <= d1?in3:in2; // select 2 or 3
		w2  <= d2?in1:in0; // select 0 or 1
		w3  <= d3?in3:in2; // select 2 or 3
	 end // always @ (d0 or d1 or d2 or d3 or in0 or in1 or in2 or in3)


   always @ (posedge clk)
	 begin
		if (reset)
		  begin
		    out0 <= 1'b0;
		    out1 <= 1'b0;
		    out2 <= 1'b0;
		    out3 <= 1'b0;
		  end
		else
		  begin
		    out0 <= w0;
		    out1 <= w1;
		    out2 <= w2;
		    out3 <= w3;
		  end
	 end // always @ (posedge clk)


endmodule

// Design of the Viterbi decoder
module viterbi_decoder (d, data_in, data_valid, in_clk, sys_clk, reset);
	// Output signals for the design module
	// Decoded output signal from the Viterbi decoder
	output d;
	
	// Input signals for the design module
	// Input data (2 bits) and valid signal
	input [1:0] data_in;
	input data_valid;
	// Input clock for receiving data
	input in_clk;
	// System clock for processing
	input sys_clk;
	// Reset signal for the Viterbi decoder
	input reset;
	
	// Internal wires
	wire [15:0] buffered_data;
	wire buffer_full;
	
	// Set of branch metric outputs from the BMU
	wire [1:0] brch_met0,brch_met1,brch_met2,brch_met3;
	wire [1:0] brch_met4,brch_met5,brch_met6,brch_met7;
	
	// Outputs from the ACS units
	// Decision bit output from the ACS units
	wire d0,d1,d2,d3;
	// Output from the ACS that indicates the new path metric
	wire [3:0] n_pm0,n_pm1,n_pm2,n_pm3;
	
	// Outputs from the PMSM units
	wire [3:0] p_m0, p_m1, p_m2, p_m3;
	
	// Input buffer instantiation
	input_buffer input_buf (
		.in_clk(in_clk),
		.sys_clk(sys_clk),
		.reset(reset),
		.data_in(data_in),
		.data_valid(data_valid),
		.data_out(buffered_data),
		.data_ready(buffer_full)
	);
	
	// BMU instantiation with buffered data
	bmu brch_met (
		.data_in(buffered_data),
		.bm0(brch_met0),
		.bm1(brch_met1),
		.bm2(brch_met2),
		.bm3(brch_met3),
		.bm4(brch_met4),
		.bm5(brch_met5),
		.bm6(brch_met6),
		.bm7(brch_met7),
		.clk(sys_clk),
		.reset(reset)
	);
	
	// Rest of the Viterbi decoder implementation
	// =====================================================
	
	// Instantiate the 4 ACS units
	add_compare_select acs0 (n_pm0, d0,
		p_m0, brch_met0, p_m1, brch_met2);
	add_compare_select acs1 (n_pm1, d1,
		p_m2, brch_met4, p_m3, brch_met6);
	add_compare_select acs2 (n_pm2, d2,
		p_m0, brch_met1, p_m1, brch_met3);
	add_compare_select acs3 (n_pm3, d3,
		p_m2, brch_met5, p_m3, brch_met7);
		
	// =====================================================
	
	// PMSM instantiation
	pmsm path_metric_sm (n_pm0, n_pm1, n_pm2, n_pm3,
		p_m0, p_m1, p_m2, p_m3, sys_clk, reset);
	
	// =====================================================
	
	// SPD instantiation
	spd survivor_path_dec (d0, d1, d2, d3, p_m0, p_m1, p_m2, p_m3,
		d, sys_clk, reset);
	
endmodule

/// pmsm module (Path Metric State Memory)

module pmsm (npm0, npm1, npm2, npm3, pm0, pm1, pm2, pm3, clk, reset);

   // outputs
   output [3:0] pm0, pm1, pm2, pm3;

   // inputs
   input  	clk, reset;
   input [3:0] 	npm0, npm1, npm2, npm3;

   reg [3:0] 	pm0, pm1, pm2, pm3;
   reg [3:0] 	npm0norm, npm1norm, npm2norm, npm3norm;
   
   // Defining constants: parameter [name_of_constant] = value;
   parameter saturating_value = 4'd15;
   
   always @ (npm0 or npm1 or npm2 or npm3)
	 begin
	   if ((npm0 <= npm1)&&(npm0 <= npm2)&&(npm0 <= npm3))
	     begin
	       npm0norm <= 0;
	       npm1norm <= npm1-npm0;
	       npm2norm <= npm2-npm0;
	       npm3norm <= npm3-npm0;
	     end
	   else if ((npm1 <= npm0)&&(npm1 <= npm2)&&(npm1 <= npm3))
	     begin
	       npm0norm <= npm0-npm1;
	       npm1norm <= 0;
	       npm2norm <= npm2-npm1;
	       npm3norm <= npm3-npm1;
	     end
	   else if ((npm2 <= npm0)&&(npm2 <= npm1)&&(npm2 <= npm3))
	     begin
	       npm0norm <= npm0-npm2;
	       npm1norm <= npm1-npm2;
	       npm2norm <= 0;
	       npm3norm <= npm3-npm2;
	     end
	   else if ((npm3 <= npm0)&&(npm3 <= npm1)&&(npm3 <= npm2))
	     begin
	       npm0norm <= npm0-npm3;
	       npm1norm <= npm1-npm3;
	       npm2norm <= npm2-npm3;
	       npm3norm <= 0;
	     end
	 end // always @ (npm0 or npm1 or npm2 or npm3)


	/**
	 * @modified by Zhiyang Ong, November 1, 2007
	 * Note that the first register is reset to zero,
	 * and the rest are reset to infinity, which is
	 * represented by the saturating value of 15
	 * = 2^n - 1 = 2^4 - 1.
	 *
	 * This prevents the solution from arriving at a
	 * set of false/incorrect set of equivalent
	 * paths in the Trellis diagram. Multiple paths
	 * with zero costs indicate no unique solution.
	 * Also, these infinite/saturated values will be
	 * "removed"/diminished in 2 clock cycles.
	 */
   always @ (posedge clk)
	 begin
		if (reset)
		  begin
		    pm0 <= 4'd0;
		    pm1 <= saturating_value;
		    pm2 <= saturating_value;
		    pm3 <= saturating_value;
		  end
		else
		  begin
		    pm0 <= npm0norm;
		    pm1 <= npm1norm;
		    pm2 <= npm2norm;
		    pm3 <= npm3norm;
		  end
	 end // always @ (posedge clk)
endmodule

/*
 spdu module
*/

module spdu (in0, in1, in2, in3, d0, d1, d2, d3,
    	       out0, out1, out2, out3, clk, reset);

   // outputs
   output  	out0, out1, out2, out3;
   
   // inputs
   input  	in0, in1, in2, in3;
   input 	d0, d1, d2, d3; 
   input 	clk, reset;
   
   // registers
   reg   	w0, w1, w2, w3;
   reg		out0, out1, out2, out3;

   always @ (d0 or d1 or d2 or d3 or in0 or in1 or in2 or in3)
	 begin
		w0  <= d0?in1:in0; // select 0 or 1
		w1  <= d1?in3:in2; // select 2 or 3
		w2  <= d2?in1:in0; // select 0 or 1
		w3  <= d3?in3:in2; // select 2 or 3
	 end // always @ (d0 or d1 or d2 or d3 or in0 or in1 or in2 or in3)


   always @ (posedge clk)
	 begin
		if (reset)
		  begin
		    out0 <= 1'b0;
		    out1 <= 1'b0;
		    out2 <= 1'b0;
		    out3 <= 1'b0;
		  end
		else
		  begin
		    out0 <= w0;
		    out1 <= w1;
		    out2 <= w2;
		    out3 <= w3;
		  end
	 end // always @ (posedge clk)


endmodule

/*
 Andrew Mattheisen 
 Zhiyang Ong 

 EE-577b 2007 fall
 VITERBI DECODER 
 spd module
 
 @modified by Zhiyang Ong on November 1, 2007
 The output out signal must be of the data type reg
 I had to reallocate this data-type reg.
 Correction: It is relabelled to the wire data type since
 it is not used again, or explicitly assigned a value in
 this module
*/
/*
 Andrew Mattheisen 
 Zhiyang Ong 

 EE-577b 2007 fall
 VITERBI DECODER 
 selector module
*/

module selector (pm0, pm1, pm2, pm3, d0, d1);

   // outputs
   output  	d0, d1;
   
   // inputs
   input [3:0] 	pm0, pm1, pm2, pm3;
   
   // registers
   reg   	d0, d1;
   reg [1:0]	int0, int1;
   reg [3:0]	pm_int0, pm_int1;

   always @ (pm0 or pm1 or pm2 or pm3)
	 begin
		int0 = (pm0<=pm1)?2'd0:2'd1; // select smaller of pm0 or pm1 
		int1 = (pm2<=pm3)?2'd2:2'd3; // select smaller of pm2 or pm3
		pm_int0 = (pm0<=pm1)?pm0:pm1; // select smaller of pm0 or pm1
		pm_int1 = (pm2<=pm3)?pm2:pm3; // select smaller of pm2 or pm3
		{d1,d0} = (pm_int0<=pm_int1)?int0:int1; // create control signals d0 and d1
	 end // always @ (pm0 or pm1 or pm2 or pm3)


endmodule


/*
 Andrew Mattheisen 
 Zhiyang Ong 

 EE-577b 2007 fall
 VITERBI DECODER 
 2-4demux module used in spdu module
*/

module demux (in0, in1, in2, in3, d0, d1, out);

   // outputs
   output  	out;
   
   // inputs
   input  	in0, in1, in2, in3;
   input 	d0, d1; 
   
   // registers
   reg temp1, temp2, out;
   
   always@(in0 or in1 or in2 or in3 or d0 or d1)
     begin
       temp1 = d0?in1:in0;
       temp2 = d0?in3:in2;
       out =  d1?temp2:temp1;     
     end // always@(in0 or in1 or in2 or in3 or d0 or d1)

endmodule

module spd (d0, d1, d2, d3, pm0, pm1, pm2, pm3, out, clk, reset);

   // outputs
   output  	out;
   
   // inputs
   input 	d0, d1, d2, d3;
   input [3:0]	pm0, pm1, pm2, pm3; 
   input 	clk, reset;
   
	// @modified by Zhiyang Ong on November 1, 2007
	// Registers...
//	reg out;
/*
	reg selectord0, selectord1;
	reg spdu0out0, spdu0out1, spdu0out2, spdu0out3;
	reg spdu1out0, spdu1out1, spdu1out2, spdu1out3;
	reg spdu2out0, spdu2out1, spdu2out2, spdu2out3;
	reg spdu3out0, spdu3out1, spdu3out2, spdu3out3;
	reg spdu4out0, spdu4out1, spdu4out2, spdu4out3;
	reg spdu5out0, spdu5out1, spdu5out2, spdu5out3;
	reg spdu6out0, spdu6out1, spdu6out2, spdu6out3;
	reg spdu7out0, spdu7out1, spdu7out2, spdu7out3;
	reg spdu8out0, spdu8out1, spdu8out2, spdu8out3;
	reg spdu9out0, spdu9out1, spdu9out2, spdu9out3;
	reg spdu10out0, spdu10out1, spdu10out2, spdu10out3;
	reg spdu11out0, spdu11out1, spdu11out2, spdu11out3;
	reg spdu12out0, spdu12out1, spdu12out2, spdu12out3;
	reg spdu13out0, spdu13out1, spdu13out2, spdu13out3;
	reg spdu14out0, spdu14out1, spdu14out2, spdu14out3;
*/



   // wires
   // @Modified by Zhiyang Ong on November 1, 2007
   wire out;
   
   wire 	selectord0, selectord1;
   wire 	spdu0out0, spdu0out1, spdu0out2, spdu0out3;
   wire 	spdu1out0, spdu1out1, spdu1out2, spdu1out3;
   wire 	spdu2out0, spdu2out1, spdu2out2, spdu2out3;
   wire 	spdu3out0, spdu3out1, spdu3out2, spdu3out3;
   wire 	spdu4out0, spdu4out1, spdu4out2, spdu4out3;
   wire 	spdu5out0, spdu5out1, spdu5out2, spdu5out3;
   wire 	spdu6out0, spdu6out1, spdu6out2, spdu6out3;
   wire 	spdu7out0, spdu7out1, spdu7out2, spdu7out3;
   wire 	spdu8out0, spdu8out1, spdu8out2, spdu8out3;
   wire 	spdu9out0, spdu9out1, spdu9out2, spdu9out3;
   wire 	spdu10out0, spdu10out1, spdu10out2, spdu10out3;
   wire 	spdu11out0, spdu11out1, spdu11out2, spdu11out3;
   wire 	spdu12out0, spdu12out1, spdu12out2, spdu12out3;
   wire 	spdu13out0, spdu13out1, spdu13out2, spdu13out3;
   wire 	spdu14out0, spdu14out1, spdu14out2, spdu14out3;

   spdu spdu0(1'b0, 
   	      1'b0, 
   	      1'b1, 
   	      1'b1, d0, d1, d2, d3,
    	spdu0out0, 
    	spdu0out1, 
    	spdu0out2, 
    	spdu0out3, clk, reset);

   spdu spdu1(spdu0out0, 
   	      spdu0out1, 
   	      spdu0out2, 
   	      spdu0out3, d0, d1, d2, d3,
    	spdu1out0, 
    	spdu1out1, 
    	spdu1out2, 
    	spdu1out3, clk, reset);

   spdu spdu2(spdu1out0, 
   	      spdu1out1, 
   	      spdu1out2, 
   	      spdu1out3, d0, d1, d2, d3,
    	spdu2out0, 
    	spdu2out1, 
    	spdu2out2, 
    	spdu2out3, clk, reset);

   spdu spdu3(spdu2out0, 
   	      spdu2out1, 
   	      spdu2out2, 
   	      spdu2out3, d0, d1, d2, d3,
    	spdu3out0, 
    	spdu3out1, 
    	spdu3out2, 
    	spdu3out3, clk, reset);

   spdu spdu4(spdu3out0, 
   	      spdu3out1, 
   	      spdu3out2, 
   	      spdu3out3, d0, d1, d2, d3,
    	spdu4out0, 
    	spdu4out1, 
    	spdu4out2, 
    	spdu4out3, clk, reset);

   spdu spdu5(spdu4out0, 
   	      spdu4out1, 
   	      spdu4out2, 
   	      spdu4out3, d0, d1, d2, d3,
    	spdu5out0, 
    	spdu5out1, 
    	spdu5out2, 
    	spdu5out3, clk, reset);

   spdu spdu6(spdu5out0, 
   	      spdu5out1, 
   	      spdu5out2, 
   	      spdu5out3, d0, d1, d2, d3,
    	spdu6out0, 
    	spdu6out1, 
    	spdu6out2, 
    	spdu6out3, clk, reset);

   spdu spdu7(spdu6out0, 
   	      spdu6out1, 
   	      spdu6out2, 
   	      spdu6out3, d0, d1, d2, d3,
    	spdu7out0, 
    	spdu7out1, 
    	spdu7out2, 
    	spdu7out3, clk, reset);

   spdu spdu8(spdu7out0, 
   	      spdu7out1, 
   	      spdu7out2, 
   	      spdu7out3, d0, d1, d2, d3,
    	spdu8out0, 
    	spdu8out1, 
    	spdu8out2, 
    	spdu8out3, clk, reset);

   spdu spdu9(spdu8out0, 
   	      spdu8out1, 
   	      spdu8out2, 
   	      spdu8out3, d0, d1, d2, d3,
    	spdu9out0, 
    	spdu9out1, 
    	spdu9out2, 
    	spdu9out3, clk, reset);

   spdu spdu10(spdu9out0, 
   	       spdu9out1, 
   	       spdu9out2, 
   	       spdu9out3, d0, d1, d2, d3,
    	spdu10out0, 
    	spdu10out1, 
    	spdu10out2, 
    	spdu10out3, clk, reset);

   spdu spdu11(spdu10out0, 
   	       spdu10out1, 
   	       spdu10out2, 
   	       spdu10out3, d0, d1, d2, d3,
    	spdu11out0, 
    	spdu11out1, 
    	spdu11out2, 
    	spdu11out3, clk, reset);

   spdu spdu12(spdu11out0, 
   	       spdu11out1, 
   	       spdu11out2, 
   	       spdu11out3, d0, d1, d2, d3,
    	spdu12out0, 
    	spdu12out1, 
    	spdu12out2, 
    	spdu12out3, clk, reset);

   spdu spdu13(spdu12out0, 
   	       spdu12out1, 
   	       spdu12out2, 
   	       spdu12out3, d0, d1, d2, d3,
    	spdu13out0, 
    	spdu13out1, 
    	spdu13out2, 
    	spdu13out3, clk, reset);

   spdu spdu14(spdu13out0, 
   	       spdu13out1, 
   	       spdu13out2, 
   	       spdu13out3, d0, d1, d2, d3,
    	spdu14out0, 
    	spdu14out1, 
    	spdu14out2, 
    	spdu14out3, clk, reset);



   selector selector1 (pm0, pm1, pm2, pm3, selectord0, selectord1);

   demux demux1 (spdu14out0, spdu14out1, spdu14out2, spdu14out3,
	         selectord0, selectord1, out);

endmodule



//`timescale 1ns/10ps

//module pmsmtb;
//    reg [3:0]	npm0, npm1, npm2, npm3;
//    reg 	clk, reset;
//    wire [3:0] 	pm0, pm1, pm2, pm3;

//    pmsm pmsm1(npm0, npm1, npm2, npm3, pm0, pm1, pm2, pm3, clk, reset);

//    initial
//        begin
//            npm0=4'd0; npm1=4'd1; npm2=4'd2; npm3=4'd3; 
//            clk=1'b0; reset=1'b0;
//            #10;
//            clk=1'b1; reset=1'b0; // posedge clk
//	    #10;
//            clk=1'b0; reset=1'b1;
//	    #10;
//            clk=1'b1; reset=1'b1; // posedge clk
//	    #10;
//            clk=1'b0; reset=1'b0;
//	    #10;
//            clk=1'b1; reset=1'b0; // posedge clk
//	    #10;
//	    npm0=4'd2; npm1=4'd3; npm2=4'd5; npm3=4'd9; 
//            clk=1'b0; reset=1'b0;
//	    #10;
//            clk=1'b1; reset=1'b0; // posedge clk
//            #10;
//	    npm0=4'd5; npm1=4'd1; npm2=4'd15; npm3=4'd3; 
//            clk=1'b0; reset=1'b0;
//	    #10;
//            clk=1'b1; reset=1'b0; // posedge clk
//            #10;
//        end
//initial
//    begin
//	$shm_open("pmsm.shm");
//	$shm_probe("AC");	
//    end
//endmodule


`timescale 1ns/10ps

module spdutb;
    reg 	d0, d1, d2, d3;
    reg [3:0]	pm0, pm1, pm2, pm3;
    reg 	clk, reset;
    wire 	out;

    spd spd1(d0, d1, d2, d3, pm0, pm1, pm2, pm3, out, clk, reset);
    
    always #5 clk = ~clk;
    
    initial #330 $finish;
    
    initial
        begin
            clk=0;
	    pm0=4'd1; pm1=4'd1; pm2=4'd0; pm3=4'd1;
            d0=1'b0; d1=1'b1; d2=1'b0; d3=1'b1; 
	    reset=1'b1;
	    #10;
	    reset=1'b0;
	    #10;

        end
        
initial
    begin
	$shm_open("spdu.shm");
	$shm_probe("AC");	
    end
endmodule

//// testbench_viterbi_decoder_new.v
//`timescale 1ns / 1ps // Định nghĩa đơn vị thời gian cho mô phỏng

//module testbench_viterbi_decoder_new;

//  // Khai báo các tín hiệu
//  reg clk;         // Tín hiệu đồng hồ
//  reg reset;       // Tín hiệu reset
//  reg [1:0] cx;    // Đầu vào mã hóa (2 bit)
//  wire d;          // Đầu ra giải mã (1 bit)

//  // Khai báo các hằng số
//  parameter CLK_PERIOD = 10; // Chu kỳ clock là 10ns (tương đương 100 MHz)
//  parameter DATA_BITS = 5;   // Số lượng bit dữ liệu gốc (không bao gồm tail bits)
//  parameter TAIL_BITS = 3;   // Số lượng tail bits thêm vào
//  parameter TOTAL_BITS = DATA_BITS + TAIL_BITS; // Tổng số bit đầu vào cho encoder

//  // Mảng chứa chuỗi CX đầu vào đã tính toán (8 cặp bit)
//  reg [1:0] cx_input_sequence [0:TOTAL_BITS-1];

//  // Mảng chứa chuỗi D mong muốn (để so sánh)
//  reg [DATA_BITS-1:0] expected_d_sequence; // Chỉ 5 bit dữ liệu gốc

//  // Biến đếm cho việc truyền dữ liệu
//  integer i;
//  integer decoded_bit_count;

//  // Instantiate (khởi tạo) module viterbi_decoder của bạn
//  viterbi_decoder dut (
//    .d(d),
//    .cx(cx),
//    .clk(clk),
//    .reset(reset)
//  );

//  // Khối khởi tạo chuỗi dữ liệu
//  initial begin
//    // Khởi tạo chuỗi CX đầu vào
//    cx_input_sequence[0] = 2'b11; // 1 (từ chuỗi gốc)
//    cx_input_sequence[1] = 2'b10; // 0
//    cx_input_sequence[2] = 2'b00; // 1
//    cx_input_sequence[3] = 2'b01; // 1
//    cx_input_sequence[4] = 2'b01; // 0
//    cx_input_sequence[5] = 2'b11; // 0 (tail bit)
//    cx_input_sequence[6] = 2'b00; // 0 (tail bit)
//    cx_input_sequence[7] = 2'b00; // 0 (tail bit)

//    // Chuỗi D mong muốn (chỉ 5 bit dữ liệu gốc)
//    expected_d_sequence = 5'b10110;
//  end

//  // Khối tạo tín hiệu đồng hồ (clock generator)
//  initial begin
//    clk = 0; // Khởi tạo clock ở mức thấp
//    forever #(CLK_PERIOD / 2) clk = ~clk; // Chuyển đổi trạng thái mỗi CLK_PERIOD/2
//  end

//  // Khối tạo tín hiệu reset và chuỗi đầu vào
//  initial begin
//    decoded_bit_count = 0;

//    // 1. Giai đoạn Reset ban đầu
//    reset = 1;      // Kích hoạt reset
//    cx = 2'b00;     // Đảm bảo đầu vào ổn định trong quá trình reset
//    # (CLK_PERIOD * 5); // Giữ reset trong 5 chu kỳ clock (đủ dài để ổn định)

//    reset = 0;      // Hủy kích hoạt reset
//    # (CLK_PERIOD * 2); // Đợi 2 chu kỳ clock sau khi hủy reset để bộ giải mã khởi động

//    $display("--- Bắt đầu gửi dữ liệu CX và kiểm tra D ---");

//    // 2. Giai đoạn Gửi dữ liệu CX
//    for (i = 0; i < TOTAL_BITS; i = i + 1) begin
//      cx = cx_input_sequence[i];
//      #CLK_PERIOD; // Đợi 1 chu kỳ clock sau khi áp dụng CX
//      // Tại đây, bạn có thể thêm logic kiểm tra đầu ra 'd' sau một độ trễ
//      // Độ trễ của Viterbi decoder thường là khoảng 5*K đến 7*K bit
//      // Với K=3, độ trễ có thể là 15-21 chu kỳ clock
//      // Chúng ta sẽ kiểm tra sau khi tất cả dữ liệu được đưa vào và bộ giải mã đã ổn định
//    end

//    $display("--- Đã gửi xong dữ liệu CX ---");

//    // 3. Đợi bộ giải mã ổn định và xuất hết dữ liệu (độ trễ giải mã)
//    # (CLK_PERIOD * (7*3)); // Đợi khoảng 7*K chu kỳ clock để giải mã xong

//    $display("--- Bắt đầu kiểm tra đầu ra giải mã D ---");

//    // Kiểm tra đầu ra giải mã d
//    // Vì 'd' là một tín hiệu 1 bit và được xuất ra từng bit, chúng ta cần thu thập nó.
//    // Cách đơn giản nhất là quan sát trên waveform hoặc viết một khối kiểm tra riêng.
//    // Do độ trễ, các bit 'd' sẽ xuất hiện sau một thời gian.

//    // Để kiểm tra tự động, bạn sẽ cần một cơ chế thu thập các bit 'd' và so sánh.
//    // Đây là một cách đơn giản để kiểm tra 5 bit dữ liệu gốc:
//    // Tuy nhiên, việc kiểm tra trực tiếp như vậy hơi phức tạp do độ trễ của decoder.
//    // Cách hiệu quả nhất là nhìn vào waveform và so sánh thủ công, hoặc dùng assertion (SystemVerilog).

//    // Để minh họa, chúng ta sẽ giả định 'd' đã ổn định và xuất ra đúng.
//    // Thực tế, bạn sẽ thu thập các bit 'd' sau độ trễ và lưu vào một reg/queue.
//    // Ví dụ về một kiểm tra đơn giản (giả định 'd' là bit cuối cùng của chuỗi mong muốn):
//    // if (d == expected_d_sequence[0]) begin // Chỉ kiểm tra bit cuối cùng
//    //   $display("Kiem tra bit cuoi: OK");
//    // end else begin
//    //   $display("Kiem tra bit cuoi: FAILED. Expected %b, got %b", expected_d_sequence[0], d);
//    // end

//    $display("--- Kết thúc mô phỏng ---");

//    # (CLK_PERIOD * 5); // Chạy thêm vài chu kỳ cuối cùng
//    $finish;          // Dừng mô phỏng
//  end

//  // Khối giám sát và hiển thị đầu ra
//  initial begin
//    $monitor("Time=%0t, clk=%b, reset=%b, cx=%b, d=%b", $time, clk, reset, cx, d);
//  end

//endmodule