`include "param.vh"

module soc(
    input logic clk,
    input logic rst,

    output logic flush_output,
    //output logic nop_output,

    AXI  icache_axi,

    output logic [29:0] dst_addr,
    output logic [31:0] dst_write_data,
    input logic [31:0] dst_read_data,
    output logic [3:0] dst_write_we
);
    assign flush_output = branch_en | EX_ecall;

    logic nop_load_use;
    logic nop_multi_use;
    assign nop_load_use = (EX_rd_sel == `rd_sel_dst_data) && (EX_rd_addr == ID_rs1_addr || EX_rd_addr == ID_rs2_addr) && (EX_rd_we == 1'b1);
    assign nop_multi_use = (EX_multi_sel != 2'b10) && (EX_rd_addr == ID_rs1_addr || EX_rd_addr == ID_rs2_addr);

    pipeline_ctrl u_pipeline_ctrl(
        .nop_load_use       	(nop_load_use       ),
        .nop_multi_use      	(nop_multi_use      ),
        .branch_en               	(branch_en               	),
        .EX_ecall               	(EX_ecall               	),
        .divider_stall         	(divider_stall         	),
        .Icache_miss          	(Icache_miss          	),
        .pc_stall               	(pc_stall              	),
        .if1_if2_stall              ( if1_if2_stall),
        .if2_id_stall               (if2_id_stall),
        .id_ex_stall                (id_ex_stall ),
        .ex_men_stall               (ex_men_stall),
        .men_wb_stall               (men_wb_stall),
        .Icache_stall               (Icache_stall),
        .if1_if2_flush              (if1_if2_flush),
        .if2_id_flush               (if2_id_flush),
        .id_ex_flush                (id_ex_flush ),
        .Icache_flush               (Icache_flush)
    );

    //---------------------------------
    // IF1

    logic [31:0] IF1_pc;
    logic [31:0] IF1_npc;
    logic [31:0] branch_pc;
    logic branch_en;
    logic pc_stall;

    PC u_PC(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .branch_pc 	(branch_pc  ),
        .branch_en 	(branch_en  ),
        .stall      (pc_stall        ),
        .pc        	(IF1_pc         ),
        .npc       	(IF1_npc        )
    );

    //---------------------------------
    
    logic if1_if2_stall;
    logic if1_if2_flush;

    if1_if2 u_if1_if2(
        .clk     	(clk      ),
        .rst     	(rst      ),
        .flush   	(if1_if2_flush    ),
        .stall     	(if1_if2_stall      ),
        .pc      	(IF1_pc       ),
        .pc_out  	(IF2_pc   ),
        .npc     	(IF1_npc      ),
        .npc_out 	(IF2_npc  )
    );
    //---------------------------------
    // IF2

    logic [31:0] IF2_pc;
    logic [31:0] IF2_npc;
    logic [31:0] IF2_ist_data;
    logic Icache_stall;
    logic Icache_flush;
    logic Icache_miss;
    
    Icache u_Icache(
        .clk          	(clk           ),
        .rst          	(rst           ),
        .flush        	(Icache_flush         ),
        .stall          (Icache_stall           ),
        .addr           (IF1_pc),
        .data           (IF2_ist_data),
        .Icache_miss     (Icache_miss     ),
        .axi_if          (icache_axi      )
    );
    

    //---------------------------------

    logic if2_id_stall;
    logic if2_id_flush;

    if2_id u_if2_id(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .stall      (if2_id_stall      ),
        .flush     	(if2_id_flush     ),
        .pc        	(IF2_pc         ),
        .pc_out    	(ID_pc         ),
        .npc       	(IF2_npc        ),
        .npc_out   	(ID_npc        ),
        .ist_data  	(IF2_ist_data   ),
        .ist_data_out	(ID_ist_data   )
    );

    //--------------------------------------
    // ID

    logic [31:0] ID_pc;
    logic [31:0] ID_npc;
    logic [31:0] ID_ist_data;

    logic [4:0] ID_rs1_addr;
    logic [4:0] ID_rs2_addr;
    logic [4:0] ID_rd_addr;

    logic ID_rd_we;
    logic [31:0] ID_imm;
    logic [3:0] ID_alu_op;
    logic ID_alu_input1_sel;
    logic ID_alu_input2_sel;
    logic [3:0] ID_branch_sel;
    logic ID_dst_write_we;
    logic [2:0] ID_dst_width;
    logic [2:0] ID_rd_sel;
    logic [1:0] ID_multi_sel;
    logic ID_divider_sel;
    logic [11:0] ID_csr_addr;
    logic ID_csr_we;
    logic [2:0] ID_csr_sel;
    logic [4:0] ID_csr_zimm;
    logic ID_ecall;
    logic ID_mret;

    decoder u_decoder(
        .ist    	(ID_ist_data     ),
        .rs1_addr    	(ID_rs1_addr     ),
        .rs2_addr    	(ID_rs2_addr     ),
        .imm    	(ID_imm     ),
        .rd_addr     	(ID_rd_addr     	),
        .rd_we    	(ID_rd_we     ),
        .alu_input1_sel 	(ID_alu_input1_sel  ),
        .alu_input2_sel 	(ID_alu_input2_sel  ),
        .alu_op 	(ID_alu_op  ),
        .branch_sel 	(ID_branch_sel  ),
        .dst_write_we 	(ID_dst_write_we  ),
        .dst_width 	(ID_dst_width  ),
        .rd_sel 	(ID_rd_sel  ),
        .multi_sel 	(ID_multi_sel  ),
        .divider_sel 	(ID_divider_sel  ),
        .csr_addr 	(ID_csr_addr  ),
        .csr_we    	(ID_csr_we     ),
        .csr_sel   	(ID_csr_sel    ),
        .csr_zimm  	(ID_csr_zimm   ),
        .ecall     	(ID_ecall      ),
        .mret      	(ID_mret       )
    );
    
    logic [31:0] ID_rs1;
    logic [31:0] ID_rs2;
    logic [31:0] rd;
    logic [31:0] ID_csr_rdata;
    
    regfile u_regfile(
        .clk      	(clk       ),
        .rst      	(rst       ),
        .rs1_addr 	(ID_rs1_addr  ),
        .rs1      	(ID_rs1       ),
        .rs2_addr 	(ID_rs2_addr  ),
        .rs2      	(ID_rs2       ),
        .rd_addr  	(WB_rd_addr   ),
        .rd_we    	(WB_rd_we     ),
        .rd       	(rd        )
    );

    logic [31:0] mtvec_global;
    logic [31:0] mepc_global;

    CSR u_CSR(
        .clk      	(clk       ),
        .rst      	(rst       ),
        .csr_rdata	(ID_csr_rdata   ),
        .csr_addr 	(ID_csr_addr  ),
        .csr_waddr  (WB_csr_addr   ),
        .csr_wdata	(WB_csr_wdata       ),
        .csr_we   	(WB_csr_we  ),
        .mtvec_global 	(mtvec_global  ),
        .mepc_global 	(mepc_global  ),
        .mepc_in 	( WB_pc ),
        .mcause_in 	({WB_exp_code[4],27'b0,WB_exp_code[3:0]} ),
        .exp_in   	(WB_exp_en  ),
        .mret_in  	(EX_mret  )
    );

    //--------------------------------------

    logic id_ex_stall;
    logic id_ex_flush;

    id_ex u_id_ex(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .stall      (id_ex_stall        ),
        .flush     	(id_ex_flush     	),
        .rd_we     	(ID_rd_we      ),
        .rd_we_out 	(EX_rd_we  ),
        .imm       	(ID_imm     ),
        .imm_out   	(EX_imm    ),
        .alu_op    	(ID_alu_op  ),
        .alu_op_out 	(EX_alu_op  ),
        .alu_input1_sel 	(ID_alu_input1_sel  ),
        .alu_input1_sel_out 	(EX_alu_input1_sel  ),
        .alu_input2_sel 	(ID_alu_input2_sel  ),
        .alu_input2_sel_out 	(EX_alu_input2_sel  ),
        .branch_sel 	(ID_branch_sel  ),
        .branch_sel_out 	(EX_branch_sel  ),
        .dst_write_we 	(ID_dst_write_we  ),
        .dst_write_we_out 	(EX_dst_write_we  ),
        .dst_width  	(ID_dst_width  	),
        .dst_width_out  	(EX_dst_width  	),
        .rd_addr    	(ID_rd_addr    	),
        .rd_addr_out 	(EX_rd_addr    	),
        .rd_sel     	(ID_rd_sel     	),
        .rd_sel_out  	(EX_rd_sel     	),
        .multi_sel  	(ID_multi_sel  	),
        .multi_sel_out	(EX_multi_sel  	),
        .divider_sel 	(ID_divider_sel 	),
        .divider_sel_out	(EX_divider_sel 	),
        .rs1        	(ID_rs1        	),
        .rs1_out    	(EX_rs1        	),
        .rs1_addr   	(ID_rs1_addr    ),
        .rs1_addr_out   	(EX_rs1_addr    ),
        .rs2        	(ID_rs2         ),
        .rs2_addr   	(ID_rs2_addr    ),
        .rs2_addr_out   	(EX_rs2_addr    ),
        .rs2_out    	(EX_rs2        	),
        .pc         	(ID_pc        	),
        .pc_out     	(EX_pc        	),
        .npc        	(ID_npc       	),
        .npc_out    	(EX_npc       	),
        .csr_addr   	(ID_csr_addr    ),
        .csr_addr_out   	(EX_csr_addr    ),
        .csr_we     	(ID_csr_we      ),
        .csr_we_out 	(EX_csr_we      ),
        .csr_sel    	(ID_csr_sel     ),
        .csr_sel_out 	(EX_csr_sel     ),
        .csr_rdata  	(ID_csr_rdata   ),
        .csr_rdata_out  	(EX_csr_rdata   ),
        .csr_zimm   	(ID_csr_zimm    ),
        .csr_zimm_out   	(EX_csr_zimm    ),
        .ecall      	(ID_ecall       ),
        .ecall_out  	(EX_ecall       ),
        .mret       	(ID_mret        ),
        .mret_out   	(EX_mret        )
    );  
    //--------------------------------------
    // EX

    logic EX_rd_we;
    logic [31:0] EX_imm;
    logic [3:0] EX_alu_op;
    logic EX_alu_input1_sel;
    logic EX_alu_input2_sel;
    logic [3:0] EX_branch_sel;
    logic EX_dst_write_we;
    logic [2:0] EX_dst_width;
    logic [2:0] EX_rd_sel;
    logic [1:0] EX_multi_sel;
    logic EX_divider_sel;
    logic [4:0] EX_rd_addr;
    logic [31:0] EX_rs1;
    logic [4:0] EX_rs1_addr;
    logic [31:0] EX_rs2;
    logic [4:0] EX_rs2_addr;
    logic [31:0] EX_pc;
    logic [31:0] EX_npc;

    logic [31:0] alu_input1;
    logic [31:0] alu_input2;
    logic [31:0] EX_alu_output;
    logic zero_flag;

    logic [31:0] alu_rs1;
    logic [31:0] alu_rs2;

    logic EX_ecall;
    logic EX_mret;

    always_comb begin
        case(forward_rs1)
            2'b00:
                alu_rs1 = EX_rs1;
            2'b01:
                alu_rs1 = MEN_alu_output;
            2'b10:
                alu_rs1 = rd;
            default:
                alu_rs1 = EX_rs1;
        endcase
    end

    always_comb begin
        case(forward_rs2)
            2'b00:
                alu_rs2 = EX_rs2;
            2'b01:
                alu_rs2 = MEN_alu_output;
            2'b10:
                alu_rs2 = rd;
            default:
                alu_rs2 = EX_rs2;
        endcase
    end

    assign alu_input1 = (EX_alu_input1_sel == 1'b0) ? alu_rs1 : EX_pc;
    assign alu_input2 = (EX_alu_input2_sel == 1'b0) ? alu_rs2 : EX_imm;

    ALU u_ALU(
        .alu_input1 	(alu_input1  ),
        .alu_input2 	(alu_input2  ),
        .alu_op     	(EX_alu_op      ),
        .alu_output 	(EX_alu_output  ),
        .zero_flag  	(zero_flag   )
    );

    logic [11:0] EX_csr_addr;
    logic EX_csr_we;
    logic [2:0] EX_csr_sel;
    logic [31:0] EX_csr_rdata;
    logic [4:0] EX_csr_zimm;
    logic [31:0] EX_csr_wdata;
    
    priv u_priv(
        .csr_rdata 	(EX_csr_rdata  ),
        .rs        	(alu_rs1        	),
        .zimm      	(EX_csr_zimm      	),
        .csr_sel   	(EX_csr_sel    ),
        .csr_wdata 	(EX_csr_wdata  )
    );
    
    assign dst_addr = EX_alu_output[31:2];
    Dcache u_Dcache(
        .rs2       	(alu_rs2        	),
        .addr      	(EX_alu_output[1:0]      	),
        .dst_width 	(EX_dst_width 	),
        .data_out 	(dst_write_data 	),
        .dst_write_we(EX_dst_write_we 	),
        .dst_write_we_out  	(dst_write_we  	)
    );

    multiplier u_multiplier(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .symbolic  	(EX_multi_sel 	),
        .x         	(alu_rs1    ),
        .y         	(alu_rs2    ),
        .p         	(MEN_multiplier_output)
    );
    
    logic [31:0] MEN_quotient_output;
    logic [31:0] MEN_remainder_output;
    logic divider_start;
    assign divider_start = (EX_rd_sel == `rd_sel_div || EX_rd_sel == `rd_sel_rem) ? 1'b1 : 1'b0;
    logic divider_stall;

    divider u_divider(
        .clk              	(clk               ),
        .rst              	(rst               ),
        .dividend_input   	(alu_rs1    ),
        .divisor_input    	(alu_rs2     ),
        .sign             	(EX_divider_sel              ),
        .start            	(divider_start             ),
        .quotient_output  	(MEN_quotient_output   ),
        .remainder_output 	(MEN_remainder_output  ),
        .stall             	(divider_stall              )
    );
    

    //--------------------------------------
    logic ex_men_stall;

    ex_men u_ex_men(
        .clk              	(clk               ),
        .rst              	(rst               ),
        .stall            	(ex_men_stall       ),
        .pc               	(EX_pc                ),
        .pc_out             (MEN_pc             ),
        .npc              	(EX_npc               ),
        .npc_out          	(MEN_npc          	 ),
        .rd_we            	(EX_rd_we             ),
        .rd_we_out        	(MEN_rd_we         ),
        .dst_width        	(EX_dst_width         ),
        .dst_width_out    	(MEN_dst_width     ),
        .rd_addr          	(EX_rd_addr           ),
        .rd_addr_out        (MEN_rd_addr        ),
        .rd_sel           	(EX_rd_sel            ),
        .rd_sel_out       	(MEN_rd_sel        ),
        .alu_output       	(EX_alu_output        ),
        .alu_output_out   	(MEN_alu_output    ),
        .csr_addr         	(EX_csr_addr          ),
        .csr_addr_out       (MEN_csr_addr       ),
        .csr_we           	(EX_csr_we            ),
        .csr_we_out         (MEN_csr_we         ),
        .csr_wdata        	(EX_csr_wdata         ),
        .csr_wdata_out      (MEN_csr_wdata      ),
        .csr_rdata        	(EX_csr_rdata         ),
        .csr_rdata_out      (MEN_csr_rdata),
        .ecall           	(EX_ecall            ),
        .ecall_out          (MEN_ecall          )
    );
    
    //--------------------------------------
    // MEM

    logic [31:0] MEN_alu_output;
    logic [31:0] MEN_dst_data;
    logic [31:0] MEN_pc;
    logic [31:0] MEN_npc;
    logic [2:0] MEN_dst_width;
    logic MEN_rd_we;
    logic [2:0] MEN_rd_sel;
    logic [4:0] MEN_rd_addr;

    logic MEN_ecall;

    logic [63:0] MEN_multiplier_output;

    read_ctrl u_read_ctrl(
        .dst_read_data       (dst_read_data),
        .addr                (MEN_alu_output[1:0]),
        .dst_width           (MEN_dst_width),
        .data_out            (MEN_dst_data)    
    );


    logic [11:0] MEN_csr_addr;
    logic [31:0] MEN_csr_wdata;
    logic MEN_csr_we;
    logic [31:0] MEN_csr_rdata;

    //--------------------------------------
    logic men_wb_stall;

    men_wb u_men_wb(
        .clk         	(clk          ),
        .rst         	(rst          ),
        .stall          (men_wb_stall          ),
        .rd_addr        (MEN_rd_addr        ),
        .rd_addr_out    (WB_rd_addr    ),
        .rd_en          (MEN_rd_we          ),
        .rd_en_out      (WB_rd_we      ),
        .dst_data       (MEN_dst_data       ),
        .dst_data_out   (WB_dst_data   ),
        .rd_sel      	(MEN_rd_sel       ),
        .rd_sel_out  	(WB_rd_sel   ),
        .multiplier_output(MEN_multiplier_output),
        .multiplier_output_out(WB_multiplier_output),
        .divider_quotient(MEN_quotient_output),
        .divider_quotient_out(WB_quotient_output),
        .divider_remainder(MEN_remainder_output),
        .divider_remainder_out(WB_remainder_output),
        .alu_out     	(MEN_alu_output      ),
        .alu_out_out 	(WB_alu_output  ),
        .pc             (MEN_pc             ),
        .pc_out         (WB_pc         ),
        .npc         	(MEN_npc          ),
        .npc_out     	(WB_npc      ),
        .csr_addr       (MEN_csr_addr       ),
        .csr_addr_out   (WB_csr_addr   ),
        .csr_rdata      (MEN_csr_rdata      ),
        .csr_rdata_out  (WB_csr_rdata  ),
        .csr_we         (MEN_csr_we         ),
        .csr_we_out     (WB_csr_we     ),
        .csr_wdata      (MEN_csr_wdata),
        .csr_wdata_out  (WB_csr_wdata  ),
        .ecall          (MEN_ecall          ),
        .ecall_out      (WB_ecall      )
    );
    
    //--------------------------------------
    // WB
    
    logic [2:0] WB_rd_sel;
    logic [31:0] WB_alu_output;
    logic [31:0] WB_dst_data;
    logic [31:0] WB_pc;
    logic [31:0] WB_npc;
    logic [4:0] WB_rd_addr;
    logic WB_rd_we;

    logic [31:0] WB_csr_rdata;
    logic WB_csr_we;
    logic [11:0] WB_csr_addr;
    logic [31:0] WB_csr_wdata;

    logic [63:0] WB_multiplier_output;
    logic [31:0] multiplier_output_low;
    logic [31:0] multiplier_output_high;
    assign multiplier_output_low = WB_multiplier_output[31:0];
    assign multiplier_output_high = WB_multiplier_output[63:32];
    logic [31:0] WB_quotient_output;
    logic [31:0] WB_remainder_output;

    always_comb begin
        case(WB_rd_sel)
            `rd_sel_alu_output:
                rd = WB_alu_output;
            `rd_sel_dst_data:
                rd = WB_dst_data;
            `rd_sel_npc:
                rd = WB_npc;
            `rd_sel_csr:
                rd = WB_csr_rdata;
            `rd_sel_mul_low:
                rd = multiplier_output_low;
            `rd_sel_mul_high:
                rd = multiplier_output_high;
            `rd_sel_div:
                rd = WB_quotient_output;
            `rd_sel_rem:
                rd = WB_remainder_output;
            default:
                rd = WB_alu_output;
        endcase
    end

    logic WB_ecall;
    logic WB_exp_en;
    logic [4:0] WB_exp_code;

    exp_commit u_exp_commit(
        .ecall 	(WB_ecall  ),
        .exp_en 	(WB_exp_en  ),
        .exp_code 	(WB_exp_code  )
    );

    //--------------------------------------
    // test module

    `ifdef DEBUG
    always_comb begin
        update_pc(WB_npc);
    end
    `endif

    // -------------------

    // Hazard Detection Unit
    // output declaration of module hazard_forwarding_unit
    logic [1:0] forward_rs1;
    logic [1:0] forward_rs2;
    
    hazard_forwarding_unit u_hazard_forwarding_unit(
        .MEN_rd_we   	(MEN_rd_we    ),
        .MEN_rd_addr 	(MEN_rd_addr  ),
        .WB_rd_we    	(WB_rd_we     ),
        .WB_rd_addr  	(WB_rd_addr   ),
        .EX_rs1_addr 	(EX_rs1_addr  ),
        .EX_rs2_addr 	(EX_rs2_addr  ),
        .forward_rs1   	(forward_rs1    ),
        .forward_rs2   	(forward_rs2    )
    );
    

    branch u_branch(
        .branch_sel 	(EX_branch_sel  ),
        .zero_flag  	(zero_flag   ),
        .alu_output 	(EX_alu_output  ),
        .imm        	(EX_imm         ),
        .current_pc 	(EX_pc          ),
        .current_npc 	(EX_npc         ),
        .exp_en   	    (WB_exp_en    ),
        .mtvec      	(mtvec_global  ),
        .mepc       	(mepc_global   ),
        .mret      	    (EX_mret       ),    
        .next_pc    	(branch_pc     ),
        .branch_en  	(branch_en   )
    );

endmodule
