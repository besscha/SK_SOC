#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <random>

#include "VTop.h"
#include "RAM.cpp"
#include "nemu/nemu.h"

using namespace std;

extern uint32_t *pmen;

int sim_time = 0;

CPU_state SKcpu_state;
CPU_state nemu_state;

extern "C" void print_test(int num){
    printf("Hello world! %d\n", num);
}

extern "C" void update_reg(int reg_num, int value) {
    if (reg_num == 0) return; // x0 is always 0
    SKcpu_state.gpr[reg_num] = value;
}

extern "C" void update_pc(int new_pc) {
    SKcpu_state.pc = new_pc == 0x80000000 | new_pc == 0x0 ? SKcpu_state.pc : new_pc - 4;
}

extern "C" void update_csr(int csr_num, int value) {
    switch (csr_num) {
        case 0x305: // mtvec
            SKcpu_state.csr.mtvec = value;
            break;
        case 0x341: // mepc
            SKcpu_state.csr.mepc = value;
            break;
        case 0x342: // mcause
            SKcpu_state.csr.mcause = value;
            break;
        case 0x300: // mstatus
            SKcpu_state.csr.mstatus = value;
            break;
        default:
            break;
    }
}

void print_regfile(CPU_state cpu_state) {
    printf("Register File:\n");
    printf("PC: %08x\n", cpu_state.pc);
    printf("(ra) x1: %08x    ", cpu_state.gpr[1]);
    printf("(sp) x2: %08x    ", cpu_state.gpr[2]);
    printf("(gp) x3: %08x    ", cpu_state.gpr[3]);
    printf("(tp) x4: %08x\n", cpu_state.gpr[4]);
    printf("(t0) x5: %08x    ", cpu_state.gpr[5]);
    printf("(t1) x6: %08x    ", cpu_state.gpr[6]);
    printf("(t2) x7: %08x    ", cpu_state.gpr[7]);
    printf("(s0) x8: %08x\n", cpu_state.gpr[8]);
    printf("(s1) x9: %08x    ", cpu_state.gpr[9]);
    printf("(a0) x10: %08x    ", cpu_state.gpr[10]);
    printf("(a1) x11: %08x    ", cpu_state.gpr[11]);
    printf("(a2) x12: %08x\n", cpu_state.gpr[12]);
    printf("(a3) x13: %08x    ", cpu_state.gpr[13]);
    printf("(a4) x14: %08x    ", cpu_state.gpr[14]);
    printf("(a5) x15: %08x    ", cpu_state.gpr[15]);
    printf("(a6) x16: %08x\n", cpu_state.gpr[16]);
    printf("(a7) x17: %08x    ", cpu_state.gpr[17]);
    printf("(s2) x18: %08x    ", cpu_state.gpr[18]);
    printf("(s3) x19: %08x    ", cpu_state.gpr[19]);
    printf("(s4) x20: %08x\n", cpu_state.gpr[20]);
    printf("(s5) x21: %08x    ", cpu_state.gpr[21]);
    printf("(s6) x22: %08x    ", cpu_state.gpr[22]);
    printf("(s7) x23: %08x    ", cpu_state.gpr[23]);
    printf("(s8) x24: %08x\n", cpu_state.gpr[24]);
    printf("(s9) x25: %08x    ", cpu_state.gpr[25]);
    printf("(s10) x26: %08x    ", cpu_state.gpr[26]);
    printf("(s11) x27: %08x    ", cpu_state.gpr[27]);
    printf("(t3) x28: %08x\n", cpu_state.gpr[28]);
    printf("(t4) x29: %08x    ", cpu_state.gpr[29]);
    printf("(t5) x30: %08x    ", cpu_state.gpr[30]);
    printf("(t6) x31: %08x\n", cpu_state.gpr[31]);
    printf("mtvec: %08x    ", cpu_state.csr.mtvec);
    printf("mepc: %08x    ", cpu_state.csr.mepc);
    printf("mcause: %08x    ", cpu_state.csr.mcause);
    printf("mstate: %08x\n", cpu_state.csr.mstatus);
}

