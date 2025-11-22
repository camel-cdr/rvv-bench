/*
 * This benchmark is designed to mimic the properties of DCT/IDCT kernels,
 * which are common in video processing.
 *
 * They involve applying a kernel of operations between rows of matrices (in
 * this case 8x8), transposing the matrices and applying the same kernel again.
 * The final result is transposed again (which we skip here) and written back
 * to a 2d block of an image.
 *
 * Traditionally, such kernels are written with fixed 128-bit SIMD, but we also
 * show how to process multiple 8x8 matrices at once with and without changing
 * the input data layout.
 *
 * We primarily want to compare different implementations of transposing 8x8
 * matrices inside 8 vector registers.
 * One thing to consider is that a transpose implementation may take longer to
 * complete, but might finish computing the first rows quicker than an
 * otherwise faster transpose, which finishes all of its rows at a similar
 * time.
 * To include this in the measurement, the kernel was chosen to be very simple
 * and with only local inter-row dependencies. It can start partially executing
 * as soon as two adjacent rows (2-aligned) are completed.
 */
.text
.balign 8

#if MX_N == 1

.macro kernel_v16_v24
	vaaddu.vv v25, v16, v17
	vaaddu.vv v27, v18, v19
	vaaddu.vv v29, v20, v21
	vaaddu.vv v31, v22, v23
	vsub.vv v24, v16, v25
	vsub.vv v25, v17, v25
	vsub.vv v26, v18, v27
	vsub.vv v27, v19, v27
	vsub.vv v28, v20, v29
	vsub.vv v29, v21, v29
	vsub.vv v30, v22, v31
	vsub.vv v31, v23, v31
.endm

.macro kernel_v16_v16
	vaaddu.vv v24, v16, v17
	vaaddu.vv v25, v18, v19
	vaaddu.vv v26, v20, v21
	vaaddu.vv v27, v22, v23
	vsub.vv v16, v16, v24
	vsub.vv v17, v17, v24
	vsub.vv v18, v18, v25
	vsub.vv v19, v19, v25
	vsub.vv v20, v20, v26
	vsub.vv v21, v21, v26
	vsub.vv v22, v22, v27
	vsub.vv v23, v23, v27
.endm


/* trans8x8:
 * can't clobber: a0-a3, a7, t1-t6, v10,v11, vtype */


.macro template_zip SEW kernel trans8x8:vararg
	/* vaadd should do (rs1+rs2)>>1 */
	csrwi vxrm, 2

	/* strided destination pointers */
.ifc \SEW, 8
	slli a7, a3, 3 /* bstride = n*8 */
.else
	slli a7, a3, 4 /* bstride = n*8*2 */
.endif
	add t1, a0, a7
	add t2, t1, a7
	add t3, t2, a7
	add t4, t3, a7
	add t5, t4, a7
	add t6, t5, a7
	add a7, t6, a7

	/* n=n*8 for strip-mining */
	slli a3, a3, 3

1:
	vsetvli t0, x0, e\SEW, m8, ta, ma
	vle\SEW\().v v16, (a2)
.ifc \SEW, 16
	add a2, a2, t0
.endif
	add a2, a2, t0 /* inc src */

	vsetvli t0, x0, e\SEW, m1, ta, ma

	\kernel
	\trans8x8
	kernel_v16_v16

	MINU t0, t0, a3
	vsetvli t0, t0, e\SEW, m1, ta, ma
	sub a3, a3, t0 /* dec n */
.ifc \SEW, 16
	slli t0, t0, 1
.endif

	vse\SEW\().v v16, (a0)
	add a0, a0, t0
	vse\SEW\().v v17, (t1)
	add t1, t1, t0
	vse\SEW\().v v18, (t2)
	add t2, t2, t0
	vse\SEW\().v v19, (t3)
	add t3, t3, t0
	vse\SEW\().v v20, (t4)
	add t4, t4, t0
	vse\SEW\().v v21, (t5)
	add t5, t5, t0
	vse\SEW\().v v22, (t6)
	add t6, t6, t0
	vse\SEW\().v v23, (a7)
	add a7, a7, t0
	bnez a3, 1b
