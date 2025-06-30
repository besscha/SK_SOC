module ex2_men(
    input logic clk,
    input logic rst,
    input logic stall,

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
    output logic [31:0] alu_output_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            npc_out <= 32'h8000_0000;
            rd_we_out <= 1'b0;
            dst_width_out <= 3'b0;
            rd_sel_out <= 3'b0;
            alu_output_out <= 32'b0;
            rd_addr_out <= 5'b0;
        end else if (!stall) begin
            npc_out <= npc;
            rd_we_out <= rd_we;
            dst_width_out <= dst_width;
            rd_sel_out <= rd_sel;
            alu_output_out <= alu_output;
            rd_addr_out <= rd_addr;
        end
    end 
endmodule
