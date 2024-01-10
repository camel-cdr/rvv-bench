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
// * vzext.vN -> N/2 vwaddu & N/2+1 vsetvli
// * vredmax -> vfirst vmsgtu
//   the SG2042 I've got access to seems to produce the wrong result for
//   vredmax, so we need to replace it

.global utf8_to_utf16_rvv
utf8_to_utf16_rvv:
        li      a3, 2
        bltu    a3, a1, .LBB0_2
        tail    utf8_to_utf16_scalar
.LBB0_2:
        addi    sp, sp, -96
        sd      ra, 88(sp)
        sd      s0, 80(sp)
        sd      s1, 72(sp)
        sd      s2, 64(sp)
        sd      s3, 56(sp)
        sd      s4, 48(sp)
        sd      s5, 40(sp)
        sd      s6, 32(sp)
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
        bltu    a4, a3, .LBB0_22
.LBB0_8:
        mv      s2, a2
        addi    a2, sp, 12
        mv      s0, a0
        mv      s3, a1
        mv      a1, a3
        call    utf8_to_utf16_scalar
        mv      a1, a0
        beqz    a0, .LBB0_22
        mv      a2, s2
        mv      a0, s0
        vsetvli a1, zero, e16, m2, ta, ma
        beqz    s1, .LBB0_30
        mv      t4, s3
	li a1, 4
	vsetvli        zero, a1, e32, m1, ta, ma
	la a1, utf8_to_utf16_rvv.err1m
	vle32.v v11, (a1)
	la a1, utf8_to_utf16_rvv.err2m
	vle32.v v12, (a1)
	la a1, utf8_to_utf16_rvv.err3m
	vle32.v v13, (a1)
        li      a1, 64
        vsetvli a3, zero, e8, m2, ta, ma
        vmv.v.x v14, a1
        vid.v   v8
        vand.vi v16, v8, 1
        vmsne.vi        v8, v16, 0
        li      s6, 127
        li      s5, -33
        li      t5, -17
        li      a5, 63
        li      a6, -64
        li      a7, 10
        lui     t0, 1
        li      t1, 2
        li      t2, 6
        lui     t3, 16
        lui     a1, 16368
        addi    t6, a1, 1023
        addi    s3, t3, -1
        lui     a1, 884750
        addi    s4, a1, -1024
        mv      s0, a2
        j       .LBB0_13
.LBB0_11:
	vsetvli zero, zero, e8, m2, ta, ma
	vwaddu.vx v20, v18, x0
	vsetvli zero, zero, e16, m4, ta, ma
        vse16.v v20, (s0)
        mv      a2, a1
.LBB0_12:
        sub     s1, s1, a1
        slli    a2, a2, 1
        add     s0, s0, a2
        beqz    s1, .LBB0_23
.LBB0_13:
        vsetvli a1, s1, e8, m2, ta, ma
        vle8.v  v18, (a0)
        vmsgtu.vx       v9, v18, s6
        vfirst.m        a2, v9
        add     a0, a0, a1
        bltz    a2, .LBB0_11
        lbu     a2, 0(a0)
        lbu     a3, 1(a0)
        lbu     a4, 2(a0)
        vslide1down.vx  v20, v18, a2
        vslide1down.vx  v22, v20, a3
        vslide1down.vx  v24, v22, a4
        vsetvli a2, zero, e16, m2, ta, ma
        vsrl.vi v16, v22, 4
        vsrl.vi v26, v24, 4
        vsetvli zero, a1, e8, m2, ta, ma
        vand.vi v28, v22, 15
        vand.vi v16, v16, 15
        vand.vi v26, v26, 15
        vsetvli a2, zero, e8, m1, ta, ma
        vrgather.vv     v30, v11, v16
        vrgather.vv     v31, v11, v17
        vrgather.vv     v16, v12, v28
        vrgather.vv     v17, v12, v29
        vrgather.vv     v28, v13, v26
        vrgather.vv     v29, v13, v27
        vsetvli zero, a1, e8, m2, ta, ma
        vand.vv v16, v30, v16
        vand.vv v16, v16, v28
        vmsgtu.vx       v10, v20, s5
        vmsgtu.vx       v9, v18, t5
        vmor.mm v10, v10, v9
        vmsgtu.vx       v26, v16, s6
        vmxor.mm        v10, v10, v26
        vmsgt.vi        v26, v16, 0
        vmor.mm v10, v26, v10
        vfirst.m        a2, v10
        bgez    a2, .LBB0_22
        vsrl.vi v16, v18, 6
        vmsne.vi        v10, v16, 2
        vcpop.m a2, v10
        vcompress.vm    v16, v18, v10
        vmsgtu.vx       v26, v18, s5
        vfirst.m        a3, v26
        vcompress.vm    v18, v20, v10
        bltz    a3, .LBB0_19
        vfirst.m        a3, v9
        vcompress.vm    v20, v22, v10
        bltz    a3, .LBB0_20
        vcompress.vm    v22, v24, v10
        vsetvli a3, a2, e8, m1, ta, ma
        vand.vx v9, v18, a5
        vand.vx v10, v20, a5
        vand.vx v18, v22, a5
        vsrl.vi v20, v16, 4
        vmseq.vi        v0, v20, 12
        vssubu.vx       v20, v20, a7
        vmerge.vim      v20, v20, 3, v0
        vsll.vv v16, v16, v20
        vsrl.vv v16, v16, v20
        vwmulu.vv       v24, v10, v14
        vwaddu.wv       v24, v24, v18
        vwmulu.vv       v26, v16, v14
        vwaddu.wv       v26, v26, v9
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v28, v26, t0
        vwaddu.wv       v28, v28, v24
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v9, v20, t1
        vrsub.vi        v9, v9, 3
        vmul.vx v9, v9, t2
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v9, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v24, v0, x0
	vsetvli zero, zero, e32, m4, ta, ma
        vsrl.vv v24, v28, v24
        vsub.vx v28, v24, t3
        vsll.vi v4, v28, 6
        slli    a4, a3, 1
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a4, e16, m4, ta, ma
        vmerge.vvm      v28, v28, v4, v0
        vsetvli zero, a3, e32, m4, ta, mu
        vmsgtu.vx       v0, v24, s3
        vand.vx v28, v28, t6
        vor.vx  v24, v28, s4, v0.t
        vsll.vi v28, v24, 16
        vsrl.vi v24, v24, 16
        vor.vv  v24, v28, v24
        vsetvli zero, a4, e16, m4, ta, ma
        vmsne.vi        v9, v24, 0
        vmor.mm v9, v9, v8
        vcompress.vm    v28, v24, v9
        vcpop.m a4, v9
        vsetvli zero, a4, e16, m4, ta, ma
        vse16.v v28, (s0)
        bne     a2, a3, .LBB0_21
        mv      a2, a4
        j       .LBB0_12
.LBB0_19:
        vsetvli zero, a2, e8, m2, ta, ma
        vand.vx v18, v18, a5
        vmsltu.vx       v0, v16, a6
        vmv.v.x v20, a5
        vmerge.vim      v20, v20, -1, v0
        vand.vv v16, v16, v20
        vmerge.vim      v20, v14, 1, v0
        vwmulu.vv       v24, v16, v20
        vmerge.vim      v16, v18, 0, v0
        vwaddu.wv       v24, v24, v16
	vsetvli zero, a2, e16, m4, ta, ma
        vse16.v v24, (s0)
        j       .LBB0_12
.LBB0_20:
        vsetvli zero, a2, e8, m2, ta, ma
        vand.vx v22, v18, a5
        vand.vx v20, v20, a5
        vmsltu.vx       v9, v16, a6
        vmsgtu.vx       v10, v16, s5
        vmv.v.x v18, a5
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a2, e8, m2, ta, ma
        vmerge.vim      v18, v18, -1, v0
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v10
	vsetvli zero, a2, e8, m2, ta, ma
        vmerge.vim      v18, v18, 15, v0
        vand.vv v24, v16, v18
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a2, e8, m2, ta, ma
        vmerge.vim      v26, v14, 1, v0
        vwmulu.vv       v16, v24, v26
        vmerge.vim      v22, v22, 0, v0
        vwaddu.wv       v16, v16, v22
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v10
	vsetvli zero, a2, e16, m4, ta, mu
	vmv.v.v v24, v16
        vsll.vi v24, v16, 6, v0.t
        vsetvli zero, zero, e8, m2, ta, mu
        vwaddu.wv       v16, v24, v20, v0.t
	vsetvli zero, zero, e16, m4, ta, mu
        vse16.v v16, (s0)
        j       .LBB0_12
.LBB0_21:
        sub     a2, a2, a3
        slli    a4, a4, 1
        add     s0, s0, a4
        vsetvli zero, a2, e8, m1, ta, ma
        vand.vx v9, v19, a5
        vand.vx v10, v21, a5
        vand.vx v16, v23, a5
        vsrl.vi v18, v17, 4
        vmseq.vi        v0, v18, 12
        vssubu.vx       v18, v18, a7
        vmerge.vim      v18, v18, 3, v0
        vsll.vv v17, v17, v18
        vsrl.vv v17, v17, v18
        vwmulu.vv       v20, v10, v14
        vwaddu.wv       v20, v20, v16
        vwmulu.vv       v22, v17, v14
        vwaddu.wv       v22, v22, v9
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v24, v22, t0
        vwaddu.wv       v24, v24, v20
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v9, v18, t1
        vrsub.vi        v9, v9, 3
        vmul.vx v9, v9, t2
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v9, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v16, v0, x0
	vsetvli zero, zero, e32, m4, ta, ma
        vsrl.vv v16, v24, v16
        vsub.vx v20, v16, t3
        vsll.vi v24, v20, 6
        slli    a3, a2, 1
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a3, e16, m4, ta, ma
        vmerge.vvm      v20, v20, v24, v0
        vsetvli zero, a2, e32, m4, ta, mu
        vmsgtu.vx       v0, v16, s3
        vand.vx v20, v20, t6
        vor.vx  v16, v20, s4, v0.t
        vsll.vi v20, v16, 16
        vsrl.vi v16, v16, 16
        vor.vv  v16, v20, v16
        vsetvli zero, a3, e16, m4, ta, ma
        vmsne.vi        v9, v16, 0
        vmor.mm v9, v9, v8
        vcompress.vm    v20, v16, v9
        vcpop.m a2, v9
        vsetvli zero, a2, e16, m4, ta, ma
        vse16.v v20, (s0)
        j       .LBB0_12
.LBB0_22:
        li      a0, 0
        j       .LBB0_32
.LBB0_23:
        li      a1, 3
        beq     t4, a1, .LBB0_31
        lbu     a1, 0(a0)
        andi    a3, a1, 192
        addi    a1, a3, -128
        snez    a1, a1
        slli    a1, a1, 1
        add     a1, a1, s0
        addi    s0, a1, -2
        li      a2, 128
        li      a1, 3
        bne     a3, a2, .LBB0_28
        li      a1, 3
.LBB0_26:
        lbu     a3, -1(a0)
        addi    a0, a0, -1
        andi    a3, a3, 192
        addi    a1, a1, 1
        bne     a3, a2, .LBB0_28
        bltu    a1, t4, .LBB0_26
.LBB0_28:
        lhu     a2, -2(s0)
        srli    a2, a2, 10
        li      a3, 54
        bne     a2, a3, .LBB0_31
        addi    s0, s0, -2
        j       .LBB0_31
.LBB0_30:
        li      a1, 3
        mv      s0, a2
.LBB0_31:
        mv      a2, s0
        call    utf8_to_utf16_scalar
        seqz    a1, a0
        sub     a2, s0, s2
        srai    a2, a2, 1
        add     a0, a0, a2
        addi    a1, a1, -1
        and     a0, a0, a1
.LBB0_32:
        ld      ra, 88(sp)
        ld      s0, 80(sp)
        ld      s1, 72(sp)
        ld      s2, 64(sp)
        ld      s3, 56(sp)
        ld      s4, 48(sp)
        ld      s5, 40(sp)
        ld      s6, 32(sp)
        addi    sp, sp, 96
        ret

.data

utf8_to_utf16_rvv.err1m:
        .quad   144680345676153346
        .quad   5266116582681116800
utf8_to_utf16_rvv.err2m:
        .quad   -3761689263670582297
        .quad   -3761671395393942581
utf8_to_utf16_rvv.err3m:
        .quad   72340172838076673
        .quad   72340175954030310
