.POSIX:

include ../../config.mk

all: rvi

rvi: main.S main.c config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f rvi

run: rvi
	../../run.sh ./rvi
