#include <stdio.h>
#include <time.h>

#define N 1000000UL

// 재귀 함수: tail call 최적화를 피하기 위해 후처리를 추가
unsigned long long recursive_sum(unsigned long i, unsigned long n) {
    if (i >= n) return 0;
    // tail call 최적화를 피하기 위해 산술 연산을 더한 후에 호출
    return i + recursive_sum(i + 1, n);
}

int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    volatile unsigned long long start_value = 0;
    volatile unsigned long long end_value = N;
    volatile unsigned long long sum = recursive_sum(start_value, end_value);
    clock_gettime(CLOCK_MONOTONIC, &end);
    long seconds = end.tv_sec - start.tv_sec;
    long ns = end.tv_nsec - start.tv_nsec;
    if (ns < 0) {
        seconds--;
        ns += 1000000000;
    }
    printf("Recursive Sum: %llu\n", sum);
    printf("Elapsed time: %ld.%09ld seconds\n", seconds, ns);
    return 0;
}
