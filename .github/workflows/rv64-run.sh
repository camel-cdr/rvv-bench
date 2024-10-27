#!/bin/sh

qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=on,rvv_ma_all_1s=on,zfh=true,zvfh=true $@ && \
qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=256,rvv_ta_all_1s=on,rvv_ma_all_1s=on,zfh=true,zvfh=true $@ && \
qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=512,rvv_ta_all_1s=on,rvv_ma_all_1s=on,zfh=true,zvfh=true $@ && \
qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=1024,rvv_ta_all_1s=on,rvv_ma_all_1s=on,zfh=true,zvfh=true $@ && \
qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=off,rvv_ma_all_1s=off,zfh=true,zvfh=true $@ && \
qemu-riscv64-static -cpu rv64,v=on,vext_spec=v1.0,vlen=1024,rvv_ta_all_1s=off,rvv_ma_all_1s=off,zfh=true,zvfh=true $@
