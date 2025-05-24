`include "param.vh"
module id_ex(
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
    input logic [1:0] multi_sel,
    output logic [1:0] multi_sel_out,
    input logic divider_sel,
    output logic divider_sel_out,
    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic [31:0] rs1,
    output logic [31:0] rs1_out,
    input logic [31:0] rs2,
    output logic [31:0] rs2_out,
    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic [11:0] csr_addr,
    output logic [11:0] csr_addr_out,
    input logic csr_we,
    output logic csr_we_out,
    input logic [2:0] csr_sel,
    output logic [2:0] csr_sel_out,
    input logic [31:0] csr_rdata,
    output logic [31:0] csr_rdata_out,
    input logic [4:0] csr_zimm,
    output logic [4:0] csr_zimm_out,
    input logic ecall,
    output logic ecall_out,
    input logic mret,
    output logic mret_out
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
            multi_sel_out <= 2'b10;
            divider_sel_out <= 1'b0;
            rs1_out <= 32'h0;
            rs2_out <= 32'h0;
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
            rd_addr_out <= 5'b0;
            csr_addr_out <= 12'b0;
            csr_we_out <= 1'b0;
            csr_sel_out <= 3'b0;
            csr_rdata_out <= 32'b0;
            csr_zimm_out <= 5'b0;
            ecall_out <= 1'b0;
            mret_out <= 1'b0;
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
            multi_sel_out <= multi_sel;
            divider_sel_out <= divider_sel;
            rs1_out <= rs1;
            rs2_out <= rs2;
            pc_out <= pc;
            npc_out <= npc;
            rd_addr_out <= rd_addr;
            csr_addr_out <= csr_addr;
            csr_we_out <= csr_we;
            csr_sel_out <= csr_sel;
            csr_rdata_out <= csr_rdata;
            csr_zimm_out <= csr_zimm;
            ecall_out <= ecall;
            mret_out <= mret;
        end
    end

endmodule
