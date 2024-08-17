#include "bench.h"
#if __riscv_xlen != 32
#include "../thirdparty/rvv-chacha-poly/boring.h"

uint8_t *dest, *src;
uint8_t key[32], nonce[12];
uint32_t counter;


extern void vector_chacha20(
		uint8_t *out, const uint8_t *in,
		size_t in_len, const uint8_t key[32],
		const uint8_t nonce[12], uint32_t counter);

static void
chacha20_boring(void *restrict dest, void const *restrict src, size_t n) {
	boring_chacha20(dest, src, n, key, nonce, counter);
}

static void
chacha20_rvv(void *restrict dest, void const *restrict src, size_t n) {
	vector_chacha20(dest, src, n, key, nonce, counter);
}

typedef void *Func(void *restrict dest, void const *restrict src, size_t n);

Impl impls[] = {
	{ "boring", &chacha20_boring },
	{ "rvv", &chacha20_rvv },
};

void init(void) {
	bench_memrand(key, sizeof key);
	bench_memrand(nonce, sizeof nonce);
	counter = 0;
}

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < n+16; ++i)
		sum = uhash(sum) + mem[i];
	return sum;
}

BENCH_BEG(aligned) {
	memset(mem, 0, n+16);
	TIME f(mem, mem + MAX_MEM/2 + 16, n);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/2 - 16, "chacha20 aligned", bench_aligned )
}; BENCH_MAIN(benches)


#include "../thirdparty/rvv-chacha-poly/boring.c"
#else
void init(void) {}
Impl impls[] = {};
Bench benches[] = {};
BENCH_MAIN(benches)
#endif
