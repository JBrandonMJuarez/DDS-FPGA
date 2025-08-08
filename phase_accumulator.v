module phase_accumulator #(
	parameter		CLK_FREQ	= 5_000_000,
	parameter		ACCUM_LENGTH = 24
)(
	input												clk_in,
	input												rstn_in,
	input								[23:0]		freq_inc_in,
	output	reg	[ACCUM_LENGTH-1:0]		phase_out
);

	localparam integer freq_word = (100 * (2**ACCUM_LENGTH)) / CLK_FREQ;
	
	always @(posedge clk_in, negedge rstn_in)
	begin
		if (!rstn_in)
		begin
			phase_out  <= {ACCUM_LENGTH{1'b0}};
		end
		else
		begin
			phase_out <= phase_out + ((freq_inc_in) * (335));
		end
	end
	
endmodule