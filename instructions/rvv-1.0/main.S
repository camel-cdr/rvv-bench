#define VL s3
#define PTR s4

#include "config.h"

.macro m_nop
.endm

.macro m_1bit
vid.v v0
remu t0, t0, VL
vmseq.vx v8, v0, t0
.endm

.macro m_mask f name type setup code:vararg
	\f \name\(),  \type, \setup, \code
	\f \name\()m, \type, \setup, \code, v0.t
.endm

.macro m_bench_vx f t name
	m_mask \f bench_\()\name\()vv, \t, m_nop, \name\().vv v8, v16, v24
	m_mask \f bench_\()\name\()vx, \t, m_nop, \name\().vx v8, v16, t0
.endm

.macro m_bench_xv f t name
	m_mask \f bench_\()\name\()vv, \t, m_nop, \name\().vv v8, v16, v24
	m_mask \f bench_\()\name\()vx, \t, m_nop, \name\().vx v8, t0, v16
.endm

.macro m_bench_xi f t name
	m_mask \f bench_\()\name\()vx, \t, m_nop, \name\().vx v8, v16, t0
	m_mask \f bench_\()\name\()vi, \t, m_nop, \name\().vi v8, v16, 13
.endm

.macro m_bench_vxi f t name
	m_mask \f bench_\()\name\()vv, \t, m_nop, \name\().vv v8, v16, v24
	m_mask \f bench_\()\name\()vx, \t, m_nop, \name\().vx v8, v16, t0
	m_mask \f bench_\()\name\()vi, \t, m_nop, \name\().vi v8, v16, 13
.endm

.macro m_bench_vxm f t name
	\f bench_\()\name\()vvm, \t, m_nop, \name\().vvm v8, v16, v24, v0
	\f bench_\()\name\()vxm, \t, m_nop, \name\().vxm v8, v16, t0, v0
.endm

.macro m_bench_vxim f t name
	\f bench_\()\name\()vvm, \t, m_nop, \name\().vvm v8, v16, v24, v0
	\f bench_\()\name\()vxm, \t, m_nop, \name\().vxm v8, v16, t0, v0
	\f bench_\()\name\()vim, \t, m_nop, \name\().vim v8, v16, 13, v0
.endm

.macro m_bench_vf f t name
	m_mask \f bench_\()\name\()vv, \t, m_nop, \name\().vv v8, v16, v24
	m_mask \f bench_\()\name\()vf, \t, m_nop, \name\().vf v8, v16, ft0
.endm

.macro m_bench_fv f t name
	m_mask \f bench_\()\name\()vv, \t, m_nop, \name\().vv v8, v16, v24
	m_mask \f bench_\()\name\()vf, \t, m_nop, \name\().vf v8, ft0, v16
.endm

.macro m_bench_wx f t name
	m_mask \f bench_\()\name\()wv, \t, m_nop, \name\().wv v8, v16, v24
	m_mask \f bench_\()\name\()wx, \t, m_nop, \name\().wx v8, v16, t0
.endm

.macro m_bench_wf f t name
	m_mask \f bench_\()\name\()wv, \t, m_nop, \name\().wv v8, v16, v24
	m_mask \f bench_\()\name\()wf, \t, m_nop, \name\().wf v8, v16, ft0
.endm

.macro m_bench_wxi f t name
	m_mask \f bench_\()\name\()wv, \t, m_nop, \name\().wv v8, v16, v24
	m_mask \f bench_\()\name\()wx, \t, m_nop, \name\().wx v8, v16, t0
	m_mask \f bench_\()\name\()wi, \t, m_nop, \name\().wi v8, v16, 13
.endm

// TODO: mask SEW and LMUL thogether
.macro m_bench_ls f setup pre suf args:vararg
	m_mask \f bench_vl\()\pre\()8\()\suf\()v,  T_A,  \setup, vl\pre\()8\()\suf\().v \args
	m_mask \f bench_vs\()\pre\()8\()\suf\()v,  T_A,  \setup, vl\pre\()8\()\suf\().v \args
	m_mask \f bench_vl\()\pre\()16\()\suf\()v, T_E2, \setup, vl\pre\()16\()\suf\().v \args
	m_mask \f bench_vs\()\pre\()16\()\suf\()v, T_E2, \setup, vl\pre\()16\()\suf\().v \args
	m_mask \f bench_vl\()\pre\()32\()\suf\()v, T_E4, \setup, vl\pre\()32\()\suf\().v \args
	m_mask \f bench_vs\()\pre\()32\()\suf\()v, T_E4, \setup, vl\pre\()32\()\suf\().v \args
	m_mask \f bench_vl\()\pre\()64\()\suf\()v, T_E8, \setup, vl\pre\()64\()\suf\().v \args
	m_mask \f bench_vs\()\pre\()64\()\suf\()v, T_E8, \setup, vl\pre\()64\()\suf\().v \args
