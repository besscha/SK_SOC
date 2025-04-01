

module ex_men(
    input logic clk,
    input logic rst,

    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic rd_we,
    output logic rd_we_out,
    input logic dst_write_we,
    output logic dst_write_we_out,
    input logic [2:0] dst_width,
    output logic [2:0] dst_width_out,
    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic [1:0] rd_sel,
    output logic [1:0] rd_sel_out,
    input logic [31:0] alu_output,
    output logic [31:0] alu_output_out,
    input logic [31:0] rs2,
    output logic [31:0] rs2_out,
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

    logic [31:0] pc_reg;
    logic [31:0] npc_reg;
    logic rd_we_reg;
    logic dst_write_we_reg;
    logic [2:0] dst_width_reg;
    logic [1:0] rd_sel_reg;
    logic [4:0] rd_addr_reg;
    logic [31:0] alu_output_reg;
    logic [31:0] rs2_reg;
    logic [11:0] csr_addr_reg;
    logic csr_we_reg;
    logic [31:0] csr_wdata_reg;
    logic [31:0] csr_rdata_reg;
    logic ecall_reg;

    assign pc_out = pc_reg;
    assign npc_out = npc_reg;
    assign rd_we_out = rd_we_reg;
    assign dst_write_we_out = dst_write_we_reg;
    assign dst_width_out = dst_width_reg;
    assign rd_sel_out = rd_sel_reg;
    assign alu_output_out = alu_output_reg;
    assign rs2_out = rs2_reg;
    assign rd_addr_out = rd_addr_reg;
    assign csr_addr_out = csr_addr_reg;
    assign csr_we_out = csr_we_reg;
    assign csr_wdata_out = csr_wdata_reg;
    assign csr_rdata_out = csr_rdata_reg;
    assign ecall_out = ecall_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_reg <= 32'b0;
            npc_reg <= 32'b0;
            rd_we_reg <= 1'b0;
            dst_write_we_reg <= 1'b0;
            dst_width_reg <= 3'b0;
            rd_sel_reg <= 2'b0;
            alu_output_reg <= 32'b0;
            rs2_reg <= 32'b0;
            rd_addr_reg <= 5'b0;
            csr_addr_reg <= 12'b0;
            csr_we_reg <= 1'b0;
            csr_wdata_reg <= 32'b0;
            csr_rdata_reg <= 32'b0;
            ecall_reg <= 1'b0;
        end else begin
            pc_reg <= pc;
            npc_reg <= npc;
            rd_we_reg <= rd_we;
            dst_write_we_reg <= dst_write_we;
            dst_width_reg <= dst_width;
            rd_sel_reg <= rd_sel;
            alu_output_reg <= alu_output;
            rs2_reg <= rs2;
            rd_addr_reg <= rd_addr;
            csr_addr_reg <= csr_addr;
            csr_we_reg <= csr_we;
            csr_wdata_reg <= csr_wdata;
            csr_rdata_reg <= csr_rdata;
            ecall_reg <= ecall;
        end
    end

    
endmodule
