/*

*/

module sw2ledarray
#(
    parameter LED_HZ        = 1000,
    parameter SYSCLK_F      = 12000000,
    parameter LED_SHIFT_HZ  = 2000000,
    parameter DIMMING_STEPS = 256
)
(
    input                   sys_clk,
    input                   [(LED_CT - 1):0] data,
    
    output reg              led_do,
    output reg              led_clk
);

    localparam DIM_RES = $clog2(DIMMING_STEPS);
    
    localparam LED_CT = 8;

    localparam LED_TIME_CYC         = SYSCLK_F / LED_HZ;
    localparam LED_TIME_W           = $clog2(LED_TIME_CYC);

    reg [(LED_TIME_W - 1):0] led_refresh_ctr;

    localparam SHIFT_TIME_CYC       = SYSCLK_F / LED_SHIFT_HZ;
    localparam SHIFT_TIME_W         = $clog2(SHIFT_TIME_CYC);

    reg [(SHIFT_TIME_W - 1):0] led_shift_ctr;

    reg [(LED_CT - 1):0] shifto;
    reg [3:0] shift_ctr;

    reg [1:0] oa_state;
    localparam IDLE     = 2'h0;
    localparam DOUT     = 2'h1;
    localparam SHIFT_H  = 2'h2;
    localparam SHIFT_L  = 2'h3;

    

    initial begin
        led_do          = 0;
        led_clk         = 0;
        led_refresh_ctr = 0;
        led_shift_ctr   = 0;
        shifto          = 0;
        oa_state        = 0;
        shift_ctr       = 0;
    end


    always @ (posedge sys_clk) begin
        led_refresh_ctr <= led_refresh_ctr + 1;
    end

    always @ (posedge sys_clk) begin
        case (oa_state)
            IDLE: begin
                if(!led_refresh_ctr) begin
                    oa_state        <= DOUT;
                    shifto          <= data;
                    led_clk         <= 1'b0;
                    led_shift_ctr   <= 0;
                    shift_ctr       <= 0;
                end
            end
            DOUT: begin
                led_do      <= shifto[0];
                oa_state    <= SHIFT_H;
            end
            SHIFT_H: begin
                
                shifto      <= shifto >> 1;
                shift_ctr   <= shift_ctr + 1;
                led_clk     <= 1'b1;
                oa_state    <= SHIFT_L;
            end
            SHIFT_L: begin
                led_shift_ctr <= led_shift_ctr + 1;
                if(led_shift_ctr == (SHIFT_TIME_CYC / 2)) led_clk <= 1'b0;
                if(led_shift_ctr == SHIFT_TIME_CYC) begin
                    if(shift_ctr < (LED_CT + 1)) oa_state  <= DOUT;
                    else begin
                        oa_state        <= IDLE;
                        shift_ctr       <= 0;
                    end
                    led_shift_ctr       <= 0;
                end
            end
        endcase
    end
endmodule

