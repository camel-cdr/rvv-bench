#if 0

void
hist_rvv_assume_no_conflict(uint32_t *hist, float *x, float *y, size_t n)
{
	for (size_t vl; n > 0; n -= vl, x += vl, y += vl) {
		vl = __riscv_vsetvl_e32m8(n);
		vfloat32m8_t vx = __riscv_vle32_v_f32m8(x, vl);
		vfloat32m8_t vy = __riscv_vle32_v_f32m8(y, vl);
		vfloat32m8_t vsq = __riscv_vfmacc(__riscv_vfmul(vx, vx, vl), vy, vy, vl);
		vfloat32m8_t v = __riscv_vfsqrt(vsq, vl);
		vuint32m8_t vidx =  __riscv_vminu(__riscv_vfcvt_rtz_xu(v, vl), 100, vl);
		vidx = __riscv_vsll(vidx, 2, vl);
		vuint32m8_t vcnt =__riscv_vluxei32(hist, vidx, vl);
		vcnt = __riscv_vadd(vcnt, 1, vl);
		__riscv_vsuxei32(hist, vidx, vcnt, vl);
	}
}

void
hist_rvv_slidedown(uint32_t *hist, float *x, float *y, size_t n)
{
	for (size_t vl; n > 0; n -= vl, x += vl, y += vl) {
		vl = __riscv_vsetvl_e32m8(n);
		vfloat32m8_t vx = __riscv_vle32_v_f32m8(x, vl);
		vfloat32m8_t vy = __riscv_vle32_v_f32m8(y, vl);
		vfloat32m8_t vsq = __riscv_vfmacc(__riscv_vfmul(vx, vx, vl), vy, vy, vl);
		vfloat32m8_t v = __riscv_vfsqrt(vsq, vl);
		vuint16m4_t vidx =  __riscv_vminu(__riscv_vfncvt_rtz_xu(v, vl), 100, vl);

		for (size_t i = 0; i < vl; ++i) {
			size_t idx = __riscv_vmv_x(__riscv_vslidedown(vidx, i, 1));
			++hist[idx];
		}
	}
}
#endif

#ifdef MX

.global MX(LUT4_rvv_vloxei8_)
MX(LUT4_rvv_vloxei8_):
1:
	vsetvli a3, a2, e8, MX(), ta, ma
	vle8.v v8, (a1)
	vand.vi v8, v8, 15
	vloxei8.v v8, (a0), v8
	vse8.v v8, (a1)
	sub a2, a2, a3
	add a1, a1, a3
	bnez a2, 1b
	ret

/* assumes no conflicts, which causes the wrong result */
.global MX(hist_rvv_assume_no_conflict_)
MX(hist_rvv_assume_no_conflict_):
	li a4, 100
1:
	vsetvli a5, a3, e32, m8, ta, ma
	vle32.v v8, (a1)
	vle32.v v16, (a2)
	vfmul.vv v8, v8, v8
	vfmacc.vv v8, v16, v16
	vfsqrt.v v8, v8
	vfcvt.rtz.xu.f.v v8, v8
	vminu.vx v8, v8, a4
	vsll.vi v8, v8, 2
	vluxei32.v v16, (a0), v8
	vadd.vi v16, v16, 1
	vsuxei32.v v16, (a0), v8
	sub a3, a3, a5
	slli a5, a5, 2
	add a1, a1, a5
	add a2, a2, a5
	bnez a3, 1b
	ret



.global MX(hist_rvv_slidedown_)
MX(hist_rvv_slidedown_):
	li a6, 100
	j 2f
1:
	sub a3, a3, a7
	slli a5, a7, 2
	add a1, a1, a5
	add a2, a2, a5
	beqz a3, 4f
2:
	vsetvli a7, a3, e32, MX(), ta, ma
	beqz a7, 1b
	vle32.v v8, (a1)
	vle32.v v16, (a2)
	li a4, 0
	vfmul.vv v8, v8, v8
	vfmacc.vv v8, v16, v16
	vfsqrt.v v8, v8
	vsetvli zero, zero, e16, MXf2(), ta, ma
	vfncvt.rtz.xu.f.w v16, v8
	vminu.vx v8, v16, a6
	vsll.vi v8, v8, 2
	vsetivli zero, 1, e16, MXf2(), ta, ma
3:
	vslidedown.vx v12, v8, a4
	vmv.x.s a5, v12
	add t0, a0, a5
	lw a5, 0(t0)
	addi a5, a5, 1
	addi a4, a4, 1
	sw a5, 0(t0)
	bne a7, a4, 3b
	j 1b
4:
	ret


#endif


#if MX_N == 1

.global MX(hist_rvv_dup_entries_)
MX(hist_rvv_dup_entries_):
	vsetvli a6, zero, e32, m1, ta, ma
	beqz a3, 2f
	slli a5, a6, 2
	vmv.v.x v8, a5
	vid.v v9
	addi a5, a6, -1
	vand.vx v9, v9, a5
	vsll.vi v9, v9, 2
	li a5, 100
