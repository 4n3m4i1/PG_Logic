

module blinky (
    input UI_DPAD_D,
    output UI_RGBLED_R
);

    assign UI_RGBLED_R = ~UI_DPAD_D;
endmodule