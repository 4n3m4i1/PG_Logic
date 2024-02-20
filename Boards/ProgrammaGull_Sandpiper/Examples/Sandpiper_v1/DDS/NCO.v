/*
    02/19/2024 - Really Bad NCO to drive 2^N LUT
*/

module NCO 
#(
    parameter DIV_W = 16,
    parameter ADDR_W = 8
)(
    input sys_clk,
    input en,
    input [(DIV_W - 1):0] divider,
    output [(ADDR_W - 1):0] address
);

    reg [(DIV_W - 1):0] div;
    reg [(DIV_W - 1):0] divider_buff;
    reg [(ADDR_W - 1):0] lut_addr;
    assign address = lut_addr;

    initial begin
        div         = 0;
        divider_buff = 0;
        lut_addr    = 0;
    end

    always @ (sys_clk) begin
        if(en) begin
            divider_buff <= divider;
            if(div >= divider_buff) begin
                address <= address + 1;
                div     <= {(DIV_W){1'b0}};
            end
            else  div   <= div + 1;
        end
    end

endmodule