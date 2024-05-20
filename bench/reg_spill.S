#if 0
uint64_t complex_reduction(uint64_t *arr, size_t n) {
	uint64_t r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,ra,rb,rc,rd,re,rf;
	uint64_t t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,ta,tb,tc,td,te,tf;
	uint64_t s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf;

	r0=r1=r2=r3=r4=r5=r6=r7=r8=r9=ra=rb=rc=rd=re=rf=0;
	t0=t1=t2=t3=t4=t5=t6=t7=t8=t9=ta=tb=tc=td=te=tf=0;
	s0=s1=s2=s3=s4=s5=s6=s7=s8=s9=sa=sb=sc=sd=se=sf=0;

	for (size_t i = 0; i < n; ++i) {
		r0 = arr[0];
		r1=(r0+r1)*(r2^r3);         r2=(r4+r5)*(r6-r7)+(r0&r1);
		r3=(r8+r9)*(ra-rb)+(r0|r2); r4=(rc+rd)*(re-rf)+(r1^r3);
		r5=(t0+t1)*(t2^t3);         r6=(t4+t5)*(t6-t7)+(t0&t1);
		r7=(t8+t9)*(ta-tb)+(t0|t2); r8=(tc+td)*(te-tf)+(t1^t3);
		r9=(s0+s1)*(s2^s3);         ra=(s4+s5)*(s6-s7)+(s0&s1);
		rb=(s8+s9)*(sa-sb)+(s0|s2); rc=(sc+sd)*(se-sf)+(s1^s3);

		t0=r0+r5;t1=r1+r6;t2=r2+r7;t3=r3+r8;
		t4=r4+r9;t5=r5+ra;t6=r6+rb;t7=r7+rc;
		t8=r8+rd;t9=r9+rf;ta=ra+t0;tb=rb+t1;
		tc=rc+t2;td=rd+t3;te=rf+t4;tf=t0+t5;

		#if SPILL_LEVEL >= 1
		s0=t0+s0;s1=t1+s1;s2=t2+s2;s3=t3+s3;
		#endif
		#if SPILL_LEVEL >= 2
		s4=t4+s4;s5=t5+s5;s6=t6+s6;s7=t7+s7;
		#endif
		#if SPILL_LEVEL >= 3
		s8=t8+s8;s9=t9+s9;sa=ta+sa;sb=tb+sb;
		#endif
		#if SPILL_LEVEL >= 4
		sc=tc+sc;sd=td+sd;se=te+se;sf=tf+sf;
		#endif
	}

	return r0 + r8 + rf + t3 + t7 + tc + s8 + s9 + sa;
}
#endif

#if MX_N==1 && __riscv_xlen >= 64


.macro gen_spill_5 spill fill
        addi    sp,sp,-144
        sd      s0,136(sp)
        sd      s1,128(sp)
        sd      s2,120(sp)
        sd      s3,112(sp)
        sd      s4,104(sp)
        sd      s5,96(sp)
        sd      s6,88(sp)
        sd      s7,80(sp)
        sd      s8,72(sp)
        sd      s9,64(sp)
        sd      s11,48(sp)
\spill a0, 4, 2, 1, ins, v2
\spill a1, 5, 3, 0, ins0, v2
        sd      s10,56(sp)
        li      s8,0
        li      s7,0
        li      s6,0
        li      s4,0
        li      s3,0
        li      s11,0
        li      a4,0
\spill x0, 3, 2, 0, ins0, v3
\spill x0, 2, 1, 1, ins, v1
        li      s0,0
\spill x0, 1, 1, 0, down, v1
        li      s9,0
        li      s2,0
        li      a1,0
        li      s1,0
        li      t2,0
        li      a2,0
        li      s5,0
        li      a6,0
        li      a0,0
        li      t1,0
        li      a7,0
        li      a3,0
        li      t0,0
        li      t3,0
        li      t6,0
        li      t5,0
        li      t4,0
        li      a5,0
1:
\fill  s10, 5, 3, 0, at0,  v2
        bne     s8,s10,2f
        add     a0,a5,t1
        add     a0,a0,a1
        add     a0,a0,s0
        ld      s0,136(sp)
        ld      s1,128(sp)
        ld      s2,120(sp)
        ld      s3,112(sp)
        ld      s4,104(sp)
        ld      s5,96(sp)
        ld      s6,88(sp)
        ld      s7,80(sp)
        ld      s8,72(sp)
        ld      s9,64(sp)
        ld      s10,56(sp)
        ld      s11,48(sp)
        add     a0,a0,a4
        addi    sp,sp,144
        jr      ra
2:
        add     t1,t1,a0
