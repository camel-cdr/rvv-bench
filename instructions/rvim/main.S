#include "../common/config.h"

.macro m_nop
.endm

.macro m_full_bits
not t1, x0
not t2, x0
.endm

.macro m_benchmarks_all f
	# Shifts
	\f bench_sll, m_nop, sll t0, t1, t2
	\f bench_slli, m_nop, slli t0, t1, 0x1
	\f bench_srl, m_nop, srl t0, t1, t2
	\f bench_srli, m_nop, srli t0, t1, 0x1
	\f bench_sra, m_nop, sra t0, t1, t2
	\f bench_srai, m_nop, srai t0, t1, 0x1
	# Arithmetic
	\f bench_add, m_nop, add t0, t1, t2
	\f bench_addi, m_nop, addi t0, t1, 0x1
	\f bench_sub, m_nop, sub t0, t1, t2
	\f bench_lui, m_nop, lui t0, 0x1
	\f bench_auipc, m_nop, auipc t0, 0x1
	# Logical
	\f bench_xor, m_nop, xor t0, t1, t2
	\f bench_xori, m_nop, xori t0, t1, 0x1
	\f bench_or, m_nop, or t0, t1, t2
	\f bench_ori, m_nop, ori t0, t1, 0x1
	\f bench_and, m_nop, and t0, t1, t2
	\f bench_andi, m_nop, andi t0, t1, 0x1
	# Compare
	\f bench_slt, m_nop, slt t0, t1, t2
	\f bench_slti, m_nop, slti t0, t1, 0x1
	\f bench_sltu, m_nop, sltu t0, t1, t2
	\f bench_sltiu, m_nop, sltiu t0, t1, 0x1
	# Multiply
	\f bench_mul, m_nop, mul t0, t1, t2
	\f bench_mulh, m_nop, mulh t0, t1, t2
	\f bench_mulhsu, m_nop, mulhsu t0, t1, t2
	\f bench_mulhu, m_nop, mulhu t0, t1, t2
	# Divide
	\f bench_div, m_full_bits, div t0, t1, t2
	\f bench_divu, m_full_bits, divu t0, t1, t2
	# Remainder
	\f bench_rem, m_full_bits, rem t0, t1, t2
	\f bench_remu, m_full_bits, remu t0, t1, t2
.endm


.data


.global benchmarks
benchmarks:
.macro gen_function_pointers name setup code:vararg
	.quad \name
.endm
m_benchmarks_all gen_function_pointers
.quad 0 # zero termination


.macro gen_strings name setup code:vararg
	.string "\code"
.endm

.global benchmark_names
benchmark_names:
m_benchmarks_all gen_strings


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


# u64 f(u64 (*bench)(void))
.global run_bench
run_bench:
	addi sp, sp, -16
	sd ra, 8(sp)

	jalr a0

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
