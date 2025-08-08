module sin_gen #(
	parameter						DAC_SIZE = 12
)(
	input								clk_in,
	input								rst_in,
	input		[23:0]				f0_in,
	input		[23:0]				f1_in,
	input		[23:0]				f2_in,
	input		[23:0]				f3_in,
	input		[23:0]				f4_in,
	input		[7:0]					mode_in,
	output 	[DAC_SIZE-1:0]		DAC_data
);

	wire	clk_out;
	wire	pulse_w;
	
	wire	[ DAC_SIZE-1:0]	psrand_w;
	wire				[23:0]	counterAddr;
	wire				[23:0]	counterAddr1;
	wire				[23:0]	counter_w;
	
	
	reg 	signed [DAC_SIZE-1:0]	SinLUT [0 : 255] /* synthesis ramstyle = M9K */; 
	reg	signed [DAC_SIZE-1:0]	DAC_data_reg0;
	reg 	signed [DAC_SIZE-1:0]	DAC_data_reg1;
	reg	signed [DAC_SIZE-1:0]	DAC_data_reg2;
	reg 	signed [DAC_SIZE-1:0]	DAC_data_reg3;
	reg	signed [DAC_SIZE-1:0]	DAC_data_reg4;
	reg 	signed [DAC_SIZE-1:0]	DAC_data_reg5;
	
	
	wire				[23:0]	phase_w0;
	wire				[23:0]	phase_w1;
	wire				[23:0]	phase_w2;
	wire				[23:0]	phase_w3;
	wire				[23:0]	phase_w4;
	
	wire				[7:0]	phase0_w;
	wire				[7:0]	phase1_w;
	wire				[7:0]	phase2_w;
	wire				[7:0]	phase3_w;
	wire				[7:0]	phase4_w;
	
	wire				[1:0]	phase0_sel;
	wire				[1:0]	phase1_sel;
	wire				[1:0]	phase2_sel;
	wire				[1:0]	phase3_sel;
	wire				[1:0]	phase4_sel;
	
	wire	signed	[11:0]	sin_w0;
	wire	signed	[11:0]	sin_w1;
	wire	signed	[11:0]	sin_w2;
	wire	signed	[11:0]	sin_w3;
	wire	signed	[11:0]	sin_w4;
	wire	signed	[11:0]	multi_sin_w;
	
	
	
	initial
	begin
		$readmemh ("SinLUT.hex", SinLUT);
	end
	
	
	
	freq_divider U0_freq_div(
		.clk_in			(clk_in),
		.rst_in			(rst_in),
		.clk_out			(clk_out)
	);
	
	timer_counter U1_timer(
		.clk_in			(clk_out),
		.rst_in			(rst_in),
		.f0_in			(f0_in),
		.counter_out	(counter_w),
		.pulse_out		(pulse_w)
	);
	

	phase_accumulator_ctrl #(
		.CLK_FREQ 					(5_000_000),
		.ACCUM_LENGTH				(24),
		.N_FREQS						(5)
	)U2_phase_accumulator(
		.clk_in						(clk_out),
		.rstn_in						(rst_in),
		.pulse_in					(pulse_w),
		.mode_in						(mode_in[3:0]),
		.f0_in						(f0_in),
		.f1_in						(f1_in),
		.f2_in						(f2_in),
		.f3_in						(f3_in),
		.f4_in						(f4_in),
		.phase_out0					(phase_w0),
		.phase_out1					(phase_w1),
		.phase_out2					(phase_w2),
		.phase_out3					(phase_w3),
		.phase_out4					(phase_w4)
	);

	psrand_gen U3_psrand(
		.clk_in				(clk_out),
		.clk_in1				(clk_out),
		.rst_in				(rst_in),
		.mode_in				(mode_in[3:0]),
		.seed_in				(counter_w),
		.psrand_out			(psrand_w)
	);


	
	assign phase0_sel = phase_w0[23:22];
	assign phase0_w = (phase0_sel[0] == 1'b0) ? phase_w0[21:14] : ~phase_w0[21:14];
	
	assign phase1_sel = phase_w1[23:22];
	assign phase1_w = (phase1_sel[0] == 1'b0) ? phase_w1[21:14] : ~phase_w1[21:14];
	
	assign phase2_sel = phase_w2[23:22];
	assign phase2_w = (phase2_sel[0] == 1'b0) ? phase_w2[21:14] : ~phase_w2[21:14];
	
	assign phase3_sel = phase_w3[23:22];
	assign phase3_w = (phase3_sel[0] == 1'b0) ? phase_w3[21:14] : ~phase_w3[21:14];
	
	assign phase4_sel = phase_w4[23:22];
	assign phase4_w = (phase4_sel[0] == 1'b0) ? phase_w4[21:14] : ~phase_w4[21:14];
	
	
	always @ (*)
	begin
			DAC_data_reg0 <= SinLUT[phase0_w];
			DAC_data_reg1 <= SinLUT[phase1_w];
			DAC_data_reg2 <= SinLUT[phase2_w];
			DAC_data_reg3 <= SinLUT[phase3_w];
			DAC_data_reg4 <= SinLUT[phase4_w];
	end
	

	
	assign sin_w0 = ((phase0_sel[1] == 1'b0) ? DAC_data_reg0 : ~DAC_data_reg0 + 1'b1);
	assign sin_w1 = ((phase1_sel[1] == 1'b0) ? DAC_data_reg1 : ~DAC_data_reg1 + 1'b1);
	assign sin_w2 = ((phase2_sel[1] == 1'b0) ? DAC_data_reg2 : ~DAC_data_reg2 + 1'b1);
	assign sin_w3 = ((phase3_sel[1] == 1'b0) ? DAC_data_reg3 : ~DAC_data_reg3 + 1'b1);
	assign sin_w4 = ((phase4_sel[1] == 1'b0) ? DAC_data_reg4 : ~DAC_data_reg4 + 1'b1);
	
	assign multi_sin_w = $signed($signed(sin_w0>>>2) + $signed(sin_w1>>>3));
	
	assign DAC_data = (mode_in[3:0] == 4'b01) ? ( multi_sin_w + 12'b100000000000) : (mode_in[3:0] == 4'b11) ? psrand_w : 
	(mode_in[3:0] == 4'b100) ? phase_w0[23:14]*2 + 12'b100000000000 : (mode_in[3:0] == 4'b101) ? phase0_w*4 + 12'b100000000000 :
	(mode_in[3:0] == 4'b110) ? {12{phase_w0[23]}} : (sin_w0 + 12'b100000000000);

endmodule