void compare(){
    if (SKcpu_state.pc != nemu_state.pc) {
        printf("PC mismatch: SKcpu_state: %08x, nemu_state: %08x\n", SKcpu_state.pc, nemu_state.pc);
        //exit(0);
    }
    for(int i = 1; i < 32; i++){
        if (SKcpu_state.gpr[i] == nemu_state.gpr[i] || SKcpu_state.gpr[i] == nemu_state.gpr[i] - 0x80000000) {
            continue;
        }
        printf("Register %d mismatch: SKcpu_state: %08x, nemu_state: %08x\n", i, SKcpu_state.gpr[i], nemu_state.gpr[i]);
            //exit(0);
    }
    if (!(SKcpu_state.csr.mtvec == nemu_state.csr.mtvec || SKcpu_state.csr.mtvec == nemu_state.csr.mtvec - 0x80000000)) {
        printf("mtvec mismatch: SKcpu_state: %08x, nemu_state: %08x\n", SKcpu_state.csr.mtvec, nemu_state.csr.mtvec);
        //exit(0);
    }
    if (!(SKcpu_state.csr.mepc == nemu_state.csr.mepc || SKcpu_state.csr.mepc == nemu_state.csr.mepc - 0x80000000)) {
        printf("mepc mismatch: SKcpu_state: %08x, nemu_state: %08x\n", SKcpu_state.csr.mepc, nemu_state.csr.mepc);
        //exit(0);
    }
    if (SKcpu_state.csr.mcause != nemu_state.csr.mcause) {
        printf("mcause mismatch: SKcpu_state: %08x, nemu_state: %08x\n", SKcpu_state.csr.mcause, nemu_state.csr.mcause);
        //exit(0);
    }
    if (SKcpu_state.csr.mstatus != nemu_state.csr.mstatus) {
        printf("mstatus mismatch: SKcpu_state: %08x, nemu_state: %08x\n", SKcpu_state.csr.mstatus, nemu_state.csr.mstatus);
        //exit(0);
    }
}

void difftest(){
    difftest_step();
    compare();
    /* printf("sk");
    print_regfile(SKcpu_state);
    printf("nemu");
    print_regfile(nemu_state);
    printf("----------------------------------------------------------------\n");
    getchar(); */
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);

    VTop *top = new VTop;

    VerilatedVcdC *tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    
    pmen_load_text("test.txt");
    //pmen_load_bin("test.bin");
    init_difftest();
    difftest_step();

    SKcpu_state.pc = 0x80000000;
    
    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    top->clk = 0;
    top->rst = 1;
    top->eval();
    tfp->dump(sim_time++);

    top->clk = top->clk ? 0 : 1;
    top->eval();
    tfp->dump(sim_time++);

    top->rst = 0;
    top->clk = top->clk ? 0 : 1;
    top->eval();
    tfp->dump(sim_time++);

    for(int i = 0; i < 8; i++){
        top->clk = top->clk ? 0 : 1;
        top->eval();
        tfp->dump(sim_time++);
    }
    int last_pc = SKcpu_state.pc;
    
    for(int i=0;i<200;){
        
        top->clk = top->clk ? 0 : 1;
        top->eval();
        tfp->dump(sim_time++);
        uint32_t ist;
        ist = pmem_read(1, (SKcpu_state.pc-0x80000000)/4);
        //printf("i:%d,PC: %08x, Instruction: %08x\n", i ,SKcpu_state.pc, ist);
        if(last_pc != SKcpu_state.pc){
            last_pc = SKcpu_state.pc;
            //printf("led: %08x\n", top->LED);
            difftest();
        }

        if (ist == 0x00000000 || ist == 0x00000073) {
            printf("End of program\n");
            break;
        }
        /* if(top->clk == 1){
            print_regfile();
            getchar();
        } */

    }
    //print_regfile();

    if (SKcpu_state.gpr[10] == 0xFFFFFFFF) {
        printf("Test passed!\n");
    } else {
        printf("Test failed!\n");
    }

    tfp->dump(sim_time++);
    tfp->close();
    delete top;
    //exit(0);
}