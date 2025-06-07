#include "config.h"

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

.macro m_nop
.endm

#define bench s0
#define ptr s1

.macro m_t2or31
ori t2, t2, 31
.endm

.macro m_t2or63
ori t2, t2, 63
.endm

.macro m_t2or1
ori t2, t2, 1
.endm

.macro m_f1and1
fsgnj.s
.endm

.macro m_f1ne0
fmv.x.w a0, ft1
ori a0, a0, 1
fmv.w.x ft1, a0
.endm

.macro m_f1abs
fabs.s  fa0,fa0
.endm

.macro m_d1ne0
fmv.x.d a0, ft1
ori a0, a0, 1
fmv.d.x ft1, a0
.endm

.macro m_d1abs
fabs.d  fa0,fa0
.endm


.macro m_benchmarks_all f

	# I
	\f      bench_add,   m_nop, add   t0, t1, t2
	IF64(\f bench_addw,  m_nop, addw  t0, t1, t2)
	\f      bench_addi,  m_nop, addi  t0, t1, 13
	IF64(\f bench_addiw, m_nop, addiw t0, t1, 13)
	\f      bench_sub,   m_nop, sub   t0, t1, t2
	IF64(\f bench_subw,  m_nop, subw  t0, t1, t2)
	\f      bench_lui,   m_nop, lui   t0, 13
	\f      bench_auipc, m_nop, auipc t0, 13

	\f bench_xor,  m_nop, xor  t0, t1, t2
	\f bench_xori, m_nop, xori t0, t1, 13
	\f bench_or,   m_nop, or   t0, t1, t2
	\f bench_ori,  m_nop, ori  t0, t1, 13
	\f bench_and,  m_nop, and  t0, t1, t2
	\f bench_andi, m_nop, andi t0, t1, 13

	\f bench_slt,   m_nop, slt   t0, t1, t2
	\f bench_slti,  m_nop, slti  t0, t1, 13
	\f bench_sltu,  m_nop, sltu  t0, t1, t2
	\f bench_sltiu, m_nop, sltiu t0, t1, 13

	\f      bench_sll,   m_t2or63, sll   t0, t1, t2
	IF64(\f bench_sllw,  m_t2or31, sllw  t0, t1, t2)
	\f      bench_slli,  m_t2or63, slli  t0, t1, 13
	IF64(\f bench_slliw, m_t2or31, slliw t0, t1, 13)
	\f      bench_srl,   m_t2or63, srl   t0, t1, t2
	IF64(\f bench_srlw,  m_t2or31, srlw  t0, t1, t2)
	\f      bench_srli,  m_t2or63, srli  t0, t1, 13
	IF64(\f bench_srliw, m_t2or31, srliw t0, t1, 13)
	\f      bench_sra,   m_t2or63, sra   t0, t1, t2
	IF64(\f bench_sraw,  m_t2or31, sraw  t0, t1, t2)
	\f      bench_srai,  m_t2or63, srai  t0, t1, 13
	IF64(\f bench_sraiw, m_t2or31, sraiw t0, t1, 13)

	\f      bench_lb,  m_nop, lb  t0, 13(ptr)
	\f      bench_lh,  m_nop, lh  t0, 13(ptr)
	\f      bench_lw,  m_nop, lw  t0, 13(ptr)
	IF64(\f bench_ld,  m_nop, ld  t0, 13(ptr))
	\f      bench_lbu, m_nop, lbu t0, 13(ptr)
	\f      bench_lhu, m_nop, lhu t0, 13(ptr)
	IF64(\f bench_lwu, m_nop, lwu t0, 13(ptr))

	\f      bench_sb, m_nop, sb t0, 13(ptr)
	\f      bench_sh, m_nop, sh t0, 13(ptr)
	\f      bench_sw, m_nop, sw t0, 13(ptr)
	IF64(\f bench_sd, m_nop, sd t0, 13(ptr))


	# M
#if __riscv_m
	\f      bench_mul,    m_nop,   mul    t0, t1, t2
	\f      bench_mulh,   m_nop,   mulh   t0, t1, t2
	\f      bench_mulhsu, m_nop,   mulhsu t0, t1, t2
	\f      bench_mulhu,  m_nop,   mulhu  t0, t1, t2
	IF64(\f bench_mulw,   m_nop,   mulw   t0, t1, t2)
	\f      bench_div,    m_t2or1, div    t0, t1, t2
	IF64(\f bench_divw,   m_t2or1, divw   t0, t1, t2)
	\f      bench_divu,   m_t2or1, divu   t0, t1, t2
	IF64(\f bench_divuw,  m_t2or1, divuw  t0, t1, t2)
	\f      bench_rem,    m_t2or1, rem    t0, t1, t2
	IF64(\f bench_remw,   m_t2or1, remw   t0, t1, t2)
	\f      bench_remu,   m_t2or1, remu   t0, t1, t2
	IF64(\f bench_remuw,  m_t2or1, remuw  t0, t1, t2)
