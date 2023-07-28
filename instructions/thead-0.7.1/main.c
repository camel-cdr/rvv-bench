#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "common.h"

#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

typedef uint64_t u64;

static u64 seed = 128;

extern char const *benchmark_names;
extern u64 benchmark_types;
extern u64 (*benchmarks)(void);
extern u64 run_bench(u64 (*bench)(void), u64 type, u64 vl, u64 seed);

static int
compare_u64(void const *a, void const *b)
{
	return *(clock_t*)a - *(clock_t*)b;
}

void
run_all_types(char const *name, u64 (*bench)(void), u64 types, u64 vl) {
	static u64 arr[RUNS];

	printf("<tr><td>%s</td>", name);
	// m1..m8, e8..e64
	for (u64 vtype = 0; vtype < 16; ++vtype) {

		if (!((1 << (vtype & 3)) & types) ||
		    !((1 << (vtype >> 2)) & (types >> 4))) {
			printf("<td></td>");
			continue;
		}

		for (u64 i = 0; i < RUNS; ++i)
			arr[i] = run_bench(bench, vtype, vl, seed);
		qsort(arr, RUNS, sizeof *arr, compare_u64);
		u64 sum = 0, count = 0;
		for (u64 i = RUNS * 0.2f; i < RUNS * 0.8f; ++i, ++count)
			sum += arr[i];
		printf("<td>%2.1f</td>", sum * 1.0/(UNROLL*LOOP*count));

		seed = seed*7 + 13;
	}
	puts("</tr>");
}

int
main(void)
{

	int fd = open("/dev/urandom", O_RDONLY);
	read(fd, &seed, sizeof seed);
	close(fd);

	u64 vlarr[] = { 0, 1 };
	for (u64 i = 0; i < 2; ++i) {
		puts("");
		if (vlarr[i] != 0)
			printf("vl=%"PRIu64"\n\n", vlarr[i]);
		else
			puts("vl=VLMAX\n");
		u64 (**it)(void) = &benchmarks;
		char const **name = &benchmark_names;
		u64 *types = &benchmark_types;
		while (*it) {
			run_all_types(*name, *it, *types, vlarr[i]);
			++it;
			++name;
			++types;
		}
	}
}
