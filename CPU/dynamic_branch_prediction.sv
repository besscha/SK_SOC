`include "param.vh"

/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */

module dynamic_branch_prediction(
    input logic clk,
    input logic rst,

    input logic [31:0] pc,
    input logic [31:0] npc,
    input logic [31:0] ist,

    input logic [3:0] branch_sel,
    input logic branch_en,
    input logic [31:0] branch_ist_addr,

    output logic [31:0] next_pc,
    output logic branch_prediction_en
);
    logic B_en;
    assign B_en = ist[6:0] == `opcode_B;
    logic J_en;
    assign J_en = ist[6:0] == `opcode_J;
    logic I_jair_en;
    assign I_jair_en = ist[6:0] == `opcode_I_jair;

    logic [31:0] imm12_I;
    assign imm12_I = {{20{ist[31]}}, ist[31:20]};
    logic [31:0] imm13_B;
    assign imm13_B = {{19{ist[31]}}, ist[31], ist[7], ist[30:25], ist[11:8], 1'b0};
    logic [31:0] imm21_J;
    assign imm21_J = {{11{ist[31]}}, ist[31], ist[19:12], ist[20], ist[30:21], 1'b0};
    
    always_comb begin
        /* next_pc = npc;
        branch_prediction_en = 1'b0; */
        if (B_en && imm13_B[31] == 1)begin
            next_pc = pc + imm13_B;
            branch_prediction_en = 1'b1;
        end else if (J_en) begin
            next_pc = pc + imm21_J;
            branch_prediction_en = 1'b1;
        end else if (I_jair_en && RAS_en) begin
            next_pc = ras_top + imm12_I;
            branch_prediction_en = 1'b1;
        end else begin
            next_pc = npc;
            branch_prediction_en = 1'b0;
        end
    end

    logic BHT_jump_en;

    BHT bht_inst(
        .clk(clk),
        .sign(imm13_B[31] == 1),
        .ist_addr(pc),
        .jump_en(BHT_jump_en),
        .branch(branch_sel[3]),
        .branch_en(branch_en),
        .branch_ist_addr(branch_ist_addr)
    );

    logic [31:0] ras_top;
    logic RAS_en;
    RAS ras_inst(
        .clk(clk),
        .rst(rst),
        .ist(ist),
        .npc(npc),
        .ras_top(ras_top),
        .RAS_en(RAS_en)
    );

endmodule

module RAS(
    input logic clk,
    input logic rst,

    input logic [31:0] ist,
    input logic [31:0] npc,

    output logic [31:0] ras_top,
    output logic RAS_en
);

    logic [31:0] stack [0:7];
    logic [3:0] sp; // stack pointer

    logic [6:0] opcode;
    assign opcode = ist[6:0];
    logic [4:0] rd;
    assign rd = ist[11:7];
    logic [4:0] rs1;
    assign rs1 = ist[19:15];

    logic push_en;
    logic pop_en;

    assign push_en = (opcode == `opcode_J || opcode == `opcode_I_jair) && (rd == 5'b00001 || rd == 5'b00101);
    assign pop_en = opcode == `opcode_I_jair && (((rd == 5'b00001 || rd == 5'b00101) && ~(rs1 == 5'b00001 || rs1 == 5'b00101))
                                            || ((rd == 5'b00001 && rs1 == 5'b00101) || (rd == 5'b00001 && rs1 == 5'b00101)));

    assign RAS_en = pop_en;
    assign ras_top = stack[0]; // top of the stack

    always_ff @(posedge clk) begin
        if (rst) begin
            sp <= 0;
            stack <= '0;
        end else if (push_en && pop_en) begin
            stack[sp] <= npc;
        end else if (push_en) begin
            sp <= sp + 1;
            stack[sp] <= npc; // push npc onto the stack
        end else if (pop_en) begin
            sp <= sp - 1;
        end
    end

endmodule

module BHT(
    input logic clk,

    input logic sign,

    input logic [31:0] ist_addr,
    output logic jump_en,

    input logic branch,
    input logic branch_en,
    input logic [31:0] branch_ist_addr
);
    logic branch_reg;
    always_ff @(posedge clk) begin
        branch_reg <= branch;
    end

    logic [2:0] d,spo,dpo;
    
    assign jump_en = dpo == 3'b110 || dpo == 3'b111 || (~dpo[2] && sign); 
    always_comb begin
        if (branch_en) begin
            d = (spo[1:0] == 2'b11) ? 3'b111 : {1'b1,spo[1:0]} + 1; // Increment if branch taken
        end else begin
            d = (spo[1:0] == 2'b00) ? 3'b100 : {1'b1,spo[1:0]} - 1; // Decrement if branch not taken
        end
    end

    BHT_table bht_table_inst(
        .clk(clk),
        .a(ist_addr[8:2] ^ ist_addr[15:9]),
        .dpra(branch_ist_addr[8:2] ^ branch_ist_addr[15:9]),
        .d(d),
        .we(branch_reg),
        .spo(spo),
        .dpo(dpo)
    );

endmodule

`ifdef DEBUG

module BHT_table(
    input logic clk,
    input logic [6:0] a,
    input logic [6:0] dpra,
    input logic [2:0] d,
    input logic we,
    output logic [2:0] spo,
    output logic [2:0] dpo
);

    logic [2:0] BHT_table [0:127];
    integer i;
    initial begin
        for (i = 0; i < 128; i++) begin
            BHT_table[i] = 3'b010; // Initialize all entries to "taken"
        end
    end

    assign dpo = BHT_table[dpra];
    assign spo = BHT_table[a];

    always_ff @(posedge clk) begin
        if (we) begin
            BHT_table[a] <= d; // Write data to the table
        end
    end

endmodule //BHT_table

`endif