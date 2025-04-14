#include <stdio.h>

long fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    int n = 30;
    long result = fib(n);
    printf("Naive Recursion: fib(%d) = %ld\n", n, result);
    return 0;
}