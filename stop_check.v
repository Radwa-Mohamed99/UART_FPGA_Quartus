module stop_check (
    input  wire stp_chk_en,
    input  wire sampled_bit,

    output reg  stp_err
);

always @(*) begin

    stp_err = 1'b0;

    if (stp_chk_en) begin

        // Stop bit must be HIGH
        if (sampled_bit != 1'b1)
            stp_err = 1'b1;

    end

end

endmodule