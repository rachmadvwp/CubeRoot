/// Project : Cube Root                                           
/// Author: Rachmad                                               
/// File : cuberoot.v   										  	
/// Description : An self-made architecture for integer cube root 
/// Publication: R. V. W. Putra and T. Adiono, "Optimized Hardware Algorithm for Integer Cube Root Calculation and Its Efficient Architecture," 2015 International Symposium on Intelligent Signal Processing and Communication Systems (ISPACS), Nusa Dua Bali, Indonesia, 2015, pp. 263-267, doi: 10.1109/ISPACS.2015.7432777
//////////////////////////////////////////////////////////////////////

module  cuberoot
		(
			//input
			i_clk,
			i_rst,
			i_data,
			i_vld,
			//
			//output
			o_cuberoot_data,
			o_remainder,
			o_vld
		);
	
	parameter n = 32;
	
	// 	I/O Ports
	input          i_clk;
	input          i_rst;
	input  [n-1:0] i_data;
	input          i_vld;
	output [10:0]  o_cuberoot_data;
	output [n:0]   o_remainder;
	output         o_vld;
	
	// Registers
	reg [2:0]  state;
	reg [2:0]  r_data [0:10];
	reg [n:0]  r_acc;
	reg [n:0]  r_a;
	reg        r_vld;
	reg        r_sign;
	reg [3:0]  index;
	reg [10:0] r_result;
	//
	reg  [1:0] stage;
	reg        r_factor_gen;
	
	// Wires
	wire [1:0]   w_sign;
	wire [n-1:0] w_norm;
	wire [n:0]   w_ext;
	wire [2:0]   w_select;
	wire [n:0]   w_rem;
	wire [n:0]   w_acc;
	wire [n:0]   w_subt;
	wire [n:0]   w_concat;
	wire [n:0]   w_a1, w_a2, w_a3, w_a4, w_a5, w_a2_final;
	wire         w_compare;
	
	// State-0 (2's COMPLMENETS)
	assign w_sign = i_data[n-1] ? 1 : 0;
	assign w_norm = w_sign ? (~(i_data-1)) : i_data;
	assign w_ext  = {1'b0, w_norm};
	
	// State-1
	assign w_select = r_data[index];
	assign w_acc    = {w_rem[n-3:0], w_select};
	//
	assign w_a1 = (r_factor_gen) ? (r_a + 1'b1 ) : 0;
	assign w_a2 = (r_factor_gen) ? (w_a1 << 1  ) : 0;
	assign w_a3 = (r_factor_gen) ? (w_a1 + w_a2) : 0;
	assign w_a4 = (r_factor_gen) ? (w_a3 * r_a ) : 0;
	assign w_a5 = (r_factor_gen) ? (w_a4 + 1'b1) : 0;
	//
	assign w_compare = ((w_a5 <= r_acc) & (r_acc > 0) & (w_a5 > 0)) ? 1 : 0;
	assign w_subt    = w_compare ? w_a5 : 0;
	assign w_rem     = r_acc - w_subt;
	//
	assign w_a2_final = w_compare ? w_a2 : (r_a << 1);
	//
	assign w_concat  = {r_result[9:0], w_compare};
	
	// State-2
	assign o_cuberoot_data = r_sign ? (~r_result)+1 : r_result;
	assign o_vld           = r_vld;
	assign o_remainder     = w_rem;
	
	// Behavior
	always@(posedge i_clk)
	begin
	    if(i_rst)
		    begin
			    state        <= 0;
				index        <= 10;
			    r_sign       <= 0;
				r_data[10]   <= 0;
				r_data[ 9]   <= 0;
				r_data[ 8]   <= 0;
				r_data[ 7]   <= 0;
				r_data[ 6]   <= 0;
				r_data[ 5]   <= 0;
				r_data[ 4]   <= 0;
				r_data[ 3]   <= 0;
				r_data[ 2]   <= 0;
				r_data[ 1]   <= 0;
				r_data[ 0]   <= 0;
			    r_acc        <= 0;
			    r_a          <= 0;
				r_vld        <= 0;
				r_result     <= 0;
			end
		else
		    begin
			    if((state == 0) & i_vld)
				    begin
					    r_sign <= w_sign;
					    r_data[10] <= w_ext[32:30];
					    r_data[ 9] <= w_ext[29:27];
					    r_data[ 8] <= w_ext[26:24];
					    r_data[ 7] <= w_ext[23:21];
					    r_data[ 6] <= w_ext[20:18];
					    r_data[ 5] <= w_ext[17:15];
					    r_data[ 4] <= w_ext[14:12];
					    r_data[ 3] <= w_ext[12: 9];
					    r_data[ 2] <= w_ext[ 8: 6];
					    r_data[ 1] <= w_ext[ 5: 3];
					    r_data[ 0] <= w_ext[ 2: 0];
					    r_vld  <= 0;
						//
				        state  <= 1;
					end
				if(state == 1)
				    begin
					    r_acc <= w_acc;
					    r_a <= w_a2_final;
					    r_result <= w_concat;
						//
					    if(index == 0)
						    state <= 2;
						else
						    index <= index-1;
					end
				if(state == 2)
				    begin
					    r_result <= w_concat;
					    r_vld <= 1;
						index <= n;
					    state <= 0;
					end
			end
	end
	
	always@(posedge i_clk)
	begin
	    if(i_rst)
		    begin
			    stage <= 0;
			    r_factor_gen <= 0;
			end
		else
		    begin
			    if((w_select > 0) & (stage == 0))
				    begin
				        stage <= 1;
				        r_factor_gen <= 1;
				    end
				if((stage == 1) & (index == 0))
				    begin
				        stage <= 2;
				        r_factor_gen <= 1;
				    end
				if((stage == 2) & (i_vld))
				    begin
					    r_factor_gen <= 0;
				        stage <= 0;
					end
			end
	end
	

endmodule
