#include "common.h"

size_t utf8_to_utf32_rvv(char const *src, size_t n, uint32_t *dest);

#define MAX_UTF32_CHARS (1024*16)
static uint32_t utf32[MAX_UTF32_CHARS];
static uint32_t out[MAX_UTF32_CHARS];
static uint8_t in[MAX_UTF32_CHARS*4];

static void
test(size_t maxlen32, size_t bitFlipCount)
{
	size_t len32 = randu64() % maxlen32;
	for (size_t i = 0; i < len32; ++i) {
		do utf32[i] = randu64() >> (64 - randu64() % 22);
		while (utf32[i] > 0x10FFFF || (utf32[i] >= 0xD800 && utf32[i] <= 0xDFFF));
	}
	size_t lenIn = utf32_to_utf8_scalar(utf32, len32, (char*)in);

	if (lenIn)
	for (size_t i = 0; i < bitFlipCount; ++i)
		in[randu64() % lenIn] ^= 1 << (sizeof *in - 1);

	if (bitFlipCount)
		len32 = utf8_to_utf32_scalar((char*)in, lenIn, utf32);
	size_t lenOut = utf8_to_utf32_rvv((char*)in, lenIn, out);

	if (len32 != lenOut) {
		print("ERROR: length mismatch, expected ")(u,len32)(" got ")(u,lenOut)("\n");
		print("\nin:  ");
		for (size_t i = 0; i < lenIn; ++i)
			print(b8,in[i])(" ");
		print("\nout: ");
		for (size_t i = 0; i < lenOut; ++i)
			print(b32,out[i])(" ");
		print("\ntar: ");
		for (size_t i = 0; i < len32; ++i)
			print(b32,utf32[i])(" ");
		print_flush();exit(0);
		return;
	}
	for (size_t i = 0; i < len32; ++i) {
		if (utf32[i] != out[i]) {
			print("ERROR: at ")(u,i)("/")(u,len32)(" expected ")(u,utf32[i])(" got ")(u,out[i])("\n");
			return;
		}
	}
}

int
main(void)
{
	randState.x ^= rv_cycles();
	for (size_t i = 0; i < 10000000; ++i) {
		test(10,   2);
		test(10,   10);
		test(10,   100);
		test(100,  2);
		test(100,  10);
		test(100,  100);
		test(400,  2);
		test(400,  10);
		test(2000, 2);
		test(2000, 100);
		if ((i & 127) == 0)
		print("\r")(u,i)("          ")(flush,);
	}
	return 0;

}

