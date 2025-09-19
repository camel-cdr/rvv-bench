#include "bench.h"

void
memreverse_scalar(uint8_t *restrict dest, uint8_t const *restrict src, size_t n)
{
	for (size_t i = 0; i < n; ++i)
		dest[i] = src[n-i-1], BENCH_CLOBBER();
}

void
memreverse_scalar_autovec(uint8_t *restrict dest, uint8_t const *restrict src, size_t n)
{
	for (size_t i = 0; i < n; ++i)
		dest[i] = src[n-i-1];
}

#define IMPLS(f) \
	f(scalar) \
	f(scalar_autovec) \
	MX(f, rvv_vsse) \
	MX(f, rvv_vlse) \
	f(rvv_vrgatherei16_m1) \
	f(rvv_vrgatherei16_m2) \
	f(rvv_vrgatherei16_m4) \
	MX(f, rvv_m1_vrgatherei16) \

typedef void Func(uint8_t *restrict dest, uint8_t const *restrict src, size_t n);

#define DECLARE(f) extern Func memreverse_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &memreverse_##f, 0 },
Impl impls[] = { IMPLS(EXTRACT) };

uint8_t *dest, *src;

void init(void) { }

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < n+9; ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

void common(size_t n, size_t dOff, size_t sOff) {
	dest = mem + dOff; src = dest + MAX_MEM/2 + sOff + 9;
	memset(dest, 0, n+9);
}

BENCH_BEG(base) {
	common(n, bench_urand() & 255, bench_urand() & 255);
	TIME f(dest, src, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/2 - 521, "memreverse", bench_base ),
}; BENCH_MAIN(benches)

