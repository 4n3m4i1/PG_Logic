

module SANDPIPER_DDS (
    input CLK_12MHZ,
    input UI_DPAD_U,
    input UI_DPAD_D,
    output UI_RGBLED_B,
    output UI_GPIO_1
);

    reg pll_50MHz;
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
        .en(1'b1),
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

    initial begin
        bram_addr_pl   = 0;
        divvy       = 0;
        pll_50MHz   = 0;
        enable      = 0;
    end

    always @ (posedge pll_100MHz) begin
        pll_50MHz <= ~pll_50MHz;
    end

    always @ (posedge pll_50MHz) begin
    //    bram_addr <= bram_addr + 1;
        if(dn_button && !up_button) divvy <= divvy - 1;
        if(up_button && !dn_button) divvy <= divvy + 1;
        bram_addr_pl    <= bram_addr_bus;
    end
endmodule