\fill  a0,  1, 1, 0, at1,  v1
        sub     a3,a3,a7
        add     t3,t3,t0
        mul     t3,t3,a3
        add     t0,a2,t2
        xor     a3,s1,a1
        sub     s0,a0,s0
\fill  a5,  4, 2, 1, at1,  v2
        add     a4,a1,a4
        and     a0,a2,t2
        ld      a5,0(a5)
        xor     t5,t5,t6
        sub     a6,a6,s5
        mul     t0,t0,a3
        add     a3,s2,s9
        sub     s2,s2,s11
        add     t4,t4,a5
        xor     a1,t2,a1
        or      a2,a2,s1
        or      s5,s3,s6
        addi    s8,s8,1
        mul     a3,a3,s0
\fill  s0,  3, 2, 0, at0,  v3
        mul     a4,a4,s2
        add     a3,a3,a0
\fill  a0,  2, 1, 1, at0,  v1
        sub     a7,a0,s0
        add     a0,s3,s4
        add     s0,s5,a3
\spill s0,  1, 1, 0, ins,  v1
        mul     t4,t5,t4
        mul     a6,a6,t1
        and     t5,a5,t4
        add     t5,t3,t5
        or      t6,a5,t5
        add     t2,t4,a3
        mul     a7,a7,t1
        add     t1,a4,a1
        xor     a4,s6,s7
        add     t6,a6,t6
        and     a6,s3,s4
        xor     t3,t4,t6
        add     a1,t6,t1
        add     s9,a6,t0
        mul     a0,a0,a4
        add     a7,a7,a2
        add     a2,a5,t0
        add     s10,a6,a2
        xor     a4,s4,s7
        add     s1,t5,a7
\spill s10, 2, 1, 1, ins0, v1
        add     s10,s5,t2
        add     s0,a4,a7
\spill s10, 3, 2, 0, ins0, v3
        add     s2,t3,a0
        add     a4,a4,s1
        add     s11,a2,s9
        add     s3,s3,a2
        add     s4,s4,t2
        add     s6,s6,s1
        add     s7,s7,a1
        j       1b
.endm


.macro gen_spill_14 spill fill
        addi    sp,sp,-224
        sd      s0,216(sp)
        sd      s1,208(sp)
        sd      s2,200(sp)
        sd      s4,184(sp)
        sd      s5,176(sp)
        sd      s6,168(sp)
        sd      s7,160(sp)
        sd      s9,144(sp)
        sd      s10,136(sp)
        sd      s11,128(sp)
\spill a0, 14, 8, 0, ins,  v8
\spill a1, 15, 8, 1, down, v8
        sd      s3,192(sp)
        sd      s8,152(sp)
\spill x0, 8,  5, 0, ins,  v5
\spill x0, 7,  4, 1, ins,  v4
\spill x0, 6,  4, 0, ins0, v4
\spill x0, 5,  3, 1, ins,  v3
\spill x0, 1,  1, 1, ins,  v1
        li      s9,0
        li      s10,0
\spill x0, 4,  3, 0  ins0, v3
\spill x0, 3,  2, 1, ins,  v2
\spill x0, 2,  2, 0, ins0, v2
\spill x0, 0,  1, 0, ins0, v1
        li      s7,0
        li      s11,0
        li      s6,0
        li      s5,0
\spill x0, 13, 7, 1, ins,  v7
        li      a4,0
\spill x0, 12, 7, 0, ins0, v7
\spill x0, 11, 6, 1, ins,  v6
        li      a2,0
\spill x0, 10, 6, 0, down, v6
        li      s2,0
        li      s1,0
        li      a1,0
        li      s4,0
        li      s0,0
        li      a3,0
        li      t4,0
        li      t3,0
        li      t2,0
        li      a0,0
        li      t1,0
        li      t0,0
        li      t6,0
\spill x0, 9,  5, 1, ins0, v5
        li      a7,0
        li      a6,0
        li      t5,0
        li      a5,0
1:
\fill  s3, 8,  5, 0, at1, v5
\fill  s8, 15, 8, 1, at1, v8
        bne     s3,s8,2f
        add     a0,a5,a0
        add     a0,a0,a1
        add     a0,a0,a2
\fill  a5, 1,  1, 1, at1, v1
        ld      s0,216(sp)
        add     a0,a0,a4
        add     a0,a0,s10
        add     a0,a0,s9
        ld      s1,208(sp)
        ld      s2,200(sp)
        ld      s3,192(sp)
        ld      s4,184(sp)
        ld      s5,176(sp)
        ld      s6,168(sp)
        ld      s7,160(sp)
        ld      s8,152(sp)
        ld      s9,144(sp)
        ld      s10,136(sp)
        ld      s11,128(sp)
        add     a0,a0,a5
        addi    sp,sp,224
        jr      ra
