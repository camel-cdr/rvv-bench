.POSIX:

include ../../config.mk

all: rvm

rvm: main.S main.c ../common/config.h
	${CC} ${CFLAGS} main.S main.c -o $@

clean:
	rm -f rvm

run: rvm
	../../run.sh ./rvm
