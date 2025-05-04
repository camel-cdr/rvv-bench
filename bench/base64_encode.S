// Code generated using clang-20 from:
// https://github.com/camel-cdr/rvv-playground/blob/main/base64-encode.c
// which was slighly modified to remove a GPR spill:
// https://godbolt.org/z/vqYMv4r9c

#if MX_N == 4

.global b64_encode_rvv_LUT64
b64_encode_rvv_LUT64:
	mv a4, a2
	mv a2, a1
	vsetvli a6, zero, e8, m1, ta, ma
	slli a5, a6, 2
	bgeu a4, a5, .LBB0_3
	mv a1, a0
.LBB0_2:
	sub a0, a1, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB0_3:
	vid.v v24
	li t2, 3
	lui t3, 4128
	lui a7, 96
	lui t0, 128
	vsetvli zero, a5, e8, m4, ta, ma
	vid.v v20
	li a1, 64
	vsetvli zero, a1, e8, m4, ta, ma
	vle8.v v8, (a3)
	srli t1, a6, 2
	addi a7, a7, 10
	addi t0, t0, 4
	slli a1, t1, 1
	vsetvli a3, zero, e32, m4, ta, ma
	vmv.v.x v12, a7
	slli a3, t1, 3
	vmv.v.x v16, t0
	add a7, a1, t1
	sub t0, a3, a1
	add t1, t1, a3
	li a1, 63
	vsetvli zero, zero, e8, m1, ta, ma
	vsrl.vi v24, v24, 2
	addi t3, t3, 1
	vsetvli zero, a5, e8, m4, ta, ma
	vand.vi v20, v20, 1
	vmsne.vi v0, v20, 0
	vmv.v.x v20, a1
	vsetvli a3, zero, e8, m1, ta, ma
	vmul.vx v24, v24, t2
	vsetvli zero, a6, e32, m1, ta, ma
	vadd.vx v7, v24, t3
	slli a3, a6, 1
	add t3, a3, a6
	bgeu a1, a6, .LBB0_9
	vsetvli a1, zero, e16, m2, ta, ma
	vid.v v10
	lui a1, 32769
	vsrl.vi v10, v10, 2
	slli a1, a1, 21
	vmul.vx v10, v10, t2
	addi a1, a1, 1
	vsetvli zero, a6, e64, m2, ta, ma
	vadd.vx v10, v10, a1
	li t2, 257
	mv a1, a0
	j .LBB0_7
.LBB0_5:
	vrgather.vv v24, v9, v7
	vrgather.vv v25, v26, v7
	vrgather.vv v26, v27, v7
	vrgather.vv v27, v28, v7
.LBB0_6:
	vsetvli zero, a5, e16, m4, ta, ma
	vsrl.vv v28, v24, v12
	vsll.vv v24, v24, v16
	sub a4, a4, t3
	add a2, a2, t3
	vsetvli zero, a5, e8, m4, ta, ma
	vmerge.vvm v24, v28, v24, v0
	vand.vv v24, v24, v20
	vsetvli a3, zero, e8, m1, ta, ma
	vrgather.vv v28, v8, v24
	vrgather.vv v29, v8, v25
	vrgather.vv v30, v8, v26
	vrgather.vv v31, v8, v27
	vsetvli zero, a5, e8, m4, ta, ma
	vse8.v v28, (a1)
	add a1, a1, a5
	bltu a4, a5, .LBB0_2
.LBB0_7:
	vsetvli a3, zero, e8, m1, ta, ma
	vle8.v v9, (a2)
	add a3, a2, a7
	vle8.v v26, (a3)
	add a3, a2, t0
	vle8.v v27, (a3)
	add a3, a2, t1
	vle8.v v28, (a3)
	bltu a6, t2, .LBB0_5
	vrgatherei16.vv v24, v9, v10
	vrgatherei16.vv v25, v26, v10
	vrgatherei16.vv v26, v27, v10
	vrgatherei16.vv v27, v28, v10
	j .LBB0_6
