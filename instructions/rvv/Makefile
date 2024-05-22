.POSIX:

include ../../config.mk

all: rvv

rvv: main.S main.c config.h
	m4 main.S > gen.S
	${CC} ${CFLAGS} -s gen.S main.c -o $@
	rm gen.S

clean:
	rm -f rvv

run: rvv
	../../run.sh ./rvv
