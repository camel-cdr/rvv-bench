#include "bench.h"
#if __riscv_xlen >= 64

#define IMPLS(f) f(stack) f(fp) f(rvv_best) f(rvv_worst_merge) f(rvv_worst_slide) f(rvv_zvl128b)

typedef size_t Func(ux const *data, size_t len);

#define DECLARE5(f) extern Func reg_spill_5_##f;
#define DECLARE14(f) extern Func reg_spill_14_##f;
IMPLS(DECLARE5)
IMPLS(DECLARE14)

#define EXTRACT5(f) { #f, &reg_spill_5_##f },
#define EXTRACT14(f) { #f, &reg_spill_14_##f },
Impl impls5[] = { IMPLS(EXTRACT5) };
Impl impls14[] = { IMPLS(EXTRACT14) };

uint64_t last = 0;

void init(void) { }
ux checksum(size_t n) { return last; }

BENCH_BEG(base) {
	bench_memrand(mem, n);
	TIME last = (uint64_t)f((void*)mem, n/sizeof(uint64_t));
} BENCH_END


Bench benches[] = {
	BENCH( impls5,  MAX_MEM, "spill 5 GPRs", bench_base ),
	BENCH( impls14, MAX_MEM, "spill 14 GPRs", bench_base ),
}; BENCH_MAIN(benches)

#else
void init(void) {}
Impl impls[] = {};
Bench benches[] = {};
BENCH_MAIN(benches)
#endif
