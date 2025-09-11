#include <riscv_vector.h>

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef N
#define N (1024*128) /* change me */
#endif

static void
rvvlm_sqrt(size_t x_len, const double *x, double *y)
{
    for (size_t vl; x_len > 0; x_len -= vl, x += vl, y += vl) {
        vl = __riscv_vsetvl_e64m8(x_len);
        vfloat64m8_t v = __riscv_vle64_v_f64m8(x, vl);
        __riscv_vse64(y, __riscv_vfsqrt(v, vl), vl);
    }
}

#define APPLY(X) \
X(exp) X(exp2) X(expm1) X(log) X(log10) X(log2) X(log1p) \
X(sqrt) X(cbrt) \
X(sin) X(cos) X(tan) X(asin) X(acos) X(atan) \
X(sinh) X(cosh) X(tanh) X(asinh) X(acosh) X(atanh) \
X(erf) X(erfc) X(tgamma) X(lgamma)

#define DECLARE(f) void rvvlm_##f(size_t x_len, const double *x, double *y);
APPLY(DECLARE)

#define DEFINE(f) \
	static void lm_##f(size_t x_len, const double *x, double *y) { \
		for (size_t i = 0; i < x_len; ++i) y[i] = f(x[i]); \
	}
APPLY(DEFINE)
struct Func {
	void (*rvvlm)(size_t, const double*, double*);
	void (*lm)(size_t, const double*, double*);
	const char *name;
};

struct Func funcs[] = {
#define ENTRY(f) { rvvlm_##f, lm_##f, #f },
APPLY(ENTRY)
};

typedef struct { uint64_t x, y, z; } URand;

/* RomuDuoJr, see https://romu-random.org/ */
static inline uint64_t
urand(URand *r)
{
#define ROTL(x,n) (((x) << (n)) | ((x) >> (8*sizeof(x) - (n))))
	uint64_t xp = r->x, yp = r->y, zp = r->z;
	r->x = 15241094284759029579u * zp;
	r->y = ROTL(yp - xp, 12);
	r->z = ROTL(zp - yp, 44);
	return xp;
}


int
main(void)
{
	double *in = malloc(N*sizeof *in), *out = malloc(N*sizeof *out);
	URand r = {123, (uintptr_t)&in, (uintptr_t)&out};

	for (size_t i = 0; i < N; ++i)
		in[i] = (urand(&r) >> (64 - 53)) * (1.0 / (1ull << 53));

	for (size_t i = 0; i < sizeof funcs / sizeof *funcs; ++i) {
		size_t beg, end;
		struct Func f = funcs[i];
		printf("%s libm: ", f.name);
		for (size_t i = 0; i < 3; ++i) {
			__asm__ volatile ("csrr %0, cycle" : "=r"(beg));
			f.lm(N, in, out);
			__asm__ volatile ("csrr %0, cycle" : "=r"(end));
			printf(" %f", ((double)N) / (end-beg));
		}
		printf(" elements/cycle\n%s rvvlm:", f.name);
		for (size_t i = 0; i < 3; ++i) {
			__asm__ volatile ("csrr %0, cycle" : "=r"(beg));
			f.rvvlm(N, in, out);
			__asm__ volatile ("csrr %0, cycle" : "=r"(end));
			printf(" %f", ((double)N) / (end-beg));
		}
		printf(" elements/cycle\n");
	}
	free(in);
	free(out);
	return 0;
}