1:
	vsetvli a4, a3, e32, m1, ta, ma
	vle32.v v10, (a1)
	vle32.v v11, (a2)
	vfmul.vv v10, v10, v10
	vfmacc.vv v10, v11, v11
	vfsqrt.v v10, v10
	vfcvt.rtz.xu.f.v v10, v10
	vminu.vx v10, v10, a5
	vmadd.vv v10, v8, v9
	vluxei32.v v11, (a0), v10
	vadd.vi v11, v11, 1
	vsuxei32.v v11, (a0), v10
	sub a3, a3, a4
	slli a4, a4, 2
	add a1, a1, a4
	add a2, a2, a4
	bnez a3, 1b
2:
	vsetvli a1, zero, e32, m1, ta, ma
	vmv.v.i v8, 0
	slli a4, a6, 2
	addi a1, a0, 400
	mv a2, a0
	vsetvli a3, zero, e32, m1, ta, ma
3:
	vle32.v v9, (a0)
	vredsum.vs v9, v9, v8
	vmv.x.s t0, v9
	sw t0, (a2)
	addi a2, a2, 4
	add a0, a0, a4
	bne a2, a1, 3b
	ret

#endif

#if MX_N == 2

.global MX(hist_rvv_dup_entries_)
MX(hist_rvv_dup_entries_):
	vsetvli a6, zero, e32, m1, ta, ma
	beqz a3, 2f
	slli a5, a6, 2
	slli a4, a6, 1
	vsetvli zero, a4, e32, m2, ta, ma
	vmv.v.x v8, a5
	vid.v v10
	addi a4, a6, -1
	vand.vx v10, v10, a4
	vsll.vi v10, v10, 2
	li a7, 100
1:
	vsetvli a4, a3, e32, m2, ta, ma
	vle32.v v12, (a1)
	vle32.v v14, (a2)
	vfmul.vv v12, v12, v12
	vfmacc.vv v12, v14, v14
	vfsqrt.v v12, v12
	vfcvt.rtz.xu.f.v v12, v12
	vminu.vx v12, v12, a7
	vmadd.vv v12, v8, v10
	vsetvli a5, a4, e32, m1, ta, ma
	vluxei32.v v14, (a0), v12
	sub a5, a4, a5
	vadd.vi v14, v14, 1
	vsuxei32.v v14, (a0), v12
	vsetvli zero, a5, e32, m1, ta, ma
	vluxei32.v v12, (a0), v13
	vadd.vi v12, v12, 1
	vsuxei32.v v12, (a0), v13
	sub a3, a3, a4
	slli a4, a4, 2
	add a1, a1, a4
	add a2, a2, a4
	bnez a3, 1b
2:
	vsetvli a1, zero, e32, m1, ta, ma
	vmv.v.i v8, 0
	slli a4, a6, 2
	addi a1, a0, 400
	mv a2, a0
	vsetvli a3, zero, e32, m1, ta, ma
3:
	vle32.v v9, (a0)
	vredsum.vs v9, v9, v8
	vmv.x.s t0, v9
	sw t0, (a2)
	addi a2, a2, 4
	add a0, a0, a4
	bne a2, a1, 3b
	ret

#endif

#if MX_N == 4

.global MX(hist_rvv_dup_entries_)
MX(hist_rvv_dup_entries_):
	vsetvli a5, zero, e32, m1, ta, ma
	slli    a7, a5, 2
	beqz    a3, 2f
	vsetvli zero, a7, e32, m4, ta, ma
	vmv.v.x v8, a7
	vid.v   v12
	addi    a5, a5, -1
	vand.vx v12, v12, a5
	vsll.vi v12, v12, 2
	li      a6, 100
1:
	vsetvli a5, a3, e32, m4, ta, ma
	vle32.v v16, (a1)
	vle32.v v20, (a2)
	vfmul.vv        v16, v16, v16
	vfmacc.vv       v16, v20, v20
	vfsqrt.v        v16, v16
	vfcvt.rtz.xu.f.v        v16, v16
	vminu.vx        v16, v16, a6
	vmadd.vv        v16, v8, v12
	vsetvli a4, a5, e32, m1, ta, ma
	vluxei32.v      v20, (a0), v16
	sub     a4, a5, a4
	vadd.vi v20, v20, 1
	vsuxei32.v      v20, (a0), v16
	vsetvli t0, a4, e32, m1, ta, ma
	vluxei32.v      v16, (a0), v17
	sub     a4, a4, t0
	vadd.vi v16, v16, 1
	vsuxei32.v      v16, (a0), v17
	vsetvli t0, a4, e32, m1, ta, ma
	vluxei32.v      v16, (a0), v18
	sub     a4, a4, t0
	vadd.vi v16, v16, 1
	vsuxei32.v      v16, (a0), v18
	vsetvli zero, a4, e32, m1, ta, ma
	vluxei32.v      v16, (a0), v19
	vadd.vi v16, v16, 1
	vsuxei32.v      v16, (a0), v19
	sub     a3, a3, a5
	slli    a5, a5, 2
	add     a1, a1, a5
	add     a2, a2, a5
	bnez    a3, 1b
2:
	vsetvli a1, zero, e32, m1, ta, ma
	vmv.v.i v8, 0
	addi    a1, a0, 400
	mv      a2, a0
3:
	vsetvli a3, zero, e32, m1, ta, ma
	vle32.v v9, (a0)
	vredsum.vs      v9, v9, v8
	vsetivli        zero, 1, e32, m1, ta, ma
	vse32.v v9, (a2)
	addi    a2, a2, 4
	add     a0, a0, a7
	bne     a2, a1, 3b
	ret

#endif
