.POSIX:

include ../config.mk

BENCHS=bench_8to32 bench_8to16 bench_16to8

all: ${BENCHS}

bench_8to16: bench.c 8toN_gather.c
	${CC} ${CFLAGS} -DNAME=utf8_to_utf16 -DTO_16=1 8toN_gather.c bench.c -o $@

bench_8to32: bench.c 8toN_gather.c
	${CC} ${CFLAGS} -DNAME=utf8_to_utf32 8toN_gather.c bench.c -o $@

bench_16to8: bench.c 16to8_gather.c
	${CC} ${CFLAGS} -DNAME=utf16_to_utf8 16to8_gather.c bench.c -o $@

clean:
	rm -f ${BENCHS}


