// Code generated using clang-20 from:
// https://github.com/camel-cdr/rvv-playground/blob/main/base64-encode.c

#if MX_N == 4

.global b64_encode_rvv_LUT64
b64_encode_rvv_LUT64:
        addi    sp, sp, -16
        sd      ra, 8(sp)
        sd      s0, 0(sp)
        vsetvli a6, zero, e8, m1, ta, ma
        slli    t5, a6, 2
        bgeu    a2, t5, .LBB0_3
        mv      a4, a0
.LBB0_2:
        sub     s0, a4, a0
        mv      a0, a4
        call    b64_encode_scalar
        add     a0, a0, s0
        ld      ra, 8(sp)
        ld      s0, 0(sp)
        addi    sp, sp, 16
        ret
.LBB0_3:
        vid.v   v24
        li      t3, 3
        lui     t2, 4128
        lui     a7, 96
        lui     t0, 128
        vsetvli zero, t5, e8, m4, ta, ma
        vid.v   v20
        li      a4, 64
        srli    t1, a6, 2
        addi    a7, a7, 10
        addi    t0, t0, 4
        vsetvli zero, a4, e8, m4, ta, ma
        vle8.v  v8, (a3)
        slli    t4, t1, 1
        vsetvli a4, zero, e32, m4, ta, ma
        vmv.v.x v12, a7
        slli    a4, t1, 3
        vmv.v.x v16, t0
        add     a7, t4, t1
        sub     t0, a4, t4
        add     t1, t1, a4
        li      t4, 63
        vsetvli zero, zero, e8, m1, ta, ma
        vsrl.vi v24, v24, 2
        addi    t2, t2, 1
        vsetvli zero, t5, e8, m4, ta, ma
        vand.vi v20, v20, 1
        vmsne.vi        v0, v20, 0
        vmv.v.x v20, t4
        vsetvli a4, zero, e8, m1, ta, ma
        vmul.vx v24, v24, t3
        vsetvli zero, a6, e32, m1, ta, ma
        vadd.vx v24, v24, t2
        slli    t2, a6, 1
        add     t2, t2, a6
        bgeu    t4, a6, .LBB0_9
        vsetvli a4, zero, e16, m2, ta, ma
        vid.v   v10
        lui     a4, 32769
        vsrl.vi v10, v10, 2
        slli    a4, a4, 21
        vmul.vx v10, v10, t3
        addi    a4, a4, 1
        vsetvli zero, a6, e64, m2, ta, ma
        vadd.vx v10, v10, a4
        li      t3, 257
        mv      a4, a0
        j       .LBB0_7
.LBB0_5:
        vrgather.vv     v28, v9, v24
        vrgather.vv     v29, v25, v24
        vrgather.vv     v30, v26, v24
        vrgather.vv     v31, v27, v24
.LBB0_6:
        vsetvli zero, t5, e16, m4, ta, ma
        vsrl.vv v4, v28, v12
        vsll.vv v28, v28, v16
        sub     a2, a2, t2
        add     a1, a1, t2
        vsetvli zero, t5, e8, m4, ta, ma
        vmerge.vvm      v28, v4, v28, v0
        vand.vv v28, v28, v20
        vsetvli a5, zero, e8, m1, ta, ma
        vrgather.vv     v4, v8, v28
        vrgather.vv     v5, v8, v29
        vrgather.vv     v6, v8, v30
        vrgather.vv     v7, v8, v31
        vsetvli zero, t5, e8, m4, ta, ma
        vse8.v  v4, (a4)
        add     a4, a4, t5
        bltu    a2, t5, .LBB0_2
.LBB0_7:
        vsetvli a5, zero, e8, m1, ta, ma
        vle8.v  v9, (a1)
        add     a5, a1, a7
        vle8.v  v25, (a5)
        add     a5, a1, t0
        vle8.v  v26, (a5)
        add     a5, a1, t1
        vle8.v  v27, (a5)
        bltu    a6, t3, .LBB0_5
        vrgatherei16.vv v28, v9, v10
        vrgatherei16.vv v29, v25, v10
        vrgatherei16.vv v30, v26, v10
        vrgatherei16.vv v31, v27, v10
        j       .LBB0_6
.LBB0_9:
        li      t3, 31
        vsetvli a4, zero, e8, m2, ta, ma
        mv      a4, a0
        j       .LBB0_11
