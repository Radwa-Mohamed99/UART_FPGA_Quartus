module TX_MUX (

    input  wire       [1:0]      mux_sel,
    input  wire                  par_bit,
    input  wire                  ser_data,
    input  wire                  start_bit,
    input  wire                  stop_bit,

    output reg                   TX_OUT

);

    always @(*) begin

        case(mux_sel)

            2'b00: TX_OUT = start_bit;
            2'b01: TX_OUT = ser_data;
            2'b10: TX_OUT = par_bit;
            2'b11: TX_OUT = stop_bit;

            default: TX_OUT = stop_bit; //1

        endcase

    end

endmodule 