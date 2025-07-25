#include "bench.h"

void
ascii_to_utf16_scalar(uint16_t *restrict dest, uint8_t const *restrict src, size_t len)
{
	while (len--) BENCH_CLOBBER(), *dest++ = *src++;
}

void
ascii_to_utf16_scalar_autovec(uint16_t *restrict dest, uint8_t const *restrict src, size_t len)
{
	while (len--) *dest++ = *src++;
}

#define IMPLS(f) \
	f(scalar) f(scalar_autovec) \
	f(rvv_ext_m1) f(rvv_ext_m2) f(rvv_ext_m4) \
	f(rvv_vsseg_m1) f(rvv_vsseg_m2) f(rvv_vsseg_m4) \
	f(rvv_vss_m1) f(rvv_vss_m2) f(rvv_vss_m4) \

typedef void Func(uint16_t *restrict dest, uint8_t const *restrict src, size_t len);

#define DECLARE(f) extern Func ascii_to_utf16_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &ascii_to_utf16_##f, 0 },
Impl impls[] = { IMPLS(EXTRACT) };

uint16_t *dest;
uint8_t *src;

void init(void) { }

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < n+9; ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

void common(size_t n, size_t dOff, size_t sOff) {
	dest = (uint16_t*)mem + dOff/2;
	src = (uint8_t*)(dest + 9 + MAX_MEM/3) + sOff;
	bench_memrand(src, n+9);
	for (size_t i = 0; i < n+9; ++i) src[i] |= 0x7F;
	memset(dest, 1, (n+9)*2);
}

BENCH_BEG(base) {
	common(n, bench_urand() & 255, bench_urand() & 255);
	TIME f(dest, src, n);
} BENCH_END

BENCH_BEG(aligned) {
	common(n, 0, 0);
	TIME f(dest, src, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/3 - 512-9*2, "ascii to utf16", bench_base ),
	BENCH( impls, MAX_MEM/3 - 512-9*2, "ascii to utf16 aligned", bench_aligned ),
}; BENCH_MAIN(benches)

