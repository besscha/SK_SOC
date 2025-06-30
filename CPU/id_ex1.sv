`include "param.vh"
module id_ex1(
    input logic clk,
    input logic rst,

    input logic stall,
    input logic flush,

    input logic rd_we,
    output logic rd_we_out,
    input logic [31:0] imm,
    output logic [31:0] imm_out,
    input logic [3:0] alu_op,
    output logic [3:0] alu_op_out,
    input logic alu_input1_sel,
    output logic alu_input1_sel_out,
    input logic alu_input2_sel,
    output logic alu_input2_sel_out,
    input logic [3:0] branch_sel,
    output logic [3:0] branch_sel_out,
    input logic dst_write_we,
    output logic dst_write_we_out,
    input logic [2:0] dst_width,
    output logic [2:0] dst_width_out,
    input logic [2:0] rd_sel,
    output logic [2:0] rd_sel_out,
    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic [31:0] rs1,
    output logic [31:0] rs1_out,
    input logic [31:0] rs2,
    output logic [31:0] rs2_out,
    input logic forward_rs1_men,
    output logic forward_rs1_men_out,
    input logic forward_rs2_men,
    output logic forward_rs2_men_out,
    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic [31:0] next_pc,
    output logic [31:0] next_pc_out
);

    always_ff @(posedge clk) begin
        if (rst | flush) begin
            rd_we_out <= 1'b0;
            imm_out <= 32'h0;
            alu_op_out <= 4'b0;
            alu_input1_sel_out <= 1'b0;
            alu_input2_sel_out <= 1'b0;
            branch_sel_out <= 4'b0;
            dst_write_we_out <= 1'b0;
            dst_width_out <= 3'b0;
            rd_sel_out <= 3'b0;
            rs1_out <= 32'h0;
            rs2_out <= 32'h0;
            forward_rs1_men_out <= 1'b0;
            forward_rs2_men_out <= 1'b0;
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
            next_pc_out <= 32'h8000_0000;
            rd_addr_out <= 5'b0;
        end else if (!stall) begin
            rd_we_out <= rd_we;
            imm_out <= imm;
            alu_op_out <= alu_op;
            alu_input1_sel_out <= alu_input1_sel;
            alu_input2_sel_out <= alu_input2_sel;
            branch_sel_out <= branch_sel;
            dst_write_we_out <= dst_write_we;
            dst_width_out <= dst_width;
            rd_sel_out <= rd_sel;
            rs1_out <= rs1;
            rs2_out <= rs2;
            forward_rs1_men_out <= forward_rs1_men;
            forward_rs2_men_out <= forward_rs2_men;
            pc_out <= pc;
            npc_out <= npc;
            next_pc_out <= next_pc;
            rd_addr_out <= rd_addr;
        end
    end

endmodule
