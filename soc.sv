
`include "param.vh"

module soc(
    input logic clk,
    input logic rst

);

    logic nop;
    assign nop = nop_forwarding_unit;
    logic flush;
    assign flush = branch_en;

    //---------------------------------
    // IF

    logic [31:0] IF_pc;
    logic [31:0] IF_npc;
    logic [31:0] branch_pc;
    logic branch_en;

    PC u_PC(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .branch_pc 	(branch_pc  ),
        .branch_en 	(branch_en  ),
        .nop       	(nop        ),
        .pc        	(IF_pc         ),
        .npc       	(IF_npc        )
    );

    //---------------------------------
    if_id u_if_id(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .nop       	(nop      ),
        .flush     	(flush     ),
        .pc        	(IF_pc         ),
        .pc_out    	(ID_pc         ),
        .npc       	(IF_npc        ),
        .npc_out   	(ID_npc        ),
        .ist_data  	(ist_data   ),
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
    logic [1:0] ID_rd_sel;
    logic [11:0] ID_csr_addr;
    logic ID_csr_we;
    logic [2:0] ID_csr_sel;
    logic [4:0] ID_csr_zimm;

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
        .csr_addr 	(ID_csr_addr  ),
        .csr_we    	(ID_csr_we     ),
        .csr_sel   	(ID_csr_sel    ),
        .csr_zimm  	(ID_csr_zimm   )
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

    CSR u_CSR(
        .clk      	(clk       ),
        .rst      	(rst       ),
        .csr_rdata	(ID_csr_rdata   ),
        .csr_addr 	(ID_csr_addr  ),
        .csr_waddr  (WB_csr_addr   ),
        .csr_wdata	(WB_csr_wdata       ),
        .csr_we   	(WB_csr_we  )
    );

    //--------------------------------------
    id_ex u_id_ex(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .nop       	(nop        ),
        .flush     	(flush     	),
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
        .csr_zimm_out   	(EX_csr_zimm    )
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
    logic [1:0] EX_rd_sel;
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
    

    //--------------------------------------
    ex_men u_ex_men(
        .clk              	(clk               ),
        .rst              	(rst               ),
        .npc              	(EX_npc               ),
        .npc_out          	(MEN_npc          	 ),
        .rd_we            	(EX_rd_we             ),
        .rd_we_out        	(MEN_rd_we         ),
        .dst_write_we     	(EX_dst_write_we      ),
        .dst_write_we_out 	(MEN_dst_write_we  ),
        .dst_width        	(EX_dst_width         ),
        .dst_width_out    	(MEN_dst_width     ),
        .rd_addr          	(EX_rd_addr           ),
        .rd_addr_out        (MEN_rd_addr        ),
        .rd_sel           	(EX_rd_sel            ),
        .rd_sel_out       	(MEN_rd_sel        ),
        .alu_output       	(EX_alu_output        ),
        .alu_output_out   	(MEN_alu_output    ),
        .rs2              	(alu_rs2               ),
        .rs2_out          	(MEN_rs2           ),
        .csr_addr         	(EX_csr_addr          ),
        .csr_addr_out       (MEN_csr_addr       ),
        .csr_we           	(EX_csr_we            ),
        .csr_we_out         (MEN_csr_we         ),
        .csr_wdata        	(EX_csr_wdata         ),
        .csr_wdata_out      (MEN_csr_wdata      ),
        .csr_rdata        	(EX_csr_rdata         ),
        .csr_rdata_out      (MEN_csr_rdata)
    );
    
    //--------------------------------------
    // MEM

    logic [31:0] MEN_alu_output;
    logic [31:0] ist_data;
    logic [31:0] dst_addr;
    logic [31:0] MEN_dst_data;
    logic [31:0] MEN_npc;
    logic [31:0] MEN_rs2;
    logic [2:0] MEN_dst_width;
    logic MEN_dst_write_we;
    logic MEN_rd_we;
    logic [1:0] MEN_rd_sel;
    logic [4:0] MEN_rd_addr;
    
    assign dst_addr = MEN_alu_output;

    memory u_memory(
        .clk             	(clk              ),
        .ist_addr        	(IF_pc         ),
        .ist_data        	(ist_data         ),
        .dst_addr        	(dst_addr         ),
        .output_data       	(MEN_dst_data         ),
        .dst_width      	(MEN_dst_width  ),
        .dst_write_we    	(MEN_dst_write_we     ),
        .dst_write_data  	(MEN_rs2   )
    );

    logic [11:0] MEN_csr_addr;
    logic [31:0] MEN_csr_wdata;
    logic MEN_csr_we;
    logic [31:0] MEN_csr_rdata;

    //--------------------------------------

    men_wb u_men_wb(
        .clk         	(clk          ),
        .rst         	(rst          ),
        .rd_addr        (MEN_rd_addr        ),
        .rd_addr_out    (WB_rd_addr    ),
        .rd_en          (MEN_rd_we          ),
        .rd_en_out      (WB_rd_we      ),
        .dst_data       (MEN_dst_data       ),
        .dst_data_out   (WB_dst_data   ),
        .rd_sel      	(MEN_rd_sel       ),
        .rd_sel_out  	(WB_rd_sel   ),
        .alu_out     	(MEN_alu_output      ),
        .alu_out_out 	(WB_alu_output  ),
        .npc         	(MEN_npc          ),
        .npc_out     	(WB_npc      ),
        .csr_addr       (MEN_csr_addr       ),
        .csr_addr_out   (WB_csr_addr   ),
        .csr_rdata      (MEN_csr_rdata      ),
        .csr_rdata_out  (WB_csr_rdata  ),
        .csr_we         (MEN_csr_we         ),
        .csr_we_out     (WB_csr_we     ),
        .csr_wdata      (MEN_csr_wdata),
        .csr_wdata_out  (WB_csr_wdata  )
    );
    
    //--------------------------------------
    // WB
    
    logic [1:0] WB_rd_sel;
    logic [31:0] WB_alu_output;
    logic [31:0] WB_dst_data;
    logic [31:0] WB_npc;
    logic [4:0] WB_rd_addr;
    logic WB_rd_we;

    logic [31:0] WB_csr_rdata;
    logic WB_csr_we;
    logic [11:0] WB_csr_addr;
    logic [31:0] WB_csr_wdata;

    always_comb begin
        case(WB_rd_sel)
            2'b00:
                rd = WB_alu_output;
            2'b01:
                rd = WB_dst_data;
            2'b10:
                rd = WB_npc;
            2'b11:
                rd = WB_csr_rdata;
            default:
                rd = WB_alu_output;
        endcase
    end

    //--------------------------------------
    // test module

    always_comb begin
        update_pc(WB_npc);
    end

    // -------------------

    // Hazard Detection Unit
    // output declaration of module hazard_forwarding_unit
    logic [1:0] forward_rs1;
    logic [1:0] forward_rs2;
    logic nop_forwarding_unit;
    
    hazard_forwarding_unit u_hazard_forwarding_unit(
        .MEN_rd_we   	(MEN_rd_we    ),
        .MEN_rd_sel  	(MEN_rd_sel[0]   ),
        .MEN_rd_addr 	(MEN_rd_addr  ),
        .WB_rd_we    	(WB_rd_we     ),
        .WB_rd_addr  	(WB_rd_addr   ),
        .EX_rs1_addr 	(EX_rs1_addr  ),
        .EX_rs2_addr 	(EX_rs2_addr  ),
        .forward_rs1   	(forward_rs1    ),
        .forward_rs2   	(forward_rs2    ),
        .nop         	(nop_forwarding_unit          )
    );
    

    branch u_branch(
        .branch_sel 	(EX_branch_sel  ),
        .zero_flag  	(zero_flag   ),
        .alu_output 	(EX_alu_output  ),
        .imm        	(EX_imm         ),
        .current_pc 	(EX_pc          ),
        .current_npc 	(EX_npc         ),
        .next_pc    	(branch_pc     ),
        .branch_en  	(branch_en   )
    );

    
endmodule
