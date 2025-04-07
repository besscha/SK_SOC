`define DEBUG 1
// ---------------------------------------------------------------------
`define ALUop_and  4'b0000
`define ALUop_or   4'b0001
`define ALUop_xor  4'b0010

`define ALUop_sll  4'b1000
`define ALUop_srl  4'b1100
`define ALUop_sra  4'b0100

`define ALUop_add  4'b0011
`define ALUop_sub  4'b0111
`define ALUop_slt  4'b1111
`define ALUop_sltu 4'b1011
// ----------------------------------------------
`define opcode_R 7'b0110011
`define opcode_I_Ari 7'b0010011
`define opcode_I_ld  7'b0000011
`define opcode_I_jair 7'b1100111
`define opcode_S 7'b0100011
`define opcode_B 7'b1100011
`define opcode_J 7'b1101111
`define opcode_U_lui 7'b0110111
`define opcode_U_auipc 7'b0010111
`define opcode_I_csr 7'b1110011
// ----------------------------------------------

`define branch_sel_beq 4'b1000
`define branch_sel_bne 4'b1001
`define branch_sel_blt 4'b1100
`define branch_sel_bge 4'b1101
`define branch_sel_bltu 4'b1110
`define branch_sel_bgeu 4'b1111
`define branch_sel_jal 4'b0010
`define branch_sel_jalr 4'b0011
`define branch_sel_scr  4'b0111
// ----------------------------------------------

`define data_width_byte 3'b000
`define data_width_half 3'b001
`define data_width_word 3'b010
`define data_width_ubyte 3'b100
`define data_width_uhalf 3'b101

// ----------------------------------------------

`define nop 32'h00000013

// ----------------------------------------------

`define mcpuid_addr  12'hF00
`define mcpuid       32'b00_0000_00000000000000001000000000

`define mimpid_addr  12'hF01
`define mimpid       32'h0000_0721

`define mstatus_addr 12'h300
`define mtvec_addr        12'h305
`define mepc_addr         12'h341
`define mcause_addr       12'h342
// -------------------------------------

`define ecall_ist 32'h00000073
`define mret_ist  32'h30200073

`define ecall_id 0
`define ecall_code 5'd11

// ----------------------------------------------

`define main_memory_id 4'b1000
`define mmo_memory_id  4'b0001

//

`ifndef DPI_C
`define DPI_C
    `ifdef DEBUG
    import "DPI-C" function void update_pc(input int pc);
    import "DPI-C" function void update_reg(input int i,input int regfile);
    import "DPI-C" function int pmem_read(input bit re, input int addr);
    import "DPI-C" function void pmem_write(input int we, input int addr, input int wword);
    import "DPI-C" function void update_csr(input int csr_num, input int value);

    import "DPI-C" function void print_test(input int num);
    `endif
`endif

