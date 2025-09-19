.POSIX:

include ../config.mk

EXECS=memcpy memset memreverse utf8_count strlen mergelines mandelbrot chacha20 poly1305 ascii_to_utf16 ascii_to_utf32 byteswap LUT4 LUT6 hist base64_encode trans8x8e8 trans8x8e16

all: ${EXECS}

.c: $@.S template.S config.h bench.h
	${CC} ${CFLAGS} -o $@ $< -DINC=$@.S template.S

clean:
	rm -f ${EXECS}

run: all
	for i in ${EXECS}; do ../run.sh ./$$i || { printf "\n\n\033[0;31mFAILED\033[0m\n\n"; exit 1; } ; done

