`include "param.vh"

module ALU #(
    ALU_WIDTH = 32
) (
    input logic [ALU_WIDTH-1:0] alu_input1,
    input logic [ALU_WIDTH-1:0] alu_input2,
    input logic [3:0] alu_op,

    output logic [ALU_WIDTH-1:0] alu_output
);  

    logic [ALU_WIDTH-1:0] alu_add;
    logic [ALU_WIDTH-1:0] alu_sub;
    logic [ALU_WIDTH-1:0] alu_and;
    logic [ALU_WIDTH-1:0] alu_or;
    logic [ALU_WIDTH-1:0] alu_xor;
    logic [ALU_WIDTH-1:0] alu_sll;
    logic [ALU_WIDTH-1:0] alu_srl;
    logic [ALU_WIDTH-1:0] alu_sra;
    logic [ALU_WIDTH-1:0] alu_slt;
    logic [ALU_WIDTH-1:0] alu_sltu;



    assign alu_add = alu_input1 + alu_input2;
    assign alu_sub = alu_input1 - alu_input2;
    assign alu_and = alu_input1 & alu_input2;
    assign alu_or = alu_input1 | alu_input2;
    assign alu_xor = alu_input1 ^ alu_input2;
    assign alu_sll = alu_input1 << alu_input2[4:0];
    assign alu_srl = $signed(alu_input1) >> alu_input2[4:0];
    assign alu_sra = $signed(alu_input1) >>> alu_input2[4:0];
    assign alu_slt = ($signed(alu_input1) < $signed(alu_input2)) ? 1 : 0;
    assign alu_sltu = ($unsigned(alu_input1) < $unsigned(alu_input2)) ? 1 : 0;


    always_comb begin
        case (alu_op)
            `ALUop_add: alu_output = alu_add;
            `ALUop_sub: alu_output = alu_sub;
            `ALUop_and: alu_output = alu_and;
            `ALUop_or: alu_output = alu_or;
            `ALUop_xor: alu_output = alu_xor;
            `ALUop_sll: alu_output = alu_sll;
            `ALUop_srl: alu_output = alu_srl;
            `ALUop_sra: alu_output = alu_sra;
            `ALUop_slt: alu_output = alu_slt;
            `ALUop_sltu: alu_output = alu_sltu;
            default: alu_output = alu_add;
        endcase
    end

endmodule
