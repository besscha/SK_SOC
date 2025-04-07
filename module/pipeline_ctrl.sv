module pipeline_ctrl(
    input logic nop_load_use,
    input logic branch_en,
    input logic EX_ecall,

    output logic pc_stall,
    output logic if1_if2_stall,
    output logic if2_id_stall,
    output logic id_ex_stall,
    output logic Icache_stall,
    output logic if1_if2_flush,
    output logic if2_id_flush,
    output logic id_ex_flush,
    output logic Icache_flush
);

    assign pc_stall = nop_load_use;
    assign if1_if2_stall = nop_load_use;
    assign if2_id_stall = nop_load_use;
    assign id_ex_stall = 1'b0;
    assign Icache_stall = nop_load_use;

    assign if1_if2_flush = branch_en || EX_ecall;
    assign if2_id_flush = branch_en || EX_ecall;
    assign id_ex_flush = branch_en || EX_ecall || nop_load_use;
    assign Icache_flush = branch_en || EX_ecall;

endmodule
