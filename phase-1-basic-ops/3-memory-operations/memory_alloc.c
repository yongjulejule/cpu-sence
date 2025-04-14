#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define ALLOC_SIZE 10000000

int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    char *buffer = (char*)malloc(ALLOC_SIZE);
    memset(buffer, 'A', ALLOC_SIZE);
    char *copy = (char*)malloc(ALLOC_SIZE);
    memcpy(copy, buffer, ALLOC_SIZE);
    clock_gettime(CLOCK_MONOTONIC, &end);
    long seconds = end.tv_sec - start.tv_sec;
    long ns = end.tv_nsec - start.tv_nsec;
    if (ns < 0) {
        seconds--;
        ns += 1000000000;
    }
    printf("Memory operations completed in: %ld.%09ld seconds\n", seconds, ns);
    free(buffer);
    free(copy);
    return 0;
}
