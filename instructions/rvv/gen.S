#define VL s3

#define t7 a6
#define t8 a7

#if __riscv_xlen == 32
#define IF64(...)
#define lx lw
#define sx sw
#else
#define IF64(...) __VA_ARGS__
#define lx ld
#define sx sd
#endif

#if __riscv_flen == 64
#define IF_F64(...) __VA_ARGS__
#else
#define IF_F64(...)
#endif

#if __riscv_v_elen_fp == 64
#define IF_VF64(...) __VA_ARGS__
#else
#define IF_VF64(...)
#endif

#include "config.h"

changecom(`#', `')

.macro m_nop
.endm

define(`m_mask',
	`m_$1($2, shift(shift($*)))
	m_$1( $2`'m, shift(shift($*)), v0.t)')

define(`m_bench_vx',
	`m_mask($1, bench_$3`'vv, $2, m_nop, $3.vv, v8, v16, v24)
	m_mask( $1, bench_$3`'vx, $2, m_nop, $3.vx, v8, v16, t0)')

define(`m_bench_xv',
	`m_mask($1, bench_$3`'vv, $2, m_nop, $3.vv, v8, v16, v24)
	m_mask( $1, bench_$3`'vx, $2, m_nop, $3.vx, v8, t0,  v16)')

define(`m_bench_xi',
	`m_mask($1, bench_$3`'vx, $2, m_nop, $3.vx, v8, v16, t0)
	m_mask( $1, bench_$3`'vi, $2, m_nop, $3.vi, v8, v16, 13)')

define(`m_bench_xi',
	`m_mask($1, bench_$3`'vx, $2, m_nop, $3.vx, v8, v16, t0)
	m_mask( $1, bench_$3`'vi, $2, m_nop, $3.vi, v8, v16, 13)')

define(`m_bench_vxi',
	`m_mask($1, bench_$3`'vv, $2, m_nop, $3.vv, v8, v16, v24)
	m_mask( $1, bench_$3`'vx, $2, m_nop, $3.vx, v8, v16, t0)
	m_mask( $1, bench_$3`'vi, $2, m_nop, $3.vi, v8, v16, 13)')

define(`m_bench_vxm',
	`m_$1(bench_$3`'vvm, $2, m_nop, $3.vvm, v8, v16, v24, v0)
	 m_$1(bench_$3`'vxm, $2, m_nop, $3.vxm, v8, v16, t0, v0)')

define(`m_bench_vxim',
	`m_$1(bench_$3`'vvm, $2, m_nop, $3.vvm, v8, v16, v24, v0)
	 m_$1(bench_$3`'vxm, $2, m_nop, $3.vxm, v8, v16, t0, v0)
	 m_$1(bench_$3`'vim, $2, m_nop, $3.vim, v8, v16, 13, v0)')

define(`m_bench_vf',
	`m_mask($1, bench_$3`'vv, $2, m_nop, $3.vv, v8, v16, v24)
	m_mask( $1, bench_$3`'vf, $2, m_nop, $3.vf, v8, v16, ft0)')

define(`m_bench_fv',
	`m_mask($1, bench_$3`'vv, $2, m_nop, $3.vv, v8, v16, v24)
	m_mask( $1, bench_$3`'vf, $2, m_nop, $3.vf, v8, ft0, v16)')

define(`m_bench_wx',
	`m_mask($1, bench_$3`'wv, $2, m_nop, $3.wv, v8, v16, v24)
	m_mask( $1, bench_$3`'wx, $2, m_nop, $3.wx, v8, v16, t0)')

define(`m_bench_wf',
	`m_mask($1, bench_$3`'wv, $2, m_nop, $3.wv, v8, v16, v24)
	m_mask( $1, bench_$3`'wf, $2, m_nop, $3.wf, v8, v16, ft0)')

define(`m_bench_wxi',
	`m_mask($1, bench_$3`'wv, $2, m_nop, $3.wv, v8, v16, v24)
	m_mask( $1, bench_$3`'wx, $2, m_nop, $3.wx, v8, v16, t0)
	m_mask( $1, bench_$3`'wi, $2, m_nop, $3.wi, v8, v16, 13)')

define(`m_loadff',
	`m_mask($1, bench_vl$3`'8ffv,  $2`'8,  m_mem8,  vl$3`'8ff.v,  shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'16ffv, $2`'16, m_mem16, vl$3`'16ff.v, shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'32ffv, $2`'32, m_mem32, vl$3`'32ff.v, shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'64ffv, $2`'64, m_mem64, vl$3`'64ff.v, shift(shift(shift($*))))')

define(`m_loadstore',
	`m_mask($1, bench_vl$3`'8v,  $2`'8,  m_mem8,  vl$3`'8.v,  shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'16v, $2`'16, m_mem16, vl$3`'16.v, shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'32v, $2`'32, m_mem32, vl$3`'32.v, shift(shift(shift($*))))
	m_mask( $1, bench_vl$3`'64v, $2`'64, m_mem64, vl$3`'64.v, shift(shift(shift($*))))
	m_mask( $1, bench_vs$3`'8v,  $2`'8,  m_mem8,  vs$3`'8.v,  shift(shift(shift($*))))
	m_mask( $1, bench_vs$3`'16v, $2`'16, m_mem16, vs$3`'16.v, shift(shift(shift($*))))
	m_mask( $1, bench_vs$3`'32v, $2`'32, m_mem32, vs$3`'32.v, shift(shift(shift($*))))
	m_mask( $1, bench_vs$3`'64v, $2`'64, m_mem64, vs$3`'64.v, shift(shift(shift($*))))')


.macro m_1bit
	vid.v v0
	remu t0, t0, VL
	vmseq.vx v8, v0, t0
.endm

.macro m_mod_v24_e8_vl
	csrr t8, vtype
	vsetvli t0, x0, e8, m8, ta, ma
	vremu.vx v24, v24, VL
	vsetvl x0, VL, t8
.endm

.macro m_mod_v24_e16_vl
	csrr t8, vtype
	vsetvli t0, x0, e16, m8, ta, ma
	vremu.vx v24, v24, VL
	vsetvl x0, VL, t8
.endm

.macro m_mod_t0_vl
	remu t0, t0, VL
.endm

/* we want to roughly access the memory range of vlenb*8*4 */
.macro m_mem shift
	csrr t8, vlenb
	la t1, aligned
	ld t1, (t1) /* index base */

	slli t7, t8, 4
	addi t7, t7, -1
	and t0, t0, t7
	add t0, t0, t1 /* unit-stride base */

	slli t7, t8, 3
	addi t7, t7, -1
	and t2, t2, t7
	add t2, t2, t1   /* strided base */
	li t3, 3<<\shift /* strided stride */

	srli t0, t0, \shift
	slli t0, t0, \shift

	srli t2, t2, \shift
	slli t2, t2, \shift
.endm

.macro m_mem8
	m_mem 0
.endm
.macro m_mem16
	m_mem 1
.endm
.macro m_mem32
	m_mem 2
.endm
.macro m_mem64
	m_mem 3
.endm


.macro m_unimpl
	li a0, -1
	ret
.endm

define(`m_ifmx_t', `m_$3(shift(shift(shift($*))))')
define(`m_ifmx_f', `m_$3($4, 0, m_nop, m_unimpl)')
define(`m_ifmx_lmul_to_i', `ifelse(regexp($1,f), -1, $1, 0)')
define(`m_ifmx',`ifelse(eval($1 <= m_ifmx_lmul_to_i(m_LMUL) && $2 >= m_ifmx_lmul_to_i(m_LMUL)),1,`m_ifmx_t($*)',`m_ifmx_f($*)')')

/* calls $1 with: name type setup code:vararg */
define(`m_bench_all',`
	m_$1(bench_add, T_A, m_nop, add, t0, t1, t2)

	m_$1(bench_mul, T_A, m_nop, mul, t0, t1, t2)
	m_bench_vxi($1, T_A, vadd)
	m_bench_vx($1,  T_A, vsub)
	m_bench_xi($1,  T_A, vrsub)
	m_bench_vx($1,  T_A, vminu)
	m_bench_vx($1,  T_A, vmin)
	m_bench_vx($1,  T_A, vmaxu)
	m_bench_vx($1,  T_A, vmax)
	m_bench_vxi($1, T_A, vand)
	m_bench_vxi($1, T_A, vor)
	m_bench_vxi($1, T_A, vxor)

	m_mask($1, bench_vrgathervv,     T_A,  m_mod_v24_e8_vl,  vrgather.vv,     v8, v16, v24)
	m_mask($1, bench_vrgathervx,     T_A,  m_mod_t0_vl,      vrgather.vx,     v8, v16, t0)
	m_mask($1, bench_vrgathervi,     T_A,  m_nop,            vrgather.vi,     v8, v16, 3)
	m_mask($1, bench_vslideupvx,     T_A,  m_mod_t0_vl,      vslideup.vx,     v8, v16, t0)
	m_mask($1, bench_vslideupvi,     T_A,  m_nop,            vslideup.vi,     v8, v16, 3)
	m_mask($1, bench_vrgatherei16vv, T_ei16, m_mod_v24_e16_vl, vrgatherei16.vv, v8, v16, v24)

	m_mask($1, bench_vslidedownvx, T_A, m_mod_t0_vl,  vslidedown.vx, v8, v16, t0)
	m_mask($1, bench_vslidedownvi, T_A, m_nop,        vslidedown.vi, v8, v16, 3)

	m_mask($1, bench_vredsumvs,  T_A, m_nop, vredsum.vs,  v8, v16, v24)
	m_mask($1, bench_vredandvs,  T_A, m_nop, vredand.vs,  v8, v16, v24)
	m_mask($1, bench_vredorvs,   T_A, m_nop, vredor.vs,   v8, v16, v24)
	m_mask($1, bench_vredxorvs,  T_A, m_nop, vredxor.vs,  v8, v16, v24)
	m_mask($1, bench_vredminuvs, T_A, m_nop, vredminu.vs, v8, v16, v24)
	m_mask($1, bench_vredminvs,  T_A, m_nop, vredmin.vs,  v8, v16, v24)
	m_mask($1, bench_vredmaxuvs, T_A, m_nop, vredmaxu.vs, v8, v16, v24)
	m_mask($1, bench_vredmaxvs,  T_A, m_nop, vredmax.vs,  v8, v16, v24)

	m_bench_vx($1, T_A, vaaddu)
	m_bench_vx($1, T_A, vaadd)
	m_bench_vx($1, T_A, vasubu)
	m_bench_vx($1, T_A, vasub)

	m_mask($1, bench_vslide1upvx,   T_A, m_nop, vslide1up.vx,   v8, v16, t0)
	m_mask($1, bench_vslide1downvx, T_A, m_nop, vslide1down.vx, v8, v16, t0)

	m_bench_vxim($1, T_A, vadc)
	m_bench_vxim($1, T_A, vmadc)
	m_$1(bench_vmadcvv, T_A, m_nop, vmadc.vv, v8, v16, v24)
	m_$1(bench_vmadcvx, T_A, m_nop, vmadc.vx, v8, v16, t0)
	m_$1(bench_vmadcvi, T_A, m_nop, vmadc.vi, v8, v16, 13)
	m_bench_vxm($1,  T_A, vsbc)
	m_bench_vxm($1,  T_A, vmsbc)
	m_$1(bench_vmsbcvv, T_A, m_nop, vmsbc.vv, v8, v16, v24)
	m_$1(bench_vmsbcvx, T_A, m_nop, vmsbc.vx, v8, v16, t0)

	m_bench_vxim($1, T_A, vmerge)
	m_$1(bench_vmvvv, T_A, m_nop, vmv.v.v, v8, v16)
	m_$1(bench_vmvvx, T_A, m_nop, vmv.v.x, v8, t0)
	m_$1(bench_vmvvi, T_A, m_nop, vmv.v.i, v8, 13)
	m_bench_vxi($1, T_A, vmseq)
	m_bench_vxi($1, T_A, vmsne)
	m_bench_vx($1,  T_A, vmsltu)
	m_bench_vx($1,  T_A, vmslt)
	m_bench_vxi($1, T_A, vmsleu)
	m_bench_vxi($1, T_A, vmsle)
	m_bench_xi($1,  T_A, vmsgtu)
	m_bench_xi($1,  T_A, vmsgt)

	m_$1(bench_vcompressvm, T_A, m_nop, vcompress.vm, v8, v16, v24)

	m_$1(bench_vmandnmm, T_m1, m_nop, vmandn.mm, v8, v16, v24)
	m_$1(bench_vmandmm,  T_m1, m_nop, vmand.mm,  v8, v16, v24)
	m_$1(bench_vmormm,   T_m1, m_nop, vmor.mm,   v8, v16, v24)
	m_$1(bench_vmxormm,  T_m1, m_nop, vmxor.mm,  v8, v16, v24)
	m_$1(bench_vmornmm,  T_m1, m_nop, vmorn.mm,  v8, v16, v24)
	m_$1(bench_vmnandmm, T_m1, m_nop, vmnand.mm, v8, v16, v24)
	m_$1(bench_vmnormm,  T_m1, m_nop, vmnor.mm,  v8, v16, v24)
	m_$1(bench_vmxnormm, T_m1, m_nop, vmxnor.mm, v8, v16, v24)

	m_bench_vxi($1, T_A, vsaddu)
	m_bench_vxi($1, T_A, vsadd)
	m_bench_vx($1,  T_A, vssubu)
	m_bench_vx($1,  T_A, vssub)
	m_bench_vxi($1, T_A, vsll)
	m_bench_vx($1,  T_A, vsmul)
	m_ifmx(1,8,$1, bench_vmv1rv, T_A, m_nop, vmv1r.v, v8, v16)
	m_ifmx(2,8,$1, bench_vmv2rv, T_A, m_nop, vmv2r.v, v8, v16)
	m_ifmx(4,8,$1, bench_vmv4rv, T_A, m_nop, vmv4r.v, v8, v16)
	m_ifmx(8,8,$1, bench_vmv8rv, T_A, m_nop, vmv8r.v, v8, v16)
	m_bench_vxi($1, T_A, vsrl)
	m_bench_vxi($1, T_A, vsra)
	m_bench_vxi($1, T_A, vssrl)

	m_bench_vx($1, T_A, vdivu)
	m_bench_vx($1, T_A, vdiv)
	m_bench_vx($1, T_A, vremu)
	m_bench_vx($1, T_A, vrem)
	m_bench_vx($1, T_A, vmulhu)
	m_bench_vx($1, T_A, vmul)
	m_bench_vx($1, T_A, vmulhsu)
	m_bench_vx($1, T_A, vmulh)
	m_bench_xv($1, T_A, vmadd)
	m_bench_xv($1, T_A, vmacc)

	m_bench_wxi($1, T_N, vnsrl)
	m_bench_wxi($1, T_N, vnsra)
	m_bench_wxi($1, T_N, vnclipu)
	m_bench_wxi($1, T_N, vnclip)
	m_bench_xv($1,  T_N, vnmsub)
	m_bench_xv($1,  T_N, vnmsac)

	m_bench_vx($1, T_W, vwaddu)
	m_bench_vx($1, T_W, vwadd)
	m_bench_vx($1, T_W, vwsubu)
	m_bench_vx($1, T_W, vwsub)
	m_bench_wx($1, T_W, vwaddu)
	m_bench_wx($1, T_W, vwadd)
	m_bench_wx($1, T_W, vwsubu)
	m_bench_wx($1, T_W, vwsub)
	m_bench_vx($1, T_W, vwmulu)
	m_bench_vx($1, T_W, vwmulsu)
	m_bench_vx($1, T_W, vwmul)
	m_bench_xv($1, T_W, vwmaccu)
	m_bench_xv($1, T_W, vwmacc)
	m_bench_xv($1, T_W, vwmaccsu)
	m_mask($1, bench_vwmaccusvx,  T_W, m_nop, vwmaccus.vx,  v8, t0, v16)

	m_bench_vf($1, T_F, vfadd)
	m_bench_vf($1, T_F, vfsub)
	m_bench_vf($1, T_F, vfmin)
	m_bench_vf($1, T_F, vfmax)
	m_bench_vf($1, T_F, vfsgnj)
	m_bench_vf($1, T_F, vfsgnjn)
	m_bench_vf($1, T_F, vfsgnjx)
	m_mask($1, bench_vfslide1upvf,   T_F, m_nop, vfslide1up.vf,   v8, v16, ft0)
	m_mask($1, bench_vfslide1downvf, T_F, m_nop, vfslide1down.vf, v8, v16, ft0)

	m_mask($1, bench_vfredusumvs, T_F, m_nop, vfredusum.vs, v8, v16, v24)
	m_mask($1, bench_vfredosumvs, T_F, m_nop, vfredosum.vs, v8, v16, v24)
	m_mask($1, bench_vfredminvs,  T_F, m_nop, vfredmin.vs,  v8, v16, v24)
	m_mask($1, bench_vfredmaxvs,  T_F, m_nop, vfredmax.vs,  v8, v16, v24)

	m_$1(bench_vfmergevfm, T_F, m_nop, vfmerge.vfm, v8,  v16, ft0, v0)
	m_$1(bench_vfmvvf,     T_F, m_nop, vfmv.v.f,    v8,  ft0)

	m_bench_vf($1, T_F, vmfeq)
	m_bench_vf($1, T_F, vmfle)
	m_bench_vf($1, T_F, vmflt)
	m_bench_vf($1, T_F, vmfne)
	m_bench_vf($1, T_F, vmfgt)
	m_bench_vf($1, T_F, vmfge)

	m_bench_vf($1, T_F, vfdiv)
	m_mask($1, bench_vfrdivvf, T_F, m_nop, vfrdiv.vf, v8, v16, ft0)
	m_bench_vf($1, T_F, vfmul)
	m_mask($1, bench_vfrsubvf, T_F, m_nop, vfrsub.vf, v8, v16, ft0)
	m_bench_fv($1, T_F, vfmadd)
	m_bench_fv($1, T_F, vfmsub)
	m_bench_fv($1, T_F, vfmacc)
	m_bench_fv($1, T_F, vfmsac)

	m_bench_fv($1, T_FN, vfnmsac)
	m_bench_fv($1, T_FN, vfnmacc)
	m_bench_fv($1, T_FN, vfnmsub)
	m_bench_fv($1, T_FN, vfnmadd)

	m_mask($1, bench_vwredsumuvs, T_WR, m_nop, vwredsumu.vs, v8, v16, v24)
	m_mask($1, bench_vwredsumvs,  T_WR, m_nop, vwredsum.vs,  v8, v16, v24)

	m_bench_vf($1, T_FW, vfwadd)
	m_bench_vf($1, T_FW, vfwsub)
	m_bench_wf($1, T_FW, vfwadd)
	m_bench_wf($1, T_FW, vfwsub)
	m_bench_vf($1, T_FW, vfwmul)
	m_bench_fv($1, T_FW, vfwmacc)
	m_bench_fv($1, T_FW, vfwnmacc)
	m_bench_fv($1, T_FW, vfwmsac)
	m_bench_fv($1, T_FW, vfwnmsac)

	m_mask($1, bench_vfwredosumvs, T_FWR, m_nop, vfwredosum.vs, v8, v16, v24)
	m_mask($1, bench_vfwredusumvs, T_FWR, m_nop, vfwredusum.vs, v8, v16, v24)

	m_$1(bench_vmvsx, T_A, m_nop, vmv.s.x, v8, t0)
	m_$1(bench_vmvxs, T_A, m_nop, vmv.x.s, t0, v8)

	m_mask($1, bench_vcpopm,   T_m1,  m_nop,  vcpop.m,   t0, v8)
	m_mask($1, bench_vfirstm,  T_m1,  m_1bit, vfirst.m,  t0, v8)
	m_mask($1, bench_vzextvf2, T_VF2, m_1bit, vzext.vf2, v8, v16)
	m_mask($1, bench_vsextvf2, T_VF2, m_1bit, vsext.vf2, v8, v16)
	m_mask($1, bench_vzextvf4, T_VF4, m_1bit, vzext.vf4, v8, v16)
	m_mask($1, bench_vsextvf4, T_VF4, m_1bit, vsext.vf4, v8, v16)
	m_mask($1, bench_vzextvf8, T_VF8, m_1bit, vzext.vf8, v8, v16)
	m_mask($1, bench_vsextvf8, T_VF8, m_1bit, vsext.vf8, v8, v16)

	m_$1(bench_vfmvfs, T_F, m_nop, vfmv.f.s, ft0, v8)
	m_$1(bench_vfmvsf, T_F, m_nop, vfmv.s.f, v8,  ft0)

	m_mask($1, bench_vfcvtxufv,    T_F, m_nop, vfcvt.xu.f.v,     v8, v16)
	m_mask($1, bench_vfcvtxfv,     T_F, m_nop, vfcvt.x.f.v,      v8, v16)
	m_mask($1, bench_vfcvtfxuv,    T_F, m_nop, vfcvt.f.xu.v,     v8, v16)
	m_mask($1, bench_vfcvtfxv,     T_F, m_nop, vfcvt.f.x.v,      v8, v16)
	m_mask($1, bench_vfcvtrtzxfv,  T_F, m_nop, vfcvt.rtz.x.f.v,  v8, v16)
	m_mask($1, bench_vfcvtrtzxufv, T_F, m_nop, vfcvt.rtz.xu.f.v, v8, v16)

	m_mask($1, bench_vfwcvtxufv,    T_FW, m_nop, vfwcvt.xu.f.v,     v8, v16)
	m_mask($1, bench_vfwcvtxfv,     T_FW, m_nop, vfwcvt.x.f.v,      v8, v16)
	m_mask($1, bench_vfwcvtfxuv,    T_FW, m_nop, vfwcvt.f.xu.v,     v8, v16)
	m_mask($1, bench_vfwcvtfxv,     T_FW, m_nop, vfwcvt.f.x.v,      v8, v16)
	m_mask($1, bench_vfwcvtffv,     T_FW, m_nop, vfwcvt.f.f.v,      v8, v16)
	m_mask($1, bench_vfwcvtrtzxufv, T_FW, m_nop, vfwcvt.rtz.xu.f.v, v8, v16)
	m_mask($1, bench_vfwcvtrtzxfv,  T_FW, m_nop, vfwcvt.rtz.x.f.v,  v8, v16)

	m_mask($1, bench_vfncvtxufw,       T_FN, m_nop, vfncvt.xu.f.w,     v8, v16)
	m_mask($1, bench_vfncvtxfw,        T_FN, m_nop, vfncvt.x.f.w,      v8, v16)
	m_mask($1, bench_vfncvtfxuw,       T_FN, m_nop, vfncvt.f.xu.w,     v8, v16)
	m_mask($1, bench_vfncvtfxw,        T_FN, m_nop, vfncvt.f.x.w,      v8, v16)
	m_mask($1, bench_vfncvtffw,        T_FN, m_nop, vfncvt.f.f.w,      v8, v16)
	m_mask($1, bench_vfncvtrtzxfw,     T_FN, m_nop, vfncvt.rtz.x.f.w,  v8, v16)
	m_mask($1, bench_vfncvtrtzxufw,    T_FN, m_nop, vfncvt.rtz.xu.f.w, v8, v16)
	m_mask($1, bench_vfncvt.rod.f.f.w, T_FN, m_nop, vfncvt.rod.f.f.w,  v8, v16)

	m_mask($1, bench_vfsqrtv,   T_F, m_nop, vfsqrt.v,   v8, v16)
	m_mask($1, bench_vfrsqrt7v, T_F, m_nop, vfrsqrt7.v, v8, v16)
	m_mask($1, bench_vfrec7v,   T_F, m_nop, vfrec7.v,   v8, v16)
	m_mask($1, bench_vfclassv,  T_F, m_nop, vfclass.v,  v8, v16)

	m_mask($1, bench_vmsbfm,   T_A, m_1bit, vmsbf.m,   v8, v16)
	m_mask($1, bench_vmsofm,   T_A, m_1bit, vmsof.m,   v8, v16)
	m_mask($1, bench_vmsifm,   T_A, m_1bit, vmsif.m,   v8, v16)
	m_mask($1, bench_viotam,   T_A, m_nop,  viota.m,   v8, v16)
	m_mask($1, bench_vidv,     T_A, m_nop,  vid.v,     v8)


	m_loadstore($1, T_E, e, v8, (t0))
	m_loadff(   $1, T_E, e, v8, (t0))

	m_$1(bench_vlm, T_E8, m_mem8, vlm.v, v8, (t0))
	m_$1(bench_vsm, T_E8, m_mem8, vsm.v, v8, (t0))

	m_loadstore($1, T_E, se, v8, (t2), t3)

	m_loadstore($1, (T_A>> 4)&T_E, seg2e, v8, (t0))
	m_loadstore($1, (T_A>> 8)&T_E, seg3e, v8, (t0))
	m_loadstore($1, (T_A>> 8)&T_E, seg4e, v8, (t0))
	m_loadstore($1, (T_A>>12)&T_E, seg5e, v8, (t0))
	m_loadstore($1, (T_A>>12)&T_E, seg6e, v8, (t0))
	m_loadstore($1, (T_A>>12)&T_E, seg7e, v8, (t0))
	m_loadstore($1, (T_A>>12)&T_E, seg8e, v8, (t0))

	m_loadff(   $1, (T_A>> 4)&T_E, seg2e, v8, (t0))
	m_loadff(   $1, (T_A>> 8)&T_E, seg3e, v8, (t0))
	m_loadff(   $1, (T_A>> 8)&T_E, seg4e, v8, (t0))
	m_loadff(   $1, (T_A>>12)&T_E, seg5e, v8, (t0))
	m_loadff(   $1, (T_A>>12)&T_E, seg6e, v8, (t0))
	m_loadff(   $1, (T_A>>12)&T_E, seg7e, v8, (t0))
	m_loadff(   $1, (T_A>>12)&T_E, seg8e, v8, (t0))

	m_loadstore($1, (T_A>> 4)&T_E, sseg2e, v8, (t2), t3)
	m_loadstore($1, (T_A>> 8)&T_E, sseg3e, v8, (t2), t3)
	m_loadstore($1, (T_A>> 8)&T_E, sseg4e, v8, (t2), t3)
	m_loadstore($1, (T_A>>12)&T_E, sseg5e, v8, (t2), t3)
	m_loadstore($1, (T_A>>12)&T_E, sseg6e, v8, (t2), t3)
	m_loadstore($1, (T_A>>12)&T_E, sseg7e, v8, (t2), t3)
	m_loadstore($1, (T_A>>12)&T_E, sseg8e, v8, (t2), t3)
')


/* TODO: indexed load/stores */

.data


#if __riscv_xlen == 32
#define defptr .word
#else
#define defptr .dword
#endif

define(`m_gen_function_pointers', `defptr $1_m`'m_benchLMUL')
define(`m_gen_types', `defptr $2')
define(`m_format',`$2 shift(shift($*))')
define(`m_gen_strings', `.string "m_format(,shift(shift(shift($*))))"')

.balign 8
.global aligned
aligned:
defptr 0
.global misaligned
misaligned:
defptr 0


.balign 8
define(`m_LMUL', f8)
define(`m_benchLMUL', 1)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', f4)
define(`m_benchLMUL', 1)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', f2)
define(`m_benchLMUL', 1)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', 1)
define(`m_benchLMUL', 1)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', 2)
define(`m_benchLMUL', 2)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', 4)
define(`m_benchLMUL', 4)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

.balign 8
define(`m_LMUL', 8)
define(`m_benchLMUL', 8)
.global bench_m`'m_LMUL
	bench_m`'m_LMUL:
	m_bench_all(`gen_function_pointers')

pushdef(`m_ifmx',`m_ifmx_t($*)')

.balign 8
.global bench_types
	bench_types:
	m_bench_all(`gen_types')

.balign 8
.global bench_names
	bench_names:
	m_bench_all(`gen_strings')

.balign 8
define(`m_1p', 1+)
.global bench_count
bench_count:
	defptr eval(m_bench_all(`1p')0)

popdef(`m_ifmx')


.balign 8
u64_cycle:
.dword 0

.text
.balign 8


/* x off */
define(`m_offset1',
	`ifelse(`$1',`t0',t$2,
	 ifelse(`$1',`ft0',ft$2,
	 ifelse(`$1',`v8',v`'eval(8+$2),
	 ifelse(`$1',v16,v`'eval(16+$2),
	 ifelse(`$1',v24,v`'eval(24+$2),$1)))))')
/* acc off code:vararg */
define(`m_offset',
	`ifelse(`$3',,`m_format($1)',
		`m_offset(`$1,m_offset1($3,$2)',$2,$4,$5,$6,$7,$8,$9)')')

define(`m_gen_code_m1',
	`m_format(,$*)
m_offset(,1,$*)
m_offset(,2,$*)
m_offset(,3,$*)
m_offset(,4,$*)
m_offset(,5,$*)
m_offset(,6,$*)
m_offset(,7,$*)')

define(`m_gen_code_m2',
	`m_format(,$*)
m_offset(,2,$*)
m_offset(,4,$*)
m_offset(,6,$*)
m_format(,$*)
m_offset(,2,$*)
m_offset(,4,$*)
m_offset(,6,$*)')

define(`m_gen_code_m4',
	`m_format(,$*)
m_offset(,4,$*)
m_format(,$*)
m_offset(,4,$*)
m_format(,$*)
m_offset(,4,$*)
m_format(,$*)
m_offset(,4,$*)')

define(`m_gen_code_m8',
	`m_format(,$*)
m_format(,$*)
m_format(,$*)
m_format(,$*)
m_format(,$*)
m_format(,$*)
m_format(,$*)
m_format(,$*)')


/* name type setup code:vararg */
define(`m_gen_bench',`
$1`'_m`'m_LMUL:	pushdef(`m_code', `shift(shift(shift($*)))')
	$3
	li a0, WARMUP
1:
ifelse(m_LMUL,1,`m_gen_code_m1(m_code)')
ifelse(m_LMUL,2,`m_gen_code_m2(m_code)')
ifelse(m_LMUL,4,`m_gen_code_m4(m_code)')
ifelse(m_LMUL,8,`m_gen_code_m8(m_code)')
	addi a0, a0, -1
	bnez a0, 1b
#if defined(USE_PERF_EVENT_SLOW)
	ld a0, nolibc_perf_event_fd
	la a1, u64_cycle
	li a2, 8
	li a7, 63
	ecall /* clobbers vregs and vtype */
	ld a3, u64_cycle
	vsetvl VL, VL, s2
	bnez VL, 2f
	vsetvl VL, x0, s2
	2:
#elif defined(READ_MCYCLE)
	csrr a3, mcycle
#else
	csrr a3, cycle
#endif
	li a0, LOOP
1:
.rept UNROLL
ifelse(m_LMUL,1,`m_gen_code_m1(m_code)')
ifelse(m_LMUL,2,`m_gen_code_m2(m_code)')
ifelse(m_LMUL,4,`m_gen_code_m4(m_code)')
ifelse(m_LMUL,8,`m_gen_code_m8(m_code)')
.endr
	addi a0, a0, -1
	bnez a0, 1b
#if defined(USE_PERF_EVENT_SLOW)
	ld a0, nolibc_perf_event_fd
	la a1, u64_cycle
	li a2, 8
	li a7, 63
	ecall /* clobbers vregs and vtype */
	ld a0, u64_cycle
	vsetvl VL, VL, s2
	bnez VL, 2f
	vsetvl VL, x0, s2
	2:
#elif defined(READ_MCYCLE)
	csrr a0, mcycle
#else
	csrr a0, cycle
#endif
	sub a0, a0, a3
ret	popdef(`m_code')
')

define(`m_LMUL', 1)
m_bench_all(`gen_bench')
define(`m_LMUL', 2)
m_bench_all(`gen_bench')
define(`m_LMUL', 4)
m_bench_all(`gen_bench')
define(`m_LMUL', 8)
m_bench_all(`gen_bench')


randomize:
#if __riscv_xlen == 32
	li a1, 0x85ebca6b
	li a2, 0xc2b2ae35
	li a3, 0x7feb352d
#else
	li a1, 0xa0761d6485ebca6b
	li a2, 0x78bd642fc2b2ae35
	li a3, 0xe7037ed17feb352d
#endif

	vsetvli a4, x0, e8, m8, ta, ma
	vid.v v0
	vsetvli a4, x0, e16, m8, ta, ma
	vmul.vx v0, v0, a3
	vid.v v8
	vadd.vv v0, v0, v8
	vxor.vx v0, v0, a0

	/* murmurhash32 finalizer */
	vsetvli a4, x0, e32, m8, ta, ma

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, a1

	vsrl.vi v8, v8, 13
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, a2

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8

	/* mix to other registers */
	vmul.vx v8,  v0, a1
	vmul.vx v16, v0, a2
	vmul.vx v24, v0, a3


	/* zero floating point exponent bit to avoid NaN/Inf */
#if __riscv_xlen == 32
	vsetvli a4, x0, e32, m8, ta, ma
	li a4, ~0x40004000 /* zero upper f16/f32/f64 exponent bit */
#else
	vsetvli a4, x0, e64, m8, ta, ma
	li a4, ~0x4000000040004000 /* zero upper f16/f32/f64 exponent bit */
#endif
	vand.vx v0, v0, a4
	vand.vx v8, v8, a4
	vand.vx v16, v16, a4
	vand.vx v24, v24, a4

	/* fill t* & ft* with wyhash */
	.macro randomize_reg x xs:vararg
		add a0, a0, a1
		xor a5, a0, a2
		mulh a6, a0, a5
		mulhu a7, a0, a5
		xor \x, a6, a7
		and a5, \x, a4 /* zero upper f16/f32/f64 exponent bit */
		fmv.w.x f\()\x, a5
		.ifnb \xs
			randomize_reg \xs
		.endif
	.endm
	randomize_reg t0, t1, t2, t3, t4, t5, t6, t7, t8
	ret

/* u64 f(u64 (*bench)(void), u64 type, u64 vl, u64 seed) */
.global run_bench
run_bench:
	addi sp, sp, -48
	sx ra, 8(sp)
	sx VL, 16(sp)
	sx s1, 24(sp)
	sx s2, 32(sp)
	sx VL, 40(sp)

	mv s1, a0
	mv s2, a1 /* type */
	mv VL, a2
	mv a0, a3 /* seed */
	call randomize
	vsetvl VL, VL, s2
	bnez VL, 1f
	vsetvl VL, x0, s2
	1:
	jalr s1

	lx ra, 8(sp)
	lx VL, 16(sp)
	lx s1, 24(sp)
	lx s2, 32(sp)
	lx VL, 40(sp)
	addi sp, sp, 48
	ret
