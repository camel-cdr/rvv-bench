.POSIX:

include ../config.mk

EXECS=uarch veclibm

all: ${EXECS}

uarch: uarch.S uarch.c
	${CC} ${CFLAGS} -o $@ uarch.c uarch.S

veclibm: veclibm.c
	${CC} ${CFLAGS} -o $@ $< ../thirdparty/veclibm/src/*.c -I ../thirdparty/veclibm/include -lm -Wno-unused -Wno-maybe-uninitialized


clean:
	rm -f ${EXECS}

