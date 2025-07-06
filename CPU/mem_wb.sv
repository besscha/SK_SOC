
module mem_wb(
    input logic clk,
    input logic rst,
    input logic stall,

    input logic [31:0] alu_output,
    output logic [31:0] alu_output_out,
    input logic [31:0] dst_read_data,
    output logic [31:0] dst_read_data_out,
    input logic [2:0] dst_width,
    output logic [2:0] dst_width_out,

    input logic [4:0] rd_addr,
    output logic [4:0] rd_addr_out,
    input logic rd_en,
    output logic rd_en_out,
    input logic [2:0] rd_sel,
    output logic [2:0] rd_sel_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            alu_output_out <= 32'h0;
            dst_read_data_out <= 32'h0;
            dst_width_out <= 3'b0;
            npc_out <= 32'h8000_0000;
            rd_addr_out <= 5'b0;
            rd_en_out <= 1'b0;
            rd_sel_out <= 3'b0;
        end else if (!stall) begin
            alu_output_out <= alu_output; 
            dst_read_data_out <= dst_read_data;
            dst_width_out <= dst_width;
            npc_out <= npc;
            rd_addr_out <= rd_addr;
            rd_en_out <= rd_en;
            rd_sel_out <= rd_sel;
        end
    end

endmodule