.endm

.macro m_bench_vlnre f n
	\f bench_vl\()\n\()re8v,  T_A, m_nop, vl\()\n\()re8.v v8, (PTR)
	\f bench_vs\()\n\()re8v,  T_A, m_nop, vl\()\n\()re8.v v8, (PTR)
	\f bench_vl\()\n\()re16v, T_A, m_nop, vl\()\n\()re16.v v8, (PTR)
	\f bench_vs\()\n\()re16v, T_A, m_nop, vl\()\n\()re16.v v8, (PTR)
	\f bench_vl\()\n\()re32v, T_A, m_nop, vl\()\n\()re32.v v8, (PTR)
	\f bench_vs\()\n\()re32v, T_A, m_nop, vl\()\n\()re32.v v8, (PTR)
	\f bench_vl\()\n\()re64v, T_A, m_nop, vl\()\n\()re64.v v8, (PTR)
	\f bench_vs\()\n\()re64v, T_A, m_nop, vl\()\n\()re64.v v8, (PTR)
.endm

.macro m_mod_v24_e8_vl
	csrr t1, vtype
	vsetvli t0, x0, e8, m8, ta, ma
	vremu.vx v24, v24, VL
	vsetvl x0, VL, t1
.endm

.macro m_mod_v24_e16_vl
	csrr t1, vtype
	vsetvli t0, x0, e16, m8, ta, ma
	vremu.vx v24, v24, VL
	vsetvl x0, VL, t1
.endm

.macro m_mod_v16_vl
	vremu.vx v16, v16, VL
.endm

.macro m_mod_t0_vl
	remu t0, t0, VL
.endm

.macro m_mod_t0_8
	andi t0, t0, 7
.endm


