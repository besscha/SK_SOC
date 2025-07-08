`include "param.vh"

/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */

module branch_prediction(
    input logic clk,
    input logic rst,

    input logic [31:0] pc,
    input logic [31:0] npc,
    input logic [31:0] ist,

    output logic [31:0] next_pc,
    output logic branch_prediction_en
);

    logic B_en;
    assign B_en = ist[6:0] == `opcode_B;
    logic J_en;
    assign J_en = ist[6:0] == `opcode_J;

    logic [31:0] imm13_B;
    assign imm13_B = {{19{ist[31]}}, ist[31], ist[7], ist[30:25], ist[11:8], 1'b0};
    logic [31:0] imm21_J;
    assign imm21_J = {{11{ist[31]}}, ist[31], ist[19:12], ist[20], ist[30:21], 1'b0};

    always_comb begin
        if (B_en && imm13_B[31] == 1)begin
            next_pc = pc + imm13_B;
            branch_prediction_en = 1'b1;
        end else if (J_en) begin
            next_pc = pc + imm21_J;
            branch_prediction_en = 1'b1;
        end else begin
            next_pc = npc;
            branch_prediction_en = 1'b0;
        end
    end

endmodule