.LBB0_10:
        vsetvli a5, zero, e8, m2, ta, ma
        vrgather.vv     v28, v8, v4
        vrgather.vv     v30, v8, v6
        vsetvli zero, t5, e8, m4, ta, ma
        vse8.v  v28, (a4)
        sub     a2, a2, t2
        add     a1, a1, t2
        add     a4, a4, t5
        bltu    a2, t5, .LBB0_2
.LBB0_11:
        vsetvli a5, zero, e8, m1, ta, ma
        vle8.v  v25, (a1)
        add     a5, a1, a7
        vle8.v  v26, (a5)
        add     a5, a1, t0
        vle8.v  v27, (a5)
        add     a5, a1, t1
        vle8.v  v28, (a5)
        vrgather.vv     v4, v25, v24
        vrgather.vv     v5, v26, v24
        vrgather.vv     v6, v27, v24
        vrgather.vv     v7, v28, v24
        vsetvli zero, t5, e16, m4, ta, ma
        vsrl.vv v28, v4, v12
        vsll.vv v4, v4, v16
        vsetvli zero, t5, e8, m4, ta, ma
        vmerge.vvm      v28, v28, v4, v0
        vand.vv v4, v28, v20
        bltu    t3, a6, .LBB0_10
        vrgather.vv     v28, v8, v4
        vsetvli zero, t5, e8, m4, ta, ma
        vse8.v  v28, (a4)
        sub     a2, a2, t2
        add     a1, a1, t2
        add     a4, a4, t5
        bgeu    a2, t5, .LBB0_11
        j       .LBB0_2

.global b64_encode_rvv_seg_LUT64
b64_encode_rvv_seg_LUT64:
        addi    sp, sp, -16
        sd      ra, 8(sp)
        sd      s0, 0(sp)
        vsetvli t0, zero, e8, m1, ta, ma
        slli    t1, t0, 2
        bgeu    a2, t1, .LBB1_2
        mv      a4, a0
        j       .LBB1_10
.LBB1_2:
        li      a6, 63
        li      a7, 64
        vsetvli zero, a7, e8, m4, ta, ma
        vle8.v  v8, (a3)
        vsetvli a4, zero, e8, m1, ta, ma
        vmv.v.x v12, a6
        slli    a6, t0, 1
        add     a6, a6, t0
        bltu    t0, a7, .LBB1_5
        li      a7, 4
        li      t0, 16
        mv      a4, a0
.LBB1_4:
        vlseg3e8.v      v9, (a1)
        sub     a2, a2, a6
        add     a1, a1, a6
        vand.vv v13, v11, v12
        vsrl.vi v11, v11, 6
        vsrl.vi v14, v10, 4
        vsrl.vi v15, v9, 2
        vmacc.vx        v11, a7, v10
        vmacc.vx        v14, t0, v9
        vrgather.vv     v16, v8, v15
        vand.vv v9, v11, v12
        vand.vv v10, v14, v12
        vrgather.vv     v17, v8, v10
        vrgather.vv     v18, v8, v9
        vrgather.vv     v19, v8, v13
        vsseg4e8.v      v16, (a4)
        add     a4, a4, t1
        bgeu    a2, t1, .LBB1_4
        j       .LBB1_10
.LBB1_5:
        li      a4, 31
        bgeu    a4, t0, .LBB1_8
        vsetvli a4, zero, e8, m2, ta, ma
        li      a7, 4
        li      t0, 16
        mv      a4, a0
.LBB1_7:
        vsetvli a5, zero, e8, m1, ta, ma
        vlseg3e8.v      v13, (a1)
        sub     a2, a2, a6
        add     a1, a1, a6
        vand.vv v11, v15, v12
        vsrl.vi v10, v15, 6
        vsrl.vi v15, v14, 4
        vmacc.vx        v10, a7, v14
        vmacc.vx        v15, t0, v13
        vand.vv v10, v10, v12
        vand.vv v17, v15, v12
        vsrl.vi v16, v13, 2
        vsetvli a5, zero, e8, m2, ta, ma
        vrgather.vv     v20, v8, v16
        vrgather.vv     v22, v8, v10
        vsetvli a5, zero, e8, m1, ta, ma
        vsseg4e8.v      v20, (a4)
        add     a4, a4, t1
        bgeu    a2, t1, .LBB1_7
        j       .LBB1_10
.LBB1_8:
        li      a7, 4
        li      t0, 16
        mv      a4, a0
