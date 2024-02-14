


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
    localparam SEG_CT = 8;

    localparam RCLK_COMMIT_2_OUTPUT = 1;
    localparam RCLK_CLR             = 0;

    localparam SEG_TIME_HZ          = DISPLAY_HZ * SEG_CT;
    localparam SEG_TIME_CYC         = SYSCLK_F / SEG_TIME_HZ;
    localparam SEG_TIME_W           = $clog2(SEG_TIME_CYC);

    localparam SHIFT_CLK_DIV        = SYSCLK_F / SHIFT_CLK_F;
    localparam SHIFT_CLK_DIV_W      = $clog2(SHIFT_CLK_DIV);

    reg [(SHIFT_CLK_DIV_W - 1):0] sclk_counter;
    reg [(SEG_TIME_W - 1):0] seg_clk_counter;

    reg [15:0] shifto;

    reg [3:0]   oa_state;
    localparam IDLE = 4'h0;
    localparam SHIF = 4'h1;
    localparam SHIF_H = 4'h2;
    localparam SHIF_L = 4'h3;
    localparam INTER = 4'h4;
    localparam COMMIT = 4'h5;

    reg [3:0]shctr;

    initial begin
        sclk    = 0;
        rclk    = 0;
        oe      = 0;
        dout    = 0;
        shifto  = 0;
        seg_clk_counter = 0;
        sclk_counter = 0;
        shctr = 0;
    end

    always @ (posedge sys_clk) begin
        seg_clk_counter <= seg_clk_counter + 1;
    end

    always @ (posedge sys_clk) begin
        case (oa_state)
            IDLE: begin
                if(seg_clk_counter == SEG_TIME_CYC) begin
                    shifto      <= {8'h00, segments};
                    oa_state    <= SHIF;
                    rclk        <= 1'b0;
                end
            end
            SHIF: begin
                dout        <= shifto[0];
                shifto      <= shifto >> 1;
                oa_state    <= SHIF_H;
                shctr       <= shctr + 1;
            end
            SHIF_H: begin
                sclk        <= 1'b1;
                oa_state    <= SHIF_L;
            end
            SHIF_L: begin
                sclk_counter <= sclk_counter + 1;
                if(sclk_counter == (SHIFT_CLK_DIV / 2)) sclk <= 1'b0;
                if(sclk_counter == SHIFT_CLK_DIV) begin
                    oa_state <= INTER;
                end
            end
            INTER: begin
                if(!shctr) oa_state <= COMMIT;
                else oa_state <= SHIF;
            end
            COMMIT: begin
                rclk        <= 1'b1;
                oa_state    <= IDLE;
            end
        endcase
    end
endmodule