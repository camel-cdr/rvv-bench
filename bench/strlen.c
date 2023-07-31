#include "bench.h"

size_t
strlen_scalar(char const *s)
{
	char const *a = s;
	while (*s) { ++s; BENCH_CLOBBER(); }
	return s - a;
}

/* https://git.musl-libc.org/cgit/musl/tree/src/string/strlen.c */
#define ONES ((size_t)-1/UCHAR_MAX)
#define HIGHS (ONES * (UCHAR_MAX/2+1))
#define HASZERO(x) (((x)-ONES) & ~(x) & HIGHS)
size_t
strlen_musl(char const *s)
{
	char const *a = s;
#ifdef __GNUC__
	typedef size_t __attribute__((__may_alias__)) word;
	word const *w;
	for (; (uintptr_t)s % sizeof *w; s++) if (!*s) return s-a;
	for (w = (void const*)s; !HASZERO(*w); w++);
	s = (void const*)w;
#endif
	for (; *s; s++);
	return s-a;
}

#define strlen_libc strlen

#define IMPLS(f) \
	f(libc) \
	MX(f, rvv_page_aligned) \
	f(musl) \
	f(scalar) \
	MX(f, rvv) \


typedef size_t Func(char const *s);

#define DECLARE(f) extern Func strlen_##f;
IMPLS(DECLARE)

#define EXTRACT(f) { #f, &strlen_##f },
Impl impls[] = { IMPLS(EXTRACT) };

uint64_t last;

void init(void) {
	for (size_t i = 0; i < MAX_MEM; ++i)
		mem[i] += !mem[i]; // remove null bytes
}

uint64_t checksum(size_t n) { return last; }

BENCH(base) {
	char *p = (char*)mem + (randu64() % 511);
	p[n] = 0;
	TIME last = f(p);
	p[n] = randu64() | 1;
} BENCH_END

Bench benches[] = {
	{ MAX_MEM - 521, "strlen", bench_base },
}; BENCH_MAIN(impls, benches)

