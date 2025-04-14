#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 100000000UL

int h0() { return 0; }
int h1() { return 1; }
int h2() { return 2; }
int h3() { return 3; }
int h4() { return 4; }
int h5() { return 5; }
int h6() { return 6; }

int main() {
		volatile unsigned long long sum = 0;
		struct timespec start, end;
		clock_gettime(CLOCK_MONOTONIC, &start);
		srand(time(NULL)); // 시드 랜덤화로 매번 패턴 다르게
		int (*handlers[7])(void) = { h0, h1, h2, h3, h4, h5, h6 };

		for (int i = 0; i < N; i++) {
				int r = rand();
				int index = r % 7;
				sum += handlers[index]();  // 간접 분기
		}
		clock_gettime(CLOCK_MONOTONIC, &end);
		long seconds = end.tv_sec - start.tv_sec;
		long ns = end.tv_nsec - start.tv_nsec;
		if (ns < 0) { seconds--; ns += 1000000000; }
		printf("Unpredictable branch result: %llu\n", sum);
		printf("Elapsed time: %ld.%09ld seconds\n", seconds, ns);
		return 0;
}

