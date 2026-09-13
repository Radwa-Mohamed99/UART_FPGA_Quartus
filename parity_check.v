module parity_check #(
    parameter DATA_WIDTH = 8
)(
    input  wire                     par_chk_en,
    input  wire [DATA_WIDTH-1:0]    P_DATA,
    input  wire                     sampled_bit,
    input  wire                     PAR_TYP,

    output reg                      par_err
);

always @(*) begin

    par_err = 1'b0;

    if (par_chk_en) begin

        if (PAR_TYP == 1'b0) begin
            // Even parity
            if (sampled_bit != (^P_DATA))
                par_err = 1'b1;
        end

        else begin
            // Odd parity
            if (sampled_bit != ~(^P_DATA))
                par_err = 1'b1;
        end

    end

end

endmodule