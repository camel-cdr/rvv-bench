#define NOLIBC_MAIN
#include "../../nolibc.h"
#include "../scalar.h"

#define ROTL(x,k) (((x) << (k)) | ((x) >> (8 * sizeof(x) - (k))))

typedef struct { uint64_t x, y; } RandState;
static RandState randState = { 123, 456 };

/* RomuDuoJr, see https://romu-random.org/ */
static uint64_t
randu64(void)
{
	uint64_t xp = randState.x;
	randState.x = 15241094284759029579u * randState.y;
	randState.y = randState.y - xp;
	randState.y = (randState.y << 27) | (randState.y >> 37);
	return xp;
}

static void
print_b8(uint8_t val)
{
	if (printEnd - printIt < 8) flush();
	size_t n = 8;
	while (n--) *printIt++ = (val >> 7) + '0', val <<= 1;
}

static void
print_b16(uint16_t val)
{
	if (printEnd - printIt < 16) flush();
	size_t n = 16;
	while (n--) *printIt++ = (val >> 15) + '0', val <<= 1;
}

static void
print_b32(uint32_t val)
{
	if (printEnd - printIt < 32) flush();
	size_t n = 32;
	while (n--) *printIt++ = (val >> 31) + '0', val <<= 1;
}

