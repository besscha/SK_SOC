`include "./module/param.vh"

module exp_commit(
    input logic ecall,

    output logic exp_en,
    output logic [4:0] exp_code
);

    assign exp_en = ecall;
    always_comb begin
        if (ecall) begin
            exp_code = `ecall_code;
        end
        else begin
            exp_code = 5'b0;
        end
    end

endmodule