.endm


.macro template_seq SEW kernel trans8x8:vararg
	/* vaadd should do (rs1+rs2)>>1 */
	csrwi vxrm, 2

	/* indexed-load indices */
.ifc \SEW, 16
	/* generate: 0 1 16 17 2 3 18 19 ... 14 15 30 31 for VLEN=256 */
	vsetvli t0, zero, e16, m2, ta, ma
	srli t0, t0, 4
	addi a2, t0, -1
#ifdef __riscv_zbb
	ctz t0, t0
#else
	li t1, __riscv_xlen
1:	slli t0, t0, 1
	addi t1, t1, -1
	bnez t0, 1b
#endif
	vid.v v16
	vsrl.vi v18, v16, 1
	vand.vi v16, v16, 1
	vand.vx v20, v18, a2
	vsrl.vx v18, v18, t0
	vsll.vi v20, v20, 4
	vadd.vv v16, v20, v16
	vadd.vv v18, v18, v18
	vadd.vv v16, v18, v16
	vsll.vi v10, v16, 3
.endif

	/* strided destination pointers */
.ifc \SEW, 8
	slli a7, a3, 3 /* bstride = n*8 */
.else
	slli a7, a3, 4 /* bstride = n*8*2 */
.endif
	add t1, a0, a7
	add t2, t1, a7
	add t3, t2, a7
	add t4, t3, a7
	add t5, t4, a7
	add t6, t5, a7
	add a7, t6, a7

	/* n=n*8 for strip-mining */
	slli a3, a3, 3
1:
.ifc \SEW, 8
	vsetvli t0, x0, e64, m1, ta, ma
	vlseg8e64.v v16, (a1)
.else
	vsetvli t0, x0, e64, m8, ta, ma
	vluxei16.v v16, (a1), v10
.endif
	vsetvli t0, x0, e8, m8, ta, ma
	add a1, a1, t0 /* inc src */
	vsetvli t0, x0, e\SEW, m1, ta, ma

	\kernel
	\trans8x8
	kernel_v16_v16

	MINU t0, t0, a3
	vsetvli t0, t0, e\SEW, m1, ta, ma
	sub a3, a3, t0 /* dec n */
.ifc \SEW, 16
	slli t0, t0, 1
.endif

	vse\SEW\().v v16, (a0)
	add a0, a0, t0
	vse\SEW\().v v17, (t1)
	add t1, t1, t0
	vse\SEW\().v v18, (t2)
	add t2, t2, t0
	vse\SEW\().v v19, (t3)
	add t3, t3, t0
	vse\SEW\().v v20, (t4)
	add t4, t4, t0
	vse\SEW\().v v21, (t5)
	add t5, t5, t0
	vse\SEW\().v v22, (t6)
	add t6, t6, t0
	vse\SEW\().v v23, (a7)
	add a7, a7, t0
	bnez a3, 1b
.endm


.macro template_single MX SEW kernel trans8x8:vararg
	/* vaadd should do (rs1+rs2)>>1 */
	csrwi vxrm, 2

	/* strided destination pointers */
.ifc \SEW, 8
	slli a7, a3, 3 /* bstride = n*8 */
.else
	slli a7, a3, 4 /* bstride = n*8*2 */
.endif
	add t1, a0, a7
	add t2, t1, a7
	add t3, t2, a7
	add t4, t3, a7
	add t5, t4, a7
	add t6, t5, a7
	add a7, t6, a7

	beqz a3, 2f
