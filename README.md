# RISC-V Vector benchmark

A collection of RISC-V Vector (RVV) benchmarks to help developers write portably performant RVV code.

Benchmark results can be found at: https://camel-cdr.github.io/rvv-bench-results

## Benchmarks ([./bench/](./bench/))

Contains a bunch of benchmark of different implementations of certain algorithms.

RVV code is currently only written in assembly, and uses [`./thirdparty/rvv-rollback.S`](./thirdparty/rvv-rollback.S) to support RVV 0.7.1 and RVV 1.0, because there currently isn't any RVV 1.0 hardware easily available.

## Instruction cycle count ([./instructions/](./instructions/))

Measures the cycle count of RVV instructions by unrolling and looping over the given instruction repeatedly.

This currently only supports RVV 0.7.1 and was written for the C906 and C920 processors.

## Getting started

Start out by configuring [./config.mk](./config.mk) such that `make` works and optionally [./run.sh](./run.sh), which allows you to compile and run using `make run`.

If you have a rvv 0.7.1 supporting board (which is as of now almost certain), make sure to use a rvv 0.7.1 compatible toolchain. I've used [this one](https://github.com/brucehoult/riscv-gnu-toolchain) for development.

### Running benchmarks ([./bench/](./bench/))

To run the benchmarks, first look through ([./bench/config.h](./bench/config.h)) and adjust it to your processor (e.g. set `HAS_E64`). If it takes too long to execute, try lowering `MAX_MEM`, which is used to scale the benchmark, and play around with the other constants until it executes in a reasonable amount of time and gives a relatively smooth graph.

Now you can just run the benchmarks using `make run` in the ([./bench/](./bench/)) directory, or `make` to just build the executables.


### Measuring cycle count ([./instructions/](./instructions/))

This is currently only supported for RVV 0.7.1.

To run the cycle count measurement, first configure [instructions/thead-0.7.1/config.h](instructions/thead-0.7.1/config.h) to your processor.

Now you can just run the measurement using `make run` in the ([./instructions/thead-0.7.1/](./instructions/thead-0.7.1/)) directory, or `make` to just build the executables.

## Contributing

Here are some suggestions of things that still need to be done.

* contribute a measurement of a new CPU to: https://github.com/camel-cdr/rvv-bench-results \
  You can just create an issue with a single json file, which contains all concatenated [./bench/](./bench/) results. (after proper setup, `make run > out.json` should do the trick). \
* implement non memory bound benchmarks
* implement more benchmarks
* cycle count for RVV 1.0
* cycle count for load/stores
* cycle count for vsetvl

## License

This repository is licensed under the MIT [LICENSE](LICENSE).

