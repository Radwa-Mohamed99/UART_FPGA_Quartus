module UART #(
    parameter DATA_WIDTH = 8,
    parameter PRESCALE_WIDTH = 6
)(
    input  wire                         RST,
    input  wire                         TX_CLK,
    input  wire                         RX_CLK,

    input  wire                         RX_IN_S,
    output wire [DATA_WIDTH-1:0]        RX_OUT_P,
    output wire                         RX_OUT_V,

    input  wire [DATA_WIDTH-1:0]        TX_IN_P,
    input  wire                         TX_IN_V,
    output wire                         TX_OUT_S,
    output wire                         TX_OUT_V,

    input  wire [PRESCALE_WIDTH-1:0]    Prescale,
    input  wire                         parity_enable,
    input  wire                         parity_type,

    output wire                         parity_error,
    output wire                         framing_error
);

    //============================================================
    // UART TX
    //============================================================

    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U0_UART_TX (
        .P_DATA     (TX_IN_P),
        .clk        (TX_CLK),
        .rst_n      (RST),
        .DATA_VALID (TX_IN_V),
        .PAR_EN     (parity_enable),
        .PAR_TYP    (parity_type),

        .TX_OUT     (TX_OUT_S),
        .Busy       (TX_OUT_V)
    );


    //============================================================
    // UART RX
    //============================================================

    UART_RX #(
        .DATA_WIDTH     (DATA_WIDTH),
        .PRESCALE_WIDTH (PRESCALE_WIDTH)
    ) U0_UART_RX (
        .RX_IN      (RX_IN_S),
        .clk        (RX_CLK),
        .rst_n      (RST),
        .PAR_EN     (parity_enable),
        .PAR_TYP     (parity_type),
        .Prescale    (Prescale),

        .P_DATA      (RX_OUT_P),
        .DATA_VALID  (RX_OUT_V),
        .PAR_ERR     (parity_error),
        .Stop_ERR    (framing_error)
    );

endmodule