/*
    PGL Sandpiper Project Template
    Author
    Date
    Description

    Additional Data/Comments
*/

module top
(
    // External Clock
    
    input CLK_12MHZ,
    
    
    // UART Interface
    
    input           UART_RX,
    output wire     UART_TX,
    

    input           UI_DPAD_L,
    input           UI_DPAD_R,
    input           UI_DPAD_U,
    input           UI_DPAD_D,

    input           UI_AUX_BUTTON,

    input           [7:0] UI_SW,
    output          UI_RGBLED_R,
    //output          UI_RGBLED_G,
    output          UI_RGBLED_B,

    output          UI_7SEGSR_CLK,
    output          UI_7SEGSR_RCLK,
    output          UI_7SEGSR_DIN,
    output          UI_7SEGSR_OE,

    output          UI_ULEDSR_DIN,
    output          UI_ULEDSR_CLK
);

    /*
    wire HF_CLK;
    SB_HFOSC internal_HF_osc
    (
        .CLKHFEN(1'b1),
        .CLKHFPU(1'b1),
        .CLKHF(HF_CLK)
    );
    // 0b00 = 48 MHz
    // 0b01 = 24 MHz
    // 0b10 = 12 MHz
    // 0b11 = 6  MHz
    defparam internal_HF_osc.CLKHF_DIV = "0b00";
    */

/*
module sw2ledarray
#(
    parameter LED_HZ = 400,
    parameter SYSCLK_F = 12000000,
    parameter LED_SHIFT_HZ = 2000000
)
(
    input   sys_clk,
    input   [(LED_CT - 1):0] data,
    input   [(DIM_RES - 1):0] brightness,
    
    output reg  led_do,
    output reg  led_clk
);
*/
    // Switch -> LED array, updates on its own clock
    //  Adding external update would be easy as well.
    sw2ledarray SWEEE (
        .sys_clk(CLK_12MHZ),
        .data(UI_SW),
        .led_do(UI_ULEDSR_DIN),
        .led_clk(UI_ULEDSR_CLK)
    );

/*
module uart_controller
#(
    parameter SYSCLK_FREQ = 24000000,
    parameter BAUDRATE = 500000,
    parameter BYTE_W = 8
)
(
    input enable,
    input sys_clk,

    // RX
    input wire RX_LINE,
    output wire [(BYTE_W - 1):0]RX_DATA,
    output wire RX_DATA_READY,


    // TX
    input wire [(BYTE_W - 1):0]TX_DATA,
    input wire TX_LOAD,
    output wire TX_LOAD_OKAY,
    output wire TX_LINE
);

*/

    wire    [7:0] ua0_rx;
    wire    ua0_rx_rdy;

    reg     [7:0] ua0_tx;
    wire    tx_load_ok;
    reg     tx_loaded;

    // Wow a uart
    uart_controller 
    #(
        .SYSCLK_FREQ(12000000),
        .BAUDRATE(115200)
    ) ua0 (
        .enable(1'b1),
        .sys_clk(CLK_12MHZ),
        
        .RX_LINE(UART_RX),
        .RX_DATA(ua0_rx),
        .RX_DATA_READY(ua0_rx_rdy),

        .TX_DATA(ua0_tx),
        .TX_LOAD(tx_loaded),
        .TX_LOAD_OKAY(tx_load_ok),
        .TX_LINE(UART_TX)
    );

/*
module uart_2_segment
#(
    BYTE_W = 8
)
(
    input clk,
    input en,

    input [(BYTE_W - 1):0]char_in,
    input cvt,

    output reg [(BYTE_W - 1):0]seg_out,
    output reg seg_ud
);
*/
    wire update_screen;
    assign UI_RGBLED_R = ~update_screen;
    assign UI_RGBLED_B = ~ua0_rx_rdy;
    wire [7:0] segments;

    // ASCII -> 7 Segment conversion
    uart_2_segment u2s
    (
        .clk(CLK_12MHZ),
        .en(1'b1),
        .char_in(ua0_rx),
        .cvt(ua0_rx_rdy),
        .seg_out(segments),
        .seg_ud(update_screen)
    );

    /*
    module PGL_Sandpiper_vAlpha_7Seg_Driver
#(
    parameter DISPLAY_HZ    = 800,          // Full Display Update Rate
    parameter SYSCLK_F      = 24000000,     // Input Clock Freq.
    parameter SHIFT_CLK_F   = 2000000       // SCLK Rate
)
(
    input en,
    input sys_clk,
    input clear_buffer,
    input commit_char,
    input [(SEG_CT - 1):0]          SEGMENTS_2_LIGHT,
    input [($clog2(CAN_CT) - 1):0]  CHAR_SELECTED,
    input [(DIMMING_REG_W - 1):0]   CHAR_BRIGHTNESS,

    output reg  SCLK,
    output reg  DOUT,
    output reg  RCLK,
    output wire OE
);
    */

    reg [7:0] bright;
    reg [2:0] charsel;

    // Broken display driver :(
    PGL_Sandpiper_vAlpha_7Seg_Driver 
    #(
        .DISPLAY_HZ(200),
        .SYSCLK_F(12000000)
    ) SCREEN (
        .en(1'b1),
        .sys_clk(CLK_12MHZ),
        .clear_buffer(UI_AUX_BUTTON),
        .commit_char(update_screen),
        .SEGMENTS_2_LIGHT(segments),
        .CHAR_SELECTED(charsel),
        .CHAR_BRIGHTNESS(bright),
        
        .SCLK(UI_7SEGSR_CLK),
        .DOUT(UI_7SEGSR_DIN),
        .RCLK(UI_7SEGSR_RCLK),
        .OE(UI_7SEGSR_OE)
    );
/*
module drive_a_segment
#(
    parameter DISPLAY_HZ    = 800,          // Full Display Update Rate
    parameter SYSCLK_F      = 24000000,     // Input Clock Freq.
    parameter SHIFT_CLK_F   = 2000000       // SCLK Rate
)(
    input sys_clk,
    input [7:0]segments,

    output reg sclk,
    output reg rclk,
    output reg oe,
    output reg dout
);
*/
//    drive_a_segment das (
//        .sys_clk(CLK_12MHZ),
//        .segments(segments),
//        .sclk(UI_7SEGSR_CLK),
//        .rclk(UI_7SEGSR_RCLK),
//        .oe(UI_7SEGSR_OE),
//        .dout(UI_7SEGSR_DIN)
//    );

    initial begin
        ua0_tx          = 0;
        tx_loaded       = 0;
        charsel         = 1;
        bright          = 8'd200;
    end

    always @ (posedge CLK_12MHZ) begin
        if(tx_load_ok) begin
            if (update_screen) begin
                ua0_tx      <= segments;
                tx_loaded   <= 1'b1;
            end
            
        end

        if(tx_loaded) tx_loaded <= 1'b0;
    end


endmodule