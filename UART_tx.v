module UART_rs232_tx #(
    parameter BIT_RATE      = 9600,         // Baud rate in bits/sec
    parameter CLK_HZ        = 48_000_000,   // System clock frequency
    parameter PAYLOAD_BITS  = 8,            // Number of data bits
    parameter STOP_BITS     = 1             // Number of stop bits
)(
    input  wire                     clk,           // System clock
    input  wire                     resetn,        // Active-low reset
    output wire                     uart_txd,      // UART TX output line
    output wire                     uart_tx_busy,  // TX is currently transmitting
    input  wire                     uart_tx_en,    // Trigger to send data
    input  wire [PAYLOAD_BITS-1:0] uart_tx_data    // Data to send
);

    // ----------------------------------------
    // Derived parameters
    // ----------------------------------------

    localparam integer BIT_PERIOD_NS     = 1_000_000_000 / BIT_RATE;
    localparam integer CLK_PERIOD_NS     = 1_000_000_000 / CLK_HZ;
    localparam integer CYCLES_PER_BIT    = BIT_PERIOD_NS / CLK_PERIOD_NS;
    localparam integer COUNT_REG_LEN     = 1 + $clog2(CYCLES_PER_BIT);

    // ----------------------------------------
    // FSM State definitions
    // ----------------------------------------

    localparam FSM_IDLE  = 3'd0;
    localparam FSM_START = 3'd1;
    localparam FSM_SEND  = 3'd2;
    localparam FSM_STOP  = 3'd3;

    // ----------------------------------------
    // Internal signals and registers
    // ----------------------------------------

    reg [2:0] fsm_state, next_fsm_state;
    reg [3:0] bit_counter;
    reg [COUNT_REG_LEN-1:0] cycle_counter;
    reg [PAYLOAD_BITS-1:0] tx_data_buffer;
    reg txd_reg;

    assign uart_txd     = txd_reg;
    assign uart_tx_busy = (fsm_state != FSM_IDLE);

    wire bit_done      = (cycle_counter == CYCLES_PER_BIT);
    wire payload_sent  = (bit_counter == PAYLOAD_BITS);
    wire stop_sent     = (bit_counter == STOP_BITS && fsm_state == FSM_STOP);

    // ----------------------------------------
    // FSM next state logic
    // ----------------------------------------

    always @(*) begin
        case (fsm_state)
            FSM_IDLE:  next_fsm_state = uart_tx_en     ? FSM_START : FSM_IDLE;
            FSM_START: next_fsm_state = bit_done       ? FSM_SEND  : FSM_START;
            FSM_SEND:  next_fsm_state = payload_sent   ? FSM_STOP  : FSM_SEND;
            FSM_STOP:  next_fsm_state = stop_sent      ? FSM_IDLE  : FSM_STOP;
            default:   next_fsm_state = FSM_IDLE;
        endcase
    end

    // ----------------------------------------
    // FSM state register
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn)
            fsm_state <= FSM_IDLE;
        else
            fsm_state <= next_fsm_state;
    end

    // ----------------------------------------
    // Data buffer logic
    // ----------------------------------------

    integer i;
    always @(posedge clk) begin
        if (!resetn) begin
            tx_data_buffer <= {PAYLOAD_BITS{1'b0}};
        end else if (fsm_state == FSM_IDLE && uart_tx_en) begin
            tx_data_buffer <= uart_tx_data;
        end else if (fsm_state == FSM_SEND && bit_done) begin
            for (i = PAYLOAD_BITS - 2; i >= 0; i = i - 1)
                tx_data_buffer[i] <= tx_data_buffer[i + 1];
        end
    end

    // ----------------------------------------
    // Bit counter logic
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            bit_counter <= 4'd0;
        end else if (fsm_state == FSM_SEND && next_fsm_state == FSM_STOP) begin
            bit_counter <= 4'd0;
        end else if (fsm_state == FSM_IDLE || fsm_state == FSM_START) begin
            bit_counter <= 4'd0;
        end else if ((fsm_state == FSM_SEND || fsm_state == FSM_STOP) && bit_done) begin
            bit_counter <= bit_counter + 1'b1;
        end
    end

    // ----------------------------------------
    // Cycle counter logic
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn || bit_done) begin
            cycle_counter <= {COUNT_REG_LEN{1'b0}};
        end else if (fsm_state == FSM_START || fsm_state == FSM_SEND || fsm_state == FSM_STOP) begin
            cycle_counter <= cycle_counter + 1'b1;
        end
    end

    // ----------------------------------------
    // TXD output logic
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            txd_reg <= 1'b1; // Idle line is HIGH
        end else case (fsm_state)
            FSM_IDLE:  txd_reg <= 1'b1;
            FSM_START: txd_reg <= 1'b0; // Start bit
            FSM_SEND:  txd_reg <= tx_data_buffer[0];
            FSM_STOP:  txd_reg <= 1'b1; // Stop bit
            default:   txd_reg <= 1'b1;
        endcase
    end

endmodule

