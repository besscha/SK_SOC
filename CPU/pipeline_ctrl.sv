module pipeline_ctrl(
    input logic nop_load_use,
    input logic branch_en,
    input logic Icache_miss,
    input logic Dcache_miss,

    output logic pc_stall,
    output logic if1_if2_stall,
    output logic if2_id_stall,
    output logic id_ex1_stall,
    output logic ex1_ex2_stall,
    output logic ex2_mem_stall,
    output logic mem_wb_stall,
    output logic Icache_stall,
    output logic if1_if2_flush,
    output logic if2_id_flush,
    output logic id_ex1_flush,
    output logic ex1_ex2_flush,
    output logic Icache_flush
);

    assign pc_stall = nop_load_use || Icache_miss || Dcache_miss;
    assign Icache_stall = (nop_load_use || Dcache_miss) && !branch_en;
    assign if1_if2_stall = (nop_load_use || Icache_miss || Dcache_miss) && !branch_en;
    assign if2_id_stall = nop_load_use || Dcache_miss;
    assign id_ex1_stall = 1'b0;
    assign ex1_ex2_stall = 1'b0;
    assign ex2_mem_stall = 1'b0;
    assign mem_wb_stall = 1'b0;

    assign if1_if2_flush = 1'b0;
    assign if2_id_flush = branch_en || (Icache_miss && !if2_id_stall);
    assign id_ex1_flush = branch_en || (nop_load_use && !id_ex1_stall);
    assign ex1_ex2_flush = branch_en;
    assign Icache_flush = 1'b0;

endmodule
