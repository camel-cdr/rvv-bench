.POSIX:

include ../../config.mk

all: xtheadvector

xtheadvector: main.S main.c config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f xtheadvector

run: xtheadvector
	../../run.sh ./xtheadvector
