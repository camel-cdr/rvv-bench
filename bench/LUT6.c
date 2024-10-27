#include "bench.h"

void
LUT6_scalar(uint8_t lut[64], uint8_t *ptr, size_t n)
{
	for (; n--; ++ptr)
		*ptr = lut[*ptr & 63], BENCH_CLOBBER();
}

void
LUT6_scalar_autovec(uint8_t lut[restrict 64], uint8_t *restrict ptr, size_t n)
{
	for (; n--; ++ptr)
		*ptr = lut[*ptr & 63];
}


#define IMPLS(f) \
	f(scalar) \
	f(scalar_autovec) \
	f(rvv_gather_m4) \
	f(rvv_m1m2m4_gathers_m4) \
	f(rvv_vluxei8_m4) \
	f(rvv_vloxei8_m4) \

typedef void Func(uint8_t lut[64], uint8_t *ptr, size_t n);

#define DECLARE(f) extern Func LUT6_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &LUT6_##f },
Impl impls[] = { IMPLS(EXTRACT) };

uint8_t *ptr;

void init(void) { ptr = (uint8_t*)mem; }

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < n; ++i)
		sum = uhash(sum) + ptr[i];
	return sum;
}

BENCH_BEG(base) {
	static uint8_t lut[] =
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		"abcdefghijklmnopqrstuvwxyz"
		"0123456789"
		"+/";
	bench_memrand(ptr, n * sizeof *ptr);
	TIME f(lut, ptr, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM, "LUT6", bench_base )
}; BENCH_MAIN(benches)

