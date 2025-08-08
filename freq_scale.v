module freq_scale(
	input			[ 3:0]	f0_in,
	input			[ 3:0]	f1_in,
	input			[ 3:0]	f2_in,
	input			[ 3:0]	f3_in,
	input			[ 3:0]	f4_in,
	input			[ 3:0]	scale0_in,
	input			[ 3:0]	scale1_in,				
	input			[ 3:0]	scale2_in,				
	input			[ 3:0]	scale3_in,				
	input			[ 3:0]	scale4_in,
	output		[23:0]	f0_out,
	output		[23:0]	f1_out,
	output		[23:0]	f2_out,
	output		[23:0]	f3_out,
	output		[23:0]	f4_out
);
	
	assign f0_out =	(scale0_in == 4'b0001) ? f0_in : (scale0_in == 4'b0010) ? f0_in * 11 : (scale0_in == 4'b0100) ? f0_in * 101 : (scale0_in == 4'b1000) ? f0_in * 1001 : 0;
	assign f1_out =	(scale1_in == 4'b0001) ? f1_in : (scale1_in == 4'b0010) ? f1_in * 11 : (scale1_in == 4'b0100) ? f1_in * 101 : (scale1_in == 4'b1000) ? f1_in * 1001 : 0;
	assign f2_out =	(scale2_in == 4'b0001) ? f2_in : (scale2_in == 4'b0010) ? f2_in * 11 : (scale2_in == 4'b0100) ? f2_in * 101 : (scale2_in == 4'b1000) ? f2_in * 1001 : 0;
	assign f3_out =	(scale3_in == 4'b0001) ? f3_in : (scale3_in == 4'b0010) ? f3_in * 11 : (scale3_in == 4'b0100) ? f3_in * 101 : (scale3_in == 4'b1000) ? f3_in * 1001 : 0;
	assign f4_out =	(scale4_in == 4'b0001) ? f4_in : (scale4_in == 4'b0010) ? f4_in * 11 : (scale4_in == 4'b0100) ? f4_in * 101 : (scale4_in == 4'b1000) ? f4_in * 1001 : 0;
	
endmodule