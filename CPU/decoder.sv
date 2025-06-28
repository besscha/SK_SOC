`include "param.vh"

module decoder(
    input logic [31:0] ist,

    output logic [4:0] rs1_addr,
    output logic [4:0] rs2_addr,
    
    output logic [31:0] imm,

    output logic [4:0] rd_addr,
    output logic rd_we,

    output logic [3:0] alu_op,

    output logic alu_input1_sel,
    output logic alu_input2_sel,
    
    output logic [3:0] branch_sel,

    output logic dst_write_we,
    output logic [2:0] dst_width,

    output logic [2:0] rd_sel
);
    
    logic [6:0] opcode;
    assign opcode = ist[6:0];
    logic [2:0] funct3;
    assign funct3 = ist[14:12];
    logic [6:0] funct7;
    assign funct7 = ist[31:25];

    logic [31:0] imm12_I;
    assign imm12_I = {{20{ist[31]}}, ist[31:20]};
    logic [31:0] imm12_S;
    assign imm12_S = {{20{ist[31]}}, ist[31:25], ist[11:7]};
    logic [31:0] imm13_B;
    assign imm13_B = {{19{ist[31]}}, ist[31], ist[7], ist[30:25], ist[11:8], 1'b0};
    logic [31:0] imm20_U;
    assign imm20_U = {ist[31:12], 12'b0};

    logic [31:0] imm21_J;
    assign imm21_J = {{11{ist[31]}}, ist[31], ist[19:12], ist[20], ist[30:21], 1'b0};
    
    assign rs1_addr = ( opcode == `opcode_U_lui) ? 5'b0 : ist[19:15];
    assign rs2_addr = ist[24:20];
    
    assign rd_addr = ist[11:7];
    always_comb begin   // rd_we
        if(opcode == `opcode_R
        || opcode == `opcode_I_Ari
        || opcode == `opcode_I_ld
        || opcode == `opcode_I_jair
        || opcode == `opcode_J
        || opcode == `opcode_U_lui
        || opcode == `opcode_U_auipc) begin
            rd_we = 1'b1;
        end
        else begin
            rd_we = 1'b0;
        end
    end
    always_comb begin
        case(opcode)
            `opcode_I_ld:begin
                rd_sel = `rd_sel_dst_data;
            end
            `opcode_J,
            `opcode_I_jair:begin
                rd_sel = `rd_sel_npc;
            end
            `opcode_R:begin
                rd_sel = `rd_sel_alu_output;
            end
            default:begin
                rd_sel = `rd_sel_alu_output;
            end
        endcase
    end


    always_comb begin   // immediate number
        case(opcode)
            `opcode_I_Ari,
            `opcode_I_ld,
            `opcode_I_jair: begin
                imm = imm12_I;
            end
            `opcode_S: begin
                imm = imm12_S;
            end
            `opcode_B: begin
                imm = imm13_B;
            end
            `opcode_U_lui,
            `opcode_U_auipc: begin
                imm = imm20_U;
            end
            `opcode_J: begin
                imm = imm21_J;
            end
            default: begin
                imm = 32'b0;
            end
        endcase
    end

    assign alu_input1_sel = (opcode == `opcode_U_auipc
                            || opcode == `opcode_B
                            || opcode == `opcode_J) ? 1'b1 : 1'b0;
    assign alu_input2_sel = (  opcode == `opcode_I_jair
                            || opcode == `opcode_I_Ari
                            || opcode == `opcode_I_ld
                            || opcode == `opcode_S
                            || opcode == `opcode_U_lui
                            || opcode == `opcode_U_auipc
                            || opcode == `opcode_B
                            || opcode == `opcode_J) ? 1'b1 : 1'b0;

    logic [3:0] alu_op_R;

    always_comb begin
        case(funct3)
            3'h0:begin  //add, sub
                if(funct7 == 7'b0000000) begin
                    alu_op_R = `ALUop_add;
                end
                else if(funct7 == 7'b0100000) begin
                    alu_op_R = `ALUop_sub;
                end
                else begin
                    alu_op_R = `ALUop_add;
                end
            end
            3'h1:begin  // sll
                alu_op_R = `ALUop_sll;
            end
            3'h2:begin  //slt
                alu_op_R = `ALUop_slt;
            end
            3'h3:begin  //sltu
                alu_op_R = `ALUop_sltu;
            end
            3'h4:begin  //xor
                alu_op_R = `ALUop_xor;
            end
            3'h5:begin  //srl, sra
                if(funct7 == 7'h00) begin
                    alu_op_R = `ALUop_srl;
                end
                else if(funct7 == 7'h20) begin
                    alu_op_R = `ALUop_sra;
                end
                else begin
                    alu_op_R = `ALUop_srl;
                end
            end
            3'h6:begin  //or
                alu_op_R = `ALUop_or;
            end
            3'h7:begin  //and
                alu_op_R = `ALUop_and;
            end
            default:begin
                alu_op_R = `ALUop_add;
            end
        endcase
    end

    logic [3:0] alu_op_I_Ari;

    always_comb begin
        case(funct3)
                3'h0:begin  //addi
                    alu_op_I_Ari = `ALUop_add;
                end       
                3'h1:begin  //slli
                    alu_op_I_Ari = `ALUop_sll;
                end
                3'h2:begin  //slti
                    alu_op_I_Ari = `ALUop_slt;
                end
                3'h3:begin  //sltiu
                    alu_op_I_Ari = `ALUop_sltu;
                end
                3'h4:begin  //xori
                    alu_op_I_Ari = `ALUop_xor;
                end
                3'h5:begin  //srli, srai
                    if(funct7 == 7'h00) begin
                        alu_op_I_Ari = `ALUop_srl;
                    end
                    else if(funct7 == 7'h20) begin
                        alu_op_I_Ari = `ALUop_sra;
                    end
                    else begin
                        alu_op_I_Ari = `ALUop_srl;
                    end
                end
                3'h6:begin  //ori
                    alu_op_I_Ari = `ALUop_or;
                end
                3'h7:begin  //andi
                    alu_op_I_Ari = `ALUop_and;
                end
            endcase
    end

    always_comb begin   //alu_op
        case(opcode)
            `opcode_R:begin
                alu_op = alu_op_R;
            end
            `opcode_I_Ari:begin
                alu_op = alu_op_I_Ari;
            end
            `opcode_I_ld:begin
                alu_op = `ALUop_add;
            end
            `opcode_S:begin
                alu_op = `ALUop_add;
            end
            `opcode_B:begin
                alu_op = `ALUop_add;
            end
            `opcode_J:begin
                alu_op = `ALUop_add;
            end
            `opcode_U_lui, 
            `opcode_U_auipc:begin
                alu_op = `ALUop_add;
            end
            default:begin
                alu_op = `ALUop_add;
            end
        endcase
    end

    logic [3:0] branch_sel_B;
    assign branch_sel_B = {1'b1,funct3};
    always_comb begin       //branch_sel
        case (opcode)
            `opcode_B:begin
                branch_sel = branch_sel_B;
            end
            `opcode_J:begin
                branch_sel = `branch_sel_jal;
            end
            `opcode_I_jair:begin
                branch_sel = `branch_sel_jalr;
            end
            default:begin
                branch_sel = 4'b0000;
            end
        endcase
    end

    assign dst_write_we = (opcode == `opcode_S) ? 1'b1 : 1'b0;
    assign dst_width = funct3;
endmodule
