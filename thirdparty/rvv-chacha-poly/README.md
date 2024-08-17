NOTE: code from https://github.com/edre/rvv-chacha-poly

RISC-V vector extension implementation of chacha20 and poly1305
cryptographic primitives.

Chacha20 and poly1305 are simple to vectorize without specialized
instructions. This project implements them in assembly, and verifies them
against the BoringSSL C implementation. As expected the executed instruction
count go down a lot, but I don't have real hardware to see if the runtime does
too.

This is not an officially supported Google product.

This is a proof of concept crypto library. Those words should sound very scary
together. Don't use this.
