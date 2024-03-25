#include <riscv_vector.h>

size_t utf16_to_utf8_scalar(uint16_t const *src, size_t count, char *dest);

size_t
utf16_to_utf8_rvv(uint16_t const *src, size_t count, char *dest)
{
	size_t n = count;
	char *const destBeg = dest;
	size_t vl8m4 = __riscv_vsetvlmax_e8m4();
	vbool2_t m4mulp2 = __riscv_vmseq_vx_u8m4_b2(__riscv_vand_vx_u8m4(__riscv_vid_v_u8m4(vl8m4), 3, vl8m4), 2, vl8m4);

	for (size_t vl, vlOut; n > 0; ) {

		vl = __riscv_vsetvl_e16m2(n);

		vuint16m2_t v = __riscv_vle16_v_u16m2(src, vl);
		vbool8_t m234 = __riscv_vmsgtu_vx_u16m2_b8(v, 0x80-1, vl);

		if (__riscv_vfirst_m_b8(m234,vl) < 0) { /* 1 byte utf8 */
			vlOut = vl;
			__riscv_vse8_v_u8m1((uint8_t*)dest, __riscv_vncvt_x_x_w_u8m1(v, vlOut), vlOut);
			n -= vl, src += vl, dest += vlOut;
			continue;
		}

		vbool8_t m34  = __riscv_vmsgtu_vx_u16m2_b8(v, 0x800-1, vl);

		if (__riscv_vfirst_m_b8(m34,vl) < 0) { /* 1/2 byte utf8 */
			/* 0: [     aaa|aabbbbbb]
			 * 1: [aabbbbbb|        ] vsll 8
			 * 2: [        |   aaaaa] vsrl 6
			 * 3: [00111111|00111111]
			 * 4: [  bbbbbb|000aaaaa] (1|2)&3
			 * 5: [11000000|11000000]
			 * 6: [10bbbbbb|110aaaaa] 4|5 */
			vuint16m2_t twoByte  =
				__riscv_vand_vx_u16m2(__riscv_vor_vv_u16m2(
					__riscv_vsll_vx_u16m2(v, 8, vl),
					__riscv_vsrl_vx_u16m2(v, 6, vl),
				vl), 0b0011111100111111, vl);
			v = __riscv_vor_vx_u16m2_mu(m234, v, twoByte, 0b1000000011000000, vl);
			vuint8m2_t vout = __riscv_vreinterpret_v_u16m2_u8m2(v);

			/* Every high byte that is zero should be compressed
			 * low bytes should never be compressed, so we set them
			 * to all ones, and then create a non-zero bytes mask */
			vbool4_t mcomp = __riscv_vmsne_vx_u8m2_b4(__riscv_vreinterpret_v_u16m2_u8m2(__riscv_vor_vx_u16m2(v, 0xFF, vl)), 0, vl*2);
			vlOut = __riscv_vcpop_m_b4(mcomp, vl*2);

			vout = __riscv_vcompress_vm_u8m2(vout, mcomp, vl*2);
			__riscv_vse8_v_u8m2((uint8_t*)dest, vout, vlOut);

			n -= vl, src += vl, dest += vlOut;
			continue;
		}

		//vbool8_t sur = __riscv_vmsgtu_vx_u16m2_b8(v, 0xD800-1, vl);
		vbool8_t sur = __riscv_vmseq_vx_u16m2_b8(__riscv_vand_vx_u16m2(v, 0xF800, vl), 0xD800, vl);
		long first = __riscv_vfirst_m_b8(sur, vl);
		size_t tail = vl - first;
		vl = first < 0 ? vl : first;

		if (vl > 0) { /* 1/2/3 byte utf8 */
			/* in: [aaaabbbb|bbcccccc]
			 * v1: [0bcccccc|        ] vsll  8
			 * v1: [10cccccc|        ] vsll  8 & 0b00111111 | 0b10000000
			 * v2: [        |110bbbbb] vsrl  6 & 0b00111111 | 0b11000000
			 * v2: [        |10bbbbbb] vsrl  6 & 0b00111111 | 0b10000000
			 * v3: [        |1110aaaa] vsrl 12 | 0b11100000
			 *  1: [00000000|0bcccccc|00000000|00000000] => [0bcccccc]
			 *  2: [00000000|10cccccc|110bbbbb|00000000] => [110bbbbb] [10cccccc]
			 *  3: [00000000|10cccccc|10bbbbbb|1110aaaa] => [1110aaaa] [10bbbbbb] [10cccccc]
			 */
			vuint16m2_t v1, v2, v3, v12;
			v1 = __riscv_vor_vx_u16m2_mu(m234, v, __riscv_vand_vx_u16m2(v, 0b00111111, vl), 0b10000000, vl);
			v1 = __riscv_vsll_vx_u16m2(v1, 8, vl);

			v2 = __riscv_vor_vx_u16m2(__riscv_vand_vx_u16m2(__riscv_vsrl_vx_u16m2(v, 6, vl), 0b00111111, vl), 0b10000000, vl);
			v2 = __riscv_vor_vx_u16m2_mu(__riscv_vmnot_m_b8(m34,vl), v2, v2, 0b01000000, vl);
			v3 = __riscv_vor_vx_u16m2(__riscv_vsrl_vx_u16m2(v, 12, vl), 0b11100000, vl);
			v12 = __riscv_vor_vv_u16m2_mu(m234, v1, v1, v2, vl);

			vuint32m4_t w12 = __riscv_vwmulu_vx_u32m4(v12, 1<<8, vl);
			vuint32m4_t w123 = __riscv_vwaddu_wv_u32m4_mu(m34, w12, w12, v3, vl);
			vuint8m4_t vout = __riscv_vreinterpret_v_u32m4_u8m4(w123);

			vbool2_t mcomp = __riscv_vmor_mm_b2(m4mulp2, __riscv_vmsne_vx_u8m4_b2(vout, 0, vl*4), vl*4);
			vlOut = __riscv_vcpop_m_b2(mcomp, vl*4);

			vout = __riscv_vcompress_vm_u8m4(vout, mcomp, vl*4);
			__riscv_vse8_v_u8m4((uint8_t*)dest, vout, vlOut);

			n -= vl, src += vl, dest += vlOut;
		}

		if (tail) while (n) {
			uint16_t word = *src;
			if((word & 0xFF80)==0) {
				break;
			} else if((word & 0xF800)==0) {
				break;
			} else if ((word & 0xF800) != 0xD800) {
				break;
			} else {
				// must be a surrogate pair
				if (n <= 1) return 0;
				uint16_t diff = word - 0xD800;
				if (diff > 0x3FF) return 0;
				uint16_t diff2 = src[1] - 0xDC00;
				if (diff2 > 0x3FF) return 0;

				uint32_t value = ((diff + 0x40) << 10) + diff2 ;
				// uint32_t value = (diff << 10) + diff2 + 0x10000;

				// will generate four UTF-8 bytes
				// we have 0b11110XXX 0b10XXXXXX 0b10XXXXXX 0b10XXXXXX
				*dest++ = (char)((value>>18) | 0b11110000);
				*dest++ = (char)(((value>>12) & 0b111111) | 0b10000000);
				*dest++ = (char)(((value>>6) & 0b111111) | 0b10000000);
				*dest++ = (char)((value & 0b111111) | 0b10000000);
				src += 2;
				n-=2;
			}
		}
	}

	return (size_t)(dest - destBeg);
}

