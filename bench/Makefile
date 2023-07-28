.POSIX:

include ../config.mk

EXECS=memcpy memset utf8_count strlen mergelines mandelbrot

all: ${EXECS}

.c: $@.S template.S config.h
	$(CC) $(CFLAGS) -o $@ $< -DINC=$@.S template.S -lm

thead-0.7.1: main.S main.c common.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f ${EXECS}

run: all
	for i in ${EXECS}; do ../run.sh ./$$i; done

