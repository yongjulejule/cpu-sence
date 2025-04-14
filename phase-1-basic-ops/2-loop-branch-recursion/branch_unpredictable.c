#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 100000000UL

int main() {
    srand(0);
    volatile unsigned long long sum = 0;
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (unsigned long i = 0; i < N; i++) {
        if (rand() % 2) sum++;
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    long seconds = end.tv_sec - start.tv_sec;
    long ns = end.tv_nsec - start.tv_nsec;
    if (ns < 0) { seconds--; ns += 1000000000; }
    printf("Unpredictable branch result: %llu\n", sum);
    printf("Elapsed time: %ld.%09ld seconds\n", seconds, ns);
    return 0;
}