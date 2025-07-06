`include "param.vh"

/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */

module dynamic_branch_prediction(
    input logic clk,

    input logic [31:0] pc,
    input logic [31:0] npc,
    input logic [31:0] ist,

    input logic [3:0] branch_sel,
    input logic branch_en,
    input logic [31:0] branch_ist_addr,

    output logic [31:0] next_pc,
    output logic branch_predicion_en
);
    logic B_en;
    assign B_en = ist[6:0] == `opcode_B;
    logic J_en;
    assign J_en = ist[6:0] == `opcode_J;

    logic [31:0] imm13_B;
    assign imm13_B = {{19{ist[31]}}, ist[31], ist[7], ist[30:25], ist[11:8], 1'b0};
    logic [31:0] imm21_J;
    assign imm21_J = {{11{ist[31]}}, ist[31], ist[19:12], ist[20], ist[30:21], 1'b0};

    always_comb begin
        if (B_en && BHT_jump_en)begin
            next_pc = pc + imm13_B;
            branch_predicion_en = 1'b1;
        end else if (J_en) begin
            next_pc = pc + imm21_J;
            branch_predicion_en = 1'b1;
        end else begin
            next_pc = npc;
            branch_predicion_en = 1'b0;
        end
    end

    logic BHT_jump_en;

    BHT bht_inst(
        .clk(clk),
        .ist_addr(pc),
        .jump_en(BHT_jump_en),
        .branch(branch_sel[3]),
        .branch_en(branch_en),
        .branch_ist_addr(branch_ist_addr)
    );

endmodule

module BHT(
    input logic clk,

    input logic [31:0] ist_addr,
    output logic jump_en,

    input logic branch,
    input logic branch_en,
    input logic [31:0] branch_ist_addr
);

    logic [1:0] d,spo;
    logic [6:0] index;
    
    assign index = branch_en ? branch_ist_addr[8:2] ^ branch_ist_addr[15:9] :
                            ist_addr[8:2] ^ ist_addr[15:9];
    assign jump_en = spo == 2'b10 || spo == 2'b11; 
    always_comb begin
        if (branch) begin
            if (branch_en) begin
                d = (spo == 2'b11) ? 2'b11 : spo + 1; // Increment if branch taken
            end else begin
                d = (spo == 2'b00) ? 2'b00 : spo - 1; // Decrement if branch not taken
            end
        end
    end

    BHT_table bht_table_inst(
        .clk(clk),
        .a(index),
        .d(d),
        .we(branch_en),
        .spo(spo)
    );

endmodule

`ifdef DEBUG

module BHT_table(
    input logic clk,
    input logic [6:0] a,
    input logic [1:0] d,
    input logic we,
    output logic [1:0] spo
);

    logic [1:0] BHT_table [0:127];
    integer i;
    initial begin
        for (i = 0; i < 128; i++) begin
            BHT_table[i] = 2'b10; // Initialize all entries to "taken"
        end
    end

    assign spo = BHT_table[a];

    always_ff @(posedge clk) begin
        if (we) begin
            BHT_table[a] <= d; // Write data to the table
        end
    end

endmodule //BHT_table

`endif