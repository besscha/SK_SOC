module ex_men(
    input logic clk,
    input logic rst,
    input logic stall,

    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic rd_we,
    output logic rd_we_out,
    input logic [2:0] dst_width,
    output logic [2:0] dst_width_out,
    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic [2:0] rd_sel,
    output logic [2:0] rd_sel_out,
    input logic [31:0] alu_output,
    output logic [31:0] alu_output_out,
    input logic [11:0] csr_addr,
    output logic [11:0] csr_addr_out,
    input logic csr_we,
    output logic csr_we_out,
    input logic [31:0] csr_wdata,
    output logic [31:0] csr_wdata_out,
    input logic [31:0] csr_rdata,
    output logic [31:0] csr_rdata_out,
    input logic ecall,
    output logic ecall_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
            rd_we_out <= 1'b0;
            dst_width_out <= 3'b0;
            rd_sel_out <= 3'b0;
            alu_output_out <= 32'b0;
            rd_addr_out <= 5'b0;
            csr_addr_out <= 12'b0;
            csr_we_out <= 1'b0;
            csr_wdata_out <= 32'b0;
            csr_rdata_out <= 32'b0;
            ecall_out <= 1'b0;
        end else if (!stall) begin
            pc_out <= pc;
            npc_out <= npc;
            rd_we_out <= rd_we;
            dst_width_out <= dst_width;
            rd_sel_out <= rd_sel;
            alu_output_out <= alu_output;
            rd_addr_out <= rd_addr;
            csr_addr_out <= csr_addr;
            csr_we_out <= csr_we;
            csr_wdata_out <= csr_wdata;
            csr_rdata_out <= csr_rdata;
            ecall_out <= ecall;
        end
    end 
endmodule