#endif

	# A
#if __riscv_a
	\f      bench_lrw,      m_nop, lr.w      t0, (ptr)
	IF64(\f bench_lrd,      m_nop, lr.d      t0, (ptr))
	\f      bench_scw,      m_nop, sc.w      t0, t1, (ptr)
	IF64(\f bench_scd,      m_nop, sc.d      t0, t1, (ptr))
	\f      bench_amoswapw, m_nop, amoswap.w t0, t1, (ptr)
	IF64(\f bench_amoswapd, m_nop, amoswap.d t0, t1, (ptr))
	\f      bench_amoaddw,  m_nop, amoadd.w  t0, t1, (ptr)
	IF64(\f bench_amoaddd,  m_nop, amoadd.d  t0, t1, (ptr))
	\f      bench_amoxorw,  m_nop, amoxor.w  t0, t1, (ptr)
	IF64(\f bench_amoxord,  m_nop, amoxor.d  t0, t1, (ptr))
	\f      bench_amoandw,  m_nop, amoand.w  t0, t1, (ptr)
	IF64(\f bench_amoandd,  m_nop, amoand.d  t0, t1, (ptr))
	\f      bench_amoorw,   m_nop, amoor.w   t0, t1, (ptr)
	IF64(\f bench_amoord,   m_nop, amoor.d   t0, t1, (ptr))
	\f      bench_amominw,  m_nop, amomin.w  t0, t1, (ptr)
	IF64(\f bench_amomind,  m_nop, amomin.d  t0, t1, (ptr))
	\f      bench_amomaxw,  m_nop, amomax.w  t0, t1, (ptr)
	IF64(\f bench_amomaxd,  m_nop, amomax.d  t0, t1, (ptr))
	\f      bench_amominuw, m_nop, amominu.w t0, t1, (ptr)
	IF64(\f bench_amominud, m_nop, amominu.d t0, t1, (ptr))
	\f      bench_amomaxuw, m_nop, amomaxu.w t0, t1, (ptr)
	IF64(\f bench_amomaxud, m_nop, amomaxu.d t0, t1, (ptr))
#endif


	# F
#if __riscv_f
	\f bench_fmvwx,     m_nop, fmv.w.x   ft0, t0
	\f bench_fmvxw,     m_nop, fmv.x.w   t0,  ft0
	\f bench_fcvt_w_s,  m_nop, fcvt.w.s  t0, ft0
	\f bench_fcvt_wu_s, m_nop, fcvt.wu.s t0, ft0
	\f bench_fcvt_s_w,  m_nop, fcvt.s.w  ft0, t0
	\f bench_fcvt_s_wu, m_nop, fcvt.s.wu ft0, t0
	IF64(\f bench_fcvt_l_s,  m_nop, fcvt.l.s  t0, ft0)
	IF64(\f bench_fcvt_lu_s, m_nop, fcvt.lu.s t0, ft0)
	IF64(\f bench_fcvt_s_l,  m_nop, fcvt.s.l  ft0, t0)
	IF64(\f bench_fcvt_s_lu, m_nop, fcvt.s.lu ft0, t0)

	\f bench_flw, m_nop, flw ft0, 13(ptr)
	\f bench_fsw, m_nop, fsw ft0, 13(ptr)

	\f bench_fadds,   m_nop,   fadd.s   ft0, ft1, ft2
	\f bench_fsubs,   m_nop,   fsub.s   ft0, ft1, ft2
	\f bench_fmuls,   m_nop,   fmul.s   ft0, ft1, ft2
	\f bench_fdivs,   m_f1ne0, fdiv.s   ft0, ft1, ft2
	\f bench_fsqrts,  m_f1abs, fsqrt.s  ft0, ft1
	\f bench_fmadds,  m_nop,   fmadd.s  ft0, ft1, ft2, ft3
	\f bench_fmsubs,  m_nop,   fmsub.s  ft0, ft1, ft2, ft3
	\f bench_fnmsubs, m_nop,   fnmsub.s ft0, ft1, ft2, ft3
	\f bench_fnmadds, m_nop,   fnmadd.s ft0, ft1, ft2, ft3

	\f bench_fsgnjs,  m_nop, fsgnj.s  ft0, ft1, ft2
	\f bench_fsgnjns, m_nop, fsgnjn.s ft0, ft1, ft2
	\f bench_fsgnjxs, m_nop, fsgnjx.s ft0, ft1, ft2
	\f bench_fmins, m_nop, fmin.s ft0, ft1, ft2
	\f bench_fmaxs, m_nop, fmax.s ft0, ft1, ft2

	\f bench_feqs,    m_nop, feq.s    t0, ft0, ft1
	\f bench_flts,    m_nop, flt.s    t0, ft0, ft1
	\f bench_fles,    m_nop, fle.s    t0, ft0, ft1
	\f bench_fclasss, m_nop, fclass.s t0, ft0
