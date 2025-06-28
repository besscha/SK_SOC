
module men_wb(
    input logic clk,
    input logic rst,
    input logic stall,

    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic rd_en,
    output logic rd_en_out,
    input logic [31:0] rd,
    output logic [31:0] rd_out,
    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            rd_out <= 32'b0;
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
            rd_addr_out <= 5'b0;
            rd_en_out <= 1'b0;
        end else if (!stall) begin
            rd_out <= rd;
            pc_out <= pc;
            npc_out <= npc;
            rd_addr_out <= rd_addr;
            rd_en_out <= rd_en;
        end
    end

endmodule
