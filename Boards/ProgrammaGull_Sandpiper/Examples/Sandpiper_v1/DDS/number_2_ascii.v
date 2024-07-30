/*
*/


module num_2_seg 
#(
    parameter SYSCLK_F = 24000000,
    parameter MAX_INPUT = 65535,
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

    localparam SEG_CT = 8;
    localparam CAN_CT = 8;
    localparam INPUT_W = $clog2(MAX_INPUT);
    

    localparam  STATE_IDLE      = 4'd0;
    localparam  STATE_10000s    = 4'd1;
    localparam  STATE_STALL_0   = 4'd2;
    localparam  STATE_1000s     = 4'd3;
    localparam  STATE_STALL_1   = 4'd4;
    localparam  STATE_100s      = 4'd5;
    localparam  STATE_STALL_2   = 4'd6;
    localparam  STATE_10s       = 4'd7;
    localparam  STATE_STALL_3   = 4'd8;
    localparam  STATE_1s        = 4'd9;
    localparam  STATE_STALL_4   = 4'd10;
    reg [3:0] oa_state;

    localparam ASCII_NUMBER_OFS = 8'h30;

    reg [(INPUT_W - 1):0] inbuffer;
    reg [($clog2(ASCII_LUT_SIZE)):0] segctr;  

    initial begin
        commit              = 0;
        an_sel              = 0;
        ascii_lut_addr      = 0;
        inbuffer            = 0;
        cvt_in_prog         = 0;
    end

    always @ (posedge sys_clk) begin
        if(en) begin
            case (oa_state)
                STATE_IDLE: begin
                    if(cvt_num) begin
                        oa_state    <= STATE_START_CV;
                        an_sel      <= 0;
                        segctr      <= ASCII_NUMBER_OFS;
                        inbuffer    <= inputval;
                        cvt_in_prog <= 1;
                    end
                end
                STATE_10000s: begin
                    if(inbuffer > 16'd10000) begin
                        inbuffer    <= inbuffer - 16'd10000;
                        segctr      <= segctr + 1;
                    end
                    else begin
                        ascii_lut_addr  <= segctr;
                        segctr          <= ASCII_NUMBER_OFS;
                        oa_state        <= STATE_STALL_0;
                        an_sel          <= an_sel + 1;
                        commit          <= 1;
                    end
                end
                STATE_STALL_0: begin
                    commit      <= 0;
                    oa_state    <= STATE_1000s;
                end
                STATE_1000s: begin
                    if(inbuffer > 16'd1000) begin
                        inbuffer    <= inbuffer - 16'd1000;
                        segctr      <= segctr + 1;
                    end
                    else begin
                        ascii_lut_addr  <= segctr;
                        segctr          <= ASCII_NUMBER_OFS;
                        oa_state        <= STATE_STALL_1;
                        an_sel          <= an_sel + 1;
                        commit          <= 1;
                    end
                end
                STATE_STALL_1: begin
                    commit      <= 0;
                    oa_state    <= STATE_100s;
                end
                STATE_100s: begin
                    if(inbuffer > 16'd100) begin
                        inbuffer    <= inbuffer - 16'd100;
                        segctr      <= segctr + 1;
                    end
                    else begin
                        ascii_lut_addr  <= segctr;
                        segctr          <= ASCII_NUMBER_OFS;
                        oa_state        <= STATE_STALL_2;
                        an_sel          <= an_sel + 1;
                        commit          <= 1;
                    end
                end
                STATE_STALL_2: begin
                    commit      <= 0;
                    oa_state    <= STATE_10s;
                end
                STATE_10s: begin
                    if(inbuffer > 16'd10) begin
                        inbuffer    <= inbuffer - 16'd10;
                        segctr      <= segctr + 1;
                    end
                    else begin
                        ascii_lut_addr  <= segctr;
                        segctr          <= ASCII_NUMBER_OFS;
                        oa_state        <= STATE_STALL_3;
                        an_sel          <= an_sel + 1;
                        commit          <= 1;
                    end
                end
                STATE_STALL_3: begin
                    commit      <= 0;
                    oa_state    <= STATE_1s;
                end
                STATE_1s: begin
                    ascii_lut_addr      <= segctr + inbuffer[7:0];
                    oa_state            <= STATE_STALL_4;
                    an_sel              <= an_sel + 1;
                    commit              <= 1;
                end
                STATE_STALL_4: begin
                    commit      <= 0;
                    oa_state    <= STATE_IDLE;
                    cvt_in_prog <= 0;
                end
            endcase
        end
    end

endmodule