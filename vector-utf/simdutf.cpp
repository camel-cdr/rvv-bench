#include <cstddef>
#include <simdutf.h>
#include <simdutf.cpp>

extern "C" {

size_t
utf8_to_utf16_rvv(char const *src, size_t count, uint16_t *dest)
{
	return simdutf::convert_utf8_to_utf16le(src, count, (char16_t*)dest);
}

size_t
utf8_to_utf32_rvv(char const *src, size_t count, uint32_t *dest)
{
	return simdutf::convert_utf8_to_utf32(src, count, (char32_t*)dest);
}

size_t
utf16_to_utf8_rvv(uint16_t const *src, size_t count, char *dest)
{
	return simdutf::convert_utf16le_to_utf8((char16_t*)src, count, dest);
}

}

