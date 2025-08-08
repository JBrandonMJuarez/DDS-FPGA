module	ACK_UART(
	input						clk_in,
	input						rstn_in,
	input				[7:0]	data_in,
	input				[3:0]	mode_in,
	output	reg	[7:0]	ACK_out
);

	always @(*)
	begin
		case (data_in[7:5])
				4'b0000,
				4'b0001,
				4'b0010,
				4'b0011,
				4'b0100:
				begin
					ACK_out	=	(data_in > 4'b0000) ? 8'b01 : 8'b11111111;
				end
				4'b0101:
				begin
					case (mode_in)
						4'b0001:
						begin
							ACK_out	=	((data_in > 4'b0000) && (data_in < 4'b0110)) ? 8'b01 : 8'b11111111;
						end
						
						4'b0010:
						begin
							ACK_out	=	((data_in > 4'b0000) && (data_in < 4'b1001)) ? 8'b01 : 8'b11111111;
						end
						
						default:
						begin
							ACK_out	= 8'b11111111;
						end
					endcase
				end
				4'b0110:
				begin
					ACK_out	=	(data_in[3:0] == 4'b0001 || data_in[3:0] == 4'b0010 || 
									data_in[3:0] == 4'b0100 || data_in[3:0] == 4'b1000 ) ? 8'b01 : 8'b11111111;
				end
				4'b0111:
				begin
					case (mode_in)
						4'b0001,
						4'b0010:
						begin
							ACK_out	=	(data_in[3:0] == 4'b0001 || data_in[3:0] == 4'b0010 || 
									data_in[3:0] == 4'b0100 || data_in[3:0] == 4'b1000 ) ? 8'b01 : 8'b11111111;
						end
						default:
						begin
							ACK_out	= 8'b11111111;
						end
					endcase
				end
				default:
				begin
					ACK_out	= 8'b11111111;
				end
			endcase
	end
	
endmodule