.LBB1_9:
        vlseg3e8.v      v13, (a1)
        sub     a2, a2, a6
        add     a1, a1, a6
        vand.vv v19, v15, v12
        vsrl.vi v15, v15, 6
        vmacc.vx        v15, a7, v14
        vand.vv v18, v15, v12
        vsrl.vi v14, v14, 4
        vmacc.vx        v14, t0, v13
        vand.vv v17, v14, v12
        vsrl.vi v16, v13, 2
        vsetvli zero, t1, e8, m4, ta, ma
        vrgather.vv     v20, v8, v16
        vsetvli a5, zero, e8, m1, ta, ma
        vsseg4e8.v      v20, (a4)
        add     a4, a4, t1
        bgeu    a2, t1, .LBB1_9
.LBB1_10:
        sub     s0, a4, a0
        mv      a0, a4
        call    b64_encode_scalar
        add     a0, a0, s0
        ld      ra, 8(sp)
        ld      s0, 0(sp)
        addi    sp, sp, 16
        ret

.global b64_encode_rvv_LUT16
b64_encode_rvv_LUT16:
        addi    sp, sp, -16
        sd      ra, 8(sp)
        sd      s0, 0(sp)
        vsetvli t3, zero, e8, m1, ta, ma
        slli    t6, t3, 2
        bgeu    a2, t6, .LBB2_2
        mv      a4, a0
        j       .LBB2_7
.LBB2_2:
        li      t4, 3
        lui     a6, 96
        lui     a7, 128
        vsetvli zero, t6, e8, m4, ta, ma
        vid.v   v12
        li      t0, 63
        vsetivli        zero, 16, e8, m1, ta, ma
        vle8.v  v9, (a4)
        srli    t2, t3, 2
        slli    t1, t3, 1
        addi    a6, a6, 10
        addi    a7, a7, 4
        vsetvli zero, t6, e8, m4, ta, ma
        vand.vi v20, v12, 1
        vmv.v.x v12, t0
        slli    t0, t2, 1
        vsetvli a4, zero, e32, m4, ta, ma
        vmv.v.x v16, a6
        slli    t5, t2, 3
        vsetvli zero, t6, e8, m4, ta, ma
        vmsne.vi        v8, v20, 0
        vsetvli a4, zero, e32, m4, ta, ma
        vmv.v.x v20, a7
        add     a6, t0, t2
        sub     a7, t5, t0
        add     t0, t5, t2
        li      a4, 257
        add     t1, t1, t3
        bgeu    t3, a4, .LBB2_5
        vsetvli zero, zero, e8, m1, ta, ma
        vid.v   v10
        lui     a4, 4128
        li      t2, 51
        vsrl.vi v10, v10, 2
        addi    a4, a4, 1
        vmul.vx v10, v10, t4
        vsetvli zero, t3, e32, m1, ta, ma
        vadd.vx v10, v10, a4
        li      t3, 26
        mv      a4, a0
.LBB2_4:
        vsetvli a5, zero, e8, m1, ta, ma
        vmv1r.v v0, v8
        vle8.v  v11, (a1)
        add     a5, a1, a6
        vle8.v  v24, (a5)
        add     a5, a1, a7
        vle8.v  v25, (a5)
        add     a5, a1, t0
        sub     a2, a2, t1
        add     a1, a1, t1
        vle8.v  v26, (a5)
        vrgather.vv     v28, v11, v10
        vrgather.vv     v29, v24, v10
        vrgather.vv     v30, v25, v10
        vrgather.vv     v31, v26, v10
        vsetvli zero, t6, e16, m4, ta, ma
        vsrl.vv v24, v28, v16
        vsll.vv v28, v28, v20
        vsetvli zero, t6, e8, m4, ta, ma
        vmerge.vvm      v24, v24, v28, v0
        vand.vv v24, v24, v12
        vmsltu.vx       v0, v24, t3
        vssubu.vx       v28, v24, t2
        vmerge.vim      v28, v28, 13, v0
        vsetvli a5, zero, e8, m1, ta, ma
        vrgather.vv     v4, v9, v28
        vrgather.vv     v5, v9, v29
        vrgather.vv     v6, v9, v30
        vrgather.vv     v7, v9, v31
        vsetvli zero, t6, e8, m4, ta, ma
        vadd.vv v24, v24, v4
        vse8.v  v24, (a4)
        add     a4, a4, t6
        bgeu    a2, t6, .LBB2_4
        j       .LBB2_7
