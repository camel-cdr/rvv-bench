.POSIX:

include ../../config.mk

TESTS=8to32 8to16 16to8

all: ${TESTS}

8to16: 8to16.c common.h ../8toN_gather.c
	${CC} ${CFLAGS} -DTO_16=1 -o 8to16 8to16.c ../8toN_gather.c

8to32: 8to32.c common.h ../8toN_gather.c
	${CC} ${CFLAGS} -o 8to32 8to32.c ../8toN_gather.c

16to8: 16to8.c common.h ../16to8_gather.c
	${CC} ${CFLAGS} -o 16to8 16to8.c ../16to8_gather.c

clean:
	rm -f ${TESTS}


