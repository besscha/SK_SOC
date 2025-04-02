`include "./module/param.vh"
/* verilator lint_off UNUSEDSIGNAL */
module if_id(
    input logic clk,
    input logic rst,

    input logic nop,
    input logic flush,

    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out,
    input logic [31:0] ist_data,
    output logic [31:0] ist_data_out

);

    logic [31:0] pc_reg[1:0];
    logic [31:0] npc_reg[1:0];
    logic [31:0] ist_data_reg;
    logic flush_reg[1:0];
    always_ff @(posedge clk) begin
        flush_reg[0] <= flush;
        flush_reg[1] <= flush_reg[0];
    end

    assign pc_out = nop ? 32'h0 : pc_reg[1];
    assign npc_out = nop ? 32'h0 : npc_reg[1];
    assign ist_data_out = nop ? `nop : ist_data_reg;

    always_ff @(posedge clk) begin
        if (rst | flush ) begin
            pc_reg[0] <= 32'h0;
            npc_reg[0] <= 32'h0;
            pc_reg[1] <= 32'h0;
            npc_reg[1] <= 32'h0;
            ist_data_reg <= `nop;
        end else if (nop) begin
            pc_reg <= pc_reg;
            npc_reg <= npc_reg;
            ist_data_reg <= ist_data_reg;
        end else begin
            pc_reg[0] <= pc;
            pc_reg[1] <= pc_reg[0];
            npc_reg[0] <= npc;
            npc_reg[1] <= npc_reg[0];
            ist_data_reg <= ist_data;
        end
    end


endmodule
