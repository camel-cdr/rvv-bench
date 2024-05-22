#include "../../nolibc.h"
#include "config.h"

static ux mem[65536/sizeof(ux)];
static ux seed = 123456;

typedef ux (*BenchFunc)(void);
extern size_t bench_count;
extern char bench_names;
extern ux bench_types;
extern BenchFunc bench_m1, bench_m2, bench_m4, bench_m8;
static BenchFunc *benches[] = { &bench_m1, &bench_m2, &bench_m4, &bench_m8 };

extern ux run_bench(ux (*bench)(void), ux type, ux vl, void *ptr, ux seed);


static int
compare_ux(void const *a, void const *b)
{
	return (*(ux*)a > *(ux*)b) - (*(ux*)a < *(ux*)b);
}


static void
run_all_types(char const *name, ux bIdx, ux vl, int ta, int ma)
{
	ux arr[RUNS];


	print("<tr><td>")(s,name)("</td>");
	ux mask = bIdx[&bench_types];

	for (ux sew = 0; sew < 4; ++sew)
	for (ux lmul = 0; lmul < 4; ++lmul) {
		ux vtype = lmul | (sew<<3) | (!!ta << 6) | (!!ma << 7);

		if (!(mask >> (lmul*4 + sew) & 1)) {
			print("<td></td>");
			continue;
		}

		ux emul = lmul;
		if (mask == T_W || mask == T_FW || mask == T_N || mask == T_FN)
			emul += 1;
		if (mask == T_ei16 && sew == 0)
			emul = emul < 3 ? emul+1 : 3;
		if (mask == T_m1)
			emul = 1;
		BenchFunc bench = benches[emul][bIdx];

		for (ux i = 0; i < RUNS; ++i) {
			arr[i] = run_bench(bench, vtype, vl, mem, seed);
			if (~arr[i] == 0) goto skip;
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
		print("<td>")(fn,1,sum * 1.0f/(UNROLL*LOOP*count*8))("</td>");
		continue;
skip:
		print("<td></td>");
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
		for (ux j = 4; j--; ) {
			print("\n");
			if (vlarr[i] != 0)
				print("vl=")(u,vlarr[i]);
			else
				print("vl=VLMAX");
			print(s,j & 2 ? " ta" : " tu")(s,j & 1 ? " ma" : " mu")("\n\n");
			char const *name = &bench_names;
			for (ux bIdx = 0; bIdx < bench_count; ++bIdx) {
				run_all_types(name, bIdx, vlarr[i], j >> 1, j & 1);
				while (*name++);
			}
		}
	}
	return 0;
}
