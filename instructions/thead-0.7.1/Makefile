.POSIX:

include ../../config.mk

all: thead-0.7.1

thead-0.7.1: main.S main.c config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f thead-0.7.1

run: thead-0.7.1
	../../run.sh ./thead-0.7.1
