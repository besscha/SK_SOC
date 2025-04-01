module men_wb(
    input logic clk,
    input logic rst,

    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic rd_en,
    output logic rd_en_out,
    input logic [1:0] rd_sel,
    output logic [1:0] rd_sel_out,
    input logic [31:0] dst_data,
    output logic [31:0] dst_data_out,
    input logic [31:0] alu_out,
    output logic [31:0] alu_out_out,
    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic [31:0] csr_rdata,
    output logic [31:0] csr_rdata_out,
    input logic csr_we,
    output logic csr_we_out,
    input logic [11:0] csr_addr,
    output logic [11:0] csr_addr_out,
    input logic [31:0] csr_wdata,
    output logic [31:0] csr_wdata_out,
    input logic ecall,
    output logic ecall_out
);

    logic [1:0] rd_sel_reg;
    logic [31:0] dst_data_reg;
    logic [31:0] alu_out_reg;
    logic [31:0] pc_reg;
    logic [31:0] npc_reg;
    logic [4:0] rd_addr_reg;
    logic rd_en_reg;
    logic [31:0] csr_rdata_reg;
    logic csr_we_reg;
    logic [11:0] csr_addr_reg;
    logic [31:0] csr_wdata_reg;
    logic ecall_reg;

    assign rd_sel_out = rd_sel_reg;
    assign dst_data_out = dst_data_reg;
    assign alu_out_out = alu_out_reg;
    assign pc_out = pc_reg;
    assign npc_out = npc_reg;
    assign rd_addr_out = rd_addr_reg;
    assign rd_en_out = rd_en_reg;
    assign csr_rdata_out = csr_rdata_reg;
    assign csr_we_out = csr_we_reg;
    assign csr_addr_out = csr_addr_reg;
    assign csr_wdata_out = csr_wdata_reg;
    assign ecall_out = ecall_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            rd_sel_reg <= 2'b0;
            dst_data_reg <= 32'b0;
            alu_out_reg <= 32'b0;
            pc_reg <= 32'b0;
            npc_reg <= 32'b0;
            rd_addr_reg <= 5'b0;
            rd_en_reg <= 1'b0;
            csr_rdata_reg <= 32'b0;
            csr_we_reg <= 1'b0;
            csr_addr_reg <= 12'b0;
            csr_wdata_reg <= 32'b0;
            ecall_reg <= 1'b0;
        end else begin
            rd_sel_reg <= rd_sel;
            dst_data_reg <= dst_data;
            alu_out_reg <= alu_out;
            pc_reg <= pc;
            npc_reg <= npc;
            rd_addr_reg <= rd_addr;
            rd_en_reg <= rd_en;
            csr_rdata_reg <= csr_rdata;
            csr_we_reg <= csr_we;
            csr_addr_reg <= csr_addr;
            csr_wdata_reg <= csr_wdata;
            ecall_reg <= ecall;
        end
    end

endmodule
