#ifndef __riscv_v
# include "../../thirdparty/rvv-rollback.S"
#endif
.text
.balign 8

// Changes from original codegen (clang-18):
// * rvv-rollback for direct translation
// * vsetivli -> vsetvl
// * vle64 -> vle32
// * vmvNr -> vmv.v.v & 2 vsetvli
// * vzext.vN -> N/2 vwaddu.vx & N/2+1 vsetvli
// * vredmax -> vfirst vmsgtu
//   the SG2042 I've got access to seems to produce the wrong result for
//   vredmax, so we need to replace it

.global utf8_to_utf32_rvv
utf8_to_utf32_rvv:
        li      a3, 2
        bltu    a3, a1, .LBB0_2
        tail    utf8_to_utf32_scalar
.LBB0_2:
        addi    sp, sp, -80
        sd      ra, 72(sp)
        sd      s0, 64(sp)
        sd      s1, 56(sp)
        sd      s2, 48(sp)
        sd      s3, 40(sp)
        li      a3, 3
        addi    s1, a1, -3
        beqz    s1, .LBB0_8
        li      a4, 128
.LBB0_4:
        add     a5, a0, a3
        lbu     a5, 0(a5)
        andi    a5, a5, 192
        bne     a5, a4, .LBB0_7
        addi    a3, a3, 1
        bne     a1, a3, .LBB0_4
        mv      a3, a1
.LBB0_7:
        li      a4, 6
        bltu    a4, a3, .LBB0_21
.LBB0_8:
        mv      s2, a2
        mv      a2, sp
        mv      s0, a0
        mv      s3, a1
        mv      a1, a3
        call    utf8_to_utf32_scalar
        mv      a1, a0
        beqz    a0, .LBB0_21
        mv      a2, s2
        mv      a0, s0
        vsetvli a1, zero, e16, m2, ta, ma
        beqz    s1, .LBB0_27
        mv      t3, s3
	li a1, 4
	vsetvli        zero, a1, e32, m1, ta, ma
	la a1, utf8_to_utf32_rvv.err1m
	vle32.v v10, (a1)
	la a1, utf8_to_utf32_rvv.err2m
	vle32.v v11, (a1)
	la a1, utf8_to_utf32_rvv.err3m
	vle32.v v12, (a1)
        li      a1, 64
        vsetvli a3, zero, e8, m2, ta, ma
        vmv.v.x v14, a1
        li      t6, 127
        li      t5, -33
        li      t4, -17
        li      a5, 63
        li      a6, -64
        li      a7, 10
        lui     t0, 1
        li      t1, 2
        li      t2, 6
        mv      s0, a2
        j       .LBB0_13
.LBB0_11:
	vsetvli zero, zero, e8, m2, ta, ma
	vwaddu.vx v0, v8, x0
	vsetvli zero, zero, e16, m4, ta, ma
	vwaddu.vx v16, v0, x0
	vsetvli zero, zero, e32, m8, ta, ma
        vse32.v v16, (s0)
        mv      a4, a2
.LBB0_12:
        sub     s1, s1, a2
        slli    a4, a4, 2
        add     s0, s0, a4
        beqz    s1, .LBB0_22
.LBB0_13:
        vsetvli a2, s1, e8, m2, ta, ma
        vle8.v  v8, (a0)
        vmsgtu.vx       v13, v8, t6
        vfirst.m        a3, v13
        add     a0, a0, a2
        bltz    a3, .LBB0_11
        lbu     a3, 0(a0)
        lbu     a4, 1(a0)
        lbu     a1, 2(a0)
        vslide1down.vx  v22, v8, a3
        vslide1down.vx  v20, v22, a4
        vslide1down.vx  v18, v20, a1
        vsetvli a1, zero, e16, m2, ta, ma
        vsrl.vi v16, v20, 4
        vsrl.vi v24, v18, 4
        vsetvli zero, a2, e8, m2, ta, ma
        vand.vi v26, v20, 15
        vand.vi v16, v16, 15
        vand.vi v24, v24, 15
        vsetvli a1, zero, e8, m1, ta, ma
        vrgather.vv     v28, v10, v16
        vrgather.vv     v29, v10, v17
        vrgather.vv     v16, v11, v26
        vrgather.vv     v17, v11, v27
        vrgather.vv     v26, v12, v24
        vrgather.vv     v27, v12, v25
        vsetvli zero, a2, e8, m2, ta, ma
        vand.vv v16, v28, v16
        vand.vv v16, v16, v26
        vmsgtu.vx       v24, v22, t5
        vmsgtu.vx       v13, v8, t4
        vmor.mm v24, v24, v13
        vmsgtu.vx       v25, v16, t6
        vmxor.mm        v24, v24, v25
        vmsgt.vi        v25, v16, 0
        vmor.mm v16, v25, v24
        vfirst.m        a1, v16
        bgez    a1, .LBB0_21
        vsrl.vi v16, v8, 6
        vmsne.vi        v24, v16, 2
        vcpop.m a4, v24
        vcompress.vm    v16, v8, v24
        vmsgtu.vx       v25, v8, t5
        vfirst.m        a1, v25
        vcompress.vm    v8, v22, v24
        bltz    a1, .LBB0_19
        vfirst.m        a1, v13
        vcompress.vm    v22, v20, v24
        bltz    a1, .LBB0_20
        vcompress.vm    v20, v18, v24
        vsetvli a3, a4, e8, m1, ta, ma
        vand.vx v8, v8, a5
        vand.vx v13, v22, a5
        vand.vx v18, v20, a5
        vsrl.vi v19, v16, 4
        vmseq.vi        v0, v19, 12
        vssubu.vx       v19, v19, a7
        vmerge.vim      v19, v19, 3, v0
        vsll.vv v16, v16, v19
        vsrl.vv v16, v16, v19
        vwmulu.vv       v24, v13, v14
        vwaddu.wv       v24, v24, v18
        vwmulu.vv       v26, v16, v14
        vwaddu.wv       v26, v26, v8
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v28, v26, t0
        vwaddu.wv       v28, v28, v24
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v8, v19, t1
        vrsub.vi        v8, v8, 3
        vmul.vx v8, v8, t2
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v8, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v24, v0, x0
	vsetvli zero, zero, e32, m4, ta, ma
        vsrl.vv v24, v28, v24
        vse32.v v24, (s0)
        beq     a4, a3, .LBB0_12
        sub     a4, a4, a3
        slli    a3, a3, 2
        add     s0, s0, a3
        vsetvli zero, a4, e8, m1, ta, ma
        vand.vx v8, v9, a5
        vand.vx v9, v23, a5
        vand.vx v13, v21, a5
        vsrl.vi v16, v17, 4
        vmseq.vi        v0, v16, 12
        vssubu.vx       v16, v16, a7
        vmerge.vim      v16, v16, 3, v0
        vsll.vv v17, v17, v16
        vsrl.vv v17, v17, v16
        vwmulu.vv       v18, v9, v14
        vwaddu.wv       v18, v18, v13
        vwmulu.vv       v20, v17, v14
        vwaddu.wv       v20, v20, v8
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v24, v20, t0
        vwaddu.wv       v24, v24, v18
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v8, v16, t1
        vrsub.vi        v8, v8, 3
        vmul.vx v8, v8, t2
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v8, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v16, v0, x0
	vsetvli zero, zero, e32, m4, ta, ma
        vsrl.vv v16, v24, v16
        vse32.v v16, (s0)
        j       .LBB0_12
