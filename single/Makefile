.POSIX:

include ../config.mk

EXECS=veclibm

all: ${EXECS}

veclibm: veclibm.c
	${CC} ${CFLAGS} -o $@ $< ../thirdparty/veclibm/src/*.c -I ../thirdparty/veclibm/include -lm -Wno-unused -Wno-maybe-uninitialized

clean:
	rm -f ${EXECS}

