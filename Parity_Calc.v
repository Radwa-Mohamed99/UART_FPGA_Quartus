module Parity_Calc #(
parameter DATA_WIDTH=8
)(
input clk,
input rst_n,

input [DATA_WIDTH-1:0] P_DATA,
input DATA_VALID,
input PAR_TYP,
input PAR_EN,

output reg par_bit
);

always @(posedge clk or negedge rst_n) begin

    if(!rst_n)
        par_bit <= 0;

    else if(DATA_VALID && PAR_EN) begin

        if(PAR_TYP)
            par_bit <= ~(^P_DATA);

        else
            par_bit <= ^P_DATA;

    end

end

endmodule