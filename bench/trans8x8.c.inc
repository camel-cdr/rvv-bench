static void
trans8x8_seq_scalar(T *restrict dest, T const *restrict src1, T const *restrict srcvl, size_t n)
{
	size_t stride = n*8;
	T buf[8*8];
	for (; n--; src1 += 8*8, dest += 8) {
		for (size_t x = 0; x < 8; ++x)
		for (size_t y = 0; y < 8; y += 2) {
			T s1 = src1[y*8+x];
			T s2 = src1[y*8+8+x];
			T sum = (s1 + s2) >> 1;
			buf[y*8+x]   = s1 - sum;
			buf[y*8+8+x] = s2 - sum;
			BENCH_CLOBBER();
		}

		for (size_t x = 0; x < 8; ++x)
		for (size_t y = 0; y < 8; y += 2) {
			T s1 = buf[x*8+y];
			T s2 = buf[x*8+y+1];
			T sum = (s1 + s2) >> 1;
			dest[y*stride+x]        = s1 - sum;
			dest[y*stride+stride+x] = s2 - sum;
			BENCH_CLOBBER();
		}
	}
}

static void
trans8x8_seq_scalar_autovec(T *restrict dest, T const *restrict src1, T const *restrict srcvl, size_t n)
{
	size_t stride = n*8;
	T buf[8*8];
	for (; n--; src1 += 8*8, dest += 8) {
		for (size_t y = 0; y < 8; y += 2)
		for (size_t x = 0; x < 8; ++x) {
			T s1 = src1[y*8+x];
			T s2 = src1[y*8+8+x];
			T sum = (s1 + s2) >> 1;
			buf[y*8+x]   = s1 - sum;
			buf[y*8+8+x] = s2 - sum;
		}

		for (size_t y = 0; y < 8; y += 2)
		for (size_t x = 0; x < 8; ++x) {
			T s1 = buf[x*8+y];
			T s2 = buf[x*8+y+1];
			T sum = (s1 + s2) >> 1;
			dest[y*stride+x]        = s1 - sum;
			dest[y*stride+stride+x] = s2 - sum;
		}
	}
}

typedef void Func(T *restrict dest, T const *restrict src1, T const *restrict srcvl, size_t n);

#define DECLARE(f,_) extern Func trans8x8_##f;
IMPLS(DECLARE)

#define EXTRACT(f,skipCheck) { #f, &trans8x8_##f, skipCheck },
Impl impls[] = { IMPLS(EXTRACT) };

T *dest, *src1, *src2;

void init(void) {
	size_t n = MAX_MEM/sizeof(T)/4;
	dest = (T*)mem;
	src1 = dest + n;
	src2 = src1 + n;

	extern size_t get_trans8x8_count();
	size_t cnt = get_trans8x8_count();

	for (size_t i = 0; i < n/8/8/cnt; ++i)
	for (size_t j = 0; j < cnt; ++j)
	for (size_t y = 0; y < 8; ++y)
	for (size_t x = 0; x < 8; ++x)
		src2[i*cnt*8*8 + j*8 + y*cnt*8 + x] = src1[(i*cnt+j)*8*8 + y*8 + x];
}

ux checksum(size_t n) {
	ux sum = 0;
	for (size_t i = 0; i < n/sizeof(T); ++i)
		sum = uhash(sum) + dest[i];
	return sum;
}

BENCH_BEG(base) {
	memset(dest, 0, n);
	n /= sizeof(T)*8*8;
	TIME f(dest, src1, src2, n);
} BENCH_END

