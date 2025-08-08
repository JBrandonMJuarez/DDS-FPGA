module freq_divider(
	input				clk_in,
	input				rst_in,
	output	reg	clk_out
);

	reg [4:0] div_reg = 5'b0000;
	always @(posedge clk_in, negedge rst_in)
	begin
		if (!rst_in)
		begin
			div_reg <= 5'b00000;
			clk_out <= 1'b0;
		end
		else
		begin
			if(div_reg == 5'b00100)   
			begin
				div_reg <= 5'b00000;
            clk_out <= ~clk_out;
         end
			else
			begin
				div_reg <= div_reg + 1'b1;
         end  
		end
	end
	
endmodule