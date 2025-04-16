#include <stdio.h>

unsigned long long tail_fact(unsigned long long n, unsigned long long acc) {
    return (n == 0) ? acc : tail_fact(n - 1, n * acc);
}

int main() {
    unsigned long long n = 10000;
    long result = tail_fact(n, 1);
    printf("Tail Recursion: %llu! = %llu\n", n, result);
    return 0;
}
