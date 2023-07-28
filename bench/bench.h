#include <assert.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "config.h"

#define MX(f,F) f(F##_m1) f(F##_m2) f(F##_m4) f(F##_m8)


#define ARR_LEN(a) (sizeof a / sizeof *a)
#define ROTL(x,n) ((x << (n)) | (x >> (8*sizeof(x) - (n))))

#define STR(x) STR_(x)
#define STR_(x) #x
#define OPEN(...) __VA_ARGS__
#define FX(f,...) f(__VA_ARGS__)

#if defined(__clang__) || defined(__GNUC__) || defined(__INTEL_COMPILER)

/* artificial use of all of memory */
# define BENCH_CLOBBER() asm volatile("":::"memory")
/* artificial dependency of x on all of memory and all of memory on x */
# define BENCH_VOLATILE(x) asm volatile("" : "+g"(x) : "g"(x) : "memory")
# define BENCH_VOLATILE_REG(x) asm volatile("" : "+r"(x) : "r"(x) : "memory")
# define BENCH_VOLATILE_MEM(x) asm volatile("" : "+m"(x) : "m"(x) : "memory")

#else

# define BENCH_CLOBBER()
# define BENCH_CLOBBER_WITH(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
# define BENCH_CLOBBER_WITH_REG(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
# define BENCH_CLOBBER_WITH_MEM(x) (bench__use_ptr(&(x)), BENCH_CLOBBER())
static void bench_use_ptr(char const volatile *x) {}

#endif


static inline uint64_t
rv_cycles(void)
{
	uint64_t cycle;
	__asm volatile ("rdcycle %0" : "=r"(cycle));
	return cycle;
}

static int
compare_u64(void const *a, void const *b)
{
	return *(clock_t*)a - *(clock_t*)b;
}

typedef struct { uint64_t x, y; } RandState;
static RandState randState = {123, 456};

/* RomuDuoJr, see https://romu-random.org/ */
static uint64_t
randu64(void)
{
	uint64_t xp = randState.x;
	randState.x = 15241094284759029579u * randState.y;
	randState.y = randState.y - xp;  randState.y = ROTL(randState.y, 27);
	return xp;
}

static uint64_t
hash64(uint64_t x)
{
	x ^= x >> 32;
	x *= 0xd6e8feb86659fd93U;
	x ^= x >> 32;
	x *= 0xd6e8feb86659fd93U;
	x ^= x >> 32;
	return x;
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
	for (size_t i = 0; i < n; ++i)
		p[i] = randu64();
}

int
main(void)
{
	/* no idea why, but fopen doesn't seem to work with my toolchain */
	int fd = open("/dev/urandom", O_RDONLY);
	read(fd, &randState, sizeof randState);
	close(fd);

	/* initialize memory */
	mem = malloc(MAX_MEM);
	randmem(mem, MAX_MEM);

	init();
	bench_main();
	return 0;
}

static double
bench_time(size_t n, Impl impl, Bench bench)
{
	static uint64_t arr[MAX_REPEATS];
	clock_t beg = clock();
	size_t repeats = 0;
	for (; repeats < MAX_REPEATS; ++repeats) {
		arr[repeats] = bench.func(impl.func, n);
		if (repeats > MIN_REPEATS &&
		    clock() - beg > CLOCKS_PER_SEC * STOP_TIME)
			break;
	}
	qsort(arr, repeats, sizeof *arr, compare_u64);
	uint64_t sum = 0, count = 0;
	for (size_t i = repeats * 0.2f; i < repeats * 0.8f; ++i, ++count)
		sum += arr[i];
	return n / ((double)sum / count);
}

static void
bench_run(size_t nImpls, Impl *impls, size_t nBenches, Bench *benches)
{
	for (Bench *b = benches; b != benches + nBenches; ++b) {
		printf("{\ntitle: \"%s\",\n", b->name);
		printf("labels: [\"0\",");
		for (size_t i = 0; i < nImpls; ++i)
			printf("\"%s\",", impls[i].name);
		printf("],\n");

		size_t N = b->N;
		printf("data: [\n[");
		for (size_t n = 1; n < N; BENCH_NEXT(n))
			printf("%zu,", n);
		printf("],\n");

		for (Impl *i = impls; i != impls + nImpls; ++i) {
			printf("[");
			for (size_t n = 1; n < N; BENCH_NEXT(n)) {
				uint64_t si, s0;

				RandState seed = randState;
				(void)b->func(i->func, n);
				si = checksum(n);

				randState = seed;
				(void)b->func(impls[0].func, n);
				s0 = checksum(n);

				if (si != s0) {
					printf("ERROR: %s in %s at %zu",
					       i->name, b->name, n);
					exit(EXIT_FAILURE);
				}

				printf("%f,", bench_time(n, *i, *b));
				fflush(stdout);
			}
			printf("],\n");
		}
		printf("]\n},\n");
	}
}

#define TIME \
	for (uint64_t beg = rv_cycles(), _once = 1; _once; \
	     _cycles += rv_cycles() - beg, _once = 0)

#define BENCH(name) \
	uint64_t bench_##name(void *_func, size_t n) { \
		Func *f = _func; uint64_t _cycles = 0;
#define BENCH_END return _cycles; }

#define BENCH_MAIN(impls, benches) \
	void bench_main(void) { \
		bench_run(ARR_LEN(impls), impls, ARR_LEN(benches), benches); \
	}