2:
\fill  a5, 14, 8, 0, at0,  v8
        xor     a6,a6,a7
        add     a0,a0,t2
        ld      a5,0(a5)
        add     s2,s1,s2
        add     a4,a1,a4
        add     t5,t5,a5
        mul     t5,a6,t5
\fill  a6, 9,  5, 1, at0,  v5
        add     t2,s5,s6
        add     s3,a6,t6
        sub     a6,t0,t1
        add     t6,a3,s0
        and     t0,a3,s0
        or      a3,a3,s4
        mul     a6,s3,a6
        and     a7,a5,t5
        add     a6,a6,a7
        sub     a7,t3,t4
        mul     a7,a7,a0
        or      t1,a5,a6
        add     a7,a7,t1
        xor     t1,t5,a7
\spill t1, 9,  5, 1, down, v5
        xor     t1,s4,a1
        mul     t6,t6,t1
\fill  t1, 10, 6, 0, at1,  v6
        xor     a1,s0,a1
        sub     a2,t1,a2
\fill  t1, 12, 7, 0, at1,  v7
        mul     a2,s2,a2
        add     t0,a2,t0
\fill  a2, 11, 6, 1, at0,  v6
        add     s0,t5,t0
        sub     t1,a2,t1
        mul     t1,t1,a0
\fill  a2, 4,  3, 0, at0,  v3
        add     t1,t1,a3
\fill  a3, 13, 7, 1, at0,  v7
        add     s4,a6,t1
        sub     s1,s1,a3
        mul     a4,a4,s1
\fill  a3, 2,  2, 0, at0,  v2
        add     a0,a4,a1
        xor     a4,s11,s7
        mul     t2,t2,a4
\fill  a4, 0,  1, 0, at0,  v1
        add     a1,a7,a0
        add     a4,a4,a3
\fill  a3, 3,  2, 1, at1,  v2
        sub     t3,a3,a2
\fill  a2, 1,  1, 1, at1,  v1
        mul     t3,a4,t3
\fill  a3, 5,  3, 1, at1,  v3
        and     a4,s5,s6
        sub     t4,a2,a3
\fill  a2, 7,  4, 1, at1,  v4
        add     t3,t3,a4
        add     a4,s10,s9
        mul     t4,a4,t4
        or      a4,s5,s11
        add     s2,t6,t3
        add     s11,s11,s4
        add     s10,s10,a0
        add     s9,s9,t2
        add     t4,t4,a4
\fill  a4, 6,  4, 0, at0,  v4
        add     s8,t0,t4
        add     a3,s7,a4
\fill  a4, 0,  1, 0, at0,  v1
        sub     a4,a4,a2
        mul     a4,a3,a4
        xor     a3,s6,s7
        xor     a2,t5,a7
        add     s1,a2,t2
        add     a2,t0,t4
\spill a2, 10, 6, 0, ins,  v6
        add     s6,s6,s0
        add     s7,s7,a1
        add     a4,a4,a3
        add     a3,a5,t6
        add     s3,t3,a3
\spill s3, 11, 6, 1, ins0, v6
        add     s3,t4,s0
\spill s3, 12, 7, 0, ins,  v7
        add     s3,a3,s2
\spill s3, 13, 7, 1, ins0, v7
\fill  s3, 0,  1, 0, at0,  v1
        add     a2,t1,a4
        add     a4,a4,s4
        add     s3,s3,s1
\spill s3, 0,  1, 0, down, v1
\fill  s3, 2,  2, 0, at0,   v2
        add     s5,s5,a3
        add     s3,s3,s2
\spill s3, 2,  2, 0, down, v2
\fill  s3, 3,  2, 1, at0,  v2
        add     s3,s3,s8
\spill s3, 3,  2, 1, down, v2
\fill  s3, 4,  3, 0, at0,  v3
\fill  s8, 1,  1, 1, at0,  v1
        add     s3,s3,a2
\spill s3, 4,  3, 0, down, v3
        add     s3,t3,a3
        add     s3,s8,s3
\spill s3, 1,  1, 1, down, v1
\fill  s3, 5,  3, 1, at0,  v3
        add     s8,t4,s0
        add     s3,s3,s8
\spill s3, 5,  3, 1, down  v3
\fill  s3, 6,  4, 0, at0,  v4
        add     s8,a3,s2
        add     s3,s3,a4
\spill s3, 6,  4, 0, down, v4
\fill  s3, 7,  4, 1, at0,  v4
        add     s3,s3,s8
\spill s3, 7,  4, 1, down, v4
\fill  s3, 8,  5, 0, at0,  v5
        addi    s3,s3,1
\spill s3, 8,  5, 0, down, v5
        j       1b
