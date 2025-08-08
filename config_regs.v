module config_regs(
	input					clk_in,
	input					rstn_in,
	input			[7:0]	data_in,
	output		[3:0]	reg0_out,
	output		[3:0]	reg1_out,
	output		[3:0]	reg2_out,
	output		[3:0]	reg3_out,
	output		[3:0]	reg4_out,
	output		[3:0]	reg5_out,
	output		[3:0]	reg6_out,
	output		[3:0]	reg7_out,
	output		[3:0]	reg8_out,
	output		[3:0]	reg9_out,
	output		[3:0]	regA_out,
	output		[3:0]	regB_out,
	output		[3:0]	regC_out,
	output		[3:0]	regD_out,
	output		[3:0]	regE_out,
	output		[3:0]	regF_out
);

	reg	[3:0]	config_regs_n	[0:15];
	
	always @(posedge clk_in, negedge rstn_in)
	begin
		if (!rstn_in)
		begin
			config_regs_n[0] <= 4'b0000;
			config_regs_n[1] <= 4'b0000;
			config_regs_n[2] <= 4'b0000;
			config_regs_n[3] <= 4'b0000;
			config_regs_n[4] <= 4'b0000;
			config_regs_n[5] <= 4'b0000;
			config_regs_n[6] <= 4'b0000;
			config_regs_n[7] <= 4'b0000;
			config_regs_n[8] <= 4'b0000;
			config_regs_n[9] <= 4'b0000;
			config_regs_n[10] <= 4'b0000;
			config_regs_n[11] <= 4'b0000;
			config_regs_n[12] <= 4'b0000;
			config_regs_n[13] <= 4'b0000;
			config_regs_n[14] <= 4'b0000;
			config_regs_n[15] <= 4'b0000;
		end
		else
		begin
			case (data_in[7:4])
				4'b0000:
					config_regs_n[0] <= data_in[3:0];
				4'b0001:
					config_regs_n[1] <= data_in[3:0];
				4'b0010:
					config_regs_n[2] <= data_in[3:0];
				4'b0011:
					config_regs_n[3] <= data_in[3:0];
				4'b0100:
					config_regs_n[4] <= data_in[3:0];
				4'b0101:
					config_regs_n[5] <= data_in[3:0];
				4'b0110:
					config_regs_n[6] <= data_in[3:0];
				4'b0111:
					config_regs_n[7] <= data_in[3:0];
				4'b1000:
					config_regs_n[8] <= data_in[3:0];
				4'b1001:
					config_regs_n[9] <= data_in[3:0];
				4'b1010:
					config_regs_n[10] <= data_in[3:0];
				4'b1011:
					config_regs_n[11] <= data_in[3:0];
				4'b1100:
					config_regs_n[12] <= data_in[3:0];
				4'b1101:
			   	config_regs_n[13] <= data_in[3:0];
		      4'b1110:
	         	config_regs_n[14] <= data_in[3:0];
            4'b1111:
            	config_regs_n[15] <= data_in[3:0];			
			endcase
		end
	end
	
	assign reg0_out = config_regs_n[0];
	assign reg1_out = config_regs_n[1];
	assign reg2_out = config_regs_n[2];
	assign reg3_out = config_regs_n[3];
	assign reg4_out = config_regs_n[4];
	assign reg5_out = config_regs_n[5];
	assign reg6_out = config_regs_n[6];
	assign reg7_out = config_regs_n[7];
	assign reg8_out = config_regs_n[8];
	assign reg9_out = config_regs_n[9];
	assign regA_out = config_regs_n[10];
	assign regB_out = config_regs_n[11];
	assign regC_out = config_regs_n[12];
	assign regD_out = config_regs_n[13];
	assign regE_out = config_regs_n[14];
	assign regF_out = config_regs_n[15];

endmodule