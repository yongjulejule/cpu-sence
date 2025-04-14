#include <stdio.h>

long tail_fact(int n, long acc) {
    return (n == 0) ? acc : tail_fact(n - 1, n * acc);
}

int main() {
    int n = 20;
    long result = tail_fact(n, 1);
    printf("Tail Recursion: %d! = %ld\n", n, result);
    return 0;
}