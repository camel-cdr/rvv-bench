.POSIX:

include ../../config.mk

all: rvv

rvv: gen.S main.c config.h
	m4 gen.S > main.S
	${CC} ${CFLAGS} main.S main.c -o $@
	rm main.S

clean:
	rm -f rvv

run: rvv
	../../run.sh ./rvv
