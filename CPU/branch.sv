`include "param.vh"

module branch(
    input logic [3:0] branch_sel,
    input logic [31:0] alu_output,
    input logic [31:0] current_npc,
    input logic [31:0] next_pc,

    input logic [31:0] rs1,
    input logic [31:0] rs2,
    
    output logic [31:0] branch_pc,
    output logic branch_en
);

    logic branch_en_temp;
    assign branch_en = branch_pc != next_pc; //输出跳转使能信号

    logic equal;
    logic less;
    logic less_unsigned;
    assign equal = (rs1 == rs2); //判断两个寄存器的值是否相等
    assign less = ($signed(rs1) < $signed(rs2)); //判断rs1是否小于rs2
    assign less_unsigned = ($unsigned(rs1) < $unsigned(rs2)); //无符号比较

    always_comb begin   //根据branch_sel和comp_result来决定是否跳转
        case(branch_sel)
            `branch_sel_beq: begin
                branch_en_temp = equal;
            end
            `branch_sel_bne: begin
                branch_en_temp = ~equal;
            end
            `branch_sel_blt: begin
                branch_en_temp = less;
            end
            `branch_sel_bge: begin
                branch_en_temp = ~less;
            end
            `branch_sel_bltu: begin
                branch_en_temp = less_unsigned;
            end
            `branch_sel_bgeu: begin
                branch_en_temp = ~less_unsigned;
            end
            `branch_sel_jal,
            `branch_sel_scr,
            `branch_sel_jalr: begin
                branch_en_temp = 1'b1;
            end
            default: begin
                branch_en_temp = 1'b0;
            end
        endcase
    end

    always_comb begin
        if (branch_en_temp) begin
            branch_pc = alu_output;
        end else begin
            branch_pc = current_npc;
        end
    end

endmodule
