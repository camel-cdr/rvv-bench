#include "bench.h"

void
LUT4_scalar(uint8_t lut[16], uint8_t *ptr, size_t n)
{
	for (; n--; ++ptr)
		*ptr = lut[*ptr & 0xF], BENCH_CLOBBER();
}

void
LUT4_scalar_autovec(uint8_t lut[restrict 16], uint8_t *restrict ptr, size_t n)
{
	for (; n--; ++ptr)
		*ptr = lut[*ptr & 0xF];
}


#define IMPLS(f) \
	f(scalar) \
	f(scalar_autovec) \
	MX(f, rvv_gather) \
	f(rvv_m1_gathers_m2) \
	f(rvv_m1_gathers_m4) \
	f(rvv_m1_gathers_m8) \
	MX(f, rvv_vluxei8) \
	MX(f, rvv_vloxei8) \

typedef void Func(uint8_t lut[16], uint8_t *ptr, size_t n);

#define DECLARE(f) extern Func LUT4_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &LUT4_##f },
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
	static uint32_t lut[4] = { 0x4564907f, 0xb8ce2de0, 0xc0f7adf8, 0xa048aa9f };
	bench_memrand(ptr, n * sizeof *ptr);
	TIME f((uint8_t*)lut, ptr, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM, "LUT4", bench_base )
}; BENCH_MAIN(benches)

