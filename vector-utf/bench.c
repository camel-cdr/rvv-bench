#define NOLIBC_MAIN
#include "../nolibc.h"
#include "scalar.h"

size_t utf8_to_utf16_rvv(char const *src, size_t n, uint16_t *dest);
size_t utf8_to_utf32_rvv(char const *src, size_t n, uint32_t *dest);
size_t utf16_to_utf8_rvv(const uint16_t *src, size_t count, char *dest);


#define MAX_IN (1024*1024*4)
static uint64_t in[MAX_IN];
static uint64_t out[MAX_IN * 4];

#define NUM_REPEATS 3000

#define PCAT(a,b) a##b
#define CAT(a,b) PCAT(a,b)
#define RVV CAT(NAME, _rvv)
#define SCALAR CAT(NAME, _scalar)

#define SCALE_utf8_to_utf16 1
#define SCALE_utf8_to_utf32 1
#define SCALE_utf16_to_utf8 2
#define SCALE CAT(SCALE_, NAME)

int
main(void)
{
	size_t inSize = memread(in, sizeof in);
	if (inSize == 0) {
		print("No input provided, please pipe it into the program\n");
		return 1;
	}
	for (size_t s = 1; s; ) {
		s = memread((uint8_t*)in + inSize, (sizeof in) - inSize);
		inSize += s;
	}

	uint64_t beg, end;

	beg = rv_cycles();
	for (size_t j = 0; j < NUM_REPEATS; ++j)
		SCALAR((void*)in, inSize / SCALE, (void*)out);
	end = rv_cycles();

	double scalar_bc = inSize*(double)NUM_REPEATS / (end - beg);

	beg = rv_cycles();
	for (size_t j = 0; j < NUM_REPEATS; ++j)
		RVV((void*)in, inSize / SCALE, (void*)out);
	end = rv_cycles();

	double rvv_bc  = inSize*(double)NUM_REPEATS / (end - beg);

	print("scalar: ")(f,scalar_bc)(" b/c  rvv: ")(f,rvv_bc)(" b/c  speedup: ")(f,rvv_bc/scalar_bc)("x\n");

	return 0;
}

