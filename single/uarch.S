#define NOLIBC_DEFINE_ONLY
#include "../nolibc.h"

.text
.balign 8


.macro randomize seed
#if __riscv_xlen == 32
	li t1, 0x85ebca6b
	li t2, 0xc2b2ae35
	li t3, 0x7feb352d
#else
	li t1, 0xa0761d6485ebca6b
	li t2, 0x78bd642fc2b2ae35
	li t3, 0xe7037ed17feb352d
#endif

	vsetvli t4, x0, e8, m8, ta, ma
	vid.v v0
	vsetvli t4, x0, e16, m8, ta, ma
	vmul.vx v0, v0, t3
	vid.v v8
	vadd.vv v0, v0, v8
	vxor.vx v0, v0, \seed

	/* murmurhash32 finalizer */
	vsetvli t4, x0, e32, m8, ta, ma

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, t1

	vsrl.vi v8, v8, 13
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, t2

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8

	/* mix to other registers */
	vmul.vx v8,  v0, t1
	vmul.vx v16, v0, t2
	vmul.vx v24, v0, t3
.endm


.global get_vlenb
get_vlenb:
	csrr a0, vlenb
	ret

.global ta_is_all1s
ta_is_all1s:
	li a0, -1
	vsetvli t0, x0, e8, m8, ta, ma
	vmv.v.i v8, 2
	vmv.v.i v16, 3
	vdiv.vv v0, v8, v16
	vsetivli t0, 1, e8, m8, ta, ma
	vadd.vv v0, v8, v16
	vsetivli t0, 1, e8, m1, ta, ma
	vmv.x.s t0, v1
	beq t0, a0, 1f
	vmv.x.s t0, v7
	beq t0, a0, 1f
	vslidedown.vi v0, v0, 2
	vmv.x.s t0, v0
	beq t0, a0, 1f
	li a0, 0
	ret
1:
	li a0, 1
	ret


.global ma_is_all1s
ma_is_all1s:
	li a0, -1
	vsetvli t0, x0, e8, m8, ta, ma
	vmv.v.i v8, 3
	vmv.v.i v16, 7
	vmv.v.i v24, 7
	vsetvli t0, x0, e8, m2, ta, ma
	vmv.v.i v0, 0
	vadd.vv v8, v16, v24, v0.t
	vmv.x.s t0, v8
	beq t0, a0, 1f
	vmv.v.i v0, 3
	vadd.vv v8, v16, v24, v0.t
	vmv.x.s t0, v8
	beq t0, a0, 1f
	li a0, 0
	ret
1:
	li a0, 1
	ret


.global min_avl_vlmax
min_avl_vlmax:
	vsetvli t0, x0, e32, m8, ta, ma
	slli t1, t0, 2
1:
	vsetvli t2, t1, e32, m8, ta, ma
	bne t0, t2, 1f
	addi t1, t1, -1
	bge t1, t0, 1b
	li a0, 1
	ret
1:
	li a0, 0
	ret

# a0 = seed, a1 = N
.macro gen_measure_overlap vN
.global measure_overlap_\vN
measure_overlap_\vN:
	randomize a0
	beqz a1, 2f
1:
	vsetvli t0, x0, e64, m8, ta, ma
	vadd.vv v8, v0, v24
	vdiv.vv v0, v8, v16
	vsetvli t0, x0, e64, m1, ta, ma
	.rept 64
		vadd.vv \vN, \vN, v24
	.endr
	addi a1, a1, -1
	bnez a1, 1b
2:
	ret
.endm

gen_measure_overlap v0
gen_measure_overlap v3
gen_measure_overlap v7
gen_measure_overlap v8

.global measure_overlap_all
measure_overlap_all:
	randomize a0
	beqz a1, 2f
1:
	vsetvli t0, x0, e64, m8, ta, ma
	vadd.vv v8, v0, v24
	vdiv.vv v0, v8, v16
	vsetvli t0, x0, e64, m1, ta, ma
	.rept 64/8
		vadd.vv v0, v0, v7
		vadd.vv v1, v1, v0
		vadd.vv v2, v2, v1
		vadd.vv v3, v3, v2
		vadd.vv v4, v4, v3
		vadd.vv v5, v5, v4
		vadd.vv v6, v6, v5
		vadd.vv v7, v7, v6
	.endr
	addi a1, a1, -1
	bnez a1, 1b
2:
	ret


.global measure_mask_reinterpret_on
measure_mask_reinterpret_on:
	randomize a0
	beqz a1, 2f
1:
	vsetvli t0, x0, e16, m2, ta, ma
	vmslt.vv v0, v8, v16
	vmslt.vv v1, v16, v24
	vadd.vi v0, v0, 1
	vadd.vv v8, v16, v24, v0.t
	addi a1, a1, -1
	bnez a1, 1b
2:
	ret

.global measure_mask_reinterpret_off
measure_mask_reinterpret_off:
	randomize a0
	beqz a1, 2f
1:
	vsetvli t0, x0, e16, m2, ta, ma
	vadd.vi v8, v8, 1
	vmslt.vv v0, v8, v16
	vmslt.vv v1, v16, v24
	vadd.vv v8, v16, v24, v0.t
	addi a1, a1, -1
	bnez a1, 1b
2:
	ret
