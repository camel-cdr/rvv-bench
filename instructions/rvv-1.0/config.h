#define WARMUP 1000
#define UNROLL 64
#define LOOP 16
#define RUNS 1000

/* processor specific configs */

// e64/e32/e16/e8 m8/m4/m2/m1
#define T_A   0b11111111 // all
#define T_W   0b01110111 // widen
#define T_WR  0b01111111 // widen reduction
#define T_N   0b01110111 // narrow
#define T_F   0b11001111 // float
#define T_FW  0b01000111 // float widen
#define T_FWR 0b01001111 // float widen reduction
#define T_FN  0b01000111 // float narrow

#define T_E2 0b11101110 // extend 2
#define T_E4 0b11001100 // extend 4
#define T_E8 0b10001000 // extend 8
#define T_N8 0b11110111 // no m8
