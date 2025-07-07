#include "bench.h"

#define IMPLS(f) \
	f(seq_scalar,0) \
	f(seq_scalar_autovec,0) \
	f(zip_rvv_vslide,0) \
	IF_VF16(f(seq_rvv_vslide,0)) \
	f(seq_rvv_vslide_single,0) \
	f(seq_rvv_vlseg8_single,0) \
	f(seq_rvv_vsseg8_single,0) \
	f(seq_rvv_vls_single,0) \
	f(seq_rvv_vss_single,0) \
	f(zip_rvv_vzip_fake,1) \
	IF_VF16(f(seq_rvv_vzip_fake,1)) \
	IF_VF16(f(seq_rvv_vzip_fake_single,1)) \

#define T uint8_t
#include "trans8x8.c.inc"

Bench benches[] = {
	BENCH( impls, MAX_MEM/4-9-3, "trans8x8e8", bench_base ),
}; BENCH_MAIN(benches)