.LBB0_19:
        vsetvli zero, a4, e8, m2, ta, ma
        vand.vx v8, v8, a5
        vmsltu.vx       v0, v16, a6
        vmv.v.x v18, a5
        vmerge.vim      v18, v18, -1, v0
        vand.vv v16, v16, v18
        vmerge.vim      v18, v14, 1, v0
        vwmulu.vv       v20, v16, v18
        vmerge.vim      v8, v8, 0, v0
        vwaddu.wv       v20, v20, v8
	vsetvli zero, zero, e16, m4, ta, ma
	vwaddu.vx v24, v20, x0
	vsetvli zero, zero, e32, m8, ta, ma
        vse32.v v24, (s0)
        j       .LBB0_12
.LBB0_20:
        vsetvli zero, a4, e8, m2, ta, ma
        vand.vx v20, v8, a5
        vand.vx v22, v22, a5
        vmsltu.vx       v8, v16, a6
        vmsgtu.vx       v9, v16, t5
        vmv.v.x v18, a5
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a4, e8, m2, ta, ma
        vmerge.vim      v18, v18, -1, v0
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a4, e8, m2, ta, ma
        vmerge.vim      v18, v18, 15, v0
        vand.vv v24, v16, v18
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a4, e8, m2, ta, ma
        vmerge.vim      v26, v14, 1, v0
        vwmulu.vv       v16, v24, v26
        vmerge.vim      v20, v20, 0, v0
        vwaddu.wv       v16, v16, v20
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a4, e16, m4, ta, mu
	vmv.v.v v24, v16
        vsll.vi v24, v16, 6, v0.t
        vsetvli zero, zero, e8, m2, ta, mu
        vwaddu.wv       v16, v24, v22, v0.t
	vsetvli zero, zero, e16, m4, ta, ma
	vwaddu.vx v24, v16, x0
	vsetvli zero, zero, e32, m8, ta, ma
        vse32.v v24, (s0)
        j       .LBB0_12
.LBB0_21:
        li      a0, 0
        j       .LBB0_29
.LBB0_22:
        li      a1, 3
        beq     t3, a1, .LBB0_28
        lbu     a2, 0(a0)
        andi    a3, a2, 192
        addi    a2, a3, -128
        snez    a2, a2
        slli    a2, a2, 2
        add     s0, s0, a2
        li      a2, 128
        addi    s0, s0, -4
        bne     a3, a2, .LBB0_28
        li      a1, 3
.LBB0_25:
        lbu     a3, -1(a0)
        addi    a0, a0, -1
        andi    a3, a3, 192
        addi    a1, a1, 1
        bne     a3, a2, .LBB0_28
        bltu    a1, t3, .LBB0_25
        j       .LBB0_28
.LBB0_27:
        li      a1, 3
        mv      s0, a2
.LBB0_28:
        mv      a2, s0
        call    utf8_to_utf32_scalar
        seqz    a1, a0
        sub     a2, s0, s2
        srai    a2, a2, 2
        add     a0, a0, a2
        addi    a1, a1, -1
        and     a0, a0, a1
.LBB0_29:
        ld      ra, 72(sp)
        ld      s0, 64(sp)
        ld      s1, 56(sp)
        ld      s2, 48(sp)
        ld      s3, 40(sp)
        addi    sp, sp, 80
        ret

.data
utf8_to_utf32_rvv.err1m:
        .quad   144680345676153346
        .quad   5266116582681116800
utf8_to_utf32_rvv.err2m:
        .quad   -3761689263670582297
        .quad   -3761671395393942581
utf8_to_utf32_rvv.err3m:
        .quad   72340172838076673
        .quad   72340175954030310
