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

.global MX(LUT4_rvv_vluxei8_)
MX(LUT4_rvv_vluxei8_):
1:
	vsetvli a3, a2, e8, MX(), ta, ma
	vle8.v v8, (a1)
	vand.vi v8, v8, 15
	vluxei8.v v8, (a0), v8
	vse8.v v8, (a1)
	sub a2, a2, a3
	add a1, a1, a3
	bnez a2, 1b
	ret

# a0 = lut, a1 = ptr, a2 = len
.global MX(LUT4_rvv_gather_)
MX(LUT4_rvv_gather_):
	li t0, 16
	vsetvli zero, t0, e8, m1, ta, ma
	vle8.v v0, (a0)
1:
	vsetvli a0, a2, e8, MX(), ta, ma
	vle8.v v8, (a1)
	vand.vi v8, v8, 15
	vrgather.vv v16, v0, v8
	vse8.v v16, (a1)
	sub a2, a2, a0
	add a1, a1, a0
	bnez a2, 1b
	ret
#endif

#if MX_N == 2

.macro LUT4_rvv_m1_gathers n
	.global LUT4_rvv_m1_gathers_m\n
	LUT4_rvv_m1_gathers_m\n:
		li t0, 16
		vsetvli zero, t0, e8, m1, ta, ma
		vle8.v v0, (a0)
1:
		vsetvli a0, a2, e8, m\n, ta, ma
		vle8.v v8, (a1)
		vand.vi v8, v8, 15
		vsetvli t1, x0, e8, m1, ta, ma
		vrgather.vv v16, v0, v8
	.ifge \n-2
		vrgather.vv v17, v0, v9
	.ifge \n-4
		vrgather.vv v18, v0, v10
		vrgather.vv v19, v0, v11
	.ifge \n-8
		vrgather.vv v20, v0, v12
		vrgather.vv v21, v0, v13
		vrgather.vv v22, v0, v14
		vrgather.vv v23, v0, v15
	.endif
	.endif
	.endif
		vsetvli x0, a0, e8, m\n, ta, ma
		vse8.v v16, (a1)
		sub a2, a2, a0
		add a1, a1, a0
		bnez a2, 1b
		ret
.endm

LUT4_rvv_m1_gathers 2
#endif
#if MX_N == 4
LUT4_rvv_m1_gathers 4
#endif
#if MX_N == 8
LUT4_rvv_m1_gathers 8
#endif