.LBB0_9:
	li t2, 31
	vsetvli a1, zero, e8, m2, ta, ma
	mv a1, a0
	j .LBB0_12
.LBB0_10:
	vsetvli a3, zero, e8, m2, ta, ma
	vrgather.vv v24, v8, v28
	vrgather.vv v26, v8, v30
.LBB0_11:
	vsetvli zero, a5, e8, m4, ta, ma
	vse8.v v24, (a1)
	sub a4, a4, t3
	add a2, a2, t3
	add a1, a1, a5
	bltu a4, a5, .LBB0_2
.LBB0_12:
	vsetvli a3, zero, e8, m1, ta, ma
	vle8.v v25, (a2)
	add a3, a2, a7
	vle8.v v26, (a3)
	add a3, a2, t0
	vle8.v v27, (a3)
	add a3, a2, t1
	vle8.v v28, (a3)
	vrgather.vv v24, v25, v7
	vrgather.vv v25, v26, v7
	vrgather.vv v26, v27, v7
	vrgather.vv v27, v28, v7
	vsetvli zero, a5, e16, m4, ta, ma
	vsrl.vv v28, v24, v12
	vsll.vv v24, v24, v16
	vsetvli zero, a5, e8, m4, ta, ma
	vmerge.vvm v24, v28, v24, v0
	vand.vv v28, v24, v20
	bltu t2, a6, .LBB0_10
	vrgather.vv v24, v8, v28
	j .LBB0_11

.global b64_encode_rvv_seg_LUT64
b64_encode_rvv_seg_LUT64:
	mv a4, a2
	mv a2, a1
	vsetvli a7, zero, e8, m1, ta, ma
	slli a5, a7, 2
	bgeu a4, a5, .LBB1_2
	mv a1, a0
	sub a0, a0, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB1_2:
	li a6, 64
	vsetvli zero, a6, e8, m4, ta, ma
	vle8.v v8, (a3)
	li a3, 63
	vsetvli a1, zero, e8, m1, ta, ma
	vmv.v.x v12, a3
	slli a3, a7, 1
	add t0, a3, a7
	bltu a7, a6, .LBB1_6
	li a6, 4
	li a7, 16
	mv a1, a0
.LBB1_4:
	vlseg3e8.v v9, (a2)
	sub a4, a4, t0
	add a2, a2, t0
	vand.vv v13, v11, v12
	vsrl.vi v11, v11, 6
	vsrl.vi v14, v10, 4
	vsrl.vi v15, v9, 2
	vmacc.vx v11, a6, v10
	vmacc.vx v14, a7, v9
	vrgather.vv v16, v8, v15
	vand.vv v9, v11, v12
	vand.vv v10, v14, v12
	vrgather.vv v17, v8, v10
	vrgather.vv v18, v8, v9
	vrgather.vv v19, v8, v13
	vsseg4e8.v v16, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB1_4
.LBB1_5:
	sub a0, a1, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB1_6:
	li a1, 31
	bgeu a1, a7, .LBB1_9
	vsetvli a1, zero, e8, m2, ta, ma
	li a6, 4
	li a7, 16
	mv a1, a0
.LBB1_8:
	vsetvli a3, zero, e8, m1, ta, ma
	vlseg3e8.v v13, (a2)
	sub a4, a4, t0
	add a2, a2, t0
	vand.vv v11, v15, v12
	vsrl.vi v10, v15, 6
	vsrl.vi v15, v14, 4
	vmacc.vx v10, a6, v14
	vmacc.vx v15, a7, v13
	vand.vv v10, v10, v12
	vand.vv v17, v15, v12
	vsrl.vi v16, v13, 2
	vsetvli a3, zero, e8, m2, ta, ma
	vrgather.vv v20, v8, v16
	vrgather.vv v22, v8, v10
	vsetvli a3, zero, e8, m1, ta, ma
	vsseg4e8.v v20, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB1_8
	j .LBB1_5
