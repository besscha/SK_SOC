#include <dlfcn.h>
#include "nemu.h"

extern uint32_t *pmen;
extern CPU_state nemu_state;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

// init fuction pointer with NULL, they will be assign when init
void (*difftest_regcpy)(void *dut, bool direction) = NULL;
void (*difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*difftest_exec)(uint64_t n) = NULL;
void (*difftest_raise_intr)(uint64_t NO) = NULL;

void init_difftest(void){
    void *handle;

    const char *ref_file = "./nemu/riscv32-nemu-interpreter-so";
    handle = dlopen(ref_file, RTLD_LAZY);

    difftest_memcpy = (void (*)(paddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
    difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
    difftest_exec = (void (*)(uint64_t))dlsym(handle, "difftest_exec");
    void (*difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
    difftest_init(1234);
    difftest_memcpy(0x80000000, pmen, 300000, DIFFTEST_TO_REF);
    nemu_state.pc = 0x80000000;
    nemu_state.csr.mtvec = 0x4;
    nemu_state.csr.mstatus = 0x6;
    difftest_regcpy(&nemu_state, DIFFTEST_TO_REF);
}

void difftest_step(){
    difftest_regcpy(&nemu_state, DIFFTEST_TO_DUT);
    difftest_exec(1);
}