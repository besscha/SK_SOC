/* verilator lint_off DECLFILENAME */
module divider(
    input clk,
    input rst,

    input [31:0] dividend_input,
    input [31:0] divisor_input,
    input sign,

    input start,
    output logic [31:0] quotient_output,
    output logic [31:0] remainder_output,
    output logic stall
    );


    enum logic [2:0] {IDLE, INIT ,DIVIDE, DONE} state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        if (rst) begin
            next_state = IDLE;
        end else if (state == IDLE) begin
            if (start) begin
                if (divisor_input == divisor && dividend_input == dividend) begin
                    next_state = IDLE;
                end else begin
                    next_state = INIT;
                end
            end
        end else if (state == INIT) begin
            next_state = DIVIDE;
        end else if (state == DIVIDE) begin
            if (count == 31-left_size) begin
                next_state = DONE;
            end
        end else if (state == DONE) begin
            next_state = IDLE;
        end
    end

    logic [31:0] dividend;
    logic [31:0] divisor;

    always_ff @(posedge clk) begin
        if (rst) begin
            dividend <= 0;
            divisor <= 0;
        end else if (state == IDLE && start) begin
            dividend <= !sign ? dividend_input :
                      dividend_input[31] ? ~dividend_input + 1 : dividend_input;
            divisor  <= !sign ? divisor_input :
                     divisor_input[31] ? ~divisor_input + 1 : divisor_input;
        end
    end

    //为1时结果为负数
    logic quotient_sign;
    logic remainder_sign;

    always_ff @(posedge clk) begin
        if (rst) begin
            quotient_sign <= 0;
            remainder_sign <= 0;
        end else if (state == IDLE && start) begin
            quotient_sign <=(divisor_input != 0) && (dividend_input[31] ^ divisor_input[31])  && sign;
            remainder_sign <= dividend_input[31] && sign;
        end
    end

    logic [4:0] left_size_ln;

    ln ln_inst (
        .dividend(dividend),
        .left_size(left_size_ln)
    );
    logic [4:0] left_size;
    assign left_size = divisor == 0 ? 0 : left_size_ln;

    logic [64:0] RQ;
    logic [32:0] remainder_reg;
    assign remainder_reg = RQ[64:32];
    logic [31:0] devisor_reg;
    logic [5:0] count;

    always_ff @(posedge clk) begin
        if(rst || state == IDLE) begin
            count <= 0;
        end else if (state == DIVIDE) begin
            count <= count + 1;
        end
    end

    logic signed [32:0] sub;
    assign sub = remainder_reg - {1'b0, devisor_reg};

    always_ff @(posedge clk) begin
        if (rst)begin
            RQ <= 0;
            devisor_reg <= 0;
        end else if (state == INIT) begin
            RQ <= {32'b0, dividend, 1'b0} << left_size;
            devisor_reg <= divisor;
        end else if (state == DIVIDE) begin
            if (sub >= 0) begin
                RQ <= {sub[31:0],RQ[31:0],1'b1};
            end else begin
                RQ <= {RQ[63:0],1'b0};
            end
        end
    end

    assign quotient_output = quotient_sign ? -RQ[31:0] : RQ[31:0];
    assign remainder_output = remainder_sign ? -RQ[64:33] : RQ[64:33];
    always_comb begin
        if (next_state != IDLE) begin
            stall = 1;
        end else begin
            stall = 0;
        end
    end

endmodule

module ln(
    input [31:0] dividend,

    output [4:0] left_size
);

    logic [15:0] dividend_16;
    logic dividend_16_en;

    assign dividend_16_en = dividend[31:16] == 0;
    assign dividend_16 = dividend_16_en ? dividend[15:0] : dividend[31:16];

    logic [7:0] dividend_8;
    logic dividend_8_en;

    assign dividend_8_en = dividend_16[15:8] == 0;
    assign dividend_8 = dividend_8_en ? {dividend_16[7:0]} : {dividend_16[15:8]};

    logic [3:0] dividend_4;
    logic dividend_4_en;

    assign dividend_4_en = dividend_8[7:4] == 0;
    assign dividend_4 = dividend_4_en ? dividend_8[3:0] : dividend_8[7:4];

    logic [1:0] dividend_2;
    logic dividend_2_en;

    assign dividend_2_en = dividend_4[3:2] == 0;
    assign dividend_2 = dividend_2_en ? dividend_4[1:0] : dividend_4[3:2];
    
    assign left_size = {dividend_16_en, dividend_8_en, dividend_4_en, dividend_2_en,1'b0} +
                        (dividend_2 == 2'b00 ? 5'h2 :
                        dividend_2 == 2'b01 ? 5'h1 :
                        dividend_2 == 2'b10 ? 5'h0 :
                        5'h0);
endmodule
