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
    /*
    input CLK_12MHZ
    */
    
    // UART Interface
    /*
    input   UART_RX,
    output  UART_TX,
    */

    // Switches
    /*
    input [7:0] SW,
    */
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

endmodule