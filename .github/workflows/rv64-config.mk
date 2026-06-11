WARN=-Wall -Wextra -Wno-unused-function -Wno-unused-parameter
CC=clang-20
CFLAGS=--target=riscv64 -march=rv64gcv_zba_zbb_zbs_zfh -O3 ${WARN} -nostdlib -fno-builtin -nodefaultlibs -ffreestanding
