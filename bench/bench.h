#include "config.h"
#include "../nolibc.h"

#ifndef BENCH_NEXT
#  define BENCH_NEXT NEXT
#endif

#define MX(f,F) f(F##_m1) f(F##_m2) f(F##_m4) f(F##_m8)
#define STR(x) STR_(x)
#define STR_(x) #x

#if defined(__clang__) || defined(__GNUC__) || defined(__INTEL_COMPILER)

# define BENCH_CLOBBER() ({__asm volatile("":::"memory");})
# define BENCH_VOLATILE(x) ({__asm volatile("" : "+g"(x) : "g"(x) : "memory");})
# define BENCH_VOLATILE_REG(x) ({__asm volatile("" : "+r"(x) : "r"(x) : "memory");})
# define BENCH_VOLATILE_MEM(x) ({__asm volatile("" : "+m"(x) : "m"(x) : "memory");})
# define BENCH_FENCE() ({__asm volatile("fence.i");})


#define BENCH_MAY_ALIAS __attribute__((__may_alias__))

#else

# define BENCH_CLOBBER()
# define BENCH_CLOBBER_WITH(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
# define BENCH_CLOBBER_WITH_REG(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
# define BENCH_CLOBBER_WITH_MEM(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
static void bench_use_ptr(char const volatile *x) {}

#define BENCH_MAY_ALIAS

#endif


static int
compare_ux(void const *a, void const *b)
{
	ux A = *(ux*)a, B = *(ux*)b;
	return A < B ? -1 : A > B ? 1 : 0;
}

static URand randState = { 123, 456, 789 };
static ux bench_urand(void) { return urand(&randState); }
static void bench_memrand(void *ptr, size_t n) { return memrand(&randState, ptr, n); }

typedef struct {
	char const *name; void *func;
} Impl;
typedef struct {
	Impl *impls;
	size_t nImpls;
	size_t N;
	char const *name;
	ux (*func)(void *, size_t);
} Bench;

static unsigned char *mem = 0;

void bench_main(void);
ux checksum(size_t n);
void init(void);

#if __STDC_HOSTED__ && !defined(CUSTOM_HOST)
# include <stdlib.h>
#else
static ux heap[1 + MAX_MEM / sizeof(ux)];
#endif


int
main(void)
{

#if __STDC_HOSTED__ && !defined(CUSTOM_HOST)
	mem = malloc(MAX_MEM);
#else
	mem = (unsigned char*)heap;
#endif

	size_t x;
	randState.x ^= rv_cycles()*7;
	randState.y += rv_cycles() ^ (uintptr_t)&x + 666*(uintptr_t)mem;

	/* initialize memory */
	bench_memrand(mem, MAX_MEM);

	init();
	bench_main();
#if __STDC_HOSTED__ && !defined(CUSTOM_HOST)
	free(mem);
#endif
	return 0;
}

static fx
bench_time(size_t n, Impl impl, Bench bench)
{
	static ux arr[MAX_REPEATS];
	size_t total = 0, repeats = 0;
	for (; repeats < MAX_REPEATS; ++repeats) {
		total += arr[repeats] = bench.func(impl.func, n);
		if (repeats > MIN_REPEATS && total > STOP_CYCLES)
			break;
	}
#if MAX_REPEATS > 4
	qsort(arr, repeats, sizeof *arr, compare_ux);
	ux sum = 0, count = 0;
	for (size_t i = repeats * 0.2f; i < repeats * 0.8f; ++i, ++count)
		sum += arr[i];
#else
	ux sum = 0, count = repeats;
	for (size_t i = 0; i < repeats; ++i)
		sum += arr[i];
#endif
	return n / ((fx)sum / count);
}

static void
bench_run(Bench *benches, size_t nBenches)
{
	for (Bench *b = benches; b != benches + nBenches; ++b) {
		print("{\ntitle: \"")(s,b->name)("\",\n");
		print("labels: [\"0\",");
		for (size_t i = 0; i < b->nImpls; ++i)
			print("\"")(s,b->impls[i].name)("\",");
		print("],\n");

		size_t N = b->N;
		print("data: [\n[");
		for (size_t n = 1; n < N; n = BENCH_NEXT(n))
			print(u,n)(",");
		print("],\n")(flush,);

		for (Impl *i = b->impls; i != b->impls + b->nImpls; ++i) {
			print("[");
			for (size_t n = 1; n < N; n = BENCH_NEXT(n)) {
				ux si = 0, s0 = 0;

#if VALIDATE
				if (i != b->impls) {
					URand seed = randState;
					(void)b->func(i->func, n);
					si = checksum(n);

					randState = seed;
					(void)b->func(b->impls[0].func, n);
					s0 = checksum(n);
				}

				if (si != s0) {
					print("ERROR: ")(s,i->name)(" in ")(s,b->name)(" at ")(u,n)(flush,);
					exit(EXIT_FAILURE);
				}
#endif

				print(f,bench_time(n, *i, *b))(",")(flush,);
			}
			print("],\n")(flush,);
		}
		print("]\n},\n");
	}
}

#define TIME \
	for (ux beg = rv_cycles(), _once = 1; _once; \
	       BENCH_FENCE(), \
	       _cycles += rv_cycles() - beg, _once = 0)

#define BENCH_BEG(name) \
	ux bench_##name(void *_func, size_t n) { \
		Func *f = _func; ux _cycles = 0;
#define BENCH_END return _cycles; }

#define BENCH(impls, ...) { impls, ARR_LEN(impls), __VA_ARGS__ }

#define BENCH_MAIN(benches) \
	void bench_main(void) { \
		bench_run(benches, ARR_LEN(benches)); \
	}

