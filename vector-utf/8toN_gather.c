#include <riscv_vector.h>


#if TO_16
# define uintOut_t uint16_t
# define utf8_to_utf32_scalar utf8_to_utf16_scalar
# define utf8_to_utf32_rvv utf8_to_utf16_rvv
#else
# define uintOut_t uint32_t
#endif

size_t utf8_to_utf32_scalar(char const *src, size_t count, uintOut_t *dest);

size_t
utf8_to_utf32_rvv(char const *src, size_t count, uintOut_t *dest)
{
	size_t tail = 3;
	if (count < tail) return utf8_to_utf32_scalar(src, count, dest);

	/* validate first three bytes */
	{
		size_t idx = tail;
		while (idx < count && (src[idx] >> 6) == 0b10)
			++idx;
		uintOut_t buf[10];
		if (idx > tail + 3 || !utf8_to_utf32_scalar(src, idx, buf))
			return 0;
	}

	size_t n = count - tail;
	uintOut_t *destBeg = dest;

	static const uint64_t err1m[] = { 0x0202020202020202, 0x4915012180808080 };
	static const uint64_t err2m[] = { 0xCBCBCB8B8383A3E7, 0xCBCBDBCBCBCBCBCB };
	static const uint64_t err3m[] = { 0x0101010101010101, 0X01010101BABAAEE6 };

	const vuint8m1_t err1tbl = __riscv_vreinterpret_v_u64m1_u8m1(__riscv_vle64_v_u64m1(err1m, 2));
	const vuint8m1_t err2tbl = __riscv_vreinterpret_v_u64m1_u8m1(__riscv_vle64_v_u64m1(err2m, 2));
	const vuint8m1_t err3tbl = __riscv_vreinterpret_v_u64m1_u8m1(__riscv_vle64_v_u64m1(err3m, 2));

	const size_t vl8m1 = __riscv_vsetvlmax_e8m1();
	const size_t vl16m2 = __riscv_vsetvlmax_e16m2();

#if TO_16
	size_t vl8m2 = __riscv_vsetvlmax_e8m2();
	const vbool4_t m4even = __riscv_vmseq_vx_u8m2_b4(__riscv_vand_vx_u8m2(__riscv_vid_v_u8m2(vl8m2), 1, vl8m2), 0, vl8m2);
#endif

	for (size_t vl, vlOut; n > 0; n -= vl, src += vl, dest += vlOut) {

		vl = __riscv_vsetvl_e8m2(n);

		vuint8m2_t v0 = __riscv_vle8_v_u8m2((uint8_t const*)src, vl);
		uint64_t max = __riscv_vmv_x_s_u8m1_u8(__riscv_vredmaxu_vs_u8m2_u8m1(v0, __riscv_vmv_s_x_u8m1(0, vl), vl));

		uint8_t next0 = src[vl+0];
		uint8_t next1 = src[vl+1];
		uint8_t next2 = src[vl+2];

		/* fast path: ASCII */
		if ((max|next0|next1|next2) < 0b10000000) {
			vlOut = vl;
#if TO_16
			__riscv_vse16_v_u16m4(dest, __riscv_vzext_vf2_u16m4(v0, vlOut), vlOut);
#else
			__riscv_vse32_v_u32m8(dest, __riscv_vzext_vf4_u32m8(v0, vlOut), vlOut);
#endif
			continue;
		}

		/* see "Validating UTF-8 In Less Than One Instruction Per Byte"
		 * https://arxiv.org/abs/2010.03090 */
		vuint8m2_t v1 = __riscv_vslide1down_vx_u8m2(v0, next0, vl);
		vuint8m2_t v2 = __riscv_vslide1down_vx_u8m2(v1, next1, vl);
		vuint8m2_t v3 = __riscv_vslide1down_vx_u8m2(v2, next2, vl);

		vuint8m2_t s1 = __riscv_vreinterpret_v_u16m2_u8m2(__riscv_vsrl_vx_u16m2(__riscv_vreinterpret_v_u8m2_u16m2(v2), 4, vl16m2));
		vuint8m2_t s3 = __riscv_vreinterpret_v_u16m2_u8m2(__riscv_vsrl_vx_u16m2(__riscv_vreinterpret_v_u8m2_u16m2(v3), 4, vl16m2));

		vuint8m2_t idx2 = __riscv_vand_vx_u8m2(v2, 0xF, vl);
		vuint8m2_t idx1 = __riscv_vand_vx_u8m2(s1, 0xF, vl);
		vuint8m2_t idx3 = __riscv_vand_vx_u8m2(s3, 0xF, vl);

		#define VRGATHER_u8m1x2(tbl, idx) \
			__riscv_vset_v_u8m1_u8m2(__riscv_vlmul_ext_v_u8m1_u8m2( \
				__riscv_vrgather_vv_u8m1(tbl, __riscv_vget_v_u8m2_u8m1(idx, 0), vl8m1)), 1, \
				__riscv_vrgather_vv_u8m1(tbl, __riscv_vget_v_u8m2_u8m1(idx, 1), vl8m1));

		vuint8m2_t err1 = VRGATHER_u8m1x2(err1tbl, idx1);
		vuint8m2_t err2 = VRGATHER_u8m1x2(err2tbl, idx2);
		vuint8m2_t err3 = VRGATHER_u8m1x2(err3tbl, idx3);
		vint8m2_t errs = __riscv_vreinterpret_v_u8m2_i8m2(__riscv_vand_vv_u8m2(__riscv_vand_vv_u8m2(err1, err2, vl), err3, vl));

		vbool4_t is_3 = __riscv_vmsgtu_vx_u8m2_b4(v1, 0b11100000-1, vl);
		vbool4_t is_4 = __riscv_vmsgtu_vx_u8m2_b4(v0, 0b11110000-1, vl);
		vbool4_t is_34 = __riscv_vmor_mm_b4(is_3, is_4, vl);
		vbool4_t err34 = __riscv_vmxor_mm_b4(is_34, __riscv_vmslt_vx_i8m2_b4(errs, 0, vl), vl);
		vbool4_t errm = __riscv_vmor_mm_b4(__riscv_vmsgt_vx_i8m2_b4(errs, 0, vl), err34, vl);
		if (__riscv_vfirst_m_b4(errm , vl) >= 0)
			return 0;

		/* decoding */

		/* mask of non continuation bytes */
		vbool4_t m = __riscv_vmsgt_vx_i8m2_b4(__riscv_vreinterpret_v_u8m2_i8m2(v0), -65, vl);
		vlOut = __riscv_vcpop_m_b4(m, vl);

		/* extract first and second bytes */
		vuint8m2_t b1 = __riscv_vcompress_vm_u8m2(v0, m, vl);
		vuint8m2_t b2 = __riscv_vcompress_vm_u8m2(v1, m, vl);

		/* fast path: one and two byte */
		if (max < 0b11100000) {
			b2 = __riscv_vand_vx_u8m2(b2, 0b00111111, vlOut);

			vbool4_t m1 = __riscv_vmsgtu_vx_u8m2_b4(b1, 0b10111111, vlOut);
			b1 = __riscv_vand_vx_u8m2_mu(m1, b1, b1, 63, vlOut);

			vuint16m4_t b12 = __riscv_vwmulu_vv_u16m4(b1, __riscv_vmerge_vxm_u8m2(__riscv_vmv_v_x_u8m2(1, vlOut), 1<<6, m1, vlOut), vlOut);
			 b12 = __riscv_vwaddu_wv_u16m4_mu(m1, b12, b12, b2, vlOut);
#if TO_16
			__riscv_vse16_v_u16m4(dest, b12, vlOut);
#else
			__riscv_vse32_v_u32m8(dest, __riscv_vzext_vf2_u32m8(b12, vlOut), vlOut);
#endif
			continue;
		}

		/* fast path: one, two and three byte */
		if (max < 0b11110000) {
			vuint8m2_t b3 = __riscv_vcompress_vm_u8m2(v2, m, vl);

			b2 = __riscv_vand_vx_u8m2(b2, 0b00111111, vlOut);
			b3 = __riscv_vand_vx_u8m2(b3, 0b00111111, vlOut);

			vbool4_t m1 = __riscv_vmsgtu_vx_u8m2_b4(b1, 0b10111111, vlOut);
			vbool4_t m3 = __riscv_vmsgtu_vx_u8m2_b4(b1, 0b11011111, vlOut);

			vuint8m2_t t1 = __riscv_vand_vx_u8m2_mu(m1, b1, b1, 63, vlOut);
			b1 = __riscv_vand_vx_u8m2_mu(m3, t1, b1, 15, vlOut);

			vuint16m4_t b12 = __riscv_vwmulu_vv_u16m4(b1, __riscv_vmerge_vxm_u8m2(__riscv_vmv_v_x_u8m2(1, vlOut), 1<<6, m1, vlOut), vlOut);
			b12 = __riscv_vwaddu_wv_u16m4_mu(m1, b12, b12, b2, vlOut);
			vuint16m4_t b123 = __riscv_vwaddu_wv_u16m4_mu(m3, b12, __riscv_vsll_vx_u16m4_mu(m3, b12, b12, 6, vlOut), b3, vlOut);
#if TO_16
			__riscv_vse16_v_u16m4(dest, b123, vlOut);
#else
			__riscv_vse32_v_u32m8(dest, __riscv_vzext_vf2_u32m8(b123, vlOut), vlOut);
#endif
			continue;
		}


		/* extract third and fourth bytes */
		vuint8m2_t b3 = __riscv_vcompress_vm_u8m2(v2, m, vl);
		vuint8m2_t b4 = __riscv_vcompress_vm_u8m2(v3, m, vl);

#define M1_COMMON(idx) \
	vuint8m1_t c1 = __riscv_vget_v_u8m2_u8m1(b1, idx); \
	vuint8m1_t c2 = __riscv_vget_v_u8m2_u8m1(b2, idx); \
	vuint8m1_t c3 = __riscv_vget_v_u8m2_u8m1(b3, idx); \
	vuint8m1_t c4 = __riscv_vget_v_u8m2_u8m1(b4, idx); \
	/* remove prefix from trailing bytes */ \
	c2 = __riscv_vand_vx_u8m1(c2, 0b00111111, vlOut); \
	c3 = __riscv_vand_vx_u8m1(c3, 0b00111111, vlOut); \
	c4 = __riscv_vand_vx_u8m1(c4, 0b00111111, vlOut); \
	/* remove prefix from leading bytes
	 *
	 * We shift left and then right by the number of bytes in the prefix,
	 * which can be calculated as follows:
	 *         x                                max(x-10, 0)
	 * 0xxx -> 0000-0111 -> sift by 0 or 1   -> 0
	 * 10xx -> 1000-1011 -> don't care
	 * 110x -> 1100,1101 -> sift by 3        -> 2,3
	 * 1110 -> 1110      -> sift by 4        -> 4
	 * 1111 -> 1111      -> sift by 5        -> 5
	 *
	 * vssubu.vx v, 10, (max(x-10, 0)) almost gives us what we want, we
	 * just need to manually detect and handle the one special case:
	 */ \
	vuint8m1_t shift = __riscv_vsrl_vx_u8m1(c1, 4, vlOut); \
	shift = __riscv_vmerge_vxm_u8m1(__riscv_vssubu_vx_u8m1(shift, 10, vlOut), 3, __riscv_vmseq_vx_u8m1_b8(shift, 12, vlOut), vlOut); \
\
	c1 = __riscv_vsll_vv_u8m1(c1, shift, vlOut); \
	c1 = __riscv_vsrl_vv_u8m1(c1, shift, vlOut); \
	/* unconditionally widen and combine to c1234 */ \
	vuint16m2_t c34 = __riscv_vwaddu_wv_u16m2(__riscv_vwmulu_vx_u16m2(c3,1<<6, vlOut), c4, vlOut); \
	vuint16m2_t c12 = __riscv_vwaddu_wv_u16m2(__riscv_vwmulu_vx_u16m2(c1,1<<6, vlOut), c2, vlOut); \
	vuint32m4_t c1234 = __riscv_vwaddu_wv_u32m4(__riscv_vwmulu_vx_u32m4(c12, 1 << 12, vlOut), c34, vlOut); \
	/* derive required right-shift amount from `shift` to reduce
	 * c1234 to the required number of bytes */ \
	c1234 = __riscv_vsrl_vv_u32m4(c1234, __riscv_vzext_vf4_u32m4( \
		__riscv_vmul_vx_u8m1(__riscv_vrsub_vx_u8m1(__riscv_vssubu_vx_u8m1(shift, 2, vlOut), 3, vlOut), 6, vlOut), \
		vlOut), vlOut);

#define DOWN __riscv_vreinterpret_v_u32m4_u16m4
#define UP __riscv_vreinterpret_v_u16m4_u32m4

#if !TO_16
#define M1_STORE \
	size_t vlDest = vlOut; \
	__riscv_vse32_v_u32m4(dest, c1234, vlDest);
#else
#define M1_STORE \
	/* convert [000000000000aaaa|aaaaaabbbbbbbbbb]
	 * to      [110111bbbbbbbbbb|110110aaaaaaaaaa] */ \
	vuint32m4_t sur = __riscv_vsub_vx_u32m4(c1234, 0x10000, vlOut); \
	sur = __riscv_vor_vv_u32m4( \
		__riscv_vsll_vx_u32m4(sur, 16, vlOut), \
		__riscv_vsrl_vx_u32m4(sur, 10, vlOut), \
		vlOut); \
	sur = __riscv_vand_vx_u32m4(sur, 0x3FF03FF, vlOut); \
	sur = __riscv_vor_vx_u32m4(sur, 0xDC00D800, vlOut); \
	/* merge 1 byte c1234 and 2 byte sur */ \
	vbool8_t m4 = __riscv_vmsgtu_vx_u32m4_b8(c1234, 0xFFFF, vlOut); \
	c1234 = __riscv_vmerge_vvm_u32m4(c1234, sur, m4, vlOut); \
	/* compress and store */ \
	vbool4_t mOut = __riscv_vmor_mm_b4(__riscv_vmsne_vx_u16m4_b4(DOWN(c1234), 0, vlOut*2), m4even, vlOut*2); \
	c1234 = UP(__riscv_vcompress_vm_u16m4(DOWN(c1234), mOut, vlOut*2)); \
	size_t vlDest = __riscv_vcpop_m_b4(mOut, vlOut*2); \
	__riscv_vse16_v_u16m4(dest, DOWN(c1234), vlDest);
#endif

		/* Unrolling this manually reduces register pressure and allows
		 * us to terminate early. */
		{
			size_t vlOutm2 = vlOut;
			vlOut = __riscv_vsetvl_e8m1(vlOut);
			M1_COMMON(0)
			M1_STORE
			if (vlOutm2 == vlOut) {
				vlOut = vlDest;
				continue;
			}

			dest += vlDest;
			vlOut = vlOutm2 - vlOut;
		}
		{
			M1_COMMON(1)
			M1_STORE
			vlOut = vlDest;
		}

#undef M1_COMMON
#undef M1_STORE
#undef DOWN
#undef UP
	}

	/* validate the last character and reparse it + tail */
	if (count > tail) {
		if ((src[0] >> 6) == 0b10)
			--dest;
		while ((src[0] >> 6) == 0b10 && tail < count)
			--src, ++tail;
#if TO_16
		/* go back one more, when on high surrogate */
		if (dest[-1] >= 0xD800 && dest[-1] <= 0xDBFF)
			--dest;
#endif
	}
	size_t ret = utf8_to_utf32_scalar(src, tail, dest);
	if (ret == 0) return 0;
	return (size_t)(dest - destBeg) + ret;
}

#undef uintOut_t
#undef utf8_to_utf32_scalar
#undef utf8_to_utf32_rvv

