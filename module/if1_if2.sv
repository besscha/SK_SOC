module if1_if2(
    input logic clk,
    input logic rst,

    input logic flush,
    input logic stall,

    input logic [31:0] pc,
    output logic [31:0] pc_out,
    input logic [31:0] npc,
    output logic [31:0] npc_out
);
    always_ff @(posedge clk) begin
        if (rst | flush ) begin
            pc_out <= 32'h8000_0000;
            npc_out <= 32'h8000_0000;
        end else if (stall) begin
            pc_out <= pc_out;
            npc_out <= npc_out;
        end else begin
            pc_out <= pc;
            npc_out <= npc;
        end
    end

endmodule
