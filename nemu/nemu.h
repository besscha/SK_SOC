#ifndef __COMMON_H__
#define __COMMON_H__
#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define MAX_SIM_TIME 40000000

typedef uint32_t word_t;
typedef int32_t sword_t;
typedef unsigned long long duword_t;
typedef long long dsword_t;

#define FMT_WORD "0x%08x"

typedef word_t vaddr_t;
typedef uint32_t paddr_t;
#define FMT_PADDR "0x%08x"
typedef uint16_t ioaddr_t;

extern uint32_t *cpu_gpr;

#define PAGE_SHIFT        12
#define PAGE_SIZE         (1ul << PAGE_SHIFT)
#define PAGE_MASK         (PAGE_SIZE - 1)

typedef struct {
  int state;
  vaddr_t halt_pc;
  uint32_t halt_ret;
} SimState;

typedef struct {
  word_t mepc;
  word_t mstatus;
  word_t mcause;
  word_t mtvec;
} CSR;

typedef struct {
  word_t gpr[32];
  vaddr_t pc;
  CSR csr;
} CPU_state;

// difftest
void init_difftest(void);
void difftest_step(void);

#endif