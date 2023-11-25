#include "bench.h"

size_t
utf8_count_scalar(char const *str, size_t len)
{
	uint8_t const *p = (uint8_t const*)str;
	size_t count = 0;
	while (len--) count += (*p++ & 0xc0) != 0x80, BENCH_CLOBBER();
	return count;
}

size_t
utf8_count_scalar_autovec(char const *str, size_t len)
{
	uint8_t const *p = (uint8_t const*)str;
	size_t count = 0;
	while (len--) count += (*p++ & 0xc0) != 0x80;
	return count;
}

#define GEN_SWAR(name, popc, clobber)  \
	size_t \
	utf8_count_##name(char const *str, size_t len) \
	{ \
		uint64_t const BENCH_MAY_ALIAS *u64; \
		size_t count = 0, tail = 0; \
\
		uint8_t const *u8 = (uint8_t const*)str; \
		if (len < sizeof *u64) { \
			tail = len; \
			goto skip; \
		} \
\
		tail = sizeof *u64 - (uintptr_t)str % sizeof *u64; \
\
		len -= tail; \
		while (tail--) \
			count += (*u8++ & 0xC0) != 0x80, clobber; \
\
		u64 = (uint64_t const*)u8; \
		tail = len % sizeof *u64; \
\
		for (len /= sizeof *u64; len--; ++u64) { \
			uint64_t b1 =  ~*u64 & 0x8080808080808080; \
			uint64_t b2 =  *u64 & 0x4040404040404040; \
			count += popc((b1 >> 1) | b2); \
			clobber; \
		} \
\
		u8 = (uint8_t const*)u64; \
	skip: \
		while (tail--) \
			count += (*u8++ & 0xC0) != 0x80, clobber; \
		return count; \
	}

#if __riscv_zbb
GEN_SWAR(SWAR_popc,__builtin_popcountll,BENCH_CLOBBER())
GEN_SWAR(SWAR_popc_autovec,__builtin_popcountll,(void)0)
# define POPC(f) f(SWAR_popc) f(SWAR_popc_autovec)
#else
# define POPC(f)
#endif

static inline int
popcnt64(uint64_t x)
{
	/* 2-bit sums */
	x -= (x >> 1) & (-(uint64_t)1/3);
	/* 4-bit sums */
	x = (x & (-(uint64_t)1/15*3)) + ((x >> 2) & (-(uint64_t)1/15*3));
	/* 8-bit sums */
	x = (x + (x >> 4)) & (-(uint64_t)1/255*15);
	BENCH_VOLATILE_REG(x);
	/* now we can just add the sums together, because can't overflow,
	 * since there can't be more than 255 bits set */
	x += (x >>  8); /* 16-bit sums */
	x += (x >> 16); /* sum 16-bit sums */
	x += (x >> 32); /* sum 32-bit sums */
	return x & 127;
}


GEN_SWAR(SWAR_popc_bithack,popcnt64,BENCH_CLOBBER())
GEN_SWAR(SWAR_popc_bithack_autovec,popcnt64,(void)0)


#define IMPLS(f) \
	f(scalar) \
	f(scalar_autovec) \
	POPC(f) \
	f(SWAR_popc_bithack) \
	f(SWAR_popc_bithack_autovec) \
	MX(f, rvv) \
	MX(f, rvv_align) \
	MX(f, rvv_tail) \
	MX(f, rvv_128) \
	MX(f, rvv_4x) \
	MX(f, rvv_4x_tail) \

typedef size_t Func(char const *str, size_t len);

#define DECLARE(f) extern Func utf8_count_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &utf8_count_##f },
Impl impls[] = { IMPLS(EXTRACT) };

char *str;
uint64_t last;

void init(void) { }
uint64_t checksum(size_t n) { return last; }

void common(size_t n, size_t off) {
	str = (char*)mem + off;
	randmem(str, n + 9);
}

BENCH(base) {
	common(n, randu64() & 511);
	TIME last = (uintptr_t)f(str, n);
} BENCH_END

BENCH(aligned) {
	common(n, 0);
	TIME last = (uintptr_t)f(str, n);
} BENCH_END

Bench benches[] = {
	{ MAX_MEM - 521, "utf8 count", bench_base },
	{ MAX_MEM - 521, "utf8 count aligned", bench_aligned }
}; BENCH_MAIN(impls, benches)


