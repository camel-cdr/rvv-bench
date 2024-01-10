#include "common.h"

size_t utf8_to_utf16_rvv(char const *src, size_t n, uint16_t *dest);

#define MAX_UTF32_CHARS (1024*16)
static uint32_t utf32[MAX_UTF32_CHARS];
static uint16_t out[MAX_UTF32_CHARS*2];
static uint16_t golden[MAX_UTF32_CHARS*2];
static uint8_t in[MAX_UTF32_CHARS*4];

static void
test(size_t length, size_t bitFlipCount)
{
	size_t len32 = randu64() % length, origLen;
	origLen = len32;
	for (size_t i = 0; i < len32; ++i) {
		do utf32[i] = randu64() >> (64 - randu64() % 22);
		while (utf32[i] > 0x10FFFF || (utf32[i] >= 0xD800 && utf32[i] <= 0xDFFF));
	}
	size_t lenIn = utf32_to_utf8_scalar(utf32, len32, (char*)in);

	if (lenIn)
	for (size_t i = 0; i < bitFlipCount; ++i)
		in[randu64() % lenIn] ^= 1 << (randu64() & (sizeof *in - 1));

	size_t lenGolden = utf8_to_utf16_scalar((char*)in, lenIn, golden);
	size_t lenOut = utf8_to_utf16_rvv((char*)in, lenIn, out);

	if (lenGolden != lenOut) {
		print("ERROR: length mismatch, expected ")(u,lenGolden)(" got ")(u,lenOut)(" from ")(u,origLen)("\n");
		for (size_t i = 0; i < lenIn; ++i)
			print(b8,in[i])(" ");
		flush();exit(0);
		return;
	}
	for (size_t i = 0; i < lenGolden; ++i) {
		if (golden[i] != out[i]) {
			print("ERROR: at ")(u,i)("/")(u,lenGolden)(" expected ")(u,golden[i])(" got ")(u,out[i])("\n");
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
		print("\r")(u,i)("          "), flush();
	}
	return 0;
}

