`include "param.vh"

module receive(
    input clk,
    input rst,

    input din,

    output logic din_vld,
    output logic [7:0] din_data
    );

    localparam FullT = 10416 * `BASIC_FREQUENCY / 100;
    localparam HalfT = 5208 * `BASIC_FREQUENCY / 100;
    localparam TOTAL_BITS = 8;

    logic [15:0] div_cnt;
    logic [4:0] din_cnt;

    localparam WAIT = 0;
    localparam RECEIVE = 1;
    logic current_state, next_state;
    always @(posedge clk) begin
        if (rst)
            current_state <= WAIT;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            WAIT:begin
                if (din == 0 && div_cnt == HalfT)
                    next_state = RECEIVE;
            end
            RECEIVE:begin
                if (din_cnt == TOTAL_BITS && div_cnt == FullT)
                    next_state = WAIT;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        if (rst)
            div_cnt <= 0;
        else if (current_state == WAIT && din == 0 || current_state == RECEIVE)
            if (div_cnt == FullT)
                div_cnt <= 0;
            else
                div_cnt <= div_cnt + 1;
        else
            div_cnt <= 0;
    end

    always_ff @( posedge clk ) begin
        if (rst)
            din_cnt <= 0;
        else if (current_state == RECEIVE) begin
           if (div_cnt == HalfT)
                din_cnt <= din_cnt + 1;
        end
        else
            din_cnt <= 0;
    end

    logic accpet_din;
    always_comb begin
        accpet_din = 0;
        if (current_state == RECEIVE && div_cnt == HalfT)
            accpet_din = 1;
        else
            accpet_din = 0;
    end

    assign din_vld = current_state == WAIT ? 1 : 0;

    always_ff @( posedge clk ) begin
        if (rst)
            din_data <= 0;
        else if (accpet_din)
            din_data <= din_data[7:1] | {din , 7'b0};
    end
endmodule