.LBB1_9:
	li a6, 4
	li a7, 16
	mv a1, a0
.LBB1_10:
	vlseg3e8.v v13, (a2)
	sub a4, a4, t0
	add a2, a2, t0
	vand.vv v19, v15, v12
	vsrl.vi v15, v15, 6
	vmacc.vx v15, a6, v14
	vand.vv v18, v15, v12
	vsrl.vi v14, v14, 4
	vmacc.vx v14, a7, v13
	vand.vv v17, v14, v12
	vsrl.vi v16, v13, 2
	vsetvli zero, a5, e8, m4, ta, ma
	vrgather.vv v20, v8, v16
	vsetvli a3, zero, e8, m1, ta, ma
	vsseg4e8.v v20, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB1_10
	j .LBB1_5

.global b64_encode_rvv_LUT16
b64_encode_rvv_LUT16:
	mv a4, a2
	mv a2, a1
	vsetvli t3, zero, e8, m1, ta, ma
	slli a5, t3, 2
	bgeu a4, a5, .LBB2_2
	mv a1, a0
	sub a0, a0, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB2_2:
	li t2, 3
	lui a6, 96
	lui a7, 128
	vsetvli zero, a5, e8, m4, ta, ma
	vid.v v8
	li t0, 63
	addi a3, a3, 64
	srli a1, t3, 2
	addi a6, a6, 10
	addi a7, a7, 4
	vand.vi v20, v8, 1
	vmv.v.x v12, t0
	vsetivli zero, 16, e8, m1, ta, ma
	vle8.v v9, (a3)
	slli t1, a1, 1
	slli t0, a1, 3
	vsetvli a3, zero, e32, m4, ta, ma
	vmv.v.x v16, a6
	vsetvli zero, a5, e8, m4, ta, ma
	vmsne.vi v8, v20, 0
	vsetvli a3, zero, e32, m4, ta, ma
	vmv.v.x v20, a7
	add a6, t1, a1
	sub a7, t0, t1
	add t0, t0, a1
	slli a3, t3, 1
	li a1, 257
	add t4, a3, t3
	bgeu t3, a1, .LBB2_6
	vsetvli zero, zero, e8, m1, ta, ma
	vid.v v10
	lui a1, 4128
	li t1, 51
	vsrl.vi v10, v10, 2
	addi a1, a1, 1
	vmul.vx v10, v10, t2
	vsetvli zero, t3, e32, m1, ta, ma
	vadd.vx v10, v10, a1
	li t2, 26
	mv a1, a0
.LBB2_4:
	vsetvli a3, zero, e8, m1, ta, ma
	vmv1r.v v0, v8
	vle8.v v11, (a2)
	add a3, a2, a6
	vle8.v v26, (a3)
	add a3, a2, a7
	vle8.v v27, (a3)
	add a3, a2, t0
	sub a4, a4, t4
	add a2, a2, t4
	vle8.v v28, (a3)
	vrgather.vv v24, v11, v10
	vrgather.vv v25, v26, v10
	vrgather.vv v26, v27, v10
	vrgather.vv v27, v28, v10
	vsetvli zero, a5, e16, m4, ta, ma
	vsrl.vv v28, v24, v16
	vsll.vv v24, v24, v20
	vsetvli zero, a5, e8, m4, ta, ma
	vmerge.vvm v24, v28, v24, v0
	vand.vv v24, v24, v12
	vmsltu.vx v0, v24, t2
	vssubu.vx v28, v24, t1
	vmerge.vim v28, v28, 13, v0
	vsetvli a3, zero, e8, m1, ta, ma
	vrgather.vv v4, v9, v28
	vrgather.vv v5, v9, v29
	vrgather.vv v6, v9, v30
	vrgather.vv v7, v9, v31
	vsetvli zero, a5, e8, m4, ta, ma
	vadd.vv v24, v24, v4
	vse8.v v24, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB2_4
