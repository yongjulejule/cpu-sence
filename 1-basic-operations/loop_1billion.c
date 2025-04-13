// title: loop_1billion
// desc: 10억번 sum++ 반복
// type: cpu-bound

int main() {
  volatile unsigned long long sum = 0;
  const unsigned long long billion = 1000000000ULL; 
  for (unsigned long long i = 0; i < billion; i++) {
    sum += i;
  }
  return 0;
}
