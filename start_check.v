module start_check (
    input  wire strt_chk_en,
    input  wire sampled_bit,

    output reg strt_glitch
);

always @(*) begin

    strt_glitch = 1'b0;

    if (strt_chk_en) begin

        // Start bit must be LOW
        if (sampled_bit != 1'b0)
            strt_glitch = 1'b1;

    end

end

endmodule