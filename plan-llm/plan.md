# **Node.js Backend/DevOps CPU 감각 트레이닝: 전체 계획서**

## 1. 개요

### 1.1 목적
- Node.js 백엔드를 운영할 때, **CPU 연산**과 **시스템 리소스 사용량**을 정확히 이해하고 튜닝할 수 있도록 체득한다.
- 간단한 로우레벨(C 언어) 실습으로 시작해, 실제 Node.js API 서버 구성과 컨테이너 리소스 설계까지 이어지며 **실전적인 DevOps 감각**을 기른다.

### 1.2 전체 진행 흐름
1. **Phase 1**: CPU 기본 연산 실습 (정수·실수 연산, 반복문/분기, 메모리 연산)
2. **Phase 2**: I/O와 시스템 호출 오버헤드 이해 (파일 I/O, syscall, TCP 커넥션)
3. **Phase 3**: Node.js API와 유사한 연산들 체험 (JSON 파싱, 정렬/탐색, 해시)
4. **Phase 4**: Node.js 서버 + DevOps 연계 실습 (QPS별 CPU 측정, 프로파일링, 컨테이너 리소스 제한)
5. **Phase 5**: 종합 프로젝트 (API 설계, 요청당 CPU 사용량 측정, ECS/K8s 리소스 산정)

---

## 2. **Phase 1: CPU 기본 오퍼레이션 감각 익히기**

> **목표**: 로우레벨에서 실제 CPU 연산이 어떻게 비용이 들고 동작하는지 체감.  
> C 언어를 통해 수치적으로 측정(`clock_gettime()`, `perf stat` 등)하고,  
> **Node.js 내부 연산**과 어떤 식으로 연관되는지 감각을 쌓는다.

### 2.1 정수 vs 실수 연산

- **Task 1**: 정수 연산 (덧셈, 곱셈, 나눗셈, pow, bit 연산 등)
- **Task 2**: 실수 연산 (float, double로 pow, sqrt 등)
- **측정 포인트**  
  - `clock_gettime()`으로 함수 수행 시간(ns 단위) 측정  
  - `perf stat`으로 CPU cycle, IPC, cache miss 등 확인  
- **실무 관점 코멘트**  
  - JWT 생성, 해시 계산, 암호화(crypto) 등에서 정수/실수 연산이 얼마나 차이나는지 체감  
  - “Node.js 내부에서도 이런 수학적 연산 시 CPU 얼마 먹을까?” 감각 기르기

### 2.2 반복문, 분기, 재귀

- **Task 1**: 단순 `for-loop` vs `while`  
- **Task 2**: 여러 조건 분기를 가진 `if-else`, `switch`  
- **Task 3**: 간단 재귀 함수 (예: factorial, fibonacci)  
- **측정 포인트**  
  - 반복문 10만/100만회 돌렸을 때의 수행 시간  
  - 분기 조건 개수에 따른 CPU 명령어 수 증가량(`perf`나 `valgrind`로 확인)  
  - 재귀 호출 스택 비용과 반복문 대비 차이  
- **실무 관점 코멘트**  
  - Request validation, routing 단계에서 조건 분기 많이 생길 때 성능 차이 체감  
  - 복잡한 재귀 로직 대신 반복문으로 리팩토링할 필요성 이해

### 2.3 메모리 연산

- **Task 1**: `malloc`으로 힙 메모리 할당, `memset`, `memcpy` 실습  
- **Task 2**: 스택 변수 vs 힙 변수 할당 비용 비교  
- **측정 포인트**  
  - 각 함수 호출 시 평균 시간, syscall 여부, 페이지 폴트 등  
  - 작은 메모리 vs 큰 메모리 블록 할당 비교  
- **실무 관점 코멘트**  
  - JSON 파싱, 요청/응답 처리 시 메모리 할당 비용 영향  
  - Node.js에서 객체 생성(힙) vs 지역 변수(스택) 사용 시 성능 차이

---

## 3. **Phase 2: I/O와 시스템 레벨 오버헤드 이해**

> **목표**: 파일 I/O, syscall, TCP 연결 등 **시스템 콜**에 대한 오버헤드가 얼마나 큰지를 체감.  
> Node.js 운영 시, 로그나 외부 서비스 호출 시 병목이 어디서 생기는지 감 잡는다.

### 3.1 파일 I/O 오버헤드

- **Task 1**: 다양한 크기의 파일(1KB, 1MB, 100MB) 읽기/쓰기  
- **Task 2**: 동기(`fread`, `fwrite`) vs 비동기(`async I/O` 라이브러리) 비교  
- **측정 포인트**  
  - 파일 크기에 따른 처리 시간, I/O 대역폭, syscall 빈도  
- **실무 관점 코멘트**  
  - 대용량 파일 다운로드 API, 이미지 처리 등에서 병목  
  - 로그 파일 I/O 설계(동기 vs 비동기), I/O 버퍼링 전략 결정

### 3.2 시스템 호출 오버헤드

