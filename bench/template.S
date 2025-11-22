#define NOLIBC_DEFINE_ONLY
#include "../nolibc.h"
#include "config.h"
.text
.balign 8

#ifdef __riscv_zbb
.macro XMINU a0, a1, a2
	minu \a0, \a1, \a2
.endm
#else
.macro XMINU a0, a1, a2
	.ifnc \a0, \a1
		mv \a0, \a1
	.endif
	bltu \a1, \a2, 999f
	mv \a0, \a2
	999:
.endm
#endif

#define CAT_(a,b) a##b
#define CAT(a,b) CAT_(a,b)

#define STR(x) #x
#define STRe(x) STR(x)

#define MX_N 0
#include STRe(INC)

#undef MX_N

#define MX_N 1
#define MX8(x) x##m8
#define MX4(x) x##m4
#define MX2(x) x##m2
#define MX(x) x##m1
#define MXf2(x) x##mf2
#define MXf4(x) x##mf4
#if __riscv_v_elen >= 64
#define MXf8e8(x) x##mf8
#else
#define MXf8e8(x) x##mf4
#endif
#include STRe(INC)

#undef MX_N
#undef MX8
#undef MX4
#undef MX2
#undef MX
#undef MXf2
#undef MXf4
#undef MXf8
#undef MXf8e8

#define MX_N 2
#define MX4(x) x##m8
#define MX2(x) x##m4
#define MX(x) x##m2
#define MXf2(x) x##m1
#define MXf4(x) x##mf2
#define MXf8(x) x##mf4
#define MXf8e8(x) x##mf4
#include STRe(INC)

#undef MX_N
#undef MX4
#undef MX2
#undef MX
#undef MXf2
#undef MXf4
#undef MXf8
#undef MXf8e8

#define MX_N 4
#define MX2(x) x##m8
#define MX(x) x##m4
#define MXf2(x) x##m2
#define MXf4(x) x##m1
#define MXf8(x) x##mf2
#define MXf8e8(x) x##mf2
#include STRe(INC)

#undef MX_N
#undef MX2
#undef MX
#undef MXf2
#undef MXf4
#undef MXf8
#undef MXf8e8

#define MX_N 8
#define MX(x) x##m8
#define MXf2(x) x##m4
#define MXf4(x) x##m2
#define MXf8(x) x##m1
#define MXf8e8(x) x##m1
#include STRe(INC)

