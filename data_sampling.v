module data_sampling #(
    parameter PRESCALE_WIDTH = 6
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      data_samp_en,
    input  wire [PRESCALE_WIDTH-1:0] Prescale,
    input  wire [PRESCALE_WIDTH-1:0] edge_cnt,
    input  wire                      RX_IN,

    output reg                       sampled_bit
);

reg [2:0] samples;

always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        samples     <= 3'b000;
        sampled_bit <= 1'b0;
    end

    else if (!data_samp_en) begin
        samples     <= 3'b000;
        sampled_bit <= 1'b0;
    end

    else begin

        // First Sample
        if (edge_cnt == (Prescale >> 1) - 1'b1) begin
            samples[0] <= RX_IN;
        end

        // Second Sample
        else if (edge_cnt == (Prescale >> 1)) begin
            samples[1] <= RX_IN;
        end

        // Third Sample
        else if (edge_cnt == (Prescale >> 1) + 1'b1) begin

            // RX_IN is used directly as the third sample because samples[2]
            // does not get its new value until the current clock event finishes.
            samples[2] <= RX_IN;

            sampled_bit <=
                (samples[0] & samples[1]) |
                (samples[0] & RX_IN)      |
                (samples[1] & RX_IN);

        end

    end

end

endmodule