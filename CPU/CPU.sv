`include "param.vh"

module CPU(
    input logic clk,
    input logic rst,

    Icache_if Icache_if,
    Dcache_if Dcache_if
);
    logic nop_load_use;
    logic load_use_EX1;
    logic load_use_EX2;
   // logic load_use_MEM;
    assign load_use_EX1 = (EX1_rd_sel == `rd_sel_dst_data) && (EX1_rd_addr == ID_rs1_addr || EX1_rd_addr == ID_rs2_addr) && (EX1_rd_we == 1'b1);
    assign load_use_EX2 = (EX2_rd_sel == `rd_sel_dst_data) && (EX2_rd_addr == ID_rs1_addr || EX2_rd_addr == ID_rs2_addr) && (EX2_rd_we == 1'b1); 
    //assign load_use_MEM = (MEM_rd_sel == `rd_sel_dst_data) && (MEM_rd_addr == ID_rs1_addr || MEM_rd_addr == ID_rs2_addr) && (MEM_rd_we == 1'b1);

    logic nop_load_use_reg1;
    //logic nop_load_use_reg2;
    always_ff @(posedge clk) begin
        if (rst) begin
            nop_load_use_reg1 <= 1'b0;
            //nop_load_use_reg2 <= 1'b0;
        end else begin
            nop_load_use_reg1 <= load_use_EX1;
            //nop_load_use_reg2 <= load_use_EX2 || nop_load_use_reg1;
        end
    end

    assign nop_load_use = load_use_EX1 || load_use_EX2 || nop_load_use_reg1;


    pipeline_ctrl u_pipeline_ctrl(
        .nop_load_use       	(nop_load_use       ),
        .branch_en               	(branch_en               	),
        .Icache_miss         	(Icache_if.Icache_miss         	),
        .Dcache_miss         	(Dcache_if.Dcache_miss         	),

        .pc_stall               	(pc_stall              	),
        .if1_if2_stall              ( if1_if2_stall),
        .if2_id_stall               (if2_id_stall),
        .id_ex1_stall                (id_ex1_stall ),
        .ex1_ex2_stall               (ex1_ex2_stall),
        .ex2_mem_stall               (ex2_mem_stall),
        .mem_wb_stall               (mem_wb_stall),
        .Icache_stall               (Icache_stall),
        
        .if1_if2_flush              (if1_if2_flush),
        .if2_id_flush               (if2_id_flush),
        .id_ex1_flush                (id_ex1_flush ),
        .ex1_ex2_flush               (ex1_ex2_flush),
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
        .prediction_en (branch_prediction_en),
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
    logic branch_prediction_en;
    
    dynamic_branch_prediction u_branch_prediction(
        .clk     	(clk      ),
        .rst     	(rst      ),
        .pc      	(IF2_pc       ),
        .npc     	(IF2_npc      ),
        .ist     	(IF2_ist_data      ),
        .branch_prediction_en(branch_prediction_en),
        .next_pc 	(IF2_next_pc  ),
        .branch_sel (EX1_branch_sel),
        .branch_en (branch_res),
        .branch_ist_addr (EX2_pc)
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
                ID_rs1 = EX1_rd_sel == `rd_sel_alu_output ? EX1_alu_output : EX1_npc;
            2'b10:
                ID_rs1 = EX2_rd_sel == `rd_sel_alu_output ? EX2_alu_output : EX2_npc;
            2'b11:
                ID_rs1 = MEM_rd_sel == `rd_sel_alu_output ? MEM_alu_output : MEM_npc;
        endcase
    end

    always_comb begin
        case(forward_rs2)
            2'b00:
                ID_rs2 = rs2;
            2'b01:
                ID_rs2 = EX1_rd_sel == `rd_sel_alu_output ? EX1_alu_output : EX1_npc;
            2'b10:
                ID_rs2 = EX2_rd_sel == `rd_sel_alu_output ? EX2_alu_output : EX2_npc;
            2'b11:
                ID_rs2 = MEM_rd_sel == `rd_sel_alu_output ? MEM_alu_output : MEM_npc;
        endcase
    end

    logic forward_rs1_MEM;
    logic forward_rs2_MEM;

    assign forward_rs1_MEM = forward_rs1 == 2'b11 && MEM_rd_sel == `rd_sel_dst_data;
    assign forward_rs2_MEM = forward_rs2 == 2'b11 && MEM_rd_sel == `rd_sel_dst_data;
    //--------------------------------------

    logic id_ex1_stall;
    logic id_ex1_flush;

    id_ex1 u_id_ex1(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .stall      (id_ex1_stall        ),
        .flush     	(id_ex1_flush     	),
        .rd_we     	(ID_rd_we      ),
        .rd_we_out 	(EX1_rd_we  ),
        .imm       	(ID_imm     ),
        .imm_out   	(EX1_imm    ),
        .alu_op    	(ID_alu_op  ),
        .alu_op_out 	(EX1_alu_op  ),
        .alu_input1_sel 	(ID_alu_input1_sel  ),
        .alu_input1_sel_out 	(EX1_alu_input1_sel  ),
        .alu_input2_sel 	(ID_alu_input2_sel  ),
        .alu_input2_sel_out 	(EX1_alu_input2_sel  ),
        .branch_sel 	(ID_branch_sel  ),
        .branch_sel_out 	(EX1_branch_sel  ),
        .dst_write_we 	(ID_dst_write_we  ),
        .dst_write_we_out 	(EX1_dst_write_we  ),
        .dst_width  	(ID_dst_width  	),
        .dst_width_out  	(EX1_dst_width  	),
        .rd_addr    	(ID_rd_addr    	),
        .rd_addr_out 	(EX1_rd_addr    	),
        .rd_sel     	(ID_rd_sel     	),
        .rd_sel_out  	(EX1_rd_sel     	),
        .rs1        	(ID_rs1        	),
        .rs1_out    	(EX1_rs1_temp        	),
        .rs2        	(ID_rs2         ),
        .rs2_out    	(EX1_rs2_temp        	),
        .forward_rs1_mem    (forward_rs1_MEM    ),
        .forward_rs1_mem_out  (EX1_forward_rs1_MEM  ),
        .forward_rs2_mem    (forward_rs2_MEM    ),
        .forward_rs2_mem_out  (EX1_forward_rs2_MEM  ),
        .pc         	(ID_pc        	),
        .pc_out     	(EX1_pc        	),
        .npc        	(ID_npc       	),
        .npc_out    	(EX1_npc       	),
        .next_pc    	(ID_next_pc   	),
        .next_pc_out 	(EX1_next_pc   	)
    );  
    //--------------------------------------
    // EX1

    logic EX1_rd_we; 
    logic [31:0] EX1_imm;
    logic [3:0] EX1_alu_op;
    logic EX1_alu_input1_sel;
    logic EX1_alu_input2_sel;
    logic [3:0] EX1_branch_sel;
    logic EX1_dst_write_we;
    logic [2:0] EX1_dst_width;
    logic [2:0] EX1_rd_sel;
    logic [4:0] EX1_rd_addr;
    logic [31:0] EX1_rs1_temp;
    logic [31:0] EX1_rs1;
    logic [31:0] EX1_rs2_temp;
    logic [31:0] EX1_rs2;
    logic [31:0] EX1_pc;
    logic [31:0] EX1_npc;
    logic [31:0] EX1_next_pc;

    logic [31:0] alu_input1;
    logic [31:0] alu_input2;
    logic [31:0] EX1_alu_output;

    logic EX1_forward_rs1_MEM;
    logic EX1_forward_rs2_MEM;

    assign EX1_rs1 = (EX1_forward_rs1_MEM == 1'b1) ? WB_dst_data : EX1_rs1_temp;
    assign EX1_rs2 = (EX1_forward_rs2_MEM == 1'b1) ? WB_dst_data : EX1_rs2_temp;

    assign alu_input1 = (EX1_alu_input1_sel == 1'b1) ? EX1_pc : EX1_rs1;
    assign alu_input2 = (EX1_alu_input2_sel == 1'b1) ? EX1_imm : EX1_rs2;

    ALU u_ALU(
        .alu_input1 	(alu_input1  ),
        .alu_input2 	(alu_input2  ),
        .alu_op     	(EX1_alu_op      ),
        .alu_output 	(EX1_alu_output  )
    );
    
    //--------------------------------------

    logic ex1_ex2_flush;
    logic ex1_ex2_stall;

    ex1_ex2 u_ex1_ex2(
        .clk              	(clk               ),
        .rst              	(rst               ),
        .stall            	(ex1_ex2_stall       ),
        .flush              (ex1_ex2_flush        ),
        .pc               	(EX1_pc                ),
        .pc_out           	(EX2_pc           	 ),
        .npc              	(EX1_npc               ),
        .npc_out          	(EX2_npc          	 ),
        .next_pc         	(EX1_next_pc          ),
        .next_pc_out      	(EX2_next_pc       ),
        .rd_we            	(EX1_rd_we             ),
        .rd_we_out        	(EX2_rd_we         ),
        .dst_write_we     	(EX1_dst_write_we      ),
        .dst_write_we_out   (EX2_dst_write_we     ),
        .dst_width        	(EX1_dst_width         ),
        .dst_width_out    	(EX2_dst_width     ),
        .dst_write_data  	(EX1_rs2  	),
        .dst_write_data_out (EX2_dst_write_data),
        .rd_addr          	(EX1_rd_addr           ),
        .rd_addr_out        (EX2_rd_addr        ),
        .rd_sel           	(EX1_rd_sel            ),
        .rd_sel_out       	(EX2_rd_sel        ),
        .alu_output       	(EX1_alu_output        ),
        .alu_output_out   	(EX2_alu_output    )
    );

    //--------------------------------------
    // EX2

    logic EX2_rd_we;
    logic EX2_dst_write_we;
    logic [2:0] EX2_dst_width;
    logic [31:0] EX2_dst_write_data;
    logic [2:0] EX2_rd_sel;
    logic [4:0] EX2_rd_addr;
    logic [31:0] EX2_npc;
    logic [31:0] EX2_next_pc;
    logic [31:0] EX2_pc;
    logic [31:0] EX2_alu_output;

    logic Dcache_flush;
    assign Dcache_flush =1'b0;
    logic Dcache_stall;
    assign Dcache_stall = 1'b0;
    //logic Dcache_miss;

    assign Dcache_if.dst_addr = EX2_alu_output;
    assign Dcache_if.dst_width = EX2_dst_width;
    assign Dcache_if.dst_write_data = EX2_dst_write_data;
    assign Dcache_if.dst_write_we = EX2_dst_write_we;
    assign Dcache_if.flush = Dcache_flush;
    assign Dcache_if.stall = Dcache_stall;
    //assign Dcache_miss = Dcache_if.Dcache_miss;

    //--------------------------------------
    logic ex2_mem_stall;

    ex2_mem u_ex2_mem(
        .clk              	(clk               ),
        .rst              	(rst               ),
        .stall            	(ex2_mem_stall       ),
        .npc              	(EX2_npc               ),
        .npc_out          	(MEM_npc          	 ),
        .rd_we            	(EX2_rd_we             ),
        .rd_we_out        	(MEM_rd_we         ),
        .dst_width        	(EX2_dst_width         ),
        .dst_width_out    	(MEM_dst_width     ),
        .rd_addr          	(EX2_rd_addr           ),
        .rd_addr_out        (MEM_rd_addr        ),
        .rd_sel           	(EX2_rd_sel            ),
        .rd_sel_out       	(MEM_rd_sel        ),
        .alu_output       	(EX2_alu_output        ),
        .alu_output_out   	(MEM_alu_output    )
    );
    
    //--------------------------------------
    // MEM

    logic [31:0] MEM_alu_output;
    logic [31:0] MEM_npc;
    logic [2:0] MEM_dst_width;
    logic MEM_rd_we;
    logic [2:0] MEM_rd_sel;
    logic [4:0] MEM_rd_addr;

    //--------------------------------------
    logic mem_wb_stall;

    mem_wb u_mem_wb(
        .clk         	(clk          ),
        .rst         	(rst          ),
        .stall          (mem_wb_stall          ),
        .rd_addr        (MEM_rd_addr        ),
        .rd_addr_out    (WB_rd_addr    ),
        .rd_en          (MEM_rd_we          ),
        .rd_en_out      (WB_rd_we      ),
        .rd_sel         (MEM_rd_sel         ),
        .rd_sel_out     (WB_rd_sel     ),
        .alu_output     (MEM_alu_output     ),
        .alu_output_out (WB_alu_output ),
        .dst_read_data       (Dcache_if.dst_read_data       ),
        .dst_read_data_out   (WB_dst_read_data   ),
        .dst_width    ( MEM_dst_width    ),
        .dst_width_out (WB_dst_width ),
        .npc         	(MEM_npc          ),
        .npc_out     	(WB_npc      )
    );
    
    //--------------------------------------
    // WB

    logic [31:0] WB_npc;
    logic [4:0] WB_rd_addr;
    logic WB_rd_we;
    logic [2:0] WB_rd_sel;
    logic [31:0] WB_alu_output;
    logic [31:0] WB_dst_read_data;
    logic [31:0] WB_dst_data;
    logic [2:0] WB_dst_width;

    read_ctrl u_read_ctrl(
        .dst_read_data       (WB_dst_read_data),
        .addr                (WB_alu_output[1:0]),
        .dst_width           (WB_dst_width),
        .data_out            (WB_dst_data)    
    );


    always_comb begin
        case(WB_rd_sel)
            `rd_sel_alu_output:
                rd = WB_alu_output;
            `rd_sel_dst_data:
                rd = WB_dst_data;
            `rd_sel_npc:
                rd = WB_npc;
            default:
                rd = WB_alu_output;
        endcase
    end

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
        .EX1_rd_we(EX1_rd_we),
        .EX1_rd_addr(EX1_rd_addr),
        .EX2_rd_we(EX2_rd_we),
        .EX2_rd_addr(EX2_rd_addr),
        .MEM_rd_we (MEM_rd_we),
        .MEM_rd_addr ( MEM_rd_addr),
        .ID_rs1_addr (ID_rs1_addr),
        .ID_rs2_addr (ID_rs2_addr),
        .forward_rs1 (forward_rs1),
        .forward_rs2 (forward_rs2)
    );
    
    logic branch_res;
    branch u_branch(
        .clk        	(clk         ),
        .rst        	(rst         ),
        .branch_sel 	(EX1_branch_sel  ),
        .alu_output 	(EX2_alu_output  ),
        .rs1        	(EX1_rs1         ),
        .rs2        	(EX1_rs2         ),
        .current_npc 	(EX2_npc         ),
        .next_pc    	(EX2_next_pc     ),
        .branch_pc    	(branch_pc     ),
        .branch_en  	(branch_en   ),
        .branch_res 	(branch_res  )
    );

endmodule
