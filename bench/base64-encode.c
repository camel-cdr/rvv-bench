#include "bench.h"

size_t
b64_encode_scalar(uint8_t *dst, const uint8_t *src, size_t length, const uint8_t *lut, const uint8_t *shift)
{
	uint8_t *dstBeg = dst;
	for (; length >= 3; length -= 3, src += 3, dst += 4) {
		uint32_t u32 = src[0] << 16 | src[1] << 8 | src[2];
		dst[0] = lut[(u32 >> 18) & 63];
		dst[1] = lut[(u32 >> 12) & 63];
		dst[2] = lut[(u32 >>  6) & 63];
		dst[3] = lut[(u32 >>  0) & 63];
	}
	if (length > 0) {
		uint32_t u32 = src[0] << 8 | (length > 1 ? src[1] : 0);
		*dst++ =              lut[(u32 >> 10) & 63];
		*dst++ =              lut[(u32 >> 4) & 63];
		*dst++ = length > 1 ? lut[(u32 << 2) & 63] : '=';
		*dst++ =                                     '=';
	}
	return dst - dstBeg;
}

static uint8_t base64LUT[] =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz"
	"0123456789"
	"+/";

static const uint8_t base64shiftLUT[16] = {
	'a' - 26, '0' - 52, '0' - 52, '0' - 52,
	'0' - 52, '0' - 52, '0' - 52, '0' - 52,
	'0' - 52, '0' - 52, '0' - 52, '+' - 62,
	'/' - 63, 'A'
};

#define IMPLS(f) \
	f(scalar) \
	f(rvv_LUT64) f(rvv_LUT16) \
	f(rvv_seg_LUT64) f(rvv_seg_LUT16)

typedef size_t Func(uint8_t *dst, const uint8_t *src, size_t length, const uint8_t *lut, const uint8_t *shift);

#define DECLARE(f) extern Func b64_encode_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &b64_encode_##f },
Impl impls[] = { IMPLS(EXTRACT) };

uint8_t *dest, *src;
ux last;

void init(void) { }

ux checksum(size_t n) {
	ux sum = last;
	for (size_t i = 0; i < n+9; ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

BENCH_BEG(base) {
	src = mem;
	dest = mem + MAX_MEM/3;
	memset(dest, 0, n+9);
	TIME last = (uintptr_t)f(dest, src, n, base64LUT, base64shiftLUT);
} BENCH_END

Bench benches[] = {
	BENCH( impls, MAX_MEM/3, "base64 encode", bench_base ),
}; BENCH_MAIN(benches)

