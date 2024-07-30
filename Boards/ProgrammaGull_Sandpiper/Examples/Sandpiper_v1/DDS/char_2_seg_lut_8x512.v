/*
    8x512 Look up table for ascii char -> 7 segment conversion
*/
module char_2_seg_LUT_8x512
#(
    parameter D_W = 8,
    parameter NUM_SAMPLES = 256,
    parameter ADDR_BITS = 8
)
(
    input bram_clk,
    input bram_ce,
    input [(ADDR_BITS - 1):0]bram_addr,
    output reg [(D_W - 1):0]bram_out
);

    // Yosys BRAM_4k inference
    reg [(D_W - 1):0] LUT [(NUM_SAMPLES - 1):0];

    initial begin
        $readmemh("ascii_7seg_lut.mem", LUT);
    end

    always @ (posedge bram_clk) begin
        if(bram_ce) bram_out <= LUT[bram_addr];
    end
endmodule