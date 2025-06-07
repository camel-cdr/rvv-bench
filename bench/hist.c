#include "bench.h"

void
hist_scalar(uint32_t *hist, float *x, float *y, size_t n)
{
	for (size_t i = 0; i < n; ++i) {
		float dist = x[i]*x[i] + y[i]*y[i];
		__asm__ ("fsqrt.s %0, %0\n" : "+f"(dist));
		size_t idx = dist;
		idx = idx > 100 ? 100 : dist;
		++hist[idx];
	}
}

#define IMPLS(f) \
	f(scalar) \
	MX(f, rvv_slidedown) \
	MX(f, rvv_assume_no_conflict) \
	f(rvv_dup_entries_m1) \
	f(rvv_dup_entries_m2) \
	f(rvv_dup_entries_m4) \

typedef void Func(uint32_t *hist, float *x, float *y, size_t n);

#define DECLARE(f) extern Func hist_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &hist_##f },
Impl impls[] = { IMPLS(EXTRACT) };

static uint32_t hist[100 * (1<<16>>4)];
float *inx, *iny;

void init(void) {
	inx = (float*)mem;
	iny = (float*)(mem + MAX_MEM/2);
}

ux checksum(size_t n) {
	size_t sum = 0;
	for (size_t i = 0; i < 100; ++i)
		sum = hist[i];
	return sum <= n; // sanity check for no_conflict
}

BENCH_BEG(base) {
	n /= sizeof(float);
	memset(hist, 0, sizeof hist);
	float max = 70.71; // approx. sqrtf(100*100/2);
	for (size_t i = 0; i < n; ++i) {
		inx[i] = bench_urandf() * 2 * max - max;
		iny[i] = bench_urandf() * 2 * max - max;
	}
	TIME f(hist, inx, iny, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/2, "hist", bench_base)
}; BENCH_MAIN(benches)

