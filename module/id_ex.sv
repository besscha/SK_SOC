`include "module/param.vh"

module id_ex(
    input logic clk,
    input logic rst,

    input logic nop,
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
    input logic [1:0] rd_sel,
    output logic [1:0] rd_sel_out,
    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic [31:0] rs1,
    output logic [31:0] rs1_out,
    input logic [4:0] rs1_addr,
    output logic [4:0] rs1_addr_out,
    input logic [31:0] rs2,
    output logic [31:0] rs2_out,
    input logic [4:0] rs2_addr,
    output logic [4:0] rs2_addr_out,
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

    logic rd_we_reg;
    logic [31:0] imm_reg;
    logic [3:0] alu_op_reg;
    logic alu_input1_sel_reg;
    logic alu_input2_sel_reg;
    logic [3:0] branch_sel_reg;
    logic dst_write_we_reg;
    logic [2:0] dst_width_reg;
    logic [1:0] rd_sel_reg;
    logic [31:0] rs1_reg;
    logic [4:0] rs1_addr_reg;
    logic [31:0] rs2_reg;
    logic [4:0] rs2_addr_reg;
    logic [31:0] pc_reg;
    logic [31:0] npc_reg;
    logic [4:0] rd_addr_reg;
    logic [11:0] csr_addr_reg;
    logic csr_we_reg;
    logic [2:0] csr_sel_reg;
    logic [31:0] csr_rdata_reg;
    logic [4:0] csr_zimm_reg;
    logic ecall_reg;
    logic mret_reg;

    assign rd_we_out = nop ? 1'b0 : rd_we_reg;
    assign imm_out = nop ? 32'h0 : imm_reg;
    assign alu_op_out = nop ? 4'b0 : alu_op_reg;
    assign alu_input1_sel_out = nop ? 1'b0 : alu_input1_sel_reg;
    assign alu_input2_sel_out = nop ? 1'b0 : alu_input2_sel_reg;
    assign branch_sel_out = nop ? 4'b0 : branch_sel_reg;
    assign dst_write_we_out = nop ? 1'b0 : dst_write_we_reg;
    assign dst_width_out = nop ? 3'b0 : dst_width_reg;
    assign rd_sel_out = nop ? 2'b0 : rd_sel_reg;
    assign rs1_out = nop ? 32'h0 : rs1_reg;
    assign rs1_addr_out = rs1_addr_reg;
    assign rs2_out = nop ? 32'h0 : rs2_reg;
    assign rs2_addr_out = rs2_addr_reg;
    assign pc_out = nop ? 32'b0 : pc_reg;
    assign npc_out = nop ? 32'b0 : npc_reg;
    assign rd_addr_out = nop ? 5'b0 : rd_addr_reg;
    assign csr_addr_out = nop ? 12'b0 : csr_addr_reg;
    assign csr_we_out = nop ? 1'b0 : csr_we_reg;
    assign csr_sel_out = nop ? 3'b0 : csr_sel_reg;
    assign csr_rdata_out = nop ? 32'b0 : csr_rdata_reg;
    assign csr_zimm_out = nop ? 5'b0 : csr_zimm_reg;
    assign ecall_out = nop ? 1'b0 : ecall_reg;
    assign mret_out = nop ? 1'b0 : mret_reg;

    always_ff @(posedge clk) begin
        if (rst | flush) begin
            rd_we_reg <= 1'b0;
            imm_reg <= 32'h0;
            alu_op_reg <= 4'b0;
            alu_input1_sel_reg <= 1'b0;
            alu_input2_sel_reg <= 1'b0;
            branch_sel_reg <= 4'b0;
            dst_write_we_reg <= 1'b0;
            dst_width_reg <= 3'b0;
            rd_sel_reg <= 2'b0;
            rs1_reg <= 32'h0;
            rs1_addr_reg <= 5'h0;
            rs2_reg <= 32'h0;
            rs2_addr_reg <= 5'h0;
            pc_reg <= 32'b0;
            npc_reg <= 32'b0;
            rd_addr_reg <= 5'b0;
            csr_addr_reg <= 12'b0;
            csr_we_reg <= 1'b0;
            csr_sel_reg <= 3'b0;
            csr_rdata_reg <= 32'b0;
            csr_zimm_reg <= 5'b0;
            ecall_reg <= 1'b0;
            mret_reg <= 1'b0;
        end else if (nop) begin
            rd_we_reg <= rd_we_reg;
            imm_reg <= imm_reg;
            alu_op_reg <= alu_op_reg;
            alu_input1_sel_reg <= alu_input1_sel_reg;
            alu_input2_sel_reg <= alu_input2_sel_reg;
            branch_sel_reg <= branch_sel_reg;
            dst_write_we_reg <= dst_write_we_reg;
            dst_width_reg <= dst_width_reg;
            rd_sel_reg <= rd_sel_reg;
            rs1_reg <= rs1_reg;
            rs1_addr_reg <= rs1_addr_reg;
            rs2_reg <= rs2_reg;
            rs2_addr_reg <= rs2_addr_reg;
            pc_reg <= pc_reg;
            npc_reg <= npc_reg;
            rd_addr_reg <= rd_addr_reg;
            csr_addr_reg <= csr_addr_reg;
            csr_we_reg <= csr_we_reg;
            csr_sel_reg <= csr_sel_reg;
            csr_rdata_reg <= csr_rdata_reg;
            csr_zimm_reg <= csr_zimm_reg;
            ecall_reg <= ecall_reg;
            mret_reg <= mret_reg;
        end else begin
            rd_we_reg <= rd_we;
            imm_reg <= imm;
            alu_op_reg <= alu_op;
            alu_input1_sel_reg <= alu_input1_sel;
            alu_input2_sel_reg <= alu_input2_sel;
            branch_sel_reg <= branch_sel;
            dst_write_we_reg <= dst_write_we;
            dst_width_reg <= dst_width;
            rd_sel_reg <= rd_sel;
            rs1_reg <= rs1;
            rs1_addr_reg <= rs1_addr;
            rs2_reg <= rs2;
            rs2_addr_reg <= rs2_addr;
            pc_reg <= pc;
            npc_reg <= npc;
            rd_addr_reg <= rd_addr;
            csr_addr_reg <= csr_addr;
            csr_we_reg <= csr_we;
            csr_sel_reg <= csr_sel;
            csr_rdata_reg <= csr_rdata;
            csr_zimm_reg <= csr_zimm;
            ecall_reg <= ecall;
            mret_reg <= mret;
        end
    end

endmodule
