module pipeline_ctrl(
    input logic nop_load_use,
    input logic nop_multi_use,
    input logic branch_en,
    input logic EX_ecall,
    input logic divider_stall,
    input logic Icache_miss,
    input logic Dcache_miss,

    output logic pc_stall,
    output logic if1_if2_stall,
    output logic if2_id_stall,
    output logic id_ex_stall,
    output logic ex_men_stall,
    output logic men_wb_stall,
    output logic Icache_stall,
    output logic if1_if2_flush,
    output logic if2_id_flush,
    output logic id_ex_flush,
    output logic Icache_flush
);

    assign pc_stall = nop_load_use || nop_multi_use || divider_stall || Icache_miss || Dcache_miss;
    assign Icache_stall = nop_load_use || nop_multi_use || divider_stall || Dcache_miss;
    assign if1_if2_stall = nop_load_use || nop_multi_use || divider_stall || Icache_miss || Dcache_miss;
    assign if2_id_stall = nop_load_use || nop_multi_use || divider_stall || Dcache_miss;
    assign id_ex_stall = divider_stall;
    assign ex_men_stall = divider_stall;
    assign men_wb_stall = 1'b0;

    assign if1_if2_flush = branch_en || EX_ecall;
    assign if2_id_flush = branch_en || EX_ecall || (Icache_miss && !if2_id_stall);
    assign id_ex_flush = branch_en || EX_ecall || (nop_load_use || nop_multi_use && !id_ex_stall);
    assign Icache_flush = branch_en || EX_ecall;

endmodule
