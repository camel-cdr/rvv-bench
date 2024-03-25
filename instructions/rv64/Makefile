.POSIX:

include ../../config.mk

all: rv64

rv64: main.S main.c config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f rv64

run: rv64
	../../run.sh ./rv64
