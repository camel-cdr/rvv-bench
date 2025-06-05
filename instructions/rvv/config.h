#define WARMUP 1000
#define UNROLL 8 // automatically *8
#define LOOP 512
#define RUNS 32

// processor specific configs
//               m8  m4  m2  m1  mf2 mf4 mf8
//          SEW: 6310    6310    6310    6310
//               4268... 4268... 4268... 4268...
#define T_A    0b1111111111111111111111111111 // all
#define T_W    0b0000011101110111011101110111 // widen
#define T_WR   0b0111011101110111011101110111 // widen reduction
#define T_N    0b0000011101110111011101110111 // narrow
#define T_F    0b1110111011101110111011101110 // float
#define T_FW   0b0000011001100110011001100110 // float widen
#define T_FWR  0b0110011001100110011001100110 // float widen reduction
#define T_FN   0b0000011001100110011001100110 // float narrow

#define T_E2   0b1110111011101110111011101110 // extend 2
#define T_E4   0b1100110011001100110011001100 // extend 4
#define T_E8   0b1000100010001000100010001000 // extend 8
#define T_ei16 0b1110111111111111111111111111 // no m8

// special:
#define T_m1 ((1 << 28) | T_A) // emul<=1
