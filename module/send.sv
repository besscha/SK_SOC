module send(
    input clk,
    input rst,

    output logic dout,
    output logic dout_end,

    input dout_vld,
    input [7:0] dout_data
    );

    //localparam FullT = 867;
    localparam FullT = 10416;
    localparam TOTAL_BITS = 9;
    logic [15:0] div_cnt;          
    logic [4:0] dout_cnt;

    localparam WAIT = 0;
    localparam SEND = 1;
    reg current_state, next_state;
    always @(posedge clk) begin
        if (rst)
            current_state <= WAIT;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            WAIT:begin
                if (dout_vld)
                    next_state = SEND;
            end
            SEND:begin
                if (dout_cnt == TOTAL_BITS + 1)
                    next_state = WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        if (current_state == WAIT)
            dout_end <= 1;
        else
            dout_end <= 0;
    end

    always @(posedge clk) begin
        if (rst)
            div_cnt <= 0;
        else if (current_state == SEND)begin
            if (div_cnt == FullT)
                div_cnt <= 0;
            else
                div_cnt <= div_cnt + 1;
        end
        else
            div_cnt <= 0 ;
    end

    always @(posedge clk) begin
        if (rst)
            dout_cnt <= 0;
        else if (current_state == SEND)begin
            if (div_cnt == FullT)
                dout_cnt <= dout_cnt + 1;
        end
        else
            dout_cnt <= 0;
    end

    reg [7:0] dout_data_reg;
    always @(posedge clk) begin
        if (rst)
            dout_data_reg <= 0;
        else if (dout_vld && current_state == WAIT)
            dout_data_reg <= dout_data;
    end

    always @(posedge clk) begin
        if (rst)
            dout <= 1;
        else begin
            if (current_state == WAIT)
                dout <= 1;
            else if (current_state == SEND && div_cnt == 0) begin
               if (dout_cnt == 0)
                    dout <= 0;
                else if (dout_cnt == TOTAL_BITS)
                    dout <= 1;
                else
                    dout <= dout_data_reg[dout_cnt - 1];
            end
        end
    end

endmodule
