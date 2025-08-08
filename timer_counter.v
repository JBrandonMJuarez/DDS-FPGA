module timer_counter(
	input							clk_in,
	input							rst_in,
	input				[23:0]	f0_in,
	output			[23:0]	counter_out,
	output	reg				pulse_out
);
	reg	[23:0]	pulse_counter;
	
	wire [23:0] period_min = (2**24) / (335*f0_in);

	always @(posedge clk_in, negedge rst_in)
	begin
		if(!rst_in)
		begin
			pulse_counter <= 24'b000000000000000000000000;
			pulse_out <= 1'b0;
		end
		else
		begin
			if(pulse_counter == (period_min))   
			begin
				pulse_counter <= 24'b000000000000000000000000;
            pulse_out <= 1'b1;
         end
			else
			begin
				pulse_counter <= pulse_counter + 1'b1;
				pulse_out <= 1'b0;
         end  
		end
	end
	
	assign	counter_out = pulse_counter[23:0];


endmodule