/*
    02/12/2024 Joseph A. De Vico
*/

module button_debouncer
#(
    parameter SYSCLK_FREQ = 12000000,
    parameter DEBOUNCE_DELAY = 0.150          // ms
)(
    input       clk,
    input       D,
    output reg  Q
);

    localparam DELAY_CYCLES_DB  =  $rtoi($floor(SYSCLK_FREQ * (DEBOUNCE_DELAY)));
    localparam DELAY_CT_BITS    =  $clog2(DELAY_CYCLES_DB);

    reg [(DELAY_CT_BITS - 1):0] delay_ctr;
    reg timeout_indic;

    initial begin
        Q               = 0;
        delay_ctr       = 0;
        timeout_indic   = 0;
    end


    always @ (posedge clk) begin
        if(!timeout_indic && D) begin 
            timeout_indic   <= 1;
            Q               <= 1;
        end

        if(timeout_indic) begin
            Q               <= 0;
            
            if(delay_ctr == DELAY_CYCLES_DB) begin
                timeout_indic   <= 0;
                delay_ctr       <= 0;
            end
            else delay_ctr      <= delay_ctr + 1;
        end

    end


endmodule