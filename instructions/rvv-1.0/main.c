#include "../../nolibc.h"
#include "config.h"

static ux mem[65536/sizeof(ux)];
static ux seed = 123456;

extern char const benchmark_names;
extern ux benchmark_types;
extern ux (*benchmarks)(void);
extern ux run_bench(ux (*bench)(void), ux type, ux vl, void *ptr, ux seed);


static int
compare_ux(void const *a, void const *b)
{
	return (*(ux*)a > *(ux*)b) - (*(ux*)a < *(ux*)b);
}

void
run_all_types(char const *name, ux (*bench)(void), ux types, ux vl, int ta, int ma) {
	ux arr[RUNS];

	print("<tr><td>")(s,name)("</td>");
	// e8..e64, m1..m8
	for (ux vtype = 0; vtype < 32; ++vtype) {
		ux vlmul = vtype & 7;
		ux vsew = vtype >> 3;
		if (vlmul > 3) continue;

		if (!((1 << vlmul) & types) ||
		    !((1 << vsew) & (types >> 4))) {
			print("<td></td>");
			continue;
		}

		for (ux i = 0; i < RUNS; ++i) {
			arr[i] = run_bench(bench, vtype | (!!ta << 6) | (!!ma << 7), vl, mem, seed);
			seed = seed*7 + 13;
		}
#if RUNS > 4
		qsort(arr, RUNS, sizeof *arr, compare_ux);
		ux sum = 0, count = 0;
		for (ux i = RUNS * 0.2f; i < RUNS * 0.8f; ++i, ++count)
			sum += arr[i];
#else
		ux sum = 0, count = RUNS;
		for (ux i = 0; i < RUNS; ++i)
			sum += arr[i];
#endif
		print("<td>")(fn,1,sum * 1.0f/(UNROLL*LOOP*count))("</td>");
	}
	print("</tr>\n")(flush,);
}

int
main(void)
{
	size_t x;
	seed = rv_cycles();
	seed ^= (uintptr_t)&x;

	ux vlarr[] = { 0, 1 };
	for (ux i = 0; i < 2; ++i) {
		for (ux j = 0; j < 4; ++j) {
			print("\n");
			if (vlarr[i] != 0)
				print("vl=")(u,vlarr[i]);
			else
				print("vl=VLMAX");
			print(s,j & 2 ? " ta" : " tu")(s,j & 1 ? " ma" : " mu")("\n\n");
			ux (**it)(void) = &benchmarks;
			char const *name = &benchmark_names;
			ux *types = &benchmark_types;
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
