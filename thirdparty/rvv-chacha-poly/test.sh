#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License") ;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dependencies to be installed and on the PATH:
# https://github.com/riscv/riscv-gnu-toolchain
# https://github.com/riscv/riscv-isa-sim
#   configure --prefix=$RISCV --with-varch=v512:e64
# https://github.com/riscv/riscv-pk

ISA=rv64gcv

riscv64-unknown-elf-gcc -march=$ISA main.c boring.c vchacha.s vpoly.s -o main -O &&
    spike --isa=$ISA `which pk` main
