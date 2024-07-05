WARN=-Wall -Wextra -Wno-unused-function -Wno-unused-parameter
CC=clang-17
CFLAGS=--target=riscv32 -march=rv32gc_zve32f_zfh_zba_zbb_zbs -O3 ${WARN} -nostdlib -fno-builtin -nodefaultlibs -ffreestanding
