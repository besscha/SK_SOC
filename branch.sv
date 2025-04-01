`include "param.vh"

module branch(
    input logic [3:0] branch_sel,
    input logic zero_flag,
    input logic [31:0] alu_output,

    input logic [31:0] imm,  
    input logic [31:0] current_pc,
    input logic [31:0] current_npc,
    
    output logic [31:0] next_pc,
    output logic branch_en
);

    logic comp_result;  //为alu最后一位，可能为slt或者sltu的结果
    assign comp_result = alu_output[0];

    always_comb begin   //根据branch_sel和comp_result来决定是否跳转
        case(branch_sel)
            `branch_sel_beq: begin
                branch_en = (zero_flag == 1'b1);
            end
            `branch_sel_bne: begin
                branch_en = (zero_flag == 1'b0);
            end
            `branch_sel_blt: begin
                branch_en = comp_result;
            end
            `branch_sel_bge: begin
                branch_en = ~comp_result;
            end
            `branch_sel_bltu: begin
                branch_en = comp_result;
            end
            `branch_sel_bgeu: begin
                branch_en = ~comp_result;
            end
            `branch_sel_jal: begin
                branch_en = 1'b1;
            end
            `branch_sel_jalr: begin
                branch_en = 1'b1;
            end
            `branch_sel_scr: begin
                branch_en = 1'b1;
            end
            default: begin
                branch_en = 1'b0;
            end
        endcase
    end

    always_comb begin       //根据branch_sel和imm来决定下一个pc
        case (branch_sel)
            `branch_sel_beq,
            `branch_sel_bge,
            `branch_sel_blt,
            `branch_sel_bne,
            `branch_sel_bltu,
            `branch_sel_bgeu,
            `branch_sel_jal: begin
                next_pc = current_pc + imm;
            end
            `branch_sel_jalr: begin
                next_pc = alu_output;
            end
            `branch_sel_scr: begin
                next_pc = current_npc;
            end
            default: begin
                next_pc = 0;
            end
        endcase
    end

endmodule
