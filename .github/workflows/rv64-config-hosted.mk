WARN=-Wall -Wextra -Wno-unused-function -Wno-unused-parameter
CC=riscv64-linux-gnu-gcc
CFLAGS=-march=rv64gcv_zfh_zba_zbb_zbs -O3 ${WARN}
