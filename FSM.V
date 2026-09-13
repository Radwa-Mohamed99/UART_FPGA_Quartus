module FSM (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  DATA_VALID,
    input  wire                  ser_done,
    input  wire                  PAR_EN,

    output reg                   ser_en,
    output reg [1:0]             mux_sel,
    output reg                   Busy
);

    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b010;
    localparam PARITY = 3'b011;
    localparam STOP   = 3'b100;

    reg [2:0] current_state;
    reg [2:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin

        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (DATA_VALID)
                    next_state = START;
            end

            START: begin
                next_state = DATA;
            end

            DATA: begin
                if (ser_done) begin
                    if (PAR_EN)
                        next_state = PARITY;
                    else
                        next_state = STOP;
                end
                else begin
                    next_state = DATA;
                end
            end

            PARITY: begin
                next_state = STOP;
            end

            STOP: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase

    end

    always @(*) begin

        ser_en  = 1'b0;
        Busy    = 1'b0;
        mux_sel = 2'b11;

        case (current_state)

            IDLE: begin
                Busy    = 1'b0;
                mux_sel = 2'b11;
            end

            START: begin
                Busy    = 1'b1;
                mux_sel = 2'b00;
            end

            DATA: begin
                Busy    = 1'b1;
                mux_sel = 2'b01;

                if (ser_done)
                    ser_en = 1'b0;
                else
                    ser_en = 1'b1;
            end

            PARITY: begin
                Busy    = 1'b1;
                mux_sel = 2'b10;
            end

            STOP: begin
                Busy    = 1'b1;
                mux_sel = 2'b11;
            end

            default: begin
                Busy    = 1'b0;
                ser_en  = 1'b0;
                mux_sel = 2'b11;
            end

        endcase

    end

endmodule