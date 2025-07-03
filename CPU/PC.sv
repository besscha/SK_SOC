`include "param.vh"

module PC(
    input clk,
    input rst,

    input logic [31:0] branch_pc,
    input logic branch_en,

    input logic [31:0] prediction_pc,
    input logic prediction_en,

    input logic stall,

    output logic [31:0] pc,
    output logic [31:0] npc
);
    logic [31:0] pc_reg= 32'h8000_0000;
    
    assign pc = branch_en ? branch_pc :
                prediction_en ? prediction_pc :
                pc_reg;
    assign npc = pc + 4;

    always_ff @(posedge clk) begin
        if(rst) begin
            pc_reg <= 32'h8000_0000;
        end else if(branch_en && stall) begin
            pc_reg <= branch_pc;
        end else if(stall) begin
            pc_reg <= pc_reg;
        end else begin
            pc_reg <= npc;
        end        
    end

endmodule
