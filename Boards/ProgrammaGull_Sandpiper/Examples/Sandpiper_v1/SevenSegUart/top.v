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
    
    // DPAD Buttons
    input           UI_DPAD_L,
    input           UI_DPAD_R,
    input           UI_DPAD_U,
    input           UI_DPAD_D,
    input           UI_DPAD_C,

    // User Button
    //input           UI_AUX_BUTTON,

    // User Switches
    //input           [7:0] UI_SW,
    
    // RGB LED (On high current driver)
    output          UI_RGBLED_R,
    output          UI_RGBLED_G,
    output          UI_RGBLED_B,

    // 7 Segment Shift Register
    output          UI_7SEGSR_CLK,
    output          UI_7SEGSR_RCLK,
    output          UI_7SEGSR_DIN,
    output          UI_7SEGSR_OE,

    input           UI_ENC_BUTTON,
    input           UI_ENC_A,
    input           UI_ENC_B

    // User LED Array Shift Register
    //output          UI_ULEDSR_DIN,
    //output          UI_ULEDSR_CLK
);

    /*
    // Internal +/- 10% oscillator
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

    assign UI_RGBLED_R = ~UI_DPAD_C;
    assign UI_RGBLED_G = ~UI_DPAD_U;
    assign UI_RGBLED_B = ~UI_DPAD_D;

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
    //sw2ledarray SWEEE (
    //    .sys_clk(CLK_12MHZ),
    //    .data(UI_SW),
    //    .led_do(UI_ULEDSR_DIN),
    //    .led_clk(UI_ULEDSR_CLK)
    //);

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
    wire [7:0] bright_wires;
    reg [2:0] charsel;

    // Will drive every segment on first run Alpha 0.1 boards
    PGL_Sandpiper_vAlpha_7Seg_Driver 
    #(
        .DISPLAY_HZ(200),
        .SYSCLK_F(12000000)
    ) SCREEN (
        .en(1'b1),
        .sys_clk(CLK_12MHZ),
        .clear_buffer(UI_ENC_BUTTON),
        .commit_char(update_screen || rotenc_ud),
        .SEGMENTS_2_LIGHT(segments),
        .CHAR_SELECTED(charsel),
        .CHAR_BRIGHTNESS(bright_wires),
        
        .SCLK(UI_7SEGSR_CLK),
        .DOUT(UI_7SEGSR_DIN),
        .RCLK(UI_7SEGSR_RCLK),
        .OE(UI_7SEGSR_OE)
    );
/*
module Rotary_Encoder_PM
#(
    parameter D_RES = 16,
    parameter SYSCLK_F = 12000000,
    parameter SAMPLING_HZ = 10
)(
    input en,
    input sys_clk,

    input ENC_A,
    input ENC_B,

    input clear_ctr,

    output reg [(D_RES - 1):0] ROT_ENC_CTR,

    output reg ENC_CW,
    output reg ENC_CCW,
    output reg ROTENC_UPATE
);
*/
    wire rotenc_ud;
    Rotary_Encoder_PM #(
        .D_RES(8)
    ) RotEnc (
        .en(1'b1),
        .sys_clk(CLK_12MHZ),
        .clear_ctr(1'b0),
        .ENC_A(UI_ENC_A),
        .ENC_B(UI_ENC_B),
        .ROT_ENC_CTR(bright_wires),
        .ROTENC_UPATE(rotenc_ud)
    );
/*
module button_debouncer
#(
    parameter SYSCLK_FREQ = 12000000,
    parameter DEBOUNCE_DELAY = 0.150
)(
    input       clk,
    input       D,
    output reg  Q
);
*/  
    wire Left_Button;
    button_debouncer #(
        .SYSCLK_FREQ(12000000)
    ) DPAD_Left_Button (
        .clk(CLK_12MHZ),
        .D(UI_DPAD_L),
        .Q(Left_Button)
    );

    wire Right_Button;
    button_debouncer #(
        .SYSCLK_FREQ(12000000)
    ) DPAD_Right_Button (
        .clk(CLK_12MHZ),
        .D(UI_DPAD_R),
        .Q(Right_Button)
    );


    initial begin
        ua0_tx          = 0;
        tx_loaded       = 0;
        charsel         = 0;
        bright          = 0;

   
    end

    always @ (posedge CLK_12MHZ) begin
        if(Right_Button) charsel    <= charsel + 1;
        if(Left_Button) charsel     <= charsel - 1;

        if(tx_load_ok) begin
            if (update_screen) begin
                ua0_tx      <= 8'h30 + UI_ENC_A + UI_ENC_B;
                tx_loaded   <= 1'b1;
            end
        end

        if(UI_ENC_BUTTON) charsel <= 0;

        if(tx_loaded) begin
            tx_loaded   <= 1'b0;
            charsel     <= charsel + 1;
            if(bright < 8'd64) bright <= 8'd64;
            else bright      <= bright + 8'd64;
        end
    end


endmodule