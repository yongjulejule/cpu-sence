# Phase 1 - Step 2: 반복 / 분기 / 재귀 실험

## 목표
- 반복문 형태에 따른 성능 차이 이해
- 분기문 예측 실패(branch miss)가 성능에 미치는 영향 분석
- 재귀 호출이 스택에 미치는 영향과 꼬리 재귀 최적화 체감

## 파일 설명

- `loop_simple.c`: 기본 반복문으로 sum += i 실행
- `branch_predictable.c`: 조건이 항상 참인 분기 → 예측 쉬움
- `branch_unpredictable.c`: 조건이 랜덤한 분기 → 예측 어려움
- `recursion_naive.c`: 피보나치 재귀 → 호출 수 폭발, 성능 저하
- `recursion_tail.c`: 꼬리재귀 → 최적화 가능한 구조

## 추천 측정 항목

- Wall Time, User Time
- `perf stat` → IPC, branch-misses, stalled-cycles-frontend