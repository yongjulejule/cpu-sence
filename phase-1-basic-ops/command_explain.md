# 🧾 perf & time 측정 결과 해석 가이드

이 문서는 `/usr/bin/time -v` 와 `perf stat` 명령을 통해 얻은 측정 결과의 각 항목이 의미하는 바를 설명합니다. CPU 리소스 감각을 체득하기 위한 기초 자료로 사용하세요.

---

## 🕒 `/usr/bin/time -v` 측정 항목 설명

| 항목                                 | 설명                        | 실무 해석                            |
| ---------------------------------- | ------------------------- | -------------------------------- |
| **User time (seconds)**            | 사용자 공간에서 실행된 CPU 시간       | Node.js 로직이나 사용자 코드 실행 시간        |
| **System time (seconds)**          | 커널 공간에서 실행된 CPU 시간        | syscall, 파일 IO, 네트워크 처리 등        |
| **Elapsed (wall clock) time**      | 총 경과 시간                   | 실행 시작\~종료까지 실제 시간 (대기 포함)        |
| **Percent of CPU this job got**    | `(User+Sys)/Wall Time` 비율 | CPU를 얼마나 꽉 채웠는지 (100% 이상은 멀티스레드) |
| **Maximum resident set size**      | 최대 메모리 사용량 (RSS)          | 피크 메모리 소비량 (KB)                  |
| **Page faults / context switches** | 메모리 접근 실패, 문맥 전환 수        | 빈도가 많으면 성능 저하 가능                 |

---

## 📊 `perf stat` 측정 항목 설명

| 항목                                    | 설명                      | 실무 해석                           |
| ------------------------------------- | ----------------------- | ------------------------------- |
| **task-clock**                        | 프로세스가 실제로 CPU에서 실행된 시간  | 단일 코어 기준으로 Wall Time과 유사해야 정상   |
| **cycles**                            | CPU 클럭 싸이클 수            | 클럭 빈도 × 시간. CPU가 '뛴 횟수'         |
| **instructions**                      | 실행된 CPU 명령 수            | 프로그램의 실질 연산량                    |
| **IPC** (`instructions/cycle`)        | 싸이클당 명령 실행 수            | 1.0 이상이면 고효율, 낮으면 병목 존재         |
| **stalled-cycles-frontend**           | 명령어를 fetch 못해 대기한 싸이클 수 | instruction fetch 병목 지표         |
| **stalled-cycles-backend**            | 연산 유닛/메모리 대기 중인 시간      | memory latency, 파이프라인 병목 지표     |
| **branches / branch-misses**          | 분기 횟수 / 예측 실패 횟수        | if, for 루프에서 발생. miss 많으면 성능 저하 |
| **context-switches / cpu-migrations** | 문맥 전환 / CPU 코어 이동 횟수    | 안정적인 실행을 방해할 수 있음               |

---

## ✅ 해석 예시

### loop\_1billion 실행 시:

- **User Time**: 6.40초 → CPU에서 실제 연산한 시간
- **Wall Time**: 6.40초 → IO 없음, 순수 CPU 연산
- **Instructions**: 6.0B → 60억 개 명령 실행
- **Cycles**: 8.0B → 80억 싸이클 소모
- **IPC**: 0.75 → 75% 효율, stall 있음

이 결과는: "**싱글코어 CPU를 6.4초 100% 점유해서 60억 명령을 실행한 작업**"이라는 뜻이며,
이를 통해 1초당 몇 요청을 처리할 수 있을지 유추 가능하다.

