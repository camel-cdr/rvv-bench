#include "../nolibc.h"

#define SCALE (1024*1024*4)
#define BESTOF 8

extern size_t get_vlenb(void);
extern int ta_is_all1s(void);
extern int ma_is_all1s(void);
extern int min_avl_vlmax(void);
extern void measure_overlap_v0(size_t seed, size_t N);
extern void measure_overlap_v3(size_t seed, size_t N);
extern void measure_overlap_v7(size_t seed, size_t N);
extern void measure_overlap_v8(size_t seed, size_t N);
extern void measure_overlap_all(size_t seed, size_t N);

extern void measure_mask_reinterpret_on(size_t seed, size_t N);
extern void measure_mask_reinterpret_off(size_t seed, size_t N);

void
measure(void (*func)(size_t seed, size_t N), size_t seed, size_t N, const char *msg)
{
	size_t min = ~(size_t)0;
	for (size_t i = 0; i < BESTOF; ++i) {
		size_t beg = rv_cycles();
		func(seed, N);
		size_t cycles = rv_cycles()-beg;
		min = cycles < min ? cycles : min;
	}
	print(s,msg)(f, min*1.0/N)(" cycles/iter\n")(flush,);
}

int
main(void)
{
	size_t seed = 123456;
	seed += rv_cycles();
	seed ^= (uintptr_t)&seed;

	print("VLEN: ")(u,get_vlenb()*8)("\n");

	print("\nDetect all1s tail/mask policy with simple code snippet:\n");
	print("Tail agnostic policy: ")(s, ta_is_all1s() ? "all1s\n" : "undisturbed\n");
	print("Mask agnostic policy: ")(s, ma_is_all1s() ? "all1s\n" : "undisturbed\n");
	print("Is vl always set to min(AVL,VLMAX): ")(s, min_avl_vlmax() ? "yes\n" : "no\n");
	print("    Note: spec allows ceil(AVL/2)<=vl<=VLMAX for VLMAX<AVL<2*VLMAX\n");


	print("\nMeasures how LMUL scheduling impacts when results are ready:\n")(flush,);
	measure(measure_overlap_v0,  seed, SCALE, "LMUL=8 v0 overlap with LMUL=1 v0:     ");
	measure(measure_overlap_v3,  seed, SCALE, "LMUL=8 v0 overlap with LMUL=1 v3:     ");
	measure(measure_overlap_v7,  seed, SCALE, "LMUL=8 v0 overlap with LMUL=1 v7:     ");
	measure(measure_overlap_v8,  seed, SCALE, "LMUL=8 v0 overlap with LMUL=1 v8:     ");
	measure(measure_overlap_all, seed, SCALE, "LMUL=8 v0 overlap with LMUL=1 v0..v8: ");

	print("\nMeasures overhead of reinterpreting a mask as a vector:\n")(flush,);
	measure(measure_mask_reinterpret_on,  seed, SCALE, "reinterpret:       ");
	measure(measure_mask_reinterpret_off, seed, SCALE, "don't reinterpret: ");

	return 0;
}
