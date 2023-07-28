#ifndef __riscv_v
#include "../thiredparty/rvv-rollback.S"
#else
#define HAS_RVV_1_0
#endif
.text
.balign 8

#define STR(x) #x
#define STRe(x) STR(x)

#define MX_N 0
#include STRe(INC)

#undef MX_N
#define MX_N 1
#define MX(x) x##m1
#include STRe(INC)

#undef MX
#undef MX_N
#define MX_N 2
#define MX(x) x##m2
#include STRe(INC)

#undef MX
#undef MX_N
#define MX_N 4
#define MX(x) x##m4
#include STRe(INC)

#undef MX
#undef MX_N
#define MX_N 8
#define MX(x) x##m8
#include STRe(INC)