.macro m_benchmarks_all f
	\f bench_add, T_A, m_nop, add t0, t1, t2
	\f bench_mul, T_A, m_nop, mul t0, t1, t2
	m_bench_vxi \f, T_A, vadd
	m_bench_vx  \f, T_A, vsub
	m_bench_xi  \f, T_A, vrsub
	m_bench_vx  \f, T_A, vminu
	m_bench_vx  \f, T_A, vmin
	m_bench_vx  \f, T_A, vmaxu
	m_bench_vx  \f, T_A, vmax
	m_bench_vxi \f, T_A, vand
	m_bench_vxi \f, T_A, vor
	m_bench_vxi \f, T_A, vxor

	m_mask \f bench_vrgathervv,     T_A, m_mod_v24_e8_vl,  vrgather.vv     v8, v16, v24
	m_mask \f bench_vrgathervx,     T_A, m_mod_t0_vl,      vrgather.vx     v8, v16, t0
	m_mask \f bench_vrgathervi,     T_A, m_nop,            vrgather.vi     v8, v16, 3
	m_mask \f bench_vslideupvx,     T_A, m_mod_t0_vl,      vslideup.vx     v8, v16, t0
	m_mask \f bench_vslideupvi,     T_A, m_nop,            vslideup.vi     v8, v16, 3
	// TODO: mask SEW and LMUL thogether
	m_mask \f bench_vrgatherei16vv, T_N8, m_mod_v24_e16_vl, vrgatherei16.vv v8, v16, v24

	m_mask \f bench_vslidedownvx, T_A, m_mod_t0_vl,  vslidedown.vx v8, v16, t0
	m_mask \f bench_vslidedownvi, T_A, m_nop,        vslidedown.vi v8, v16, 3

	m_mask \f bench_vredsumvs,  T_A, m_nop, vredsum.vs  v8, v16, v24
	m_mask \f bench_vredandvs,  T_A, m_nop, vredand.vs  v8, v16, v24
	m_mask \f bench_vredorvs,   T_A, m_nop, vredor.vs   v8, v16, v24
	m_mask \f bench_vredxorvs,  T_A, m_nop, vredxor.vs  v8, v16, v24
	m_mask \f bench_vredminuvs, T_A, m_nop, vredminu.vs v8, v16, v24
	m_mask \f bench_vredminvs,  T_A, m_nop, vredmin.vs  v8, v16, v24
	m_mask \f bench_vredmaxuvs, T_A, m_nop, vredmaxu.vs v8, v16, v24
	m_mask \f bench_vredmaxvs,  T_A, m_nop, vredmax.vs  v8, v16, v24

	m_bench_vx \f, T_A, vaaddu
	m_bench_vx \f, T_A, vaadd
	m_bench_vx \f, T_A, vasubu
	m_bench_vx \f, T_A, vasub

	m_mask \f bench_vslide1upvx,   T_A, m_nop, vslide1up.vx   v8, v16, t0
	m_mask \f bench_vslide1downvx, T_A, m_nop, vslide1down.vx v8, v16, t0

	m_bench_vxim \f, T_A, vadc
	m_bench_vxim \f, T_A, vmadc
	m_bench_vxm  \f, T_A, vsbc
	m_bench_vxm  \f, T_A, vmsbc

	m_bench_vxim \f, T_A, vmerge
	\f bench_vmvvv, T_A, m_nop, vmv.v.v v8, v16
	\f bench_vmvvx, T_A, m_nop, vmv.v.x v8, t0
	\f bench_vmvvi, T_A, m_nop, vmv.v.i v8, 13
	m_bench_vxi \f, T_A, vmseq
	m_bench_vxi \f, T_A, vmsne
	m_bench_vx  \f, T_A, vmsltu
	m_bench_vx  \f, T_A, vmslt
	m_bench_vxi \f, T_A, vmsleu
	m_bench_vxi \f, T_A, vmsle
	m_bench_xi  \f, T_A, vmsgtu
	m_bench_xi  \f, T_A, vmsgt

	\f bench_vcompressvm, T_A, m_nop, vcompress.vm v0, v8, v16

	\f bench_vmandnmm, T_A, m_nop, vmandn.mm v0, v8, v16
	\f bench_vmandmm,  T_A, m_nop, vmand.mm  v0, v8, v16
	\f bench_vmormm,   T_A, m_nop, vmor.mm   v0, v8, v16
	\f bench_vmxormm,  T_A, m_nop, vmxor.mm  v0, v8, v16
	\f bench_vmornmm,  T_A, m_nop, vmorn.mm  v0, v8, v16
	\f bench_vmnandmm, T_A, m_nop, vmnand.mm v0, v8, v16
	\f bench_vmnormm,  T_A, m_nop, vmnor.mm  v0, v8, v16
	\f bench_vmxnormm, T_A, m_nop, vmxnor.mm v0, v8, v16


	m_bench_vxi \f, T_A, vsaddu
	m_bench_vxi \f, T_A, vsadd
	m_bench_vx  \f, T_A, vssubu
	m_bench_vx  \f, T_A, vssub
	m_bench_vxi \f, T_A, vsll
	m_bench_vx  \f, T_A, vsmul
	\f bench_vmv1rv, T_A, m_nop, vmv1r.v v8, v16
	\f bench_vmv2rv, T_A, m_nop, vmv2r.v v8, v16
	\f bench_vmv4rv, T_A, m_nop, vmv4r.v v8, v16
	\f bench_vmv8rv, T_A, m_nop, vmv8r.v v8, v16
	m_bench_vxi \f, T_A, vsrl
	m_bench_vxi \f, T_A, vsra
	m_bench_vxi \f, T_A, vssrl

	m_bench_vx \f, T_A, vdivu
	m_bench_vx \f, T_A, vdiv
	m_bench_vx \f, T_A, vremu
	m_bench_vx \f, T_A, vrem
	m_bench_vx \f, T_A, vmulhu
	m_bench_vx \f, T_A, vmul
	m_bench_vx \f, T_A, vmulhsu
	m_bench_vx \f, T_A, vmulh
	m_bench_xv \f, T_A, vmadd
	m_bench_xv \f, T_A, vmacc

	m_bench_wxi \f, T_N, vnsrl
	m_bench_wxi \f, T_N, vnsra
	m_bench_wxi \f, T_N, vnclipu
	m_bench_wxi \f, T_N, vnclip
	m_bench_xv  \f, T_N, vnmsub
	m_bench_xv  \f, T_N, vnmsac

	m_bench_vx \f, T_W, vwaddu
	m_bench_vx \f, T_W, vwadd
	m_bench_vx \f, T_W, vwsub
	m_bench_wx \f, T_W, vwaddu
	m_bench_wx \f, T_W, vwadd
	m_bench_wx \f, T_W, vwsub
	m_bench_vx \f, T_W, vwmulu
	m_bench_vx \f, T_W, vwmulsu
	m_bench_vx \f, T_W, vwmul
	m_bench_xv \f, T_W, vwmaccu
	m_bench_xv \f, T_W, vwmacc
	m_bench_xv \f, T_W, vwmaccsu
	m_mask \f bench_vwmaccusvx,  T_W, m_nop, vwmaccus.vx  v8, t0, v16

	m_bench_vf \f, T_F, vfadd
	m_bench_vf \f, T_F, vfsub
	m_bench_vf \f, T_F, vfmin
	m_bench_vf \f, T_F, vfmax
	m_bench_vf \f, T_F, vfsgnj
	m_bench_vf \f, T_F, vfsgnjn
	m_bench_vf \f, T_F, vfsgnjx
	m_mask \f bench_vfslide1upvf,   T_F, m_nop, vfslide1up.vf   v8, v16, ft0
	m_mask \f bench_vfslide1downvf, T_F, m_nop, vfslide1down.vf v8, v16, ft0

	m_mask \f bench_vfredusumvs, T_F, m_nop, vfredusum.vs v8, v16, v24
	m_mask \f bench_vfredosumvs, T_F, m_nop, vfredosum.vs v8, v16, v24
	m_mask \f bench_vfredminvs,  T_F, m_nop, vfredmin.vs  v8, v16, v24
	m_mask \f bench_vfredmaxvs,  T_F, m_nop, vfredmax.vs  v8, v16, v24

	\f bench_vfmergevfm, T_F, m_nop, vfmerge.vfm v8,  v16, ft0, v0
	\f bench_vfmvvf,     T_F, m_nop, vfmv.v.f    v8,  ft0

	m_bench_vf \f, T_F, vmfeq
	m_bench_vf \f, T_F, vmfle
	m_bench_vf \f, T_F, vmflt
	m_bench_vf \f, T_F, vmfne
	m_bench_vf \f, T_F, vmfgt
	m_bench_vf \f, T_F, vmfge

	m_bench_vf \f, T_F, vfdiv
	m_mask \f bench_vfrdivvf, T_F, m_nop, vfrdiv.vf v8, v16, ft0
	m_bench_vf \f, T_F, vfmul
	m_mask \f bench_vfrsubvf, T_F, m_nop, vfrsub.vf v8, v16, ft0
	m_bench_fv \f, T_F, vfmadd
	m_bench_fv \f, T_F, vfmsub
	m_bench_fv \f, T_F, vfmacc
	m_bench_fv \f, T_F, vfmsac

	m_bench_fv \f, T_FN, vfnmsac
	m_bench_fv \f, T_FN, vfnmacc
	m_bench_fv \f, T_FN, vfnmsub
	m_bench_fv \f, T_FN, vfnmadd

	m_mask \f bench_vwredsumuvs, T_WR, m_nop, vwredsumu.vs v8, v16, v24
	m_mask \f bench_vwredsumvs,  T_WR, m_nop, vwredsum.vs  v8, v16, v24

	m_bench_vf \f, T_FW, vfwadd
	m_bench_vf \f, T_FW, vfwsub
	m_bench_wf \f, T_FW, vfwadd
	m_bench_wf \f, T_FW, vfwsub
	m_bench_vf \f, T_FW, vfwmul
	m_bench_fv \f, T_FW, vfwmacc
	m_bench_fv \f, T_FW, vfwnmacc
	m_bench_fv \f, T_FW, vfwmsac
	m_bench_fv \f, T_FW, vfwnmsac

	m_mask \f bench_vfwredosumvs, T_FWR, m_nop, vfwredosum.vs v8, v16, v24
	m_mask \f bench_vfwredusumvs, T_FWR, m_nop, vfwredusum.vs v8, v16, v24

	\f bench_vmvsx, T_A, m_nop, vmv.s.x v8, t0
	\f bench_vmvxs, T_A, m_nop, vmv.x.s t0, v8

	m_mask \f bench_vcpopm,   T_A,  m_nop,  vcpop.m   t0, v8
	m_mask \f bench_vfirstm,  T_A,  m_1bit, vfirst.m  t0, v8
	m_mask \f bench_vzextvf2, T_E2, m_1bit, vzext.vf2 v8, v16
	m_mask \f bench_vsextvf2, T_E2, m_1bit, vsext.vf2 v8, v16
	m_mask \f bench_vzextvf4, T_E4, m_1bit, vzext.vf4 v8, v16
	m_mask \f bench_vsextvf4, T_E4, m_1bit, vsext.vf4 v8, v16
	m_mask \f bench_vzextvf8, T_E8, m_1bit, vzext.vf8 v8, v16
	m_mask \f bench_vsextvf8, T_E8, m_1bit, vsext.vf8 v8, v16

	\f bench_vfmvfs, T_F, m_nop, vfmv.f.s ft0, v8
	\f bench_vfmvsf, T_F, m_nop, vfmv.s.f v8,  ft0

	m_mask \f bench_vfcvtxufv,    T_F, m_nop, vfcvt.xu.f.v     v8, v16
	m_mask \f bench_vfcvtxfv,     T_F, m_nop, vfcvt.x.f.v      v8, v16
	m_mask \f bench_vfcvtfxuv,    T_F, m_nop, vfcvt.f.xu.v     v8, v16
	m_mask \f bench_vfcvtfxv,     T_F, m_nop, vfcvt.f.x.v      v8, v16
	m_mask \f bench_vfcvtrtzxfv,  T_F, m_nop, vfcvt.rtz.x.f.v  v8, v16
	m_mask \f bench_vfcvtrtzxufv, T_F, m_nop, vfcvt.rtz.xu.f.v v8, v16

	m_mask \f bench_vfwcvtxufv,    T_FW, m_nop, vfwcvt.xu.f.v     v8, v16
	m_mask \f bench_vfwcvtxfv,     T_FW, m_nop, vfwcvt.x.f.v      v8, v16
	m_mask \f bench_vfwcvtfxuv,    T_FW, m_nop, vfwcvt.f.xu.v     v8, v16
	m_mask \f bench_vfwcvtfxv,     T_FW, m_nop, vfwcvt.f.x.v      v8, v16
	m_mask \f bench_vfwcvtffv,     T_FW, m_nop, vfwcvt.f.f.v      v8, v16
	m_mask \f bench_vfwcvtrtzxufv, T_FW, m_nop, vfwcvt.rtz.xu.f.v v8, v16
	m_mask \f bench_vfwcvtrtzxfv,  T_FW, m_nop, vfwcvt.rtz.x.f.v  v8, v16

	m_mask \f bench_vfncvtxufw,       T_FN, m_nop, vfncvt.xu.f.w     v8, v16
	m_mask \f bench_vfncvtxfw,        T_FN, m_nop, vfncvt.x.f.w      v8, v16
	m_mask \f bench_vfncvtfxuw,       T_FN, m_nop, vfncvt.f.xu.w     v8, v16
	m_mask \f bench_vfncvtfxw,        T_FN, m_nop, vfncvt.f.x.w      v8, v16
	m_mask \f bench_vfncvtffw,        T_FN, m_nop, vfncvt.f.f.w      v8, v16
	m_mask \f bench_vfncvtrtzxfw,     T_FN, m_nop, vfncvt.rtz.x.f.w  v8, v16
	m_mask \f bench_vfncvtrtzxufw,    T_FN, m_nop, vfncvt.rtz.xu.f.w v8, v16
	m_mask \f bench_vfncvt.rod.f.f.w, T_FN, m_nop, vfncvt.rod.f.f.w  v8, v16


	m_mask \f bench_vfsqrtv,   T_F, m_nop, vfsqrt.v   v8, v16
	m_mask \f bench_vfrsqrt7v, T_F, m_nop, vfrsqrt7.v v8, v16
	m_mask \f bench_vfrec7v,   T_F, m_nop, vfrec7.v   v8, v16
	m_mask \f bench_vfclassv,  T_F, m_nop, vfclass.v  v8, v16

	m_mask \f bench_vmsbfm,   T_A, m_1bit, vmsbf.m   v8, v16
	m_mask \f bench_vmsofm,   T_A, m_1bit, vmsof.m   v8, v16
	m_mask \f bench_vmsifm,   T_A, m_1bit, vmsif.m   v8, v16
	m_mask \f bench_viotam,   T_A, m_nop,  viota.m   v8, v16
	m_mask \f bench_vidv,     T_A, m_nop,  vid.v     v8

	m_bench_ls \f, m_nop,        e,    ,   v8, (PTR)
	m_bench_ls \f, m_nop,        e,    ff, v8, (PTR)
	// TODO: fix this
	// m_bench_ls \f, m_mod_t0_8,   se,   ,   v8, (PTR), t0
	// m_bench_ls \f, m_mod_v16_vl, uxei, ,   v8, (PTR), v16
	// m_bench_ls \f, m_mod_v16_vl, oxei, ,   v8, (PTR), v16

	m_bench_vlnre \f, 1
	m_bench_vlnre \f, 2
	m_bench_vlnre \f, 4
	m_bench_vlnre \f, 8

	// TODO: segmented load/store
