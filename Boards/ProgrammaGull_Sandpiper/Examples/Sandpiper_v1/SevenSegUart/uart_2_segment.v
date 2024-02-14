


module uart_2_segment
#(
    parameter BYTE_W = 8
)
(
    input clk,
    input en,

    input [(BYTE_W - 1):0]char_in,
    input cvt,

    output reg [(BYTE_W - 1):0]seg_out,
    output reg seg_ud
);

    reg [1:0] oa_state;
    
    localparam IDLE = 2'b00;
    localparam WFLD = 2'b01;
    localparam POST = 2'b10;
    localparam CLRR = 2'b11;

/*
module char_2_seg_LUT_8x512
#(
    parameter D_W = 8,
    parameter NUM_SAMPLES = 512,
    parameter ADDR_BITS = 9
)
(
    input bram_clk,
    input bram_ce,
    input [(ADDR_BITS - 1):0]bram_addr,
    output reg [(D_W - 1):0]bram_out
);
*/
    wire [(BYTE_W - 1):0] lut_rd_dat;
    reg [(BYTE_W - 1):0] charaddr;

    char_2_seg_LUT_8x512 c2s
    (
        .bram_clk(clk),
        .bram_ce(en),
        .bram_addr(charaddr),
        .bram_out(lut_rd_dat)
    );

    initial begin
        seg_out     = 0;
        seg_ud      = 0;
        oa_state    = 0;
    end

    always @ (posedge clk) begin
        case (oa_state)
            IDLE: begin
                if(cvt) begin
                    charaddr <= char_in;
                    oa_state <= WFLD;
                end
            end

            WFLD: begin
                oa_state    <= POST;
            end

            POST: begin
                seg_out     <= lut_rd_dat;
                seg_ud      <= 1'b1;
                oa_state    <= CLRR;
            end

            CLRR: begin
                seg_ud      <= 1'b0;
                oa_state    <= IDLE;
            end
        endcase
    end

endmodule