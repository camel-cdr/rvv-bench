#include <riscv_vector.h>

size_t utf16_to_utf8_scalar(uint16_t const *src, size_t count, char *dest);

size_t
utf16_to_utf8_rvv(uint16_t const *src, size_t count, char *dest)
{
	size_t n = count;
	char *const destBeg = dest;

	for (size_t vl, vlOut; n > 0; ) {

		vl = __riscv_vsetvl_e16m2(n);

		vuint16m2_t v0 = __riscv_vle16_v_u16m2(src, vl);
#if 0
		uint64_t max = __riscv_vmv_x_s_u16m1_u16(__riscv_vredmaxu_vs_u16m2_u16m1(v0, __riscv_vmv_s_x_u16m1(0, vl), vl));

		if (max < 0x80) { /* 1 byte utf8 */
#else

		if (__riscv_vfirst(__riscv_vmsgtu(v0, 0x7f, vl),vl) < 0) { /* 1 byte utf8 */
#endif
			vlOut = vl;
			__riscv_vse8_v_u8m1((uint8_t*)dest, __riscv_vncvt_x_x_w_u8m1(v0, vlOut), vlOut);
			n -= vl, src += vl, dest += vlOut;
			continue;
		}

		vbool8_t m34 = __riscv_vmsgtu_vx_u16m2_b8(v0, 0x800-1, vl);
		int first = __riscv_vfirst_m_b8(m34, vl);
		size_t tail = vl - first;
		vl = first < 0 ? vl : first;

		if (vl > 0) { /* 1/2 byte utf8 */
			vbool8_t m234 = __riscv_vmsgtu_vx_u16m2_b8(v0, 0x80-1, vl);
			/* 0: [     abc|defghijk]
			 * 1: [defghijk|        ] vsll 8
			 * 2: [        |   abcde] vsrl 6
			 * 3: [00111111|00111111]
			 * 4: [  fghijk|000abcde] (1|2)&3
			 * 5: [11000000|11000000]
			 * 6: [10fghijk|110abcde] 4|5
			 */
			vuint16m2_t twoByte  =
				__riscv_vand_vx_u16m2(__riscv_vor_vv_u16m2(
					__riscv_vsll_vx_u16m2(v0, 8, vl),
					__riscv_vsrl_vx_u16m2(v0, 6, vl),
				vl), 0b0011111100111111, vl);
			v0 = __riscv_vor_vx_u16m2_mu(m234, v0, twoByte, 0b1000000011000000, vl);
			vuint8m2_t vout = __riscv_vreinterpret_v_u16m2_u8m2(v0);

			/* Every high byte that is zero should be compressed
			 * low bytes should never be compressed, so we set them
			 * to all ones, and then create a non-zero bytes mask */
			vbool4_t mcompress = __riscv_vmsne_vx_u8m2_b4(__riscv_vreinterpret_v_u16m2_u8m2(__riscv_vor_vx_u16m2(v0, 0xFF, vl)), 0, vl*2);
			vlOut = __riscv_vcpop_m_b4(mcompress, vl*2);

			vout = __riscv_vcompress_vm_u8m2(vout, mcompress, vl*2);
			__riscv_vse8_v_u8m2((uint8_t*)dest, vout, vlOut);

			n -= vl, src += vl, dest += vlOut;
		}

		if (tail) while (n) {
			uint16_t word = *src;
			if((word & 0xFF80)==0) {
				break;
			} else if((word & 0xF800)==0) {
				break;
			} else if ((word & 0xF800) != 0xD800) {
				// will generate three UTF-8 bytes
				// we have 0b1110XXXX 0b10XXXXXX 0b10XXXXXX
				*dest++ = (char)((word>>12) | 0b11100000);
				*dest++ = (char)(((word>>6) & 0b111111) | 0b10000000);
				*dest++ = (char)((word & 0b111111) | 0b10000000);
				++src;
				--n;
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