.LBB2_5:
        vsetvli zero, zero, e16, m2, ta, ma
        vid.v   v10
        lui     a4, 32769
        li      t2, 51
        vsrl.vi v10, v10, 2
        slli    a4, a4, 21
        vmul.vx v10, v10, t4
        addi    a4, a4, 1
        vsetvli zero, t3, e64, m2, ta, ma
        vadd.vx v10, v10, a4
        li      t3, 26
        mv      a4, a0
.LBB2_6:
        vsetvli a5, zero, e8, m1, ta, ma
        vmv1r.v v0, v8
        vle8.v  v24, (a1)
        add     a5, a1, a6
        vle8.v  v25, (a5)
        add     a5, a1, a7
        vle8.v  v26, (a5)
        add     a5, a1, t0
        sub     a2, a2, t1
        add     a1, a1, t1
        vle8.v  v27, (a5)
        vrgatherei16.vv v28, v24, v10
        vrgatherei16.vv v29, v25, v10
        vrgatherei16.vv v30, v26, v10
        vrgatherei16.vv v31, v27, v10
        vsetvli zero, t6, e16, m4, ta, ma
        vsrl.vv v24, v28, v16
        vsll.vv v28, v28, v20
        vsetvli zero, t6, e8, m4, ta, ma
        vmerge.vvm      v24, v24, v28, v0
        vand.vv v24, v24, v12
        vmsltu.vx       v0, v24, t3
        vssubu.vx       v28, v24, t2
        vmerge.vim      v28, v28, 13, v0
        vsetvli a5, zero, e8, m1, ta, ma
        vrgather.vv     v4, v9, v28
        vrgather.vv     v5, v9, v29
        vrgather.vv     v6, v9, v30
        vrgather.vv     v7, v9, v31
        vsetvli zero, t6, e8, m4, ta, ma
        vadd.vv v24, v24, v4
        vse8.v  v24, (a4)
        add     a4, a4, t6
        bgeu    a2, t6, .LBB2_6
.LBB2_7:
        sub     s0, a4, a0
        mv      a0, a4
        call    b64_encode_scalar
        add     a0, a0, s0
        ld      ra, 8(sp)
        ld      s0, 0(sp)
        addi    sp, sp, 16
        ret

.global b64_encode_rvv_seg_LUT16
b64_encode_rvv_seg_LUT16:
        addi    sp, sp, -16
        sd      ra, 8(sp)
        sd      s0, 0(sp)
        vsetvli a7, zero, e8, m1, ta, ma
        slli    t3, a7, 2
        bgeu    a2, t3, .LBB3_2
        mv      a4, a0
        j       .LBB3_4
.LBB3_2:
        li      t0, 63
        vsetivli        zero, 16, e8, m1, ta, ma
        vle8.v  v8, (a4)
        slli    t1, a7, 1
        li      a6, 4
        vsetvli a4, zero, e8, m1, ta, ma
        vmv.v.x v9, t0
        add     a7, a7, t1
        li      t0, 16
        li      t1, 51
        li      t2, 26
        mv      a4, a0
.LBB3_3:
        vlseg3e8.v      v10, (a1)
        sub     a2, a2, a7
        add     a1, a1, a7
        vand.vv v15, v12, v9
        vsrl.vi v12, v12, 6
        vsrl.vi v13, v11, 4
        vmacc.vx        v12, a6, v11
        vmacc.vx        v13, t0, v10
        vand.vv v14, v12, v9
        vand.vv v13, v13, v9
        vsrl.vi v12, v10, 2
        vsetvli zero, t3, e8, m4, ta, ma
        vmsltu.vx       v0, v12, t2
        vssubu.vx       v16, v12, t1
        vmerge.vim      v16, v16, 13, v0
        vsetvli a5, zero, e8, m1, ta, ma
        vrgather.vv     v20, v8, v16
        vrgather.vv     v21, v8, v17
        vrgather.vv     v22, v8, v18
        vrgather.vv     v23, v8, v19
        vsetvli zero, t3, e8, m4, ta, ma
        vadd.vv v12, v12, v20
        vsetvli a5, zero, e8, m1, ta, ma
        vsseg4e8.v      v12, (a4)
        add     a4, a4, t3
        bgeu    a2, t3, .LBB3_3
.LBB3_4:
        sub     s0, a4, a0
        mv      a0, a4
        call    b64_encode_scalar
        add     a0, a0, s0
        ld      ra, 8(sp)
        ld      s0, 0(sp)
        addi    sp, sp, 16
        ret

#endif

