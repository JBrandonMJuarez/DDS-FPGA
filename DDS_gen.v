module DDS_gen #(
	parameter			DAC_SIZE = 12	
)(
	input							clk_in,
	input							rstn_in,
	input							mode_in,
	input							rx_in,
	input					[7:0]	data_in,
	output						tx_out,
	output				[7:0]	rxdata_out,
	output	[DAC_SIZE-1:0]	data_out
);

	wire	[7:0]	uart_data_rx;
	wire	[7:0]	uart_data_tx;
	wire	[3:0]	config_regs_w	[0:15];
	
	wire	[19:0]	freq0_w;
	wire	[19:0]	freq1_w;
	wire	[19:0]	freq2_w;
	wire	[19:0]	freq3_w;
	wire	[19:0]	freq4_w;
	

	sin_gen #(
		.DAC_SIZE		(DAC_SIZE)
	) U0_SinGen(
		.clk_in			(clk_in),
	   .rst_in			(rstn_in),
	   .f0_in			(freq0_w),
		.f1_in			(freq1_w),
		.f2_in			(freq2_w),
		.f3_in			(freq3_w),
		.f4_in			(freq4_w),
		.mode_in			(config_regs_w[15]),
	   .DAC_data		(data_out)
	
	);
	
	freq_scale	U4_FreqScale(
		.f0_in			(config_regs_w[0]),
		.f1_in			(config_regs_w[1]),
		.f2_in			(config_regs_w[2]),
		.f3_in			(config_regs_w[3]),
		.f4_in			(config_regs_w[4]),
		.scale0_in		(config_regs_w[6]),
		.scale1_in		(config_regs_w[7]),
		.scale2_in		(config_regs_w[8]),
		.scale3_in		(config_regs_w[9]),
		.scale4_in		(config_regs_w[10]),
		.f0_out			(freq0_w),
		.f1_out			(freq1_w),
		.f2_out			(freq2_w),
		.f3_out			(freq3_w),
		.f4_out			(freq4_w)
	);
	
	
	config_regs U1_DDS_regs (
		.clk_in			(clk_in),
		.rstn_in			(rstn_in),
		.data_in			(uart_data_rx),
		.reg0_out		(config_regs_w[0]),	// Inicio
		.reg1_out		(config_regs_w[1]),	// Fin
		.reg2_out		(config_regs_w[2]),	// Incremento
		.reg3_out		(config_regs_w[3]),	// Modo
		.reg4_out		(config_regs_w[4]),
		.reg5_out		(config_regs_w[5]),
		.reg6_out		(config_regs_w[6]),
		.reg7_out		(config_regs_w[7]),
		.reg8_out		(config_regs_w[8]),
		.reg9_out		(config_regs_w[9]),
		.regA_out		(config_regs_w[10]),
		.regB_out		(config_regs_w[11]),
		.regC_out		(config_regs_w[12]),
		.regD_out		(config_regs_w[13]),
		.regE_out		(config_regs_w[14]),
		.regF_out		(config_regs_w[15])
	);

	UART_module U2_UART (
		.clk     		(clk_in), // Top level system clock input.
		.resetn    		(rstn_in), // Slide switches.
		.uart_rxd		(rx_in), // UART Recieve pin.
		.uart_txd		(tx_out), // UART transmit pin.
		.rx_data			(uart_data_rx),
		.tx_data			(uart_data_tx)
	);
	
	ACK_UART		U3_ACK_UART(
		.clk_in			(clk_in),
		.rstn_in			(rstn_in),
		.data_in			(uart_data_rx),
		.mode_in			(config_regs_w[15]),
		.ACK_out			(uart_data_tx)
	);

	assign rxdata_out = uart_data_rx;

endmodule