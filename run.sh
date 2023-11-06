#!/bin/sh

# configure `make run` to work with your setup

# local execution
#./$@

# using qemu
qemu-riscv64 -cpu rv64,v=on,vext_spec=v1.0,vlen=256,rvv_ta_all_1s=on,rvv_ma_all_1s=on,Zfh=true,x-zvfh=true $@

