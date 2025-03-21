#include "bench.h"

size_t
b64_encode_scalar(uint8_t *dst, const uint8_t *src, size_t length, const uint8_t LUTs[64+16])
{
	uint8_t *dstBeg = dst;
	for (; length >= 3; length -= 3, src += 3, dst += 4) {
		uint32_t u32 = src[0] << 16 | src[1] << 8 | src[2];
		dst[0] = LUTs[(u32 >> 18) & 63];
		dst[1] = LUTs[(u32 >> 12) & 63];
		dst[2] = LUTs[(u32 >>  6) & 63];
		dst[3] = LUTs[(u32 >>  0) & 63];
	}
	if (length > 0) {
		uint32_t u32 = src[0] << 8 | (length > 1 ? src[1] : 0);
		*dst++ =              LUTs[(u32 >> 10) & 63];
		*dst++ =              LUTs[(u32 >>  4) & 63];
		*dst++ = length > 1 ? LUTs[(u32 <<  2) & 63] : '=';
		*dst++ =                                       '=';
	}
	return dst - dstBeg;
}

static uint8_t base64LUTs[64 + 16] =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz"
	"0123456789"
	"+/"
	"\x47\xfc\xfc\xfc\xfc\xfc\xfc\xfc\xfc\xfc\xfc\xed\xf0\x41"
	// 'a'-26, 10x '0' - 52, '+' - 62, '/' - 63, 'A'
;

/* used to prevent GPR spill in vectorized implementations */
size_t
b64_encode_scalar_tail(size_t prefix, uint8_t *dst, const uint8_t *src, size_t length)
{
	return prefix + b64_encode_scalar(dst, src, length, base64LUTs);
}


#define IMPLS(f) \
	f(scalar) \
	f(rvv_LUT64) f(rvv_LUT16) \
	f(rvv_seg_LUT64) f(rvv_seg_LUT16)

typedef size_t Func(uint8_t *dst, const uint8_t *src, size_t length, const uint8_t LUTs[64+16]);

#define DECLARE(f) extern Func b64_encode_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &b64_encode_##f },
Impl impls[] = { IMPLS(EXTRACT) };

uint8_t *dest, *src;
size_t last;

void init(void) { }

ux checksum(size_t n) {
	ux sum = last;
	for (size_t i = 0; i < last+9; ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

BENCH_BEG(base) {
	src = mem;
	dest = mem + MAX_MEM/3;
	memset(dest, 0, n*2+9);
	TIME last = f(dest, src, n, base64LUTs);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/3, "base64 encode", bench_base ),
}; BENCH_MAIN(benches)

