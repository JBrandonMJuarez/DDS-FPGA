module Sin_LUT (
	input									clk_in,
	input			[8:0]					addr_in,
	output reg	[15:0]				LUT_out

);
	reg signed [15:0] LUT_Sin [0:511] /* synthesis ramstyle = M9K */; 
	
	initial
	begin
		$readmemh ("SinLUT.txt", LUT_Sin);
	end
	

	always @ (posedge clk_in)
	begin
		LUT_out <= LUT_Sin[addr_in];
	end

endmodule