1:
	addi a3, a3, -1

	vsetivli x0, 8, e\SEW, \MX, ta, ma
	addi t0, a1, 1*\SEW
	vle\SEW\().v v16, (a1)
	addi a2, a1, 2*\SEW
	vle\SEW\().v v17, (t0)
	addi t0, a1, 3*\SEW
	vle\SEW\().v v18, (a2)
	addi a2, a1, 4*\SEW
	vle\SEW\().v v19, (t0)
	addi t0, a1, 5*\SEW
	vle\SEW\().v v20, (a2)
	addi a2, a1, 6*\SEW
	vle\SEW\().v v21, (t0)
	addi t0, a1, 7*\SEW
	vle\SEW\().v v22, (a2)
	vle\SEW\().v v23, (t0)
	addi a1, a1, 8*\SEW

	\kernel
	\trans8x8
	kernel_v16_v16

	vse\SEW\().v v16, (a0)
	addi a0, a0, \SEW
	vse\SEW\().v v17, (t1)
	addi t1, t1, \SEW
	vse\SEW\().v v18, (t2)
	addi t2, t2, \SEW
	vse\SEW\().v v19, (t3)
	addi t3, t3, \SEW
	vse\SEW\().v v20, (t4)
	addi t4, t4, \SEW
	vse\SEW\().v v21, (t5)
	addi t5, t5, \SEW
	vse\SEW\().v v22, (t6)
	addi t6, t6, \SEW
	vse\SEW\().v v23, (a7)
	addi a7, a7, \SEW
	bnez a3, 1b
2:
.endm

.macro do_trans8x8_rvv_vslide e4 e2 e1
	vsetvli t0, x0, e\e4, m4, ta, mu
	vmv4r.v v24, v16

	vmv1r.v v0, v1
	vslide1up.vx v16, v20, x0, v0.t
	vmv1r.v v0, v2
	vslide1down.vx v20, v24, x0, v0.t

	vsetvli t0, x0, e\e2, m2, ta, mu
	vmv2r.v v24, v18
	vmv2r.v v26, v22

	vslide1down.vx v18, v16, x0, v0.t
	vslide1down.vx v22, v20, x0, v0.t
	vmv1r.v v0, v1
	vslide1up.vx v16, v24, x0, v0.t
	vslide1up.vx v20, v26, x0, v0.t

	vsetvli t0, x0, e\e1, m1, ta, mu
	vmv1r.v v24, v16
	vmv1r.v v25, v18
	vmv1r.v v26, v20
	vmv1r.v v27, v22

	vslide1up.vx v16, v17, x0, v0.t
	vslide1up.vx v18, v19, x0, v0.t
	vslide1up.vx v20, v21, x0, v0.t
	vslide1up.vx v22, v23, x0, v0.t
	vmv1r.v v0, v2
	vslide1down.vx v17, v24, x0, v0.t
	vslide1down.vx v19, v25, x0, v0.t
	vslide1down.vx v21, v26, x0, v0.t
	vslide1down.vx v23, v27, x0, v0.t
.endm

.macro do_trans8x8_rvv_vslide_single e4 e2 e1 mx
	vsetivli t0, 2, e\e4, \mx, ta, mu
	vmv4r.v v24, v16

	vmv1r.v v0, v1
	vslide1up.vx v16, v20, x0, v0.t
	vslide1up.vx v17, v21, x0, v0.t
	vslide1up.vx v18, v22, x0, v0.t
	vslide1up.vx v19, v23, x0, v0.t
	vmv1r.v v0, v2
	vslide1down.vx v20, v24, x0, v0.t
	vslide1down.vx v21, v25, x0, v0.t
	vslide1down.vx v22, v26, x0, v0.t
	vslide1down.vx v23, v27, x0, v0.t

	vsetivli t0, 4, e\e2, \mx, ta, mu
	vmv2r.v v24, v18
	vmv2r.v v26, v22

	vslide1down.vx v18, v16, x0, v0.t
	vslide1down.vx v19, v17, x0, v0.t
	vslide1down.vx v22, v20, x0, v0.t
	vslide1down.vx v23, v21, x0, v0.t
	vmv1r.v v0, v1
	vslide1up.vx v16, v24, x0, v0.t
	vslide1up.vx v17, v25, x0, v0.t
	vslide1up.vx v20, v26, x0, v0.t
	vslide1up.vx v21, v27, x0, v0.t

	vsetivli t0, 8, e\e1, \mx, ta, mu
	vmv1r.v v24, v16
	vmv1r.v v25, v18
	vmv1r.v v26, v20
	vmv1r.v v27, v22

	vslide1up.vx v16, v17, x0, v0.t
	vslide1up.vx v18, v19, x0, v0.t
	vslide1up.vx v20, v21, x0, v0.t
	vslide1up.vx v22, v23, x0, v0.t
	vmv1r.v v0, v2
	vslide1down.vx v17, v24, x0, v0.t
	vslide1down.vx v19, v25, x0, v0.t
	vslide1down.vx v21, v26, x0, v0.t
	vslide1down.vx v23, v27, x0, v0.t
