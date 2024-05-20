#define WARMUP 1000
#define UNROLL 8 // automatically *8
#define LOOP 64
#define RUNS 500

// processor specific configs
//               m8  m4  m2  m1
//          SEW: 6310    6310
//               4268... 4268...
#define T_A    0b1111111111111111 // all
#define T_W    0b0000011101110111 // widen
#define T_WR   0b0111011101110111 // widen reduction
#define T_N    0b0000011101110111 // narrow
#define T_F    0b1100110011001100 // float
#define T_FW   0b0000010001000100 // float widen
#define T_FWR  0b0100010001000100 // float widen reduction
#define T_FN   0b0000010001000100 // float narrow

#define T_E2   0b1110111011101110 // extend 2
#define T_E4   0b1100110011001100 // extend 4
#define T_E8   0b1000100010001000 // extend 8
#define T_ei16 0b1110111111111111 // no m8
