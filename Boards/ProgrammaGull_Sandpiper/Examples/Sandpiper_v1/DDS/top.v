

module SANDPIPER_DDS (
    input CLK_12MHZ,

    // DPAD
    input UI_DPAD_U,
    input UI_DPAD_D,
    input UI_DPAD_C,

    // Arr Gee Bee
    output UI_RGBLED_R,
    output UI_RGBLED_G,
    output UI_RGBLED_B,

    // RCLP DAC Output
    output UI_GPIO_1,

    // 7 Segment Shift Register
    output          UI_7SEGSR_CLK,
    output          UI_7SEGSR_RCLK,
    output          UI_7SEGSR_DIN,
    output          UI_7SEGSR_OE
);

    reg pll_50MHz;
    reg pll_25MHz;
    wire PLL_LOCK;
    assign UI_RGBLED_B = ~(PLL_LOCK & CLK_12MHZ);
    wire pll_100MHz;
    ice_pll pll_100MHz_src (
        .pll_clk_src(CLK_12MHZ),
        .PLL_LOCK(PLL_LOCK),
        .pll_clk_out(pll_100MHz)
    );


    wire [7:0]bram_addr_bus;
    reg [15:0]divvy;
    NCO #(
        .DIV_W(16),
        .ADDR_W(8)
    ) nco (
        .sys_clk(pll_50MHz),
        .en(PLL_LOCK),
        .divider(divvy),
        .address(bram_addr_bus)
    );


    wire up_button;
    button_debouncer #(
        .SYSCLK_FREQ(50000000)
    ) up_button_inst (
        .clk(pll_50MHz),
        .D(UI_DPAD_U),
        .Q(up_button)
    );

    wire dn_button;
    button_debouncer #(
        .SYSCLK_FREQ(50000000)
    ) dn_button_inst (
        .clk(pll_50MHz),
        .D(UI_DPAD_D),
        .Q(dn_button)
    );

    wire ct_button;
    button_debouncer #(
        .SYSCLK_FREQ(50000000)
    ) ct_button_inst (
        .clk(pll_50MHz),
        .D(UI_DPAD_C),
        .Q(ct_button)
    );

    reg [7:0]bram_addr_pl;
    wire [15:0]bram_data;
    sin_bram #(
        .DATA_W(16),
        .SAMPLE_CT(256),
        .SAMPLE_ADDR_BITS(8)
    ) sinlut (
        .bram_clk(pll_50MHz),
        .bram_ce(1'b1),
        .bram_addr(bram_addr_pl),
        .bram_out(bram_data)
    );

    fods_mod #(
        .DATA_W(16)
    ) ddsout (
        .mod_clk(pll_100MHz),
        .mod_din(bram_data),
        .mod_dout(UI_GPIO_1)
    );

/*
module num_2_seg 
#(
    parameter SYSCLK_F = 24000000,
    parameter MAX_DIGITS = 5,
    parameter ASCII_LUT_SIZE = 256
) (
    input   en,
    input   cvt_num,
    input   sys_clk,

    input   [(INPUT_W - 1):0] inputval,

    output reg [($clog2(CAN_CT) - 1):0] an_sel,         // selected anode/character
    output reg [($clog2(ASCII_LUT_SIZE) - 1):0] ascii_lut_addr, // Address for Ascii LUT
    output reg commit,                                   // write values to 7 seg driver
    output reg cvt_in_prog
);
*/
    wire commit_from_n2s;
    wire [7:0] numeric_char_addr;
    wire [2:0] numeric_an_sel;
    num_2_seg n2s_inst (
        .en(1'b1),
        .cvt_num(dn_button || up_button),
        .sys_clk(pll_25MHz),
        .inputval(divvy),
        .an_sel(numeric_an_sel),
        .ascii_lut_addr(numeric_char_addr),
        .commit(commit_from_n2s)
    );


    wire [7:0] segbus;
    char_2_seg_LUT_8x512 c2s (
        .bram_clk(pll_25MHz),
        .bram_ce(1'b1),
        .bram_addr(numeric_char_addr),
        .bram_out(segbus)
    );

    PGL_Sandpiper_vAlpha_7Seg_Driver #(
        .SYSCLK_F(25000000)
    ) display_inst (
        .en(1'b1),
        .sys_clk(pll_25MHz),
        .clear_buffer(ct_button),
        .commit_char(commit_from_n2s),
        .SEGMENTS_2_LIGHT(segbus),
        .CHAR_SELECTED(numeric_an_sel),
        .CHAR_BRIGHTNESS(8'hFF),

        .SCLK(UI_7SEGSR_CLK),
        .DOUT(UI_7SEGSR_DIN),
        .RCLK(UI_7SEGSR_RCLK),
        .OE(UI_7SEGSR_OE)
    );



    reg redled;
    reg greenled;
    assign UI_RGBLED_G = ~greenled;
    assign UI_RGBLED_R = ~redled;

    initial begin
        bram_addr_pl   = 0;
        divvy       = 0;
        pll_50MHz   = 0;
        pll_25MHz   = 0;
        enable      = 0;

        redled      = 0;
        greenled    = 0;
    end

    always @ (posedge pll_100MHz) begin
        pll_50MHz   <= ~pll_50MHz;
    end

    always @ (posedge pll_50MHz) begin
        pll_25MHz   <= ~pll_25MHz;
    //    bram_addr <= bram_addr + 1;
        if(dn_button && !up_button) begin
            divvy <= divvy - 1;
            redled      <= !redled;
            greenled    <= 0;
        end
        else if(up_button && !dn_button) begin
            divvy <= divvy + 1;
            redled      <= 0;
            greenled    <= !greenled;
        end
        //if(UI_DPAD_D && !UI_DPAD_U) divvy <= divvy - 1;
        //if(UI_DPAD_U && !UI_DPAD_D) divvy <= divvy + 1;
        bram_addr_pl    <= bram_addr_bus;
    end
endmodule