.endm

.macro do_trans8x8_rvv_vlseg8_single SEW
	addi a4, a6, 1*\SEW
	vse\SEW\().v v24, (a6)
	addi a5, a6, 2*\SEW
	vse\SEW\().v v25, (a4)
	addi a4, a6, 3*\SEW
	vse\SEW\().v v26, (a5)
	addi a5, a6, 4*\SEW
	vse\SEW\().v v27, (a4)
	addi a4, a6, 5*\SEW
	vse\SEW\().v v28, (a5)
	addi a5, a6, 6*\SEW
	vse\SEW\().v v29, (a4)
	addi a4, a6, 7*\SEW
	vse\SEW\().v v30, (a5)
	vse\SEW\().v v31, (a4)
	vlseg8e\SEW\().v v16, (a6)
.endm

.macro do_trans8x8_rvv_vsseg8_single SEW
	vsseg8e\SEW\().v v24, (a6)
	addi a4, a6, 1*\SEW
	vle\SEW\().v v16, (a6)
	addi a5, a6, 2*\SEW
	vle\SEW\().v v17, (a4)
	addi a4, a6, 3*\SEW
	vle\SEW\().v v18, (a5)
	addi a5, a6, 4*\SEW
	vle\SEW\().v v19, (a4)
	addi a4, a6, 5*\SEW
	vle\SEW\().v v20, (a5)
	addi a5, a6, 6*\SEW
	vle\SEW\().v v21, (a4)
	addi a4, a6, 7*\SEW
	vle\SEW\().v v22, (a5)
	vle\SEW\().v v23, (a4)
.endm

.macro do_trans8x8_rvv_vls_single SEW
	addi a4, a6, 1*\SEW
	vse\SEW\().v v24, (a6)
	addi a5, a6, 2*\SEW
	vse\SEW\().v v25, (a4)
	addi a4, a6, 3*\SEW
	vse\SEW\().v v26, (a5)
	addi a5, a6, 4*\SEW
	vse\SEW\().v v27, (a4)
	addi a4, a6, 5*\SEW
	vse\SEW\().v v28, (a5)
	addi a5, a6, 6*\SEW
	vse\SEW\().v v29, (a4)
	addi a4, a6, 7*\SEW
	vse\SEW\().v v30, (a5)
	vse\SEW\().v v31, (a4)

	li t0, \SEW
	addi a4, a6, 1*\SEW/8
	vlse\SEW\().v v16, (a6), t0
	addi a5, a6, 2*\SEW/8
	vlse\SEW\().v v17, (a4), t0
	addi a4, a6, 3*\SEW/8
	vlse\SEW\().v v18, (a5), t0
	addi a5, a6, 4*\SEW/8
	vlse\SEW\().v v19, (a4), t0
	addi a4, a6, 5*\SEW/8
	vlse\SEW\().v v20, (a5), t0
	addi a5, a6, 6*\SEW/8
	vlse\SEW\().v v21, (a4), t0
	addi a4, a6, 7*\SEW/8
	vlse\SEW\().v v22, (a5), t0
	vlse\SEW\().v v23, (a4), t0
