#include "../../nolibc.h"
#include "config.h"

typedef uint64_t u64;


extern char const benchmark_names;
extern u64 (*benchmarks)(void);
extern u64 run_bench(u64 (*bench)(void));


static int
compare_u64(void const *a, void const *b)
{
	return (*(u64*)a > *(u64*)b) - (*(u64*)a < *(u64*)b);
}

void
run(char const *name, u64 (*bench)(void)) {
	u64 arr[RUNS];

	print("<tr><td>")(s,name)("</td>");
    for (u64 i = 0; i < RUNS; ++i)
        arr[i] = run_bench(bench);
    qsort(arr, RUNS, sizeof *arr, compare_u64);

    u64 sum = 0, count = 0;
    for (u64 i = RUNS * 0.2f; i < RUNS * 0.8f; ++i, ++count)
        sum += arr[i];
    print("<td>")(fn,1,sum * 1.0/(UNROLL*LOOP*count))("</td>");
	print("</tr>\n");
	flush();
}

int
main(void)
{
    u64 (**it)(void) = &benchmarks;
    char const *name = &benchmark_names;
    while (*it) {
        run(name, *it);
        ++it;
        while (*name++);
    }
	return 0;
}