.endm


.data


.global benchmarks
benchmarks:
.macro gen_function_pointers name type setup code:vararg
	.quad \name
.endm
m_benchmarks_all gen_function_pointers
.quad 0 # zero termination

.global benchmark_types
benchmark_types:
.macro gen_types name type setup code:vararg
	.quad \type
.endm
m_benchmarks_all gen_types


.macro gen_strings name type setup code:vararg
	.string "\code"
.endm

.global benchmark_names
benchmark_names:
m_benchmarks_all gen_strings


.text
.balign 8

.macro m_gen_benchname name type setup code:vararg
	\name:
		\setup
		li a0, WARMUP
	1:
		\code
		addi a0, a0, -1
		bnez a0, 1b
		li a0, LOOP
		rdcycle a1
	1:
	.rept UNROLL
		\code
	.endr
		addi a0, a0, -1
		bnez a0, 1b
		rdcycle a0
		sub a0, a0, a1
	ret
.endm

m_benchmarks_all m_gen_benchname


randomize:
	li a1, 0xa0761d6485ebca6b
	li a2, 0x78bd642fc2b2ae35
	li a3, 0xe7037ed17feb352d

	vsetvli a4, x0, e8, m8, ta, ma
	vid.v v0
	vsetvli a4, x0, e16, m8, ta, ma
	vmul.vx v0, v0, a3
	vid.v v8
	vadd.vv v0, v0, v8
	vxor.vx v0, v0, a0

	# murmurhash32 finalizer
	vsetvli a4, x0, e32, m8, ta, ma

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, a1

	vsrl.vi v8, v8, 13
	vxor.vv v0, v0, v8
	vmul.vx v0, v0, a2

	vsrl.vi v8, v8, 16
	vxor.vv v0, v0, v8

	# mix to other registers
	vmul.vx v8,  v0, a1
	vmul.vx v16, v0, a2
	vmul.vx v24, v0, a3


	# zero floating point exponent bit to avoid NaN/Inf
	vsetvli a4, x0, e16, m8, ta, ma
	li a4, ~0x4000000040004000 # zero upper f16/f32/f64 exponent bit
	vand.vx v0, v0, a4
	vand.vx v8, v8, a4
	vand.vx v16, v16, a4
	vand.vx v24, v24, a4

	# fill t* & ft* with wyhash
	.macro randomize_reg x xs:vararg
		add a0, a0, a1
		xor a5, a0, a2
		mulh a6, a0, a5
		mulhu a7, a0, a5
		xor \x, a6, a7
		and a5, \x, a4 # zero upper f16/f32/f64 exponent bit
		fmv.w.x f\()\x, a5
		.ifnb
			randomize_reg \xs
		.endif
	.endm
	randomize_reg t0, t1, t2, t3, t4, t5, t6

	ret

# u64 f(u64 (*bench)(void), u64 type, u64 vl, void *ptr, u64 seed)
.global run_bench
run_bench:
	addi sp, sp, -56
	sd ra, 8(sp)
	sd VL, 16(sp)
	sd s1, 24(sp)
	sd s2, 32(sp)
	sd VL, 40(sp)
	sd PTR, 48(sp)

	mv s1, a0
	mv s2, a1 # type
	mv VL, a2
	mv PTR, a3
	mv a0, a4 # seed
	call randomize
	vsetvl VL, VL, s2
	bnez VL, 1f
	vsetvl VL, x0, s2
	1:
	jalr s1

	ld ra, 8(sp)
	ld VL, 16(sp)
	ld s1, 24(sp)
	ld s2, 32(sp)
	ld VL, 40(sp)
	ld PTR, 48(sp)
	addi sp, sp, 56
	ret
