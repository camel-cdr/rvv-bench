.POSIX:

include ../../config.mk

all: rvv-1.0

rvv-1.0: main.S main.c types.h ../common/config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f rvv-1.0

run: rvv-1.0
	../../run.sh ./rvv-1.0
