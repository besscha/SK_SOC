
`include "./module/param.vh"

module PC(
    input clk,
    input rst,

    input logic [31:0] branch_pc,
    input logic branch_en,

    input logic nop,

    output logic [31:0] pc,
    output logic [31:0] npc
);
    logic [31:0] pc_reg;
    assign pc = pc_reg;
    assign npc = pc + 4;

    always_ff @(posedge clk) begin
        if(rst) begin
            pc_reg <= 32'b0;
        end else if(nop) begin
            pc_reg <= pc_reg;
        end else if(branch_en) begin
            pc_reg <= branch_pc;
        end else begin
            pc_reg <= npc;
        end        
    end

endmodule
