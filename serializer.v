module serializer #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [DATA_WIDTH-1:0] P_DATA,
    input  wire                  ser_en,
    input  wire                  Data_Valid,

    output wire                  ser_data,
    output reg                   ser_done
);

    reg [DATA_WIDTH-1:0] data_reg;
    reg [$clog2(DATA_WIDTH)-1:0] bit_cnt;

    assign ser_data = data_reg[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= {DATA_WIDTH{1'b0}};
            bit_cnt  <= 'd0;
            ser_done <= 1'b0;
        end
        else begin
            ser_done <= 1'b0;

            if (Data_Valid) begin
                data_reg <= P_DATA;
                bit_cnt  <= 'd0;
            end

            else if (ser_en) begin

                if (bit_cnt == DATA_WIDTH-1) begin
                    ser_done <= 1'b1;
                end
                else begin
                    data_reg <= data_reg >> 1;
                    bit_cnt  <= bit_cnt + 1'b1;
                end

            end
        end
    end

endmodule