#endif

	# D
#if __riscv_d && __riscv_xlen != 32
	\f bench_fmvdx,   m_nop, fmv.d.x   ft0, t0
	\f bench_fmvxd,   m_nop, fmv.x.d   t0,  ft0
	\f bench_fcvtwd,  m_nop, fcvt.w.d  t0,  ft0
	\f bench_fcvtwud, m_nop, fcvt.wu.d t0,  ft0
	\f bench_fcvtdw,  m_nop, fcvt.d.w  ft0, t0
	\f bench_fcvtdwu, m_nop, fcvt.d.wu ft0, t0
	\f bench_fcvtld,  m_nop, fcvt.l.d  t0,  ft0
	\f bench_fcvtlud, m_nop, fcvt.lu.d t0,  ft0
	\f bench_fcvtdl,  m_nop, fcvt.d.l  ft0, t0
	\f bench_fcvtdlu, m_nop, fcvt.d.lu ft0, t0

	\f bench_fld, m_nop, fld ft0, 13(ptr)
	\f bench_fsd, m_nop, fsd ft0, 13(ptr)

	\f bench_faddd,   m_nop,   fadd.d   ft0, ft1, ft2
	\f bench_fsubd,   m_nop,   fsub.d   ft0, ft1, ft2
	\f bench_fmuld,   m_nop,   fmul.d   ft0, ft1, ft2
	\f bench_fdivd,   m_d1ne0, fdiv.d   ft0, ft1, ft2
	\f bench_fsqrtd,  m_d1abs, fsqrt.d  ft0, ft1
	\f bench_fmaddd,  m_nop,   fmadd.d  ft0, ft1, ft2, ft3
	\f bench_fmsubd,  m_nop,   fmsub.d  ft0, ft1, ft2, ft3
	\f bench_fnmsubd, m_nop,   fnmsub.d ft0, ft1, ft2, ft3
	\f bench_fnmaddd, m_nop,   fnmadd.d ft0, ft1, ft2, ft3

	\f bench_fsgnjd,  m_nop, fsgnj.d  ft0, ft1, ft2
	\f bench_fsgnjnd, m_nop, fsgnjn.d ft0, ft1, ft2
	\f bench_fsgnjxd, m_nop, fsgnjx.d ft0, ft1, ft2
	\f bench_fmind, m_nop, fmin.d ft0, ft1, ft2
	\f bench_fmaxd, m_nop, fmax.d ft0, ft1, ft2

	\f bench_feqd,    m_nop, feq.d    t0, ft0, ft1
	\f bench_fltd,    m_nop, flt.d    t0, ft0, ft1
	\f bench_fled,    m_nop, fle.d    t0, ft0, ft1
	\f bench_fclassd, m_nop, fclass.d t0, ft0
#endif


#if __riscv_zba
	IF64(\f bench_adduw,    m_nop, add.uw    t0, t1, t2)
	\f      bench_sh1add,   m_nop, sh1add    t0, t1, t2
	IF64(\f bench_sh1adduw, m_nop, sh1add.uw t0, t1, t2)
	\f      bench_sh2add,   m_nop, sh2add    t0, t1, t2
	IF64(\f bench_sh2adduw, m_nop, sh2add.uw t0, t1, t2)
	\f      bench_sh3add,   m_nop, sh3add    t0, t1, t2
	IF64(\f bench_sh3adduw, m_nop, sh3add.uw t0, t1, t2)
	IF64(\f bench_slliuw,   m_nop, slli.uw   t0, t1, 13)
	IF64(\f bench_zextw,    m_nop, zext.w    t0, t1)
#endif

