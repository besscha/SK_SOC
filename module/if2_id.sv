`include "./module/param.vh"
/* verilator lint_off UNUSEDSIGNAL */
module if2_id(
    input logic clk,
    input logic rst,

    input logic stall,
    input logic flush,

    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic [31:0] ist_data,
    output logic [31:0] ist_data_out

);

    always_ff @(posedge clk) begin
        if (rst | flush ) begin
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
            ist_data_out <= `nop;
        end else if (stall) begin
            pc_out <= pc_out;
            npc_out <= npc_out;
            ist_data_out <= ist_data_out;
        end else begin
            pc_out <= pc;
            npc_out <= npc;
            ist_data_out <= ist_data;
        end
    end


endmodule
