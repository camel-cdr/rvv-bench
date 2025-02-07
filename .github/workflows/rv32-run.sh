#!/bin/sh

# zfh=true,zvfh=true disabled for now
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=on,rvv_ma_all_1s=on $@ && \
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=256,rvv_ta_all_1s=on,rvv_ma_all_1s=on $@ && \
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=512,rvv_ta_all_1s=on,rvv_ma_all_1s=on $@ && \
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=1024,rvv_ta_all_1s=on,rvv_ma_all_1s=on $@ &&\
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=128,rvv_ta_all_1s=off,rvv_ma_all_1s=off $@ && \
qemu-riscv32-static -cpu rv32,zve32f=on,vext_spec=v1.0,vlen=1024,rvv_ta_all_1s=off,rvv_ma_all_1s=off $@

