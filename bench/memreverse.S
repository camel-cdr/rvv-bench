#ifdef MX

.global MX(memreverse_rvv_vsse_)
MX(memreverse_rvv_vsse_):
	li t1, -1
	add a0, a0, a2
	addi a0, a0, -1
1:
	vsetvli t0, a2, e8, MX(), ta, ma
	vle8.v v0, (a1)
	add a1, a1, t0
	sub a2, a2, t0
	vsse8.v v0, (a0), t1
	sub a0, a0, t0
	bnez a2, 1b
	ret

.global MX(memreverse_rvv_vlse_)
MX(memreverse_rvv_vlse_):
	li t1, -1
	add a1, a1, a2
	addi a1, a1, -1
1:
	vsetvli t0, a2, e8, MX(), ta, ma
	vlse8.v v0, (a1), t1
	sub a1, a1, t0
	sub a2, a2, t0
	vse8.v v0, (a0)
	add a0, a0, t0
	bnez a2, 1b
	ret

#if MX_N < 8
.global MX(memreverse_rvv_vrgatherei16_)
MX(memreverse_rvv_vrgatherei16_):
	vsetvli t0, x0, e16, MX2(), ta, ma
	add a0, a0, a2
	bltu a2, t0, 2f
	vid.v v0
	addi t1, t0, -1
	vrsub.vx v0, v0, t1
	vsetvli t0, x0, e8, MX(), ta, ma
1:
	sub a0, a0, t0
	sub a2, a2, t0
	vle8.v v8, (a1)
	vrgatherei16.vv v16, v8, v0
	add a1, a1, t0
	vse8.v v16, (a0)
	bgeu a2, t0, 1b
2:	/* tail */
	vsetvli t0, a2, e8, MX(), ta, ma
	li t1, -1
	addi a0, a0, -1
	vle8.v v0, (a1)
	vsse8.v v0, (a0), t1
	ret
#endif

.global MX(memreverse_rvv_m1_vrgatherei16_)
MX(memreverse_rvv_m1_vrgatherei16_):
	vsetvli t0, x0, e16, m2, ta, ma
	vid.v v0
	addi t1, t0, -1
	vrsub.vx v0, v0, t1
	vsetvli t0, x0, e8, MX(), ta, ma
	add a0, a0, a2
	bltu a2, t0, 2f
1:
	sub a0, a0, t0
	sub a2, a2, t0
	vle8.v v8, (a1)
	vsetvli t1, x0, e8, m1, ta, ma
#if MX_N == 1
	vrgatherei16.vv v16, v8, v0
#elif MX_N == 2
	vrgatherei16.vv v17, v8, v0
	vrgatherei16.vv v16, v9, v0
#elif MX_N == 4
	vrgatherei16.vv v19, v8, v0
	vrgatherei16.vv v18, v9, v0
	vrgatherei16.vv v17, v10, v0
	vrgatherei16.vv v16, v11, v0
#elif MX_N == 8
	vrgatherei16.vv v23, v8, v0
	vrgatherei16.vv v22, v9, v0
	vrgatherei16.vv v21, v10, v0
	vrgatherei16.vv v20, v11, v0
	vrgatherei16.vv v19, v12, v0
	vrgatherei16.vv v18, v13, v0
	vrgatherei16.vv v17, v14, v0
	vrgatherei16.vv v16, v15, v0
#endif
	vsetvli t1, x0, e8, MX(), ta, ma
	add a1, a1, t0
	vse8.v v16, (a0)
	bgeu a2, t0, 1b
2:	/* tail */
	vsetvli t0, a2, e8, MX(), ta, ma
	li t1, -1
	addi a0, a0, -1
	vle8.v v0, (a1)
	vsse8.v v0, (a0), t1
	ret
#endif
