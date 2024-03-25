#define WARMUP 1000
#define UNROLL 64
#define LOOP 16
#define RUNS 1000

/* processor specific configs */

#define HAS_M __riscv_m
#define HAS_A __riscv_a
#define HAS_F __riscv_f
#define HAS_D __riscv_d

#define HAS_Zba 1
#define HAS_Zbb 1
#define HAS_Zbc 0
#define HAS_Zbs 1

