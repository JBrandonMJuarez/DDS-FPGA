module UART_rs232_rx #(
    parameter BIT_RATE      = 9600,
    parameter CLK_HZ        = 48_000_000,
    parameter PAYLOAD_BITS  = 8,
    parameter STOP_BITS     = 1
)(
    input  wire                   clk,            // System clock
    input  wire                   resetn,         // Active-low reset
    input  wire                   uart_rxd,       // UART receive line
    input  wire                   uart_rx_en,     // UART receive enable
    output wire                   uart_rx_break,  // BREAK condition detected (all zeros)
    output wire                   uart_rx_valid,  // Indicates valid received data
    output reg  [PAYLOAD_BITS-1:0] uart_rx_data   // Received data output
);

    // ----------------------------------------
    // Derived Parameters
    // ----------------------------------------

    localparam integer BIT_PERIOD_NS     = 1_000_000_000 / BIT_RATE;
    localparam integer CLK_PERIOD_NS     = 1_000_000_000 / CLK_HZ;
    localparam integer CYCLES_PER_BIT    = BIT_PERIOD_NS / CLK_PERIOD_NS;
    localparam integer COUNT_REG_LEN     = 1 + $clog2(CYCLES_PER_BIT);

    // ----------------------------------------
    // Internal Registers and Wires
    // ----------------------------------------

    reg rxd_sync_0, rxd_sync_1;
    reg [PAYLOAD_BITS-1:0] received_data;
    reg [COUNT_REG_LEN-1:0] cycle_counter;
    reg [3:0] bit_counter;
    reg sampled_bit;

    reg [2:0] fsm_state, next_fsm_state;

    localparam FSM_IDLE  = 3'd0;
    localparam FSM_START = 3'd1;
    localparam FSM_RECV  = 3'd2;
    localparam FSM_STOP  = 3'd3;

    // ----------------------------------------
    // Output Assignments
    // ----------------------------------------

    assign uart_rx_valid = (fsm_state == FSM_STOP) && (next_fsm_state == FSM_IDLE);
    assign uart_rx_break = uart_rx_valid && ~|received_data;

    // ----------------------------------------
    // Receive Data Register
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            uart_rx_data <= {PAYLOAD_BITS{1'b0}};
        end else if (fsm_state == FSM_STOP) begin
            uart_rx_data <= received_data;
        end
    end

    // ----------------------------------------
    // FSM Next State Logic
    // ----------------------------------------

    wire bit_complete   = (cycle_counter == CYCLES_PER_BIT) ||
                          (fsm_state == FSM_STOP && cycle_counter == CYCLES_PER_BIT / 2);
    wire all_bits_done  = (bit_counter == PAYLOAD_BITS);

    always @(*) begin
        case (fsm_state)
            FSM_IDLE:  next_fsm_state = rxd_sync_1 ? FSM_IDLE : FSM_START;
            FSM_START: next_fsm_state = bit_complete ? FSM_RECV : FSM_START;
            FSM_RECV:  next_fsm_state = all_bits_done ? FSM_STOP : FSM_RECV;
            FSM_STOP:  next_fsm_state = bit_complete ? FSM_IDLE : FSM_STOP;
            default:   next_fsm_state = FSM_IDLE;
        endcase
    end

    // ----------------------------------------
    // Shift Register for Received Data
    // ----------------------------------------

    integer i;
    always @(posedge clk) begin
        if (!resetn || fsm_state == FSM_IDLE) begin
            received_data <= {PAYLOAD_BITS{1'b0}};
        end else if (fsm_state == FSM_RECV && bit_complete) begin
            received_data[PAYLOAD_BITS-1] <= sampled_bit;
            for (i = PAYLOAD_BITS-2; i >= 0; i = i - 1) begin
                received_data[i] <= received_data[i+1];
            end
        end
    end

    // ----------------------------------------
    // Bit Counter
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn || fsm_state != FSM_RECV) begin
            bit_counter <= 4'b0;
        end else if (fsm_state == FSM_RECV && bit_complete) begin
            bit_counter <= bit_counter + 1'b1;
        end
    end

    // ----------------------------------------
    // Sample UART Line in Middle of Bit Period
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            sampled_bit <= 1'b0;
        end else if (cycle_counter == CYCLES_PER_BIT / 2) begin
            sampled_bit <= rxd_sync_1;
        end
    end

    // ----------------------------------------
    // Cycle Counter
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn || bit_complete) begin
            cycle_counter <= {COUNT_REG_LEN{1'b0}};
        end else if (fsm_state == FSM_START || fsm_state == FSM_RECV || fsm_state == FSM_STOP) begin
            cycle_counter <= cycle_counter + 1'b1;
        end
    end

    // ----------------------------------------
    // FSM State Register
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            fsm_state <= FSM_IDLE;
        end else begin
            fsm_state <= next_fsm_state;
        end
    end

    // ----------------------------------------
    // Input Synchronization for UART RX Line
    // ----------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            rxd_sync_0 <= 1'b1;
            rxd_sync_1 <= 1'b1;
        end else if (uart_rx_en) begin
            rxd_sync_0 <= uart_rxd;
            rxd_sync_1 <= rxd_sync_0;
        end
    end

endmodule
