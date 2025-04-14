#include <stdio.h>
#include <math.h>
#include <time.h>
#define ITERATIONS 100000000

int main() {
    volatile double result = 0.0;
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 1; i <= ITERATIONS; i++) {
        // 제곱근과 거듭제곱 연산 결합하여 사용
        result += sqrt(pow((double)i, 1.2));
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    long seconds = end.tv_sec - start.tv_sec;
    long ns = end.tv_nsec - start.tv_nsec;
    if (ns < 0) {
        seconds--;
        ns += 1000000000;
    }
    printf("Result: %f\n", result);
    printf("Elapsed time: %ld.%09ld seconds\n", seconds, ns);
    return 0;
}

