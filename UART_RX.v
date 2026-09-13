module UART_RX #(
    parameter DATA_WIDTH = 8,
    parameter PRESCALE_WIDTH = 6
)(
    input  wire                       RX_IN,
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       PAR_EN,
    input  wire                       PAR_TYP,
    input  wire [PRESCALE_WIDTH-1:0]  Prescale,

    output wire [DATA_WIDTH-1:0]      P_DATA,
    output wire                       DATA_VALID,
    output wire                       PAR_ERR,
    output wire                       Stop_ERR
);

wire [3:0] bit_cnt;
wire [PRESCALE_WIDTH-1:0] edge_cnt;

wire edge_bit_counter_en;

wire data_samp_en;
wire deser_en;
wire strt_chk_en;
wire par_chk_en;
wire stp_chk_en;

wire sampled_bit;

wire strt_glitch;
wire par_err;
wire stp_err;


//============================================================
// Edge & Bit Counter
//============================================================

edge_bit_counter #(
    .PRESCALE_WIDTH(PRESCALE_WIDTH),
    .BIT_CNT_WIDTH (4)
) edge_bit_counter_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (edge_bit_counter_en),
    .PAR_EN     (PAR_EN),
    .Prescale   (Prescale),

    .bit_cnt    (bit_cnt),
    .edge_cnt   (edge_cnt)
);


//============================================================
// Data Sampling
//============================================================

data_sampling #(
    .PRESCALE_WIDTH(PRESCALE_WIDTH)
) data_sampling_inst (
    .clk          (clk),
    .rst_n        (rst_n),
    .data_samp_en (data_samp_en),
    .Prescale     (Prescale),
    .edge_cnt     (edge_cnt),
    .RX_IN        (RX_IN),

    .sampled_bit  (sampled_bit)
);


//============================================================
// Deserializer
//============================================================

deserializer #(
    .DATA_WIDTH(DATA_WIDTH)
) deserializer_inst (
    .clk         (clk),
    .rst_n       (rst_n),
    .deser_en    (deser_en),
    .sampled_bit (sampled_bit),

    .P_DATA      (P_DATA)
);


//============================================================
// Start Check
//============================================================

start_check start_check_inst (
    .strt_chk_en (strt_chk_en),
    .sampled_bit (sampled_bit),

    .strt_glitch (strt_glitch)
);


//============================================================
// Parity Check
//============================================================

parity_check #(
    .DATA_WIDTH(DATA_WIDTH)
) parity_check_inst (
    .par_chk_en  (par_chk_en),
    .P_DATA      (P_DATA),
    .sampled_bit (sampled_bit),
    .PAR_TYP     (PAR_TYP),

    .par_err     (par_err)
);


//============================================================
// Stop Check
//============================================================

stop_check stop_check_inst (
    .stp_chk_en  (stp_chk_en),
    .sampled_bit (sampled_bit),

    .stp_err     (stp_err)
);


//============================================================
// FSM
//============================================================

uart_rx_fsm #(
    .BIT_CNT_WIDTH (4),
    .PRESCALE_WIDTH(PRESCALE_WIDTH)
) uart_rx_fsm_inst (
    .clk                   (clk),
    .rst_n                 (rst_n),

    .RX_IN                 (RX_IN),
    .PAR_EN                (PAR_EN),
    .Prescale            (Prescale),

    .par_err               (par_err),
    .strt_glitch           (strt_glitch),
    .stp_err               (stp_err),

    .bit_cnt               (bit_cnt),
    .edge_cnt              (edge_cnt),

    .edge_bit_counter_en   (edge_bit_counter_en),
    .data_valid            (DATA_VALID),
    .data_samp_en          (data_samp_en),
    .deser_en              (deser_en),
    .strt_chk_en           (strt_chk_en),
    .par_chk_en            (par_chk_en),
    .stp_chk_en            (stp_chk_en)
);


//============================================================
// Error Outputs
//============================================================

assign PAR_ERR  = par_err;
assign Stop_ERR = stp_err;

endmodule