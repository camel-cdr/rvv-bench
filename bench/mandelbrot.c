#include "bench.h"

void
mandelbrot_scalar_f32(size_t width, size_t maxIter, uint32_t *res)
{
	for (size_t y = 0; y < width; ++y)
	for (size_t x = 0; x < width; ++x) {
		float cx = x * 2.0f / width - 1.5;
		float cy = y * 2.0f / width - 1;
		size_t iter = 0;
		float zx = 0, zy = 0, zxS = 0, zyS = 0;

		BENCH_VOLATILE_REG(cy);
		while (zxS + zyS <= 4 && iter < maxIter) {
			zxS = zxS - zyS + cx;
			zy = 2 * zx * zy + cy;
			zx = zxS;
			zxS = zx*zx;
			zyS = zy*zy;
			++iter;
		}
		*res++ = iter;
	}
}

#if __riscv_flen == 64
void
mandelbrot_scalar_f64(size_t width, size_t maxIter, uint32_t *res)
{
	for (size_t y = 0; y < width; ++y)
	for (size_t x = 0; x < width; ++x) {
		double cx = x * 2.0 / width - 1.5;
		double cy = y * 2.0 / width - 1;
		size_t iter = 0;
		double zx = 0, zy = 0, zxS = 0, zyS = 0;

		BENCH_VOLATILE_REG(cy);
		while (zxS + zyS <= 4 && iter < maxIter) {
			zxS = zxS - zyS + cx;
			zy = 2 * zx * zy + cy;
			zx = zxS;
			zxS = zx*zx;
			zyS = zy*zy;
			++iter;
		}
		*res++ = iter;
	}
}
#endif

#define IMPLS(f) \
	f(scalar_f32) \
	IF_F64(f(scalar_f64)) \
	IF_VF16(f(rvv_f16_m1)) \
	IF_VF16(f(rvv_f16_m2)) \
	f(rvv_f32_m1) \
	f(rvv_f32_m2) \
	IF_VF64(f(rvv_f64_m1)) \
	IF_VF64(f(rvv_f64_m2)) \

typedef void Func(size_t width, size_t maxIter, uint32_t *res);

#define DECLARE(f) extern Func mandelbrot_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &mandelbrot_##f },
Impl impls[] = { IMPLS(EXTRACT) };

void init(void) { }

/* disabled, because of rounding errors, please independently verify */
ux checksum(size_t n) {
#if 0
	double sum = 0;
	uint32_t *ptr = (uint32_t*)mem;
	n = usqrt(n);
	for (size_t i = 0; i < n*n; ++i)
		sum += *ptr++;
	print("<")(f,sum/(n*n+1))(">");
#endif
	return 0;
}

BENCH_BEG(base) {
	n = usqrt(n);
	TIME f(n, mandelbrot_ITER, (uint32_t*)mem);
} BENCH_END

Bench benches[] = {
	BENCH(
		impls,
		SCALE_mandelbrot(MAX_MEM / 4),
		"mandelbrot "STR(mandelbrot_ITER),
		bench_base
	)
}; BENCH_MAIN(benches)