.endm


.macro spill_stack reg idx _:vararg
	sd \reg, (8*\idx)(sp)
.endm
.macro fill_stack reg idx _:vararg
	ld \reg, (8*\idx)(sp)
.endm

.global reg_spill_5_stack
reg_spill_5_stack: gen_spill_5 spill_stack fill_stack
.global reg_spill_14_stack
reg_spill_14_stack: gen_spill_14 spill_stack fill_stack


.macro spill_fp reg idx _:vararg
.ifc \idx, 12
	fmv.d.x fa0, \reg
.else
.ifc  \idx, 13
	fmv.d.x fa1, \reg
.else
.ifc  \idx, 14
	fmv.d.x fa2, \reg
.else
.ifc  \idx, 15
	fmv.d.x fa3, \reg
.else
	fmv.d.x ft\idx, \reg
.endif
.endif
.endif
.endif
.endm
.macro fill_fp reg idx _:vararg
.ifc \idx, 12
	fmv.x.d \reg, fa0
.else
.ifc  \idx, 13
	fmv.x.d \reg, fa1
.else
.ifc  \idx, 14
	fmv.x.d \reg, fa2
.else
.ifc  \idx, 15
	fmv.x.d \reg, fa3
.else
	fmv.x.d \reg, ft\idx
.endif
.endif
.endif
.endif
.endm

.global reg_spill_5_fp
reg_spill_5_fp: gen_spill_5 spill_fp fill_fp
.global reg_spill_14_fp
reg_spill_14_fp: gen_spill_14 spill_fp fill_fp


.macro spill_rvv_best reg idx _:vararg
	vmv.s.x v\idx, \reg
.endm
.macro fill_rvv_best reg idx _:vararg
	vmv.x.s \reg, v\idx
.endm

.global reg_spill_5_rvv_best
reg_spill_5_rvv_best:
	vsetivli x0, 1, e64, m1, ta, ma
	gen_spill_5 spill_rvv_best fill_rvv_best

.global reg_spill_14_rvv_best
reg_spill_14_rvv_best:
	vsetivli x0, 1, e64, m1, ta, ma
	gen_spill_14 spill_rvv_best fill_rvv_best


.macro spill_rvv_worst_merge reg _0 id idx _:vararg
	vmv.v.i v0, 1<<\idx
	vmv.v.x v30, \reg
	vmerge.vvm v\id, v\id, v30, v0
.endm
.macro spill_rvv_worst_slide reg _0 id idx _:vararg
	vslidedown.vi v0, v\id, \idx
	vmv.s.x v0, \reg
	vslideup.vi v\id, v0, \idx
.endm
.macro fill_rvv_worst reg _0 id idx _:vararg
	vslidedown.vi v0, v\id, \idx
	vmv.x.s \reg, v0
.endm

.global reg_spill_5_rvv_worst_merge
reg_spill_5_rvv_worst_merge:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_5 spill_rvv_worst_merge fill_rvv_worst
.global reg_spill_14_rvv_worst_merge
reg_spill_14_rvv_worst_merge:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_14 spill_rvv_worst_merge fill_rvv_worst

.global reg_spill_5_rvv_worst_slide
reg_spill_5_rvv_worst_slide:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_5 spill_rvv_worst_slide fill_rvv_worst
.global reg_spill_14_rvv_worst_slide
reg_spill_14_rvv_worst_slide:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_14 spill_rvv_worst_slide fill_rvv_worst


.macro zvl128b_at0 reg v
	vmv.x.s \reg, \v
.endm

.macro zvl128b_at1 reg v
	vslidedown.vi v0, \v, 1
	vmv.x.s \reg, v0
.endm

.macro zvl128b_ins0 reg v
	vmv.s.x \v, \reg
.endm

.macro zvl128b_ins reg v
	vmv.v.x \v, \reg
.endm

.macro zvl128b_up reg v
	vslide1up.vx \v, \v, \reg
.endm

.macro zvl128b_down reg v
	vslide1down.vx \v, \v, \reg
.endm

.macro spill_rvv_zvl128b reg _0 _1 _2 func args:vararg
	zvl128b_\func \reg, \args
.endm
.macro fill_rvv_zvl128b reg _0 _1 _2 func args:vararg
	zvl128b_\func \reg, \args
.endm

.global reg_spill_5_rvv_zvl128b
reg_spill_5_rvv_zvl128b:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_5 spill_rvv_zvl128b fill_rvv_zvl128b
.global reg_spill_14_rvv_zvl128b
reg_spill_14_rvv_zvl128b:
	vsetivli x0, 2, e64, m1, ta, ma
	gen_spill_14 spill_rvv_zvl128b fill_rvv_zvl128b

#endif

