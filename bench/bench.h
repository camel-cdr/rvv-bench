#include "config.h"
#include "../nolibc.h"

#ifndef BENCH_NEXT
#  define BENCH_NEXT NEXT
#endif

#define MX(f,F) f(F##_m1) f(F##_m2) f(F##_m4) f(F##_m8)
#define STR(x) STR_(x)
#define STR_(x) #x

#define ROTL(x,n) ((x << (n)) | (x >> (8*sizeof(x) - (n))))

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
compare_u64(void const *a, void const *b)
{
	uint64_t A = *(uint64_t*)a, B = *(uint64_t*)b;
	return A < B ? -1 : A > B ? 1 : 0;
}

typedef struct { uint64_t x, y; } RandState;
static RandState randState = { 123, 456 };

/* RomuDuoJr, see https://romu-random.org/ */
static uint64_t
randu64(void)
{
	uint64_t xp = randState.x;
	randState.x = 15241094284759029579u * randState.y;
	randState.y = randState.y - xp;  randState.y = ROTL(randState.y, 27);
	return xp;
}

typedef struct {
	char const *name; void *func;
} Impl;
typedef struct {
	size_t N;
	char const *name;
	uint64_t (*func)(void *, size_t);
} Bench;

static unsigned char *mem = 0;

void bench_main(void);
uint64_t checksum(size_t n);
void init(void);

static void
randmem(void *ptr, size_t n)
{
	unsigned char *p = ptr;
#ifdef __GNUC__
	typedef uint64_t __attribute__((__may_alias__)) u64;
	for (; n && (uintptr_t)p % 8; --n) *p++ = randu64();
	u64 *p64 = (u64*)p;
	for (; n > 8; n -= 8) *p64++ = randu64();
	p = (unsigned char*)p64;
#endif
	while (n--) *p++ = randu64();
}

#if __STDC_HOSTED__
# include <stdlib.h>
#else
static uint64_t heap[1 + MAX_MEM / sizeof(uint64_t)];
#endif


int
main(void)
{

#if __STDC_HOSTED__
	mem = malloc(MAX_MEM);
#else
	mem = (unsigned char*)heap;
#endif

	size_t x;
	randState.x ^= rv_cycles()*7;
	randState.y += rv_cycles() ^ (uintptr_t)&x + 666*(uintptr_t)mem;

	/* initialize memory */
	randmem(mem, MAX_MEM);

	init();
	bench_main();
#if __STDC_HOSTED__
	free(mem);
#endif
	return 0;
}

static double
bench_time(size_t n, Impl impl, Bench bench)
{
	static uint64_t arr[MAX_REPEATS];
	size_t total = 0, repeats = 0;
	for (; repeats < MAX_REPEATS; ++repeats) {
		total += arr[repeats] = bench.func(impl.func, n);
		if (repeats > MIN_REPEATS && total > STOP_CYCLES)
			break;
	}
#if MAX_REPEATS > 4
	qsort(arr, repeats, sizeof *arr, compare_u64);
	uint64_t sum = 0, count = 0;
	for (size_t i = repeats * 0.2f; i < repeats * 0.8f; ++i, ++count)
		sum += arr[i];
#else
	uint64_t sum = 0, count = repeats;
	for (size_t i = 0; i < repeats; ++i)
		sum += arr[i];
#endif
	return n / ((double)sum / count);
}

static void
bench_run(size_t nImpls, Impl *impls, size_t nBenches, Bench *benches)
{
	for (Bench *b = benches; b != benches + nBenches; ++b) {
		print("{\ntitle: \"")(s,b->name)("\",\n");
		print("labels: [\"0\",");
		for (size_t i = 0; i < nImpls; ++i)
			print("\"")(s,impls[i].name)("\",");
		print("],\n");

		size_t N = b->N;
		print("data: [\n[");
		for (size_t n = 1; n < N; n = BENCH_NEXT(n))
			print(u,n)(",");
		print("],\n");
		flush();

		for (Impl *i = impls; i != impls + nImpls; ++i) {
			print("[");
			for (size_t n = 1; n < N; n = BENCH_NEXT(n)) {
				uint64_t si = 0, s0 = 0;

				if (i != impls) {
					RandState seed = randState;
					(void)b->func(i->func, n);
					si = checksum(n);

					randState = seed;
					(void)b->func(impls[0].func, n);
					s0 = checksum(n);
				}

				if (si != s0) {
					print("ERROR: ")(s,i->name)(" in ")(s,b->name)(" at ")(u,n);
					flush();
					exit(EXIT_FAILURE);
				}

				print(f,bench_time(n, *i, *b))(",");
				flush();
			}
			print("],\n");
			flush();
		}
		print("]\n},\n");
	}
}

#define TIME \
	for (uint64_t beg = rv_cycles(), _once = 1; _once; \
	       BENCH_FENCE(), \
	       _cycles += rv_cycles() - beg, _once = 0)

#define BENCH(name) \
	uint64_t bench_##name(void *_func, size_t n) { \
		Func *f = _func; uint64_t _cycles = 0;
#define BENCH_END return _cycles; }

#define BENCH_MAIN(impls, benches) \
	void bench_main(void) { \
		bench_run(ARR_LEN(impls), impls, ARR_LEN(benches), benches); \
	}

