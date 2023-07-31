#include "bench.h"
#include "rvv-chacha-poly/boring.h"

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
	{ "chacha20_boring", &chacha20_boring },
	{ "chacha20_rvv", &chacha20_rvv },
};

void init(void) {
	randmem(key, sizeof key);
	randmem(nonce, sizeof nonce);
	counter = 0;
}

uint64_t checksum(size_t n) {
	uint64_t sum = 0;
	for (size_t i = 0; i < n+16; ++i)
		sum = hash64(sum) + mem[i];
	return sum;
}

BENCH(aligned) {
	memset(mem, 0, n+16);
	TIME f(mem, mem + MAX_MEM/2 + 16, n);
} BENCH_END

Bench benches[] = {
	{ MAX_MEM/2 - 16, "chacha20 aligned", bench_aligned }
}; BENCH_MAIN(impls, benches)


#include "rvv-chacha-poly/boring.c"
