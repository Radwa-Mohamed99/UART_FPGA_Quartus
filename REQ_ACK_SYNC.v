`timescale 1ns / 1ps

// =============================================================================
// REQ_ACK_SYNC - Synchronous pulse-stretching synchronizer
//
// Crosses a REQ + DATA bundle from the fast REQ_CLK domain into the slow 
// synchronous ACK_CLK domain (REQ_CLK / 32).
// CDC synchronization flip-flops and ASYNC_REG attributes have been removed.
// =============================================================================

module REQ_ACK_SYNC #(
    parameter DATA_WIDTH = 8
)(
    // ---- REQ (source) domain ----
    input  wire                  REQ_CLK,
    input  wire                  RST_REQ,        // active-low
    input  wire                  REQ,            // 1-cycle request pulse
    input  wire [DATA_WIDTH-1:0] REQ_DATA,

    // ---- ACK (destination) domain ----
    input  wire                  ACK_CLK,        // Synchronous, REQ_CLK / 32
    input  wire                  RST_ACK,        // active-low
    input  wire                  ACK,            // consumer consumption ack
    output wire                  OUT_VLD,        // held Data_Valid in ACK domain
    output reg  [DATA_WIDTH-1:0] OUT_DATA        // data in ACK domain
);

    reg                  pending;
    reg [DATA_WIDTH-1:0] req_data_hold;

    // ---------------------------------------------------------------------
    // ACK edge detection in REQ_CLK domain
    // ---------------------------------------------------------------------
    reg ack_d;

    always @ (posedge REQ_CLK or negedge RST_REQ)
    begin
        if(!RST_REQ)
        begin
            ack_d <= 1'b0;
        end
        else
        begin
            ack_d <= ACK;
        end
    end

    wire ack_sync_r = ACK && !ack_d;

    // ---------------------------------------------------------------------
    // REQ side: stretch the request into a held level, clear on the ACK echo.
    // ---------------------------------------------------------------------
    always @ (posedge REQ_CLK or negedge RST_REQ)
    begin
        if(!RST_REQ)
        begin
            pending        <= 1'b0;
            req_data_hold  <= {DATA_WIDTH{1'b0}};
        end
        else if(REQ)
        begin
            pending        <= 1'b1;
            req_data_hold  <= REQ_DATA;
        end
        else if(ack_sync_r)
        begin
            pending        <= 1'b0;
        end
    end

    // ---------------------------------------------------------------------
    // ACK side (ACK_CLK domain): capture the data when pending, present 
    // OUT_VLD held until ACK arrives.
    // ---------------------------------------------------------------------
    reg valid_level;

    always @ (posedge ACK_CLK or negedge RST_ACK)
    begin
        if(!RST_ACK)
        begin
            valid_level <= 1'b0;
            OUT_DATA    <= {DATA_WIDTH{1'b0}};
        end
        else
        begin
            if(pending && !ACK && !valid_level)   // req pending, consumer idle
            begin
                OUT_DATA    <= req_data_hold;     
                valid_level <= 1'b1;              
            end
            else if(ACK)                          // consumer consumed (busy)
            begin
                valid_level <= 1'b0;              
            end
        end
    end

    assign OUT_VLD = valid_level;

endmodule