#define WARMUP 1000

#define UNROLL 64
#define LOOP 16
#define RUNS 1000

#if 0
// C910: e8/16/32/64 f16/32/64
#define T_A  0b11111111
#define T_W  0b01110111
#define T_N  0b01110111
#define T_F  0b11101111
#define T_FW 0b01100111
#define T_FN 0b01100111
#else
// C906: e8/16/32 f16/32
#define T_A  0b1111111
#define T_W  0b0110111
#define T_N  0b0110111
#define T_F  0b1101111
#define T_FW 0b0100111
#define T_FN 0b0100111
#endif

