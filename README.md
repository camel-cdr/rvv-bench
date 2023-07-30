# RISC-V Vector benchmark

A collection of RISC-V Vector (RVV) benchmarks to help developers write portably performant RVV code.

Benchmark results can be found at: https://camel-cdr.github.io/rvv-bench-results

## Benchmarks ([./bench/](./bench/))

Contains a bunch of benchmark of different implementations of certain algorithms.

RVV code is currently only written in assembly, and uses [`./thiredparty/rvv-rollback.S`](./thiredparty/rvv-rollback.S) to support RVV 0.7.1 and RVV 1.0, because there currently isn't any RVV 1.0 hardware easily available.

## Instruction cycle count ([./instructions/](./instructions/))

Measures the cycle count of RVV instructions by unrolling and looping over the given instruction repeatedly.

This currently only supports RVV 0.7.1 and was written for the C906 and C910 processors.

## Contributing

If you have a rvv 0.7.1 supporting board (which is as of now almoat certain), make sure to use a rvv 0.7.2 compatible toolchain. I've used [this one](https://github.com/brucehoult/riscv-gnu-toolchain) for development.

Here are some suggestions of things that still need to be done.

* contribute a measurement of a new CPU to: https://github.com/camel-cdr/rvv-bench-results
* implement non memory bound benchmarks
* implement more benchmarks
* cycle count for RVV 1.0
* cycle count for load/stores
* cycle count for vsetvl

## License

This repository is licensed under the MIT [LICENSE](LICENSE).

