#define NOLIBC_MAIN
#include "../../nolibc.h"
#include "../scalar.h"

static URand randState = { 123, 456, 789 };

static uint64_t randu64(void) { return urand(&randState); }

static void
print_b8(uint8_t val)
{
	if (printEnd - printIt < 8) print_flush();
	size_t n = 8;
	while (n--) *printIt++ = (val >> 7) + '0', val <<= 1;
}

static void
print_b16(uint16_t val)
{
	if (printEnd - printIt < 16) print_flush();
	size_t n = 16;
	while (n--) *printIt++ = (val >> 15) + '0', val <<= 1;
}

static void
print_b32(uint32_t val)
{
	if (printEnd - printIt < 32) print_flush();
	size_t n = 32;
	while (n--) *printIt++ = (val >> 31) + '0', val <<= 1;
}

