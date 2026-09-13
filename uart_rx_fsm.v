module uart_rx_fsm #(
    parameter BIT_CNT_WIDTH  = 4,
    parameter PRESCALE_WIDTH = 6
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire                     RX_IN,
    input  wire                     PAR_EN,

    input  wire                     par_err,
    input  wire                     strt_glitch,
    input  wire                     stp_err,

    input  wire [BIT_CNT_WIDTH-1:0] bit_cnt,
    input  wire [PRESCALE_WIDTH-1:0] edge_cnt,
    input  wire [PRESCALE_WIDTH-1:0] Prescale,

    output reg                      edge_bit_counter_en,
    output reg                      data_valid,
    output reg                      data_samp_en,
    output reg                      deser_en,
    output reg                      strt_chk_en,
    output reg                      par_chk_en,
    output reg                      stp_chk_en
);

    //============================================================
    // FSM States
    //============================================================

    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b010;
    localparam PARITY = 3'b011;
    localparam STOP   = 3'b100;
    localparam VALID  = 3'b101;

    reg [2:0] current_state;
    reg [2:0] next_state;

    reg par_err_latched;
    reg stp_err_latched;


    //============================================================
    // State Register
    //============================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            current_state <= IDLE;
        end

        else begin
            current_state <= next_state;
        end

    end


    //============================================================
    // Error Registers
    //============================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            par_err_latched <= 1'b0;
            stp_err_latched <= 1'b0;
        end

        else if (current_state == IDLE && !RX_IN) begin

            // Clear errors at the beginning of a new frame
            par_err_latched <= 1'b0;
            stp_err_latched <= 1'b0;

        end

        else if (current_state == PARITY &&
                 edge_cnt == ((Prescale >> 1) + 2)) begin

            // Capture parity error
            par_err_latched <= par_err;

        end

        else if (current_state == STOP &&
                 edge_cnt == ((Prescale >> 1) + 2)) begin

            // Capture stop error
            stp_err_latched <= stp_err;

        end

    end


    //============================================================
    // Next State Logic
    //============================================================

    always @(*) begin

        next_state = current_state;

        case (current_state)

            //====================================================
            // IDLE
            //====================================================

            IDLE: begin

                if (!RX_IN)
                    next_state = START;

            end


            //====================================================
            // START
            //====================================================

            START: begin

                if (strt_glitch)
                    next_state = IDLE;

                else if (bit_cnt == 4'd1)
                    next_state = DATA;

            end


            //====================================================
            // DATA
            //====================================================

            DATA: begin

                if (bit_cnt == 4'd9) begin

                    if (PAR_EN)
                        next_state = PARITY;

                    else
                        next_state = STOP;

                end

            end


            //====================================================
            // PARITY
            //====================================================

            PARITY: begin

                if (bit_cnt == 4'd10)
                    next_state = STOP;

            end


            //====================================================
            // STOP
            //====================================================

            STOP: begin

                if (bit_cnt == 4'd0)
                    next_state = VALID;

            end


            //====================================================
            // VALID
            //====================================================

            VALID: begin

                next_state = IDLE;

            end


            //====================================================
            // Default
            //====================================================

            default: begin

                next_state = IDLE;

            end

        endcase

    end


    //============================================================
    // Output Logic
    //============================================================

    always @(*) begin

        // Default values
        edge_bit_counter_en = 1'b0;
        data_valid          = 1'b0;
        data_samp_en        = 1'b0;
        deser_en            = 1'b0;
        strt_chk_en         = 1'b0;
        par_chk_en          = 1'b0;
        stp_chk_en          = 1'b0;

        case (current_state)

            //====================================================
            // IDLE
            //====================================================

            IDLE: begin

            end


            //====================================================
            // START
            //====================================================

            START: begin

                edge_bit_counter_en = 1'b1;
                data_samp_en        = 1'b1;
                strt_chk_en         = 1'b1;

            end


            //====================================================
            // DATA
            //====================================================

            DATA: begin

                edge_bit_counter_en = 1'b1;
                data_samp_en        = 1'b1;

                if (edge_cnt == ((Prescale >> 1) + 2))
                    deser_en = 1'b1;

            end


            //====================================================
            // PARITY
            //====================================================

            PARITY: begin

                edge_bit_counter_en = 1'b1;
                data_samp_en        = 1'b1;

                if (edge_cnt == ((Prescale >> 1) + 2))
                    par_chk_en = 1'b1;

            end


            //====================================================
            // STOP
            //====================================================

            STOP: begin

                edge_bit_counter_en = 1'b1;
                data_samp_en        = 1'b1;

                if (edge_cnt == ((Prescale >> 1) + 2))
                    stp_chk_en = 1'b1;

            end


            //====================================================
            // VALID
            //====================================================

            VALID: begin

                if (!par_err_latched && !stp_err_latched)
                    data_valid = 1'b1;

            end


            //====================================================
            // Default
            //====================================================

            default: begin

                edge_bit_counter_en = 1'b0;
                data_valid          = 1'b0;
                data_samp_en        = 1'b0;
                deser_en            = 1'b0;
                strt_chk_en         = 1'b0;
                par_chk_en          = 1'b0;
                stp_chk_en          = 1'b0;

            end

        endcase

    end

endmodule