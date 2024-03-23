#include "../../nolibc.h"
#include "config.h"

typedef uint64_t u64;

static u64 seed = 128;

extern char const benchmark_names;
extern u64 benchmark_types;
extern u64 (*benchmarks)(void);
extern u64 run_bench(u64 (*bench)(void), u64 type, u64 vl, u64 seed);


static int
compare_u64(void const *a, void const *b)
{
	return (*(u64*)a > *(u64*)b) - (*(u64*)a < *(u64*)b);
}

void
run_all_types(char const *name, u64 (*bench)(void), u64 types, u64 vl, int ta, int ma) {
	u64 arr[RUNS];

	print("<tr><td>")(s,name)("</td>");
	// e8..e64, m1..m8
	for (u64 vtype = 0; vtype < 32; ++vtype) {
		u64 vlmul = vtype & 7;
		u64 vsew = vtype >> 3;
		if (vlmul > 3) continue;

		if (!((1 << vlmul) & types) ||
		    !((1 << vsew) & (types >> 4))) {
			print("<td></td>");
			continue;
		}

		for (u64 i = 0; i < RUNS; ++i)
			arr[i] = run_bench(bench, vtype | (!!ta << 6) | (!!ma << 7), vl, seed);
		qsort(arr, RUNS, sizeof *arr, compare_u64);

		u64 sum = 0, count = 0;
		for (u64 i = RUNS * 0.2f; i < RUNS * 0.8f; ++i, ++count)
			sum += arr[i];
		print("<td>")(fn,1,sum * 1.0/(UNROLL*LOOP*count))("</td>");

		seed = seed*7 + 13;
	}
	print("</tr>\n");
	flush();
}

int
main(void)
{
	size_t x;
	__asm volatile ("rdcycle %0" : "=r"(seed));
	seed ^= (uintptr_t)&x;

	u64 vlarr[] = { 0, 1 };
	for (u64 i = 0; i < 2; ++i) {
		for (u64 j = 0; j < 4; ++j) {
			print("\n");
			if (vlarr[i] != 0)
				print("vl=")(u,vlarr[i]);
			else
				print("vl=VLMAX");
			print(s,j & 2 ? " ta" : " tu")(s,j & 1 ? " ma" : " mu")("\n\n");
			u64 (**it)(void) = &benchmarks;
			char const *name = &benchmark_names;
			u64 *types = &benchmark_types;
			while (*it) {
				run_all_types(name, *it, *types, vlarr[i], j >> 1, j & 1);
				++it;
				while (*name++);
				++types;
			}
		}
	}
	return 0;
}