#if __riscv_zbb
	\f bench_andn, m_nop, andn t0, t1, t2
	\f bench_orn,  m_nop, orn  t0, t1, t2
	\f bench_xnor, m_nop, xnor t0, t1, t2

	\f      bench_clz,  m_nop, clz  t0, t1
	IF64(\f bench_clzw, m_nop, clzw t0, t1)
	\f      bench_ctz,  m_nop, ctz  t0, t1
	IF64(\f bench_ctzw, m_nop, ctzw t0, t1)

	\f bench_cpop,  m_nop, cpop  t0, t1
	IF64(\f bench_cpopw, m_nop, cpopw t0, t1)

	\f bench_max,  m_nop, max  t0, t1, t2
	\f bench_maxu, m_nop, maxu t0, t1, t2
	\f bench_min,  m_nop, min  t0, t1, t2
	\f bench_minu, m_nop, minu t0, t1, t2

	\f bench_sextb, m_nop, sext.b t0, t1
	\f bench_sexth, m_nop, sext.h t0, t1
	\f bench_zexth, m_nop, zext.h t0, t1

	\f      bench_rol,   m_t2or63, rol   t0, t1, t2
	IF64(\f bench_rolw,  m_t2or31, rolw  t0, t1, t2)
	\f      bench_ror,   m_t2or63, ror   t0, t1, t2
	\f      bench_rori,  m_nop,    rori  t0, t1, 13
	IF64(\f bench_roriw, m_nop,    roriw t0, t1, 13)
	IF64(\f bench_rorw,  m_t2or31, rorw  t0, t1, t2)

	\f bench_orc,  m_nop, orc.b t0, t1
	\f bench_rev8, m_nop, rev8  t0, t1
#endif

#if __riscv_zbc
	\f bench_clmul,  m_nop, clmul  t0, t1, t2
	\f bench_clmulh, m_nop, clmulh t0, t1, t2
	\f bench_clmulr, m_nop, clmulr t0, t1, t2
#endif

#if __riscv_zbs
	\f bench_bclr,  m_nop, bclr  t0, t1, t2
	\f bench_bclri, m_nop, bclri t0, t1, 13
	\f bench_bext,  m_nop, bext  t0, t1, t2
	\f bench_bexti, m_nop, bexti t0, t1, 13
	\f bench_binv,  m_nop, binv  t0, t1, t2
	\f bench_binvi, m_nop, binvi t0, t1, 13
	\f bench_bset,  m_nop, bset  t0, t1, t2
	\f bench_bseti, m_nop, bseti t0, t1, 13
#endif

.endm

.data

#if __riscv_xlen == 32
#define defptr .word
#else
#define defptr .dword
#endif

.balign 8
.global benchmarks
benchmarks:
.macro gen_function_pointers name setup code:vararg
	defptr \name
.endm
m_benchmarks_all gen_function_pointers
defptr 0 # zero termination


.macro gen_strings name setup code:vararg
	.string "\code"
.endm

.balign 8
.global benchmark_names
benchmark_names:
m_benchmarks_all gen_strings


.balign 8
u64_cycle:
.dword 0

.text
.balign 8

.macro m_gen_benchname name setup code:vararg
	\name:
		\setup
		li a0, WARMUP
	1:
		\code
		addi a0, a0, -1
		bnez a0, 1b
#if defined(USE_PERF_EVENT_SLOW)
		ld a0, nolibc_perf_event_fd
		la a1, u64_cycle
		li a2, 8
		li a7, 63
		ecall
		ld a3, u64_cycle
#elif defined(READ_MCYCLE)
		csrr a3, mcycle
#else
		csrr a3, cycle
#endif
		li a0, LOOP
	1:
	.rept UNROLL
		\code
	.endr
		addi a0, a0, -1
		bnez a0, 1b
		fence.i
#if defined(USE_PERF_EVENT_SLOW)
		ld a0, nolibc_perf_event_fd
		la a1, u64_cycle
		li a2, 8
		li a7, 63
		ecall
		ld a0, u64_cycle
#elif defined(READ_MCYCLE)
		csrr a0, mcycle
#else
		csrr a0, cycle
#endif
		sub a0, a0, a3
	ret
.endm

m_benchmarks_all m_gen_benchname


randomize:
#if __riscv_xlen == 32
	li a1, 0x85ebca6b
	li a2, 0xc2b2ae35
#else
	li a1, 0xa0761d6485ebca6b
	li a2, 0x78bd642fc2b2ae35
#endif

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

# u64 f(u64 (*bench)(), void *ptr, u64 seed)
.global run_bench
run_bench:
	addi sp, sp, -32
	sx ra, 8(sp)
	sx bench, 16(sp)
	sx ptr, 24(sp)

	mv bench, a0
	mv ptr, a1
	mv a0, a2 # seed
	call randomize
	jalr bench

	lx ra, 8(sp)
	lx bench, 16(sp)
	lx ptr, 24(sp)
	addi sp, sp, 32
	ret
