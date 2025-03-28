/* verilator lint_off UNUSEDSIGNAL */

module soc(
    input clk,
    input rst,

    output logic [31:0] t_pc,
    output logic [31:0] t_ist_data
);

    assign t_pc = pc;
    assign t_ist_data = ist_data;

    logic [31:0] pc;
    logic [31:0] npc;
    logic [31:0] branch_pc;
    logic branch_en;
    
    PC u_PC(
        .clk       	(clk        ),
        .rst       	(rst        ),
        .branch_pc 	(branch_pc  ),
        .branch_en 	(branch_en  ),
        .pc        	(pc         ),
        .npc       	(npc        )
    );

    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rd_we;
    logic [31:0] imm;
    logic [3:0] alu_op;
    logic alu_input1_sel;
    logic alu_input2_sel;
    logic [3:0] branch_sel;
    logic dst_write_we;
    logic [2:0] dst_width;
    logic [1:0] rd_sel;
    
    decoder u_decoder(
        .ist    	(ist_data     ),
        .rs1_addr    	(rs1_addr     ),
        .rs2_addr    	(rs2_addr     ),
        .imm    	(imm     ),
        .rd_addr     	(rd_addr      ),
        .rd_we    	(rd_we     ),
        .alu_input1_sel 	(alu_input1_sel  ),
        .alu_input2_sel 	(alu_input2_sel  ),
        .alu_op 	(alu_op  ),
        .branch_sel 	(branch_sel  ),
        .dst_write_we 	(dst_write_we  ),
        .dst_width 	(dst_width  ),
        .rd_sel 	(rd_sel  )
    );
    
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] rd;
    
    regfile u_regfile(
        .clk      	(clk       ),
        .rst      	(rst       ),
        .rs1_addr 	(rs1_addr  ),
        .rs1      	(rs1       ),
        .rs2_addr 	(rs2_addr  ),
        .rs2      	(rs2       ),
        .rd_addr  	(rd_addr   ),
        .rd_we    	(rd_we     ),
        .rd       	(rd        )
    );

    logic [31:0] alu_input1;
    logic [31:0] alu_input2;
    logic [31:0] alu_output;
    logic zero_flag;

    assign alu_input1 = (alu_input1_sel == 1'b0) ? rs1 : pc;
    assign alu_input2 = (alu_input2_sel == 1'b0) ? rs2 : imm;
    
    ALU u_ALU(
        .alu_input1 	(alu_input1  ),
        .alu_input2 	(alu_input2  ),
        .alu_op     	(alu_op      ),
        .alu_output 	(alu_output  ),
        .zero_flag  	(zero_flag   )
    );
    
    branch u_branch(
        .branch_sel 	(branch_sel  ),
        .zero_flag  	(zero_flag   ),
        .alu_output 	(alu_output  ),
        .imm        	(imm         ),
        .current_pc 	(pc          ),
        .next_pc    	(branch_pc     ),
        .branch_en  	(branch_en   )
    );

    logic [31:0] ist_data;
    logic [31:0] dst_addr;
    logic [31:0] dst_data;
    
    assign dst_addr = alu_output;

    memory u_memory(
        .clk             	(clk              ),
        .ist_addr        	(pc         ),
        .ist_data        	(ist_data         ),
        .dst_addr        	(dst_addr         ),
        .output_data        	(dst_data         ),
        .dst_width 	(dst_width  ),
        .dst_write_we    	(dst_write_we     ),
        .dst_write_data  	(rs2   )
    );

    always_comb begin
        case(rd_sel)
            2'b00:
                rd = alu_output;
            2'b01:
                rd = dst_data;
            2'b10:
                rd = npc;
            default:
                rd = alu_output;
        endcase
    end

    
endmodule
