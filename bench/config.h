
/* the maximum number of bytes to allocate */
#define MAX_MEM (1024*1024*32)
/* the byte count for the next run */
#define BENCH_NEXT(c) (c += c/7 + 3)

/* minimum number of repeats, to sample median from */
#define MIN_REPEATS 10
/* maxium number of repeats, executed until more then STOP_TIME has elapsed */
#define MAX_REPEATS 64

/* stop repeats early afer this many seconds have elapsed */
#define STOP_TIME 0.1


/* custom scaling factors for benchmarks, these are used to make sure each
 * benchmark approximately takes the same amount of time. */

#define SCALE_mandelbrot(N) ((N)/10)
#define SCALE_mergelines(N) ((N)/10)

/* benchmark specific configurations */
#define mandelbrot_ITER 100

