.text
.balign 8

#if MX_N == 1

.global get_trans8x8_count
get_trans8x8_count:
	vsetvli a0, x0, e16, m1, ta, ma
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
	template_zip 16 kernel_v16_v16 do_trans8x8_rvv_vslide 64 32 16
	ret

#if IF_VF16(1)+0
.global trans8x8_seq_rvv_vslide
trans8x8_seq_rvv_vslide:
	/* even/odd masks */
	vsetvli t0, x0, e8, m1, ta, ma
	li t0, 0b10101010
	vmv.v.x v1, t0
	vnot.v v2, v1
	template_seq 16 kernel_v16_v16 do_trans8x8_rvv_vslide 64 32 16
	ret
#endif

.global trans8x8_seq_rvv_vslide_single
trans8x8_seq_rvv_vslide_single:
	/* even/odd masks */
	vsetvli t0, x0, e16, m1, ta, ma
	li t0, 0b10101010
	vmv.v.x v1, t0
	vnot.v v2, v1
	template_single m1 16 kernel_v16_v16 do_trans8x8_rvv_vslide_single 64 32 16 m1
	ret

.global trans8x8_seq_rvv_vlseg8_single
trans8x8_seq_rvv_vlseg8_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single m1 16 kernel_v16_v24 do_trans8x8_rvv_vlseg8_single 16
	ret

.global trans8x8_seq_rvv_vsseg8_single
trans8x8_seq_rvv_vsseg8_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single m1 16 kernel_v16_v24 do_trans8x8_rvv_vsseg8_single 16
	ret

.global trans8x8_seq_rvv_vls_single
trans8x8_seq_rvv_vls_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single m1 16 kernel_v16_v24 do_trans8x8_rvv_vls_single 16
	ret

.global trans8x8_seq_rvv_vss_single
trans8x8_seq_rvv_vss_single:
	vsetvli t0, x0, e8, m8, ta, ma
	sub a6, sp, t0
	template_single m1 16 kernel_v16_v24 do_trans8x8_rvv_vss_single 16
	ret

.macro do_trans8x8_rvv_vrgather
	vsetvli t0, x0, e16, m8, ta, ma
	vrgather.vv v16, v24, v0
	vsetvli t0, x0, e16, m1, ta, ma
.endm
.macro trans8x8_rvv_vrgather_init
	vsetvli t0, x0, e16, m1, ta, ma
	vid.v v8
#ifdef __riscv_zbb
	ctz t1, t0
#else
	li t1, __riscv_xlen
1:	slli t0, t0, 1
	addi t1, t1, -1
	bnez t0, 1b
#endif
	li t0, 8
	vand.vi v9, v8, 7
	vsll.vx v0, v9, t1
	vsrl.vi v8, v8, 3
	vmacc.vx v0, t0, v8
	vadd.vi v1, v0, 1
	vadd.vi v2, v0, 2
	vadd.vi v3, v0, 3
	vadd.vi v4, v0, 4
	vadd.vi v5, v0, 5
	vadd.vi v6, v0, 6
	vadd.vi v7, v0, 7

.endm
.global trans8x8_zip_rvv_vrgather
trans8x8_zip_rvv_vrgather:
	trans8x8_rvv_vrgather_init
	template_zip 16 kernel_v16_v24 do_trans8x8_rvv_vrgather
	ret

#if IF_VF16(1)+0
.global trans8x8_seq_rvv_vrgather
trans8x8_seq_rvv_vrgather:
	trans8x8_rvv_vrgather_init
	template_seq 16 kernel_v16_v24 do_trans8x8_rvv_vrgather
	ret
#endif

.global trans8x8_zip_rvv_vzip_fake
trans8x8_zip_rvv_vzip_fake:
	template_zip 16 kernel_v16_v16 do_trans8x8_rvv_vzip_fake 64 32 16
	ret

#if IF_VF16(1)+0
.global trans8x8_seq_rvv_vzip_fake
trans8x8_seq_rvv_vzip_fake:
	template_seq 16 kernel_v16_v16 do_trans8x8_rvv_vzip_fake 64 32 16
	ret
#endif

.global trans8x8_seq_rvv_vzip_fake_single
trans8x8_seq_rvv_vzip_fake_single:
	template_single m1 16 kernel_v16_v16 do_trans8x8_rvv_vzip_fake_single 64 32 16 m1
	ret

#endif
