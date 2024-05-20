.POSIX:

include ../../config.mk

all: rvv-1.0

rvv-1.0: main.S main.c config.h
	m4 main.S > gen.S
	${CC} ${CFLAGS} -s gen.S main.c -o $@
	rm gen.S

clean:
	rm -f rvv-1.0

run: rvv-1.0
	../../run.sh ./rvv-1.0
