.POSIX:

include ../config.mk

EXECS=memcpy memset utf8_count strlen mergelines mandelbrot chacha20 poly1305 ascii_to_utf16 ascii_to_utf32

all: ${EXECS}

.c: $@.S template.S config.h bench.h
	${CC} ${CFLAGS} -o $@ $< -DINC=$@.S template.S -lm

clean:
	rm -f ${EXECS}

run: all
	for i in ${EXECS}; do ../run.sh ./$$i; done

