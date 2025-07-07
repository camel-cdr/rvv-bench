.text
.balign 8

#if MX_N == 1

.global get_trans8x8_count
get_trans8x8_count:
	vsetvli a0, x0, e8, m1, ta, ma
	srli a0, a0, 3
	ret

#include "trans8x8.S.inc"

.global trans8x8_zip_rvv_vslide
trans8x8_zip_rvv_vslide:
	/* even/odd masks */
	vsetvli t0, x0, e8, m1, ta, ma
	li t0, 0b10101010
	vmv.v.x v1, t0
	vnot.v v2, v1
	template_zip 8 kernel_v16_v16 do_trans8x8_rvv_vslide 32 16 8
	ret

#if IF_VF16(1)+0
.global trans8x8_seq_rvv_vslide
trans8x8_seq_rvv_vslide:
	/* even/odd masks */
	vsetvli t0, x0, e8, m1, ta, ma
	li t0, 0b10101010
	vmv.v.x v1, t0
	vnot.v v2, v1
	template_seq 8 kernel_v16_v16 do_trans8x8_rvv_vslide 32 16 8
	ret
#endif

.global trans8x8_seq_rvv_vslide_single
trans8x8_seq_rvv_vslide_single:
	/* even/odd masks */
	vsetvli t0, x0, e8, m1, ta, ma
	li t0, 0b10101010
	vmv.v.x v1, t0
	vnot.v v2, v1
	template_single mf2 8 kernel_v16_v16 do_trans8x8_rvv_vslide_single 32 16 8 mf2
	ret

.global trans8x8_seq_rvv_vlseg8_single
trans8x8_seq_rvv_vlseg8_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single mf2 8 kernel_v16_v24 do_trans8x8_rvv_vlseg8_single 8
	ret

.global trans8x8_seq_rvv_vsseg8_single
trans8x8_seq_rvv_vsseg8_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single mf2 8 kernel_v16_v24 do_trans8x8_rvv_vsseg8_single 8
	ret


.global trans8x8_seq_rvv_vls_single
trans8x8_seq_rvv_vls_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single mf2 8 kernel_v16_v24 do_trans8x8_rvv_vls_single 8
	ret

.global trans8x8_seq_rvv_vss_single
trans8x8_seq_rvv_vss_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single mf2 8 kernel_v16_v24 do_trans8x8_rvv_vss_single 8
	ret

.global trans8x8_zip_rvv_vzip_fake
trans8x8_zip_rvv_vzip_fake:
	template_zip 8 kernel_v16_v16 do_trans8x8_rvv_vzip_fake 32 16 8
	ret

#if IF_VF16(1)+0
.global trans8x8_seq_rvv_vzip_fake
trans8x8_seq_rvv_vzip_fake:
	template_seq 8 kernel_v16_v16 do_trans8x8_rvv_vzip_fake 32 16 8
	ret
#endif

.global trans8x8_seq_rvv_vzip_fake_single
trans8x8_seq_rvv_vzip_fake_single:
	template_single mf2 8 kernel_v16_v16 do_trans8x8_rvv_vzip_fake_single 32 16 8 mf2
	ret

#endif

