module psrand_gen(
	input									clk_in,
	input									clk_in1,
	input									rst_in,
	input				[ 3:0]			mode_in,
	input				[23:0]			seed_in,
	output	reg	[11:0]			psrand_out
);
	
	
	reg	[ 3:0]	mode_d;
	reg	[31:0]	seed0;
	reg	[31:0]	seed1;
	reg	[31:0]	seed2;
	
	always @(posedge clk_in or negedge rst_in)
	begin
		if (!rst_in)
		begin
			mode_d <= 4'b0000;
		end
		else
		begin
			mode_d <= mode_in;
		end
	end

	wire trigger_pulse = (mode_in == 4'b0011) && (mode_d != 4'b0011);
	
	always @(posedge clk_in, negedge rst_in)
	begin
		if (!rst_in)
		begin
			seed0 <= 32'b00000000000000000000000000000000;
			seed1 <= 32'b00000000000000000000000000000000;
			seed2 <= 32'b00000000000000000000000000000000;
		end
		else
		begin
			if(trigger_pulse)
			begin
				seed0[23:0] <= seed_in;
			end
			else
			begin
				seed1 <= seed0 ^ (seed0 << 13);
			   seed2 <= seed1 ^ (seed1 >> 7);
			   seed0 <= seed2 ^ (seed2 << 11);
			end
		end
	end
	
	always @(posedge clk_in, negedge rst_in)
	begin
		if(!rst_in)
		begin
			psrand_out <= 12'b000100001111;
		end
		else
		begin
			if((seed0 & 32'h0000001) == 32'h0000001)
			begin
				psrand_out <= 1000;
			end
			else
			begin
				psrand_out <= 2000;
			end
		end
	end

//	assign psrand_out = ((seed0 & 12'h001) == 12'h001) ? -12'd1000 : 12'd1000;


endmodule