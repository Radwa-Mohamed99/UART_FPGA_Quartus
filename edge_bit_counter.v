/*
    Prescale = 8

    edge_cnt:
    0 1 2 3 4 5 6 7 | 0 1 2 3 4 5 6 7 |
                      ↓
                    bit_cnt++

    bit_cnt:
    0                 | 1                 | 2 ...
*/

module edge_bit_counter #(
    parameter PRESCALE_WIDTH = 6,
    parameter BIT_CNT_WIDTH  = 4
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      enable,
    input  wire                      PAR_EN,
    input  wire [PRESCALE_WIDTH-1:0] Prescale,

    output reg  [BIT_CNT_WIDTH-1:0]  bit_cnt,
    output reg  [PRESCALE_WIDTH-1:0] edge_cnt
);

    //============================================================
    // Next-State Signals
    //============================================================

    reg [BIT_CNT_WIDTH-1:0]  bit_cnt_next;
    reg [PRESCALE_WIDTH-1:0] edge_cnt_next;


    //============================================================
    // Combinational Next-State Logic
    //============================================================

    always @(*) begin

        // Default: hold current values
        bit_cnt_next  = bit_cnt;
        edge_cnt_next = edge_cnt;

        if (enable) begin

            // Last edge of the current bit
            if (edge_cnt == Prescale - 1'b1) begin

                edge_cnt_next = {PRESCALE_WIDTH{1'b0}};

                //================================================
                // Parity Enabled
                // 11 bits: bit_cnt = 0 --> 10
                //================================================

                if (PAR_EN) begin

                    if (bit_cnt == 4'd10)
                        bit_cnt_next = {BIT_CNT_WIDTH{1'b0}};
                    else
                        bit_cnt_next = bit_cnt + 1'b1;

                end

                //================================================
                // Parity Disabled
                // 10 bits: bit_cnt = 0 --> 9
                //================================================

                else begin

                    if (bit_cnt == 4'd9)
                        bit_cnt_next = {BIT_CNT_WIDTH{1'b0}};
                    else
                        bit_cnt_next = bit_cnt + 1'b1;

                end

            end

            //====================================================
            // Normal Edge
            //====================================================

            else begin

                edge_cnt_next = edge_cnt + 1'b1;

            end

        end

        //========================================================
        // Counter Disabled
        //========================================================

        else begin

            edge_cnt_next = {PRESCALE_WIDTH{1'b0}};
            bit_cnt_next  = {BIT_CNT_WIDTH{1'b0}};

        end

    end


    //============================================================
    // Sequential Registers
    //============================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            edge_cnt <= {PRESCALE_WIDTH{1'b0}};
            bit_cnt  <= {BIT_CNT_WIDTH{1'b0}};

        end

        else begin

            edge_cnt <= edge_cnt_next;
            bit_cnt  <= bit_cnt_next;

        end

    end

endmodule