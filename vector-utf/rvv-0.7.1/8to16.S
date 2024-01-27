
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
        li      a4, 3
        mv      a3, a1
        bgeu    a1, a4, .LBB0_2
        mv      a1, a3
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
        sd      s7, 24(sp)
        mv      s2, a2
        bne     a3, a4, .LBB0_4
        mv      s1, a3
        li      a1, 3
        j       .LBB0_9
.LBB0_4:
        li      a1, 3
        li      a2, 128
.LBB0_5:
        add     a4, a0, a1
        lbu     a4, 0(a4)
        andi    a4, a4, 192
        bne     a4, a2, .LBB0_8
        addi    a1, a1, 1
        bne     a3, a1, .LBB0_5
        mv      s1, a3
        mv      a1, a3
        li      a2, 6
        bgeu    a2, a3, .LBB0_9
        j       .LBB0_24
.LBB0_8:
        mv      s1, a3
        li      a2, 6
        bltu    a2, a1, .LBB0_24
.LBB0_9:
        addi    a2, sp, 4
        mv      s0, a0
        call    utf8_to_utf16_scalar
        mv      a1, a0
        beqz    a0, .LBB0_24
        mv      a0, s0
        addi    a1, s1, -3
        vsetvli a2, zero, e8, m2, ta, ma
        beqz    a1, .LBB0_32
        mv      t5, s1
	li a2, 4
	vsetvli        zero, a2, e32, m1, ta, ma
	la a2, utf8_to_utf16_rvv.err1m
	vle32.v v10, (a2)
	la a2, utf8_to_utf16_rvv.err2m
	vle32.v v11, (a2)
	la a2, utf8_to_utf16_rvv.err3m
	vle32.v v12, (a2)
        vsetvli a2, zero, e8, m2, ta, ma
        vid.v   v8
        vand.vi v8, v8, 1
        vmseq.vi        v13, v8, 0
        li      s7, 127
        li      s6, -33
        li      a7, -17
        li      s1, 63
        li      a6, -65
        li      s5, 64
        li      t0, 10
        lui     t1, 1
        li      t2, 2
        li      t3, 6
        lui     t4, 16
        lui     a2, 16368
        addi    t6, a2, 1023
        addi    s3, t4, -1
        lui     a2, 901134
        addi    s4, a2, -2048
        mv      s0, s2
        j       .LBB0_14
.LBB0_12:
	vsetvli zero, zero, e8, m2, ta, ma
	vwaddu.vx v16, v8, x0
	vsetvli zero, zero, e16, m4, ta, ma
        vse16.v v16, (s0)
        mv      a5, a3
.LBB0_13:
        sub     a1, a1, a3
        slli    a5, a5, 1
        add     s0, s0, a5
        beqz    a1, .LBB0_25
.LBB0_14:
        vsetvli a3, a1, e8, m2, ta, ma
        vle8.v  v8, (a0)
        vmsgtu.vx       v14, v8, s7
        vfirst.m        a2, v14
        add     a0, a0, a3
        bltz    a2, .LBB0_12
        lbu     a2, 0(a0)
        lbu     a4, 1(a0)
        lbu     a5, 2(a0)
        vslide1down.vx  v16, v8, a2
        vslide1down.vx  v18, v16, a4
        vslide1down.vx  v20, v18, a5
        vsetvli a2, zero, e16, m2, ta, ma
        vsrl.vi v14, v18, 4
        vsrl.vi v22, v20, 4
        vsetvli zero, a3, e8, m2, ta, ma
        vand.vi v24, v18, 15
        vand.vi v14, v14, 15
        vand.vi v22, v22, 15
        vsetvli a2, zero, e8, m1, ta, ma
        vrgather.vv     v26, v10, v14
        vrgather.vv     v27, v10, v15
        vrgather.vv     v14, v11, v24
        vrgather.vv     v15, v11, v25
        vrgather.vv     v24, v12, v22
        vrgather.vv     v25, v12, v23
        vsetvli zero, a3, e8, m2, ta, ma
        vand.vv v14, v26, v14
        vand.vv v14, v14, v24
        vmsgtu.vx       v23, v16, s6
        vmsgtu.vx       v22, v8, a7
        vmor.mm v23, v23, v22
        vmsgtu.vx       v24, v14, s7
        vmxor.mm        v23, v23, v24
        vmsgt.vi        v24, v14, 0
        vmor.mm v14, v24, v23
        vfirst.m        a2, v14
        bgez    a2, .LBB0_24
        vsrl.vi v14, v8, 6
        vmsne.vi        v23, v14, 2
        vcpop.m a5, v23
        vcompress.vm    v14, v8, v23
        vmsgtu.vx       v24, v8, s6
        vfirst.m        a2, v24
        vcompress.vm    v8, v16, v23
        bltz    a2, .LBB0_20
        vfirst.m        a2, v22
        vcompress.vm    v16, v18, v23
        bltz    a2, .LBB0_21
        vcompress.vm    v18, v20, v23
        vsetvli a4, a5, e8, m1, ta, ma
        vand.vx v8, v8, s1
        vand.vx v16, v16, s1
        vand.vx v18, v18, s1
        vsrl.vi v20, v14, 4
        vmseq.vi        v0, v20, 12
        vssubu.vx       v20, v20, t0
        vmerge.vim      v20, v20, 3, v0
        vsll.vv v14, v14, v20
        vsrl.vv v14, v14, v20
        vwmulu.vx       v22, v16, s5
        vwaddu.wv       v22, v22, v18
        vwmulu.vx       v24, v14, s5
        vwaddu.wv       v24, v24, v8
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v28, v24, t1
        vwaddu.wv       v28, v28, v22
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v8, v20, t2
        vrsub.vi        v8, v8, 3
        vmul.vx v8, v8, t3
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v8, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v20, v0, x0
	vsetvli zero, zero, e32, m4, ta, mu
        vsrl.vv v20, v28, v20
        vsub.vx v24, v20, t4
        vsll.vi v28, v24, 16
        vsrl.vi v24, v24, 10
        vor.vv  v24, v28, v24
        vmsgtu.vx       v0, v20, s3
        vand.vx v24, v24, t6
        vor.vx  v20, v24, s4, v0.t
        slli    a2, a4, 1
        vsetvli zero, a2, e16, m4, ta, ma
        vmsne.vi        v8, v20, 0
        vmor.mm v8, v8, v13
        vcompress.vm    v24, v20, v8
        vcpop.m a2, v8
        vsetvli zero, a2, e16, m4, ta, ma
        vse16.v v24, (s0)
        bne     a5, a4, .LBB0_22
        mv      a5, a2
        j       .LBB0_13
.LBB0_20:
        vsetvli zero, a5, e8, m2, ta, mu
        vmsgtu.vx       v0, v14, a6
        vand.vx v8, v8, s1
        vand.vx v14, v14, s1, v0.t
        vmv.v.i v16, 1
        vmerge.vxm      v16, v16, s5, v0
        vwmulu.vv       v20, v14, v16
        vwaddu.wv       v20, v20, v8, v0.t
	vsetvli zero, a5, e16, m4, ta, ma
        j       .LBB0_23
.LBB0_21:
        vsetvli zero, a5, e8, m2, ta, mu
        vand.vx v18, v8, s1
        vand.vx v16, v16, s1
        vmsgtu.vx       v8, v14, a6
        vmsgtu.vx       v9, v14, s6
	vmv.v.v v20, v14
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a5, e8, m2, ta, mu
        vand.vx v20, v14, s1, v0.t
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a5, e8, m2, ta, mu
        vand.vi v20, v14, 15, v0.t
        vmv.v.i v14, 1
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v8
	vsetvli zero, a5, e8, m2, ta, mu
        vmerge.vxm      v14, v14, s5, v0
        vwmulu.vv       v24, v20, v14
        vwaddu.wv       v24, v24, v18, v0.t
        vsetvli zero, zero, e16, m4, ta, mu
	vsetvli zero, zero, e8, m1, ta, ma
	vmv.v.v v0, v9
	vsetvli zero, a5, e16, m4, ta, mu
	vmv.v.v v20, v24
        vsll.vi v20, v24, 6, v0.t
        vsetvli zero, zero, e8, m2, ta, mu
        vwaddu.wv       v24, v20, v16, v0.t
	vsetvli zero, zero, e16, m4, ta, mu
        vse16.v v24, (s0)
        j       .LBB0_13
.LBB0_22:
        sub     a5, a5, a4
        slli    a2, a2, 1
        add     s0, s0, a2
        vsetvli zero, a5, e8, m1, ta, ma
        vand.vx v8, v9, s1
        vand.vx v9, v17, s1
        vand.vx v14, v19, s1
        vsrl.vi v16, v15, 4
        vmseq.vi        v0, v16, 12
        vssubu.vx       v16, v16, t0
        vmerge.vim      v16, v16, 3, v0
        vsll.vv v15, v15, v16
        vsrl.vv v15, v15, v16
        vwmulu.vx       v18, v9, s5
        vwaddu.wv       v18, v18, v14
        vwmulu.vx       v20, v15, s5
        vwaddu.wv       v20, v20, v8
        vsetvli zero, zero, e16, m2, ta, ma
        vwmulu.vx       v24, v20, t1
        vwaddu.wv       v24, v24, v18
        vsetvli zero, zero, e8, m1, ta, ma
        vssubu.vx       v8, v16, t2
        vrsub.vi        v8, v8, 3
        vmul.vx v8, v8, t3
        vsetvli zero, zero, e32, m4, ta, mu
	vsetvli zero, zero, e8, m1, ta, ma
	vwaddu.vx v0, v8, x0
	vsetvli zero, zero, e16, m2, ta, ma
	vwaddu.vx v16, v0, x0
	vsetvli zero, zero, e32, m4, ta, mu
        vsrl.vv v16, v24, v16
        vsub.vx v20, v16, t4
        vsll.vi v24, v20, 16
        vsrl.vi v20, v20, 10
        vor.vv  v20, v24, v20
        vmsgtu.vx       v0, v16, s3
        vand.vx v20, v20, t6
        vor.vx  v16, v20, s4, v0.t
        slli    a5, a5, 1
        vsetvli zero, a5, e16, m4, ta, ma
        vmsne.vi        v8, v16, 0
        vmor.mm v8, v8, v13
        vcompress.vm    v20, v16, v8
        vcpop.m a5, v8
        vsetvli zero, a5, e16, m4, ta, ma
.LBB0_23:
        vse16.v v20, (s0)
        j       .LBB0_13
.LBB0_24:
        li      a0, 0
        j       .LBB0_34
.LBB0_25:
        li      a1, 3
        beq     t5, a1, .LBB0_33
        lbu     a1, 0(a0)
        andi    a3, a1, 192
        addi    a1, a3, -128
        snez    a1, a1
        addi    a1, a1, -1
        andi    a1, a1, -2
        add     s0, s0, a1
        li      a2, 128
        li      a1, 3
        bne     a3, a2, .LBB0_30
        li      a1, 3
.LBB0_28:
        lbu     a3, -1(a0)
        addi    a0, a0, -1
        andi    a3, a3, 192
        addi    a1, a1, 1
        bne     a3, a2, .LBB0_30
        bltu    a1, t5, .LBB0_28
.LBB0_30:
        lhu     a2, -2(s0)
        srli    a2, a2, 10
        li      a3, 54
        bne     a2, a3, .LBB0_33
        addi    s0, s0, -2
        j       .LBB0_33
.LBB0_32:
        li      a1, 3
        mv      s0, s2
.LBB0_33:
        mv      a2, s0
        call    utf8_to_utf16_scalar
        seqz    a1, a0
        sub     a2, s0, s2
        srai    a2, a2, 1
        add     a0, a0, a2
        addi    a1, a1, -1
        and     a0, a0, a1
.LBB0_34:
        ld      ra, 88(sp)
        ld      s0, 80(sp)
        ld      s1, 72(sp)
        ld      s2, 64(sp)
        ld      s3, 56(sp)
        ld      s4, 48(sp)
        ld      s5, 40(sp)
        ld      s6, 32(sp)
        ld      s7, 24(sp)
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

