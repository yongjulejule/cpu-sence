int main() {
  volatile unsigned long long sum = 0;
  const unsigned long long billion = 1000000000ULL; 
  for (unsigned long long i = 0; i < billion; i++) {
    sum += i;
  }
  return 0;
}
