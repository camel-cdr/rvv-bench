.POSIX:

include ../../config.mk

all: scalar

scalar: main.S main.c config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f scalar

run: scalar
	../../run.sh ./scalar
