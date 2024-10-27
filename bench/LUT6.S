#if MX_N == 4

.global LUT6_rvv_vloxei8_m4
LUT6_rvv_vloxei8_m4:
	vsetvli t0, x0, e8, m4, ta, ma
	li t0, 63
	vmv.v.x v24, t0
1:
	vsetvli a3, a2, e8, m4, ta, ma
	vle8.v v8, (a1)
	vand.vv v8, v8, v24
	vloxei8.v v8, (a0), v8
	vse8.v v8, (a1)
	sub a2, a2, a3
	add a1, a1, a3
	bnez a2, 1b
	ret

.global LUT6_rvv_vluxei8_m4
LUT6_rvv_vluxei8_m4:
	vsetvli t0, x0, e8, m4, ta, ma
	li t0, 63
	vmv.v.x v24, t0
1:
	vsetvli a3, a2, e8, m4, ta, ma
	vle8.v v8, (a1)
	vand.vv v8, v8, v24
	vluxei8.v v8, (a0), v8
	vse8.v v8, (a1)
	sub a2, a2, a3
	add a1, a1, a3
	bnez a2, 1b
	ret

# a0 = lut, a1 = ptr, a2 = len
.global LUT6_rvv_gather_m4
LUT6_rvv_gather_m4:
	li t0, 64
	vsetvli zero, t0, e8, m4, ta, ma
	vle8.v v0, (a0)

	vsetvli t0, x0, e8, m4, ta, ma
	li t0, 63
	vmv.v.x v24, t0
1:
	vsetvli a0, a2, e8, m4, ta, ma
	vle8.v v8, (a1)
	vand.vv v8, v8, v24
	vrgather.vv v16, v0, v8
	vse8.v v16, (a1)
	sub a2, a2, a0
	add a1, a1, a0
	bnez a2, 1b
	ret

.global LUT6_rvv_m1m2m4_gathers_m4
LUT6_rvv_m1m2m4_gathers_m4:
	li t0, 64
	vsetvli zero, t0, e8, m4, ta, ma
	vle8.v v0, (a0)

	vsetvli t0, x0, e8, m4, ta, ma
	li t0, 63
	vmv.v.x v24, t0

	csrr t0, vlenb
	srl t0, t0, 4
	sltiu t1, t0, 4
	sltiu t0, t0, 2
	j 0f
1:
	vsetvli t1, x0, e8, m1, ta, ma
	vrgather.vv v16, v0, v8
	vrgather.vv v17, v0, v9
	vrgather.vv v18, v0, v10
	vrgather.vv v19, v0, v11
8:
	vsetvli x0, a0, e8, m4, ta, ma
	vse8.v v16, (a1)
	sub a2, a2, a0
	add a1, a1, a0
	beqz a2, 9f
0:
	vsetvli a0, a2, e8, m4, ta, ma
	vle8.v v8, (a1)
	vand.vv v8, v8, v24
	beqz t1, 1b
	beqz t0, 2f
	vrgather.vv v16, v0, v8
	j 8b
2:
	vsetvli t1, x0, e8, m2, ta, ma
	vrgather.vv v16, v0, v8
	vrgather.vv v18, v0, v10
	j 8b
9:
	ret

#endif


