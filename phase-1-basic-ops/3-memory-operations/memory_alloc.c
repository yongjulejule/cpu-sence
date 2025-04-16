#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define CHUNK_COUNT 24400
#define CHUNK_SIZE 4096 


int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

	unsigned char **base = calloc(CHUNK_COUNT + 1, sizeof(unsigned char*));

	for (int i = 0; i < CHUNK_COUNT; i++) {
		base[i] = (char*)calloc(CHUNK_SIZE + 1, sizeof(char));
		memset(base[i], 'A', CHUNK_SIZE);
	}

    clock_gettime(CLOCK_MONOTONIC, &end);
    long seconds = end.tv_sec - start.tv_sec;
    long ns = end.tv_nsec - start.tv_nsec;
    if (ns < 0) {
        seconds--;
        ns += 1000000000;
    }
	int total_size = 0;
	for (int i = 0; base[i]; i++) {
		for (int j = 0; base[i][j]; j++) {
			++total_size;
		}
	}
    printf("Memory operations completed in: %ld.%09ld seconds with %d blocks\n", seconds, ns, total_size);
	for (int i = 0; base[i]; i++) {
		free(base[i]);
	}
    free(base);
    return 0;
}
