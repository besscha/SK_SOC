`include "param.vh"

module CPU(
    input logic clk,
    input logic rst,

    Icache_if Icache_if,
    Dcache_if Dcache_if
);
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
        .Icache_miss         	(Icache_if.Icache_miss         	),
        .Dcache_miss         	(Dcache_if.Dcache_miss         	),

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
        .prediction_pc (IF2_next_pc),
        .prediction_en (branch_predicion_en),
        .stall      (pc_stall        ),
        .pc        	(IF1_pc         ),
        .npc       	(IF1_npc        )
    );

    assign Icache_if.ist_addr = IF1_pc;

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

    assign Icache_if.flush = Icache_flush;
    assign Icache_if.stall = Icache_stall;
    assign IF2_ist_data = Icache_if.ist_data;

    //---------------------------------

    logic if2_id_stall;
    logic if2_id_flush;

    logic [31:0] IF2_next_pc;
    logic branch_predicion_en;
    
    branch_predicion u_branch_predicion(
        .pc      	(IF2_pc       ),
        .npc     	(IF2_npc      ),
        .ist     	(IF2_ist_data      ),
        .branch_predicion_en(branch_predicion_en),
        .next_pc 	(IF2_next_pc  )
    );
    


    if2_id u_if2_id(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .stall      (if2_id_stall      ),
        .flush     	(if2_id_flush     ),
        .pc        	(IF2_pc         ),
        .pc_out    	(ID_pc         ),
        .npc       	(IF2_npc        ),
        .npc_out   	(ID_npc        ),
        .next_pc   	(IF2_next_pc    ),
        .next_pc_out	(ID_next_pc    ),
        .ist_data  	(IF2_ist_data   ),
        .ist_data_out	(ID_ist_data   )
    );

    //--------------------------------------
    // ID

    logic [31:0] ID_pc;
    logic [31:0] ID_npc;
    logic [31:0] ID_next_pc;
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
        .rd_sel 	(ID_rd_sel  )
    );
    
    logic [31:0] ID_rs1;
    logic [31:0] rs1;
    logic [31:0] ID_rs2;
    logic [31:0] rs2;
    logic [31:0] rd;
    logic [31:0] ID_csr_rdata;
    
    regfile u_regfile(
        .clk      	(clk       ),
        .rst      	(rst       ),
        .rs1_addr 	(ID_rs1_addr  ),
        .rs1      	(rs1       ),
        .rs2_addr 	(ID_rs2_addr  ),
        .rs2      	(rs2       ),
        .rd_addr  	(WB_rd_addr   ),
        .rd_we    	(WB_rd_we     ),
        .rd       	(rd        )
    );

    
    always_comb begin
        case(forward_rs1)
            2'b00:
                ID_rs1 = rs1;
            2'b01:
                ID_rs1 = EX_rd_sel == `rd_sel_alu_output ? EX_alu_output : EX_npc;
            2'b10:
                ID_rs1 = MEN_rd;
            default:
                ID_rs1 = rs1;
        endcase
    end

    always_comb begin
        case(forward_rs2)
            2'b00:
                ID_rs2 = rs2;
            2'b01:
                ID_rs2 = EX_rd_sel == `rd_sel_alu_output ? EX_alu_output : EX_npc;
            2'b10:
                ID_rs2 = MEN_rd;
            default:
                ID_rs2 = rs2;
        endcase
    end
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
        .rs1        	(ID_rs1        	),
        .rs1_out    	(EX_rs1        	),
        .rs2        	(ID_rs2         ),
        .rs2_out    	(EX_rs2        	),
        .pc         	(ID_pc        	),
        .pc_out     	(EX_pc        	),
        .npc        	(ID_npc       	),
        .npc_out    	(EX_npc       	),
        .next_pc    	(ID_next_pc   	),
        .next_pc_out 	(EX_next_pc   	)
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
    logic [31:0] EX_rs2;
    logic [31:0] EX_pc;
    logic [31:0] EX_npc;
    logic [31:0] EX_next_pc;

    logic [31:0] alu_input1;
    logic [31:0] alu_input2;
    logic [31:0] EX_alu_output;

    assign alu_input1 = (EX_alu_input1_sel == 1'b0) ? EX_rs1 : EX_pc;
    assign alu_input2 = (EX_alu_input2_sel == 1'b0) ? EX_rs2 : EX_imm;

    ALU u_ALU(
        .alu_input1 	(alu_input1  ),
        .alu_input2 	(alu_input2  ),
        .alu_op     	(EX_alu_op      ),
        .alu_output 	(EX_alu_output  )
    );
    
    logic Dcache_flush;
    assign Dcache_flush =1'b0;
    logic Dcache_stall;
    assign Dcache_stall = 1'b0;
    //logic Dcache_miss;

    assign Dcache_if.dst_addr = EX_alu_output;
    assign Dcache_if.dst_width = EX_dst_width;
    assign Dcache_if.dst_write_data = EX_rs2;
    assign Dcache_if.dst_write_we = EX_dst_write_we;
    assign Dcache_if.flush = Dcache_flush;
    assign Dcache_if.stall = Dcache_stall;
    //assign Dcache_miss = Dcache_if.Dcache_miss;
    
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
        .alu_output_out   	(MEN_alu_output    )
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
        .dst_read_data       (Dcache_if.dst_read_data       ),
        .addr                (MEN_alu_output[1:0]),
        .dst_width           (MEN_dst_width),
        .data_out            (MEN_dst_data)    
    );


    logic [11:0] MEN_csr_addr;
    logic [31:0] MEN_csr_wdata;
    logic MEN_csr_we;
    logic [31:0] MEN_csr_rdata;

    logic [31:0] multiplier_output_low;
    logic [31:0] multiplier_output_high;
    assign multiplier_output_low = MEN_multiplier_output[31:0];
    assign multiplier_output_high = MEN_multiplier_output[63:32];

    logic [31:0] MEN_rd;

    always_comb begin
        case(MEN_rd_sel)
            `rd_sel_alu_output:
                MEN_rd = MEN_alu_output;
            `rd_sel_dst_data:
                MEN_rd = MEN_dst_data;
            `rd_sel_npc:
                MEN_rd = MEN_npc;
            default:
                MEN_rd = MEN_alu_output;
        endcase
    end

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
        .rd             (MEN_rd),
        .rd_out         (rd         ),
        .pc             (MEN_pc             ),
        .pc_out         (WB_pc         ),
        .npc         	(MEN_npc          ),
        .npc_out     	(WB_npc      )
    );
    
    //--------------------------------------
    // WB
    
    logic [31:0] WB_pc;
    logic [31:0] WB_npc;
    logic [4:0] WB_rd_addr;
    logic WB_rd_we;
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
        .EX_rd_we(EX_rd_we),
        .EX_rd_addr(EX_rd_addr),
        .MEN_rd_we (MEN_rd_we),
        .MEN_rd_addr ( MEN_rd_addr),
        .ID_rs1_addr (ID_rs1_addr),
        .ID_rs2_addr (ID_rs2_addr),
        .forward_rs1 (forward_rs1),
        .forward_rs2 (forward_rs2)
    );
    

    branch u_branch(
        .branch_sel 	(EX_branch_sel  ),
        .alu_output 	(EX_alu_output  ),
        .rs1        	(EX_rs1         ),
        .rs2        	(EX_rs2         ),
        .current_npc 	(EX_npc         ),
        .next_pc    	(EX_next_pc     ),
        .branch_pc    	(branch_pc     ),
        .branch_en  	(branch_en   )
    );

endmodule
