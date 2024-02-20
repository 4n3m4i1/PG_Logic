/*
*/
// 100 MHz in this case
module ice_pll
(
    input wire  pll_clk_src,
    output wire PLL_LOCK,
    output wire pll_clk_out
);
    // Internal PLL
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .PLLOUT_SELECT("GENCLK"),
        .DIVR(4'd0),
        .DIVF(7'd66),
        .DIVQ(3'd3),
        .FILTER_RANGE(3'd1)
    ) pll_uut (
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .PLLOUTCORE(pll_clk_out),
        .REFERENCECLK(pll_clk_src),
        .LOCK(PLL_LOCK)
    );
endmodule