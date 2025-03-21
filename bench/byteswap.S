
#if defined(MX) && __riscv_zvbb
.global MX(byteswap32_rvv_vrev8_)
MX(byteswap32_rvv_vrev8_):
1:
	vsetvli t0, a1, e32, MX(), ta, ma
	vle32.v v0, (a0)
	vrev8.v v8, v0
	vse32.v v8, (a0)
	sub a1, a1, t0
	slli t1, t0, 2
	add a0, a0, t1
	bnez a1, 1b
	ret
#endif

#if MX_N == 4 || MX_N == 2 || MX_N == 1

# a0 = ptr, a1 = len
.global MX(byteswap32_rvv_gatherei16_)
MX(byteswap32_rvv_gatherei16_):
	vsetvli t0, x0, e16, MX2(), ta, ma
	vid.v v0
	vand.vi v8, v0, 3
	vrsub.vi v8, v8, 3
	vsrl.vi v0, v0, 2
	vsll.vi v0, v0, 2
	vadd.vv v0, v0, v8 # i/8*8 + (7-1%8)
1:
	vsetvli t0, a1, e32, MX(), ta, ma
	vle32.v v8, (a0)
	slli t1, t0, 2
	vsetvli x0, t1, e8, MX(), ta, ma
	vrgatherei16.vv v16, v8, v0
	vsetvli x0, t0, e32, MX(), ta, ma
	vse32.v v16, (a0)
	sub a1, a1, t0
	add a0, a0, t1
	bnez a1, 1b
	ret
#endif

#if MX_N == 2

.macro byteswap32_rvv_m1_gatherei16s n
	.global byteswap32_rvv_m1_gatherei16s_m\n
	byteswap32_rvv_m1_gatherei16s_m\n:
		vsetvli t0, x0, e16, MX(), ta, ma
		vid.v v0
		vand.vi v8, v0, 3
		vrsub.vi v8, v8, 3
		vsrl.vi v0, v0, 2
		vsll.vi v0, v0, 2
		vadd.vv v0, v0, v8 # i/8*8 + (7-1%8)
	1:
		vsetvli t0, a1, e32, m\n, ta, ma
		vle32.v v8, (a0)
		vsetvli t1, x0, e8, m1, ta, ma
		vrgatherei16.vv v16, v8, v0
	.ifge \n-2
		vrgatherei16.vv v17, v9, v0
	.ifge \n-4
		vrgatherei16.vv v18, v10, v0
		vrgatherei16.vv v19, v11, v0
	.ifge \n-8
		vrgatherei16.vv v20, v12, v0
		vrgatherei16.vv v21, v13, v0
		vrgatherei16.vv v22, v14, v0
		vrgatherei16.vv v23, v15, v0
	.endif
	.endif
	.endif
		vsetvli x0, t0, e32, m\n, ta, ma
		vse32.v v16, (a0)
		sub a1, a1, t0
		slli t0, t0, 2
		add a0, a0, t0
		bnez a1, 1b
		ret
.endm

byteswap32_rvv_m1_gatherei16s 2
#endif
#if MX_N == 4
byteswap32_rvv_m1_gatherei16s 4
#endif
#if MX_N == 8
byteswap32_rvv_m1_gatherei16s 8
#endif

