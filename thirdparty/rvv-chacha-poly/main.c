/* Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License") ;
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "boring.h"

void println_hex(uint8_t* data, int size) {
  while (size > 0) {
    printf("%02x", *data);
    data++;
    size--;
  }
  printf("\n");
}

// TODO: test the vector doesn't write past the end
// test function with multiple length inputs (optional printing)
// test non-block sized lengths

extern uint64_t instruction_counter();

const char* pass_str = "\x1b[32mPASS\x1b[0m";
const char* fail_str = "\x1b[31mFAIL\x1b[0m";

bool test_chacha(const uint8_t* data, size_t len, const uint8_t key[32], const uint8_t nonce[12], bool verbose) {
  extern void vector_chacha20(uint8_t *out, const uint8_t *in,
			      size_t in_len, const uint8_t key[32],
			      const uint8_t nonce[12], uint32_t counter);
  uint8_t* golden = malloc(len);
  memset(golden, 0, len);
  uint64_t start = instruction_counter();
  boring_chacha20(golden, data, len, key, nonce, 0);
  uint64_t end = instruction_counter();
  uint64_t boring_count = end - start;

  uint8_t* vector = malloc(len + 4);
  memset(vector, 0, len+4);
  start = instruction_counter();
  vector_chacha20(vector, data, len, key, nonce, 0);
  end = instruction_counter();

  bool pass = memcmp(golden, vector, len) == 0;

  if (verbose || !pass) {
    printf("golden: ");
    println_hex(golden, 32);
    printf("inst_count=%d, inst/byte=%.02f\n", boring_count, (float)(boring_count)/len);
    printf("vector: ");
    println_hex(vector, 32);
    printf("inst_count=%d, inst/byte=%.02f\n", end - start, (float)(end - start)/len);
  }

  uint32_t past_end = vector[len];
  if (past_end != 0) {
    printf("vector wrote past end %08x\n", past_end);
    pass = false;
  }

  free(golden);
  free(vector);

  return pass;
}

void test_chachas(FILE* f) {
  int len = 1024 - 11;
  uint8_t* data = malloc(len);
  uint32_t rand = 1;
  for (int i = 0; i < len; i++) {
    rand *= 101;
    rand %= 16777213; // random prime
    data[i] = (uint8_t)(rand);
  }
  uint8_t key[32] = "Setec astronomy;too many secrets";
  uint8_t nonce[12] = "BurnAfterUse";
  int counter = 0;

  bool pass = test_chacha(data, len, key, nonce, true);

  if (pass) {
    for (int i = 1, len = 1; len < 1000; len += i++) {
      fread(key, 32, 1, f);
      fread(nonce, 12, 1, f);
      if (!test_chacha(data, len, key, nonce, false)) {
	printf("Failed with len=%d\n", len);
	pass = false;
	break;
      }
    }
  }

  if (pass) {
    printf("chacha %s\n", pass_str);
  } else {
    printf("chacha %s\n", fail_str);
  }
}

bool test_poly(const uint8_t* data, size_t len, const uint8_t key[32], bool verbose) {
  extern uint64_t vector_poly1305(const uint8_t* in, size_t len,
				  const uint8_t key[32], uint8_t sig[16]);

  poly1305_state state;
  uint8_t *sig = malloc(16); // gets corrupted if I define it on the stack?
  uint64_t start = instruction_counter();
  boring_poly1305_init(&state, key);
  boring_poly1305_update(&state, data, len);
  boring_poly1305_finish(&state, sig);
  uint64_t end = instruction_counter();
  uint64_t boring_count = end - start;

  uint8_t *sig2 = malloc(16);
  start = instruction_counter();
  uint64_t mid = vector_poly1305(data, len, key, sig2);
  end = instruction_counter();

  bool pass = memcmp(sig, sig2, 16) == 0;

  if (verbose || !pass) {
    printf("boring mac: ");
    println_hex(sig, 16);
    printf("inst_count=%d, inst/byte=%.02f\n", boring_count, (float)(boring_count)/len);
    printf("vector mac: ");
    println_hex(sig2, 16);
    printf("precomputation=%d, processing=%d, inst/byte=%.02f\n",
	   mid - start, end - mid, (float)(end - mid)/len);
  }

  free(sig);
  free(sig2);
  return pass;
}

void test_polys(FILE* f) {
  const int big_len = 1024;
  uint8_t *zero = malloc(2000);
  uint8_t *max_bits = malloc(big_len);
  memset(max_bits, 0xff, big_len);
  const uint8_t one[32] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  const uint8_t key[32] = {1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 255,
  			   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  const uint8_t data[272] = "Setec astronomy;too many secrets";
  bool pass = test_poly(max_bits, big_len, max_bits, true);

  if (!pass)
    goto end;

  // random test
  const int max_len = 1000;
  uint8_t *rand = malloc(max_len);
  for (int len = 16; len <= max_len; len += 16) {
    fread((uint8_t*)key, 32, 1, f);
    fread((uint8_t*)rand, len, 1, f);
    if (!test_poly(data, len, key, false)) {
      printf("failed random input len=%d\n", len);
      pass = false;
      break;
    }
  }
  free(rand);

 end:
  if (pass) {
    printf("poly %s\n", pass_str);
  } else {
    printf("poly %s\n", fail_str);
  }

  free(zero);
  free(max_bits);
}

int main(int argc, uint8_t *argv[]) {
  extern uint32_t vlmax_u32();
  printf("VLMAX in blocks: %d\n", vlmax_u32());
  FILE* rand = fopen("/dev/urandom", "r");
  test_chachas(rand);
  printf("\n");
  test_polys(rand);
  fclose(rand);
}
