/*
    02/14/2024 Joseph A. De Vico

    Clockwise (CW) -> +
    Counter Clockwise (CCW) -> -
*/


module Rotary_Encoder_PM
#(
    parameter D_RES = 16,
    parameter SYSCLK_F = 12000000,
    parameter SAMPLING_HZ = 400
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
    localparam CLKRATIO = SYSCLK_F / (SAMPLING_HZ * 2);
    localparam CLKDIV_W = $clog2(CLKRATIO);

    reg [(CLKDIV_W - 1):0] rotenc_sample_time;

    localparam ENC_0 = 2'b00;
    localparam ENC_1 = 2'b01;
    localparam ENC_2 = 2'b10;
    localparam ENC_3 = 2'b11;

    //localparam ENC_0_1 = {ENC_0, ENC_1};
    //localparam ENC_0_2 = {ENC_0, ENC_2};
    localparam ENC_0_1 = 4'b0001;
    localparam ENC_0_2 = 4'b0010;
    localparam ENC_1_0 = 4'b0100;
    localparam ENC_1_3 = 4'b0111;
    localparam ENC_2_0 = 4'b1000;
    localparam ENC_2_3 = 4'b1011;
    localparam ENC_3_1 = 4'b1101;
    localparam ENC_3_2 = 4'b1110;

    reg [1:0] curr_enc_state;
    reg [1:0] last_enc_state;

    initial begin
        rotenc_sample_time  = 0;
        ROT_ENC_CTR         = 0;
        ENC_CW              = 0;
        ENC_CCW             = 0;
        ROTENC_UPATE        = 0;

        curr_enc_state      = 0;
        last_enc_state      = 0;
    end

    always @ (posedge sys_clk) begin
        if(en) begin
            rotenc_sample_time  <= rotenc_sample_time + 1;
            if(!rotenc_sample_time) begin
                last_enc_state  <= curr_enc_state;
                curr_enc_state  <= {ENC_A, ENC_B};

                case ({last_enc_state[1:0], ENC_A, ENC_B})
                    ENC_0_1: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR - 1;
                        ENC_CCW     <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_0_2: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR + 1;
                        ENC_CW      <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_1_0: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR + 1;
                        ENC_CW      <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_1_3: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR - 1;
                        ENC_CCW     <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_2_0: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR - 1;
                        ENC_CCW     <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_2_3: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR + 1;
                        ENC_CW      <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_3_1: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR + 1;
                        ENC_CW      <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                    ENC_3_2: begin
                        ROT_ENC_CTR <= ROT_ENC_CTR - 1;
                        ENC_CCW     <= 1;
                        ROTENC_UPATE    <= 1;
                    end
                endcase
            end
            else if(clear_ctr) begin
                ROT_ENC_CTR <= 0;
            end

            if(ENC_CW) ENC_CW                   <= 0;
            if(ENC_CCW) ENC_CCW                 <= 0;
            if(ROTENC_UPATE) ROTENC_UPATE       <= 0;

        end
    end
endmodule