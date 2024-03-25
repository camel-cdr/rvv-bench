.POSIX:

include ../../config.mk

all: rvim

rvim: main.S main.c ../common/config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f rvim

run: rvim
	../../run.sh ./rvim