.endm

.macro do_trans8x8_rvv_vss_single SEW
	li t0, \SEW
	addi a4, a6, 1*\SEW/8
	vsse\SEW\().v v24, (a6), t0
	addi a5, a6, 2*\SEW/8
	vsse\SEW\().v v25, (a4), t0
	addi a4, a6, 3*\SEW/8
	vsse\SEW\().v v26, (a5), t0
	addi a5, a6, 4*\SEW/8
	vsse\SEW\().v v27, (a4), t0
	addi a4, a6, 5*\SEW/8
	vsse\SEW\().v v28, (a5), t0
	addi a5, a6, 6*\SEW/8
	vsse\SEW\().v v29, (a4), t0
	addi a4, a6, 7*\SEW/8
	vsse\SEW\().v v30, (a5), t0
	vsse\SEW\().v v31, (a4), t0

	addi a4, a6, 1*\SEW
	vle\SEW\().v v16, (a6)
	addi a5, a6, 2*\SEW
	vle\SEW\().v v17, (a4)
	addi a4, a6, 3*\SEW
	vle\SEW\().v v18, (a5)
	addi a5, a6, 4*\SEW
	vle\SEW\().v v19, (a4)
	addi a4, a6, 5*\SEW
	vle\SEW\().v v20, (a5)
	addi a5, a6, 6*\SEW
	vle\SEW\().v v21, (a4)
	addi a4, a6, 7*\SEW
	vle\SEW\().v v22, (a5)
	vle\SEW\().v v23, (a4)
.endm


.macro do_trans8x8_rvv_vzip_fake e4 e2 e1
	vsetvli t0, x0, e\e4, m4, ta, ma
	vxor.vv v16, v24, v28
	vadd.vv v20, v24, v28

	vsetvli t0, x0, e\e2, m2, ta, ma
	vxor.vv v26, v18, v16
	vxor.vv v30, v22, v20
	vadd.vv v26, v18, v16
	vadd.vv v30, v22, v20

	vsetvli t0, x0, e\e1, m1, ta, ma
	vxor.vv v16, v24, v25
	vxor.vv v18, v26, v27
	vxor.vv v20, v28, v29
	vxor.vv v22, v30, v31
	vadd.vv v17, v25, v24
	vadd.vv v19, v27, v26
	vadd.vv v21, v29, v28
	vadd.vv v23, v31, v30
.endm

.macro do_trans8x8_rvv_vzip_fake_single e4 e2 e1 mx
	vsetivli t0, 2, e\e4, \mx, ta, ma
	vxor.vv v16, v24, v28
	vxor.vv v17, v25, v29
	vxor.vv v18, v26, v30
	vxor.vv v19, v27, v31
	vadd.vv v20, v24, v28
	vadd.vv v21, v25, v29
	vadd.vv v22, v26, v30
	vadd.vv v23, v27, v31

	vsetivli t0, 4, e\e2, \mx, ta, ma
	vxor.vv v26, v18, v16
	vxor.vv v27, v19, v17
	vxor.vv v30, v22, v20
	vxor.vv v31, v23, v21
	vadd.vv v26, v18, v16
	vadd.vv v27, v19, v17
	vadd.vv v30, v22, v20
	vadd.vv v31, v23, v21

	vsetivli t0, 8, e\e1, \mx, ta, ma
	vxor.vv v16, v24, v25
	vxor.vv v18, v26, v27
	vxor.vv v20, v28, v29
	vxor.vv v22, v30, v31
	vadd.vv v17, v25, v24
	vadd.vv v19, v27, v26
	vadd.vv v21, v29, v28
	vadd.vv v23, v31, v30
.endm

#endif

