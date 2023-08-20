#!/bin/sh

# configure `make run` to work with your setup

# local execution
./$@

# using qemu
# qemu-riscv64 -E LD_LIBRARY_PATH=/usr/riscv64-linux-gnu/lib -cpu rv64,v=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=on,rvv_ma_all_1s=on /usr/riscv64-linux-gnu/lib/ld-linux-riscv64-lp64d.so.1 $@
# qemu-riscv64 -E LD_LIBRARY_PATH=/usr/riscv64-linux-gnu/lib -cpu rv64,v=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=on,rvv_ma_all_1s=on,Zfh=true,x-zvfh=true /usr/riscv64-linux-gnu/lib/ld-linux-riscv64-lp64d.so.1 $@

# upload and run on ssh
# scp -i ~/.ssh/XXX -r "$1" USER@XXX.XXX.XXX.XXX:/home/USER
# ssh -i ~/.ssh/XXX USER@XXX.XXX.XXX.XXX "$@"
