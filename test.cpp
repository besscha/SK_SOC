#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <random>

#include "Vsoc.h"

using namespace std;

int sim_time = 0;

int pc = 0;
int regfile[32] = {0};

extern "C" void update_reg(int reg_num, int value) {
    regfile[reg_num] = value;
}

extern "C" void update_pc(int new_pc) {
    pc = new_pc;
}

void print_regfile() {
    printf("Register File:\n");
    printf("PC: %08x\n", pc-4);
    printf("(ra) x1: %08x    ", regfile[1]);
    printf("(sp) x2: %08x    ", regfile[2]);
    printf("(gp) x3: %08x    ", regfile[3]);
    printf("(tp) x4: %08x\n", regfile[4]);
    printf("(t0) x5: %08x    ", regfile[5]);
    printf("(t1) x6: %08x    ", regfile[6]);
    printf("(t2) x7: %08x    ", regfile[7]);
    printf("(s0) x8: %08x\n", regfile[8]);
    printf("(s1) x9: %08x    ", regfile[9]);
    printf("(a0) x10: %08x    ", regfile[10]);
    printf("(a1) x11: %08x    ", regfile[11]);
    printf("(a2) x12: %08x\n", regfile[12]);
    printf("(a3) x13: %08x    ", regfile[13]);
    printf("(a4) x14: %08x    ", regfile[14]);
    printf("(a5) x15: %08x    ", regfile[15]);
    printf("(a6) x16: %08x\n", regfile[16]);
    printf("(a7) x17: %08x    ", regfile[17]);
    printf("(s2) x18: %08x    ", regfile[18]);
    printf("(s3) x19: %08x    ", regfile[19]);
    printf("(s4) x20: %08x\n", regfile[20]);
    printf("(s5) x21: %08x    ", regfile[21]);
    printf("(s6) x22: %08x    ", regfile[22]);
    printf("(s7) x23: %08x    ", regfile[23]);
    printf("(s8) x24: %08x\n", regfile[24]);
    printf("(s9) x25: %08x    ", regfile[25]);
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);

    Vsoc *top = new Vsoc;

    VerilatedVcdC *tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);

    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    top->clk = 0;
    top->rst = 1;
    top->eval();
    tfp->dump(sim_time++);

    top->clk = 1;
    top->eval();
    tfp->dump(sim_time++);

    top->rst = 0;
    top->clk = 0;
    top->eval();
    tfp->dump(sim_time++);

    for(;;){
        top->clk = top->clk ? 0 : 1;
        top->eval();
        tfp->dump(sim_time++);
        if (top->t_ist_data == 0x00000073){
            break;
        }

        /* if(top->clk == 1){
            print_regfile();
            getchar();
        } */

    }

    if (regfile[10] == 0x00000000) {
        printf("Test passed!\n");
    } else {
        printf("Test failed!\n");
    }

    tfp->dump(sim_time++);
    tfp->close();
    delete top;
    exit(0);
}