.LBB2_5:
	sub a0, a1, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB2_6:
	vsetvli zero, zero, e16, m2, ta, ma
	vid.v v10
	lui a1, 32769
	li t1, 51
	vsrl.vi v10, v10, 2
	slli a1, a1, 21
	vmul.vx v10, v10, t2
	addi a1, a1, 1
	vsetvli zero, t3, e64, m2, ta, ma
	vadd.vx v10, v10, a1
	li t2, 26
	mv a1, a0
.LBB2_7:
	vsetvli a3, zero, e8, m1, ta, ma
	vmv1r.v v0, v8
	vle8.v v25, (a2)
	add a3, a2, a6
	vle8.v v26, (a3)
	add a3, a2, a7
	vle8.v v27, (a3)
	add a3, a2, t0
	sub a4, a4, t4
	add a2, a2, t4
	vle8.v v28, (a3)
	vrgatherei16.vv v24, v25, v10
	vrgatherei16.vv v25, v26, v10
	vrgatherei16.vv v26, v27, v10
	vrgatherei16.vv v27, v28, v10
	vsetvli zero, a5, e16, m4, ta, ma
	vsrl.vv v28, v24, v16
	vsll.vv v24, v24, v20
	vsetvli zero, a5, e8, m4, ta, ma
	vmerge.vvm v24, v28, v24, v0
	vand.vv v24, v24, v12
	vmsltu.vx v0, v24, t2
	vssubu.vx v28, v24, t1
	vmerge.vim v28, v28, 13, v0
	vsetvli a3, zero, e8, m1, ta, ma
	vrgather.vv v4, v9, v28
	vrgather.vv v5, v9, v29
	vrgather.vv v6, v9, v30
	vrgather.vv v7, v9, v31
	vsetvli zero, a5, e8, m4, ta, ma
	vadd.vv v24, v24, v4
	vse8.v v24, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB2_7
	j .LBB2_5

.global b64_encode_rvv_seg_LUT16
b64_encode_rvv_seg_LUT16:
	mv a4, a2
	mv a2, a1
	vsetvli a1, zero, e8, m1, ta, ma
	slli a5, a1, 2
	bgeu a4, a5, .LBB3_2
	mv a1, a0
	sub a0, a0, a0
	mv a3, a4
	tail b64_encode_scalar_tail
.LBB3_2:
	li a6, 63
	addi a7, a3, 64
	slli a3, a1, 1
	vmv.v.x v8, a6
	vsetivli zero, 16, e8, m1, ta, ma
	vle8.v v9, (a7)
	add t2, a3, a1
	li a6, 4
	li a7, 16
	li t0, 51
	li t1, 26
	mv a1, a0
.LBB3_3:
	vsetvli a3, zero, e8, m1, ta, ma
	vlseg3e8.v v10, (a2)
	sub a4, a4, t2
	add a2, a2, t2
	vand.vv v15, v12, v8
	vsrl.vi v12, v12, 6
	vsrl.vi v13, v11, 4
	vmacc.vx v12, a6, v11
	vmacc.vx v13, a7, v10
	vand.vv v14, v12, v8
	vand.vv v13, v13, v8
	vsrl.vi v12, v10, 2
	vsetvli zero, a5, e8, m4, ta, ma
	vmsltu.vx v0, v12, t1
	vssubu.vx v16, v12, t0
	vmerge.vim v16, v16, 13, v0
	vsetvli a3, zero, e8, m1, ta, ma
	vrgather.vv v20, v9, v16
	vrgather.vv v21, v9, v17
	vrgather.vv v22, v9, v18
	vrgather.vv v23, v9, v19
	vsetvli zero, a5, e8, m4, ta, ma
	vadd.vv v12, v12, v20
	vsetvli a3, zero, e8, m1, ta, ma
	vsseg4e8.v v12, (a1)
	add a1, a1, a5
	bgeu a4, a5, .LBB3_3
	sub a0, a1, a0
	mv a3, a4
	tail b64_encode_scalar_tail

#endif