- **Task 1**: `getpid`, `gettimeofday`, `open`, `stat` 등 직접 호출  
- **Task 2**: `syscall()` vs 유저 레벨 함수 비교 (예: 유저 레벨 `time()` 함수 vs 직접 `syscall()`)  
- **측정 포인트**  
  - syscall 진입/반환 시간, context switch 오버헤드  
- **실무 관점 코멘트**  
  - Node.js 내부에서 C++ 바인딩(native module) 호출 시 오버헤드  
  - 빈번한 syscall 발생 시 CPU 소모량 인식

### 3.3 TCP 커넥션 비용 측정

- **Task 1**: `socket()`, `connect()`, `send()`, `recv()` 를 loopback(127.0.0.1)으로 테스트  
- **Task 2**: Keep-Alive 켠 상태 vs 매번 새로운 커넥션  
- **측정 포인트**  
  - 요청당 커넥션 생성 비용, 왕복 시간, 패킷 교환 횟수  
- **실무 관점 코멘트**  
  - Node.js API 서버가 DB/Redis 호출 시 매번 소켓 연결하면 비용 크다 → 커넥션 풀, Keep-Alive 전략  
  - 외부 API나 마이크로서비스 간 호출의 Overhead 파악

---

## 4. **Phase 3: Node.js 백엔드 요청과 유사한 연산 체험**

> **목표**: 실제 Node.js API 서버 내에서 흔히 발생하는 연산들(파싱·정렬·해시 등)을 로우레벨 관점에서 먼저 체험하고,  
> 그 비용을 명확히 이해한다.

### 4.1 JSON 파싱 vs 직렬화

- **Task 1**: RapidJSON, cJSON 같은 라이브러리 사용해서 파싱 및 직렬화  
- **Task 2**: 문자열 크기를 달리해서(10KB, 100KB 등) 파싱 비용 비교  
- **측정 포인트**  
  - 파싱/직렬화 시 CPU 점유, 메모리 사용량  
- **실무 관점 코멘트**  
  - API 응답 보낼 때 JSON 직렬화 병목  
  - 대량의 JSON을 한 번에 주고받을 때 CPU+메모리 어느정도 소요되는지 체감

### 4.2 정렬, 탐색, 필터

- **Task 1**: C 표준 라이브러리의 `qsort`, `bsearch` 사용  
- **Task 2**: 단순 for-loop 필터 vs 고급 알고리즘 비교  
- **측정 포인트**  
  - 데이터 크기(1천, 1만, 10만)별 정렬/탐색 시간  
- **실무 관점 코멘트**  
  - API에서 대량 데이터 정렬할 때 병목  
  - 캐싱된 데이터에 대한 필터·정렬 로직이 많은 경우 CPU 사용량 예측

### 4.3 해시 함수 성능 비교

- **Task 1**: `djb2`, `xxhash`, `murmurhash` 등 간단 해시 함수 비교  
- **측정 포인트**  
  - 데이터 입력 크기에 따른 해시 계산 시간  
- **실무 관점 코멘트**  
  - Redis Key hashing, JWT signature, 각종 요청 식별자 해싱 시 비용  
  - 속도가 중요한 곳(로그인, 인증, API게이트웨이 등)에서 해시 알고리즘 선택

---

## 5. **Phase 4: Node.js 서버 + DevOps 관점 연계 실습**

> **목표**: 단순 C 코드 실험이 아닌, 실제 **Node.js 서버**를 구성해보고,  
> 부하 테스트 + 프로파일링을 통해 **QPS와 CPU 사용량**의 상관관계를 직접 측정한다.  
> 컨테이너 리소스 제한 등을 통해 DevOps 관점의 리소스 설계 방안을 탐색한다.

### 5.1 요청 1건당 리소스 소비 측정 실험

- **Task 1**: “가상의 API 로직”을 Node.js로 구성  
  - (1) 메모리 할당 + JSON 파싱  
  - (2) DB 호출 흉내내기 → 예: `child_process.exec('ls')` 대신 syscall 몇 개 호출  
  - (3) 응답 직렬화  
- **Task 2**: 1초에 500 QPS, 1000 QPS 등 부하 시나리오 돌려보기 (`wrk`, `ab`, `hey`)  
- **측정 포인트**  
  - 요청 1건 처리에 걸리는 CPU 시간 (avg, p95)  
  - Node.js 프로세스의 전체 CPU 점유율  
- **실무 관점 코멘트**  
  - “QPS 500일 때 CPU 코어 몇 개 needed?” → 스펙 추정  
  - API가 늘어날수록 누적되는 부하 예측

### 5.2 Node.js 서버에서 실제 CPU 측정

- **Task 1**: Node.js `--inspect` 사용하여 Chrome DevTools나 VSCode로 CPU 프로파일링  
- **Task 2**: Flamegraph(V8 트레이서)로 핫스팟 함수 찾기  
- **실무 관점 코멘트**  
  - 불필요한 연산, GC(가비지 컬렉션), JSON 처리 등 핫스팟 식별  
  - 성능 최적화 포인트가 어디인지 근거 기반 파악

