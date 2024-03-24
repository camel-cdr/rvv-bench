#define vl s0

#include "config.h"

.macro multiline xs:vararg
	multiline_ \xs, nl
.endm
.macro multiline_ a b c d e f xs:vararg
	.ifc \a, nl
		multiline_ \b \c \d \e \f \xs
	.else
	.ifc \b, nl
		\a
		multiline_ \c \d \e \f \xs
	.else
	.ifc \c, nl
		\a \b
		multiline_ \d \e \f \xs
	.else
	.ifc \d, nl
		\a \b, \c
		multiline_ \e \f \xs
	.else
	.ifc \e, nl
		\a \b, \c, \d
		multiline_ \f \xs
	.else
	.ifc \f, nl
		\a \b, \c, \d, \e
		multiline_ \xs
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
.endm

.macro m_nop
.endm

.macro m_benchmarks_all f
	\f bench_add, m_nop, add t0, t1, t2
	\f bench_mul, m_nop, mul t0, t1, t2
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
