/*
    02/14/2024  Joseph A. De Vico
    ADC084S101 SPI Interface
    https://www.ti.com/lit/ds/symlink/adc084s101.pdf

    Shift on FALLING
    Read on RISING
    SCK Idle HIGH

    16 clk read cycle

    DO -> {7:0 Ctrl Reg}{7:0 Dont Care}
    DI -> 0000{7:0 Data}0000

    Note: Channel selection applies to the N+1th sample
        Basically what you send in this moment applies to the
        next sample
*/


module ADC084S101_Interface
#(
    parameter SYSCLK_F = 12000000,
    parameter D_W = 8,
    parameter NUM_CHANS = 4,
    parameter FS = 500000
)(
    input   en,
    input   rst,
    input   sys_clk,

    input   single_trig,
    input   free_running,
    output  reg channel_rq,
    input   [($clog2(NUM_CHANS) - 1):0] chan_sel,
    
    output  reg [(D_W - 1):0] data,
    output  reg [($clog2(NUM_CHANS) - 1):0] data_aligned_channel,
    input   data_read,
    output  data_present,

    output  csn,
    output  reg sck,
    output  sdo,
    input   sdi
);
    localparam CLK_F_RATIO = ((SYSCLK_F / (FS * 16)) / 2) - 1;
    localparam SCK_CT_W = $clog2(CLK_F_RATIO);

    reg [(SCK_CT_W - 1):0] SCK_CLK_DIV;

    localparam SCK_HIGH = 1'b1;
    localparam SCK_LOW  = 1'b0;

    localparam CS_ASSERT    = 1'b1;
    localparam CS_DEASSERT  = 1'b0;
    reg CSN;
    assign csn = !CSN;

    localparam IDLE         = 3'd0;
    localparam SHIFT_PRE    = 3'd1;
    localparam SHIFT_OUT    = 3'd2;
    localparam SHIFT_IN     = 3'd3;
    localparam SHIFT_TERM   = 3'd4;

    reg [2:0]   oa_state;
    reg [4:0]   shift_ctr;
    reg [16:0]  SDO_Shift_Reg;
    reg [15:0]  SDI_Shift_Reg;

    assign sdo = SDO_Shift_Reg[15];

    reg set_dr;
    reg data_ready;
    assign data_present = data_ready;

    reg [($clog2(NUM_CHANS) - 1):0]tmp_chan_reg;

    initial begin
        oa_state            = IDLE;
        SDI_Shift_Reg       = 0;
        SDO_Shift_Reg       = 0;
        channel_rq          = 0;
        shift_ctr           = 0;
        sck                 = 0;
        CSN                 = 0;
        data_ready          = 0;
        SCK_CLK_DIV         = 0;

        data                = 0;
        data_aligned_channel = 0;
        tmp_chan_reg        = 0;
        set_dr              = 0;
    end


    always @ (posedge sys_clk) begin
        if(en && !rst) begin
            case (oa_state)
                IDLE: begin
                    sck     <= SCK_HIGH;
                    if(free_running || single_trig) begin
                        oa_state    <= SHIFT_PRE;
                        SCK_CLK_DIV <= 1;
                        shift_ctr   <= 0;
                        channel_rq  <= 0;
                        set_dr      <= 0;
                    end
                end
                SHIFT_PRE: begin
                    tmp_chan_reg    <= chan_sel;
                    SDO_Shift_Reg   <= {4'b0000, chan_sel[($clog2(NUM_CHANS) - 1):0], {(16 - 3 - $clog2(NUMCHANS)){1'b0}}};
                    oa_state        <= SHIFT_OUT;
                end
                SHIFT_OUT: begin
                    channel_rq      <= 1;
                    if(!SCK_CLK_DIV) begin
                        sck             <= SCK_LOW;
                        shift_ctr       <= shift_ctr + 1;
                        SDO_Shift_Reg   <= {SDO_Shift_Reg[15:0], 1'b0};
                    end
                    
                    if(SCK_CLK_DIV == CLK_F_RATIO) begin
                        if(shift_ctr == 16) begin
                            oa_state    <= SHIFT_TERM;
                        end
                        else oa_state    <= SHIFT_IN;
                        SCK_CLK_DIV <= 0;
                    end
                    else SCK_CLK_DIV <= SCK_CLK_DIV + 1;
                end
                SHIFT_IN: begin
                    if(!SCK_CLK_DIV) begin
                        sck             <= SCK_HIGH;
                        SDI_Shift_Reg   <= {SDI_Shift_Reg[14:0], sdi};
                    end
                    
                    if(SCK_CLK_DIV == CLK_F_RATIO) begin
                        oa_state    <= SHIFT_OUT;
                        SCK_CLK_DIV <= 0;
                    end
                    else SCK_CLK_DIV <= SCK_CLK_DIV + 1;
                end
                SHIFT_TERM: begin
                    data_aligned_channel    <= tmp_chan_reg;
                    data    <= SDI_Shift_Reg[11:4];
                    set_dr  <= 1;
                    oa_state    <= IDLE;
                end
            endcase
        end
        else begin
            oa_state        <= IDLE;
            SDI_Shift_Reg   <= {(16){1'b0}};
            SDO_Shift_Reg   <= {(17){1'b0}};
            sck             <= SCK_HIGH;
            CSN             <= CS_DEASSERT;
            SCK_CLK_DIV     <= 0;
            set_dr          <= 0;
            data_aligned_channel <= 0;
            data            <= 0;
        end
    end

    always @ (posedge sys_clk) begin
        if(en && !rst) begin
            if(set_dr) begin
                data_ready      <= 1;
            end
            else if(data_read) begin
                data_ready      <= 0;
            end
        end
        else data_ready <= 0;
    end

endmodule