### 5.3 컨테이너 리소스 제한 실험

- **Task 1**: Docker 컨테이너에 `--cpus=0.5`, `--memory=128m` 등 제한 적용  
- **Task 2**: 동일 부하(wrk 등)를 걸어본 뒤 응답 속도 비교  
- **측정 포인트**  
  - CPU 제한(반 코어, 1코어)에 따라 처리량, 레이턴시 변화  
  - 메모리 부족 시 OOM(Out Of Memory) 발생 여부  
- **실무 관점 코멘트**  
  - K8s나 ECS에서 리소스 Requests/Limit 설정 시 “얼마가 적절한가?” 결정하는 근거  
  - 클라우드 비용 최적화: 필요한 만큼만 CPU/메모리 할당

---

## 6. **Phase 5: 종합 실습 프로젝트**

> **목표**: 실제 API 서버를 설계하고, 요청당 CPU/메모리 비용을 추정해본 뒤,  
> 목표 QPS와 레이턴시를 달성하기 위한 **인프라 리소스 스펙**을 산출한다.

### 6.1 요구사항
- 엔드포인트:
  1. `/login`: JWT 생성, Redis 검증(흉내 또는 실제)  
  2. `/profile`: DB에서 유저 정보 조회, 정렬  
  3. `/updateScore`: 파라미터 검증, DB 쓰기

- **목표**: `500 QPS` 시 `p95 < 100ms` 레이턴시

### 6.2 Node.js 구현 + CPU 측정

- **Task 1**: 실제 Node.js 코드 작성 (`express`나 `fastify` 등 자유)  
- **Task 2**: 각 요청 흐름에서 CPU 사용량, 소요시간 측정 (프로파일러, `wrk`)  
- **Task 3**: Redis, DB 호출 부분은 실제 연결 or Mock(흉내) 선택 가능

### 6.3 컨테이너/클라우드 자원 산정

- **Task 1**: “현재 코드 기준으로 500 QPS 처리 시, CPU 코어 몇 개 필요?” 계산  
  - 요청당 CPU 사용시간 × QPS = 총 CPU 사용량  
  - 여유율(80% 선) 고려  
- **Task 2**: 메모리 측정 → DB 커넥션 풀, 캐시, Node.js 자체 힙 사이즈 등  
- **Task 3**: 최종 ECS/K8s 설정 스펙(예: CPU 2 vCPU, Memory 1GB 등) 제안  
- **Task 4**: 종합 리포트 작성 (QPS 기반 계산 과정 + 실제 측정 결과)

---

## 7. **실습에 활용할 도구**

| 도구                | 설명                                                                                               |
|---------------------|----------------------------------------------------------------------------------------------------|
| **C 언어 + GCC**     | 가장 낮은 추상화 계층에서 CPU/메모리 연산 체감                                                     |
| **`clock_gettime()`** | 나노초 단위 시간 측정, 로우레벨 실험용                                                            |
| **`perf stat`**      | CPU 사이클, IPC, 캐시 미스 등 하드웨어 성능 카운터 확인                                            |
| **`valgrind`, `callgrind`** | 함수 호출별로 명령어 카운트, 캐시 사용량 분석                                               |
| **`wrk`, `ab`, `hey`** | HTTP 부하 생성 도구 (QPS, TPS 등 확인)                                                           |
| **Node.js Inspector** | `--inspect` 옵션으로 V8 엔진 프로파일링 (Flamegraph 등)                                           |
| **Docker**           | 컨테이너로 리소스 격리 (CPU, 메모리 제한 실험)                                                     |
| **VS Code / Vim**    | 실습 및 디버깅 환경 추천                                                                           |

---

## 8. **결과물 및 보고서 예시**

1. **연산별 실험 결과 표**  
   - 예: “정수 곱셈 1000만회: 평균 2.3ms”, “JSON 파싱 10KB: 500µs”
2. **API 요청 1건 처리 흐름도 + 추정 CPU 사용량**  
   - 예: “Redis 검증 0.2ms, JSON 직렬화 0.1ms → 전체 1건당 0.4ms”
3. **컨테이너 리소스 튜닝 로그**  
   - `--cpus=1.0` vs `--cpus=0.5`일 때 처리율 차이, 메모리 부족 시 로그
4. **최종 리소스 산정 보고서**  
   - 예: “500 QPS, p95 90ms 달성 → vCPU 2개 + 메모리 1GB 필요 (ECS Fargate t3.medium 이상)”

---

## 9. **이후 확장 아이디어**

- **DB 연동**: 실제 MySQL/PostgreSQL 연결해 쿼리 비용 측정  
- **Redis 캐시 vs DB 직통**: 캐싱 효과 비교  
- **gRPC vs REST**: RPC 프로토콜 비교 실험  
- **Node.js GC 튜닝**: `--max-old-space-size` 설정 등에 따른 성능 변동  

