module UART_module (
    input               clk,         // Top-level system clock input
    input               resetn,      // Active-low reset
    input   wire        uart_rxd,    // UART receive pin
    output  wire        uart_txd,    // UART transmit pin
    output  wire [7:0]  rx_data,     // Received data output
    input   wire [7:0]  tx_data      // Data to transmit
);

// Parameters
parameter CLK_HZ        = 50000000;  // Clock frequency in Hz
parameter BIT_RATE      = 9600;      // UART baud rate
parameter PAYLOAD_BITS  = 8;         // Number of data bits

// Internal signals
wire [PAYLOAD_BITS-1:0] uart_rx_data;
wire                    uart_rx_valid;
wire                    uart_rx_break;

wire                    uart_tx_busy;
wire                    uart_tx_en;

// Output register for received data
reg [PAYLOAD_BITS-1:0] rx_data_reg;
assign rx_data = rx_data_reg;

// Echo received data back
assign uart_tx_en = uart_rx_valid;

// Receive data capture
always @(posedge clk) begin
    if (!resetn) begin
        rx_data_reg <= 8'hF0;
    end else if (uart_rx_valid) begin
        rx_data_reg <= uart_rx_data;
    end
end

// UART Receiver instance
UART_rs232_rx #(
    .BIT_RATE     (BIT_RATE),
    .PAYLOAD_BITS (PAYLOAD_BITS),
    .CLK_HZ       (CLK_HZ)
) uart_rx_inst (
    .clk            (clk),
    .resetn         (resetn),
    .uart_rxd       (uart_rxd),
    .uart_rx_en     (1'b1),
    .uart_rx_break  (uart_rx_break),
    .uart_rx_valid  (uart_rx_valid),
    .uart_rx_data   (uart_rx_data)
);

// UART Transmitter instance
UART_rs232_tx #(
    .BIT_RATE     (BIT_RATE),
    .PAYLOAD_BITS (PAYLOAD_BITS),
    .CLK_HZ       (CLK_HZ)
) uart_tx_inst (
    .clk            (clk),
    .resetn         (resetn),
    .uart_txd       (uart_txd),
    .uart_tx_en     (uart_tx_en),
    .uart_tx_busy   (uart_tx_busy),
    .uart_tx_data   (tx_data)
);

endmodule

