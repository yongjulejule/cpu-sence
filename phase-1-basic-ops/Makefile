CC = gcc
CFLAGS = -O2
LIBS = -lm
OUT_DIR = outputs
LOG_DIR = $(OUT_DIR)/logs
RESULT_FILE = results.md

# 🔍 실험 디렉토리
DIRS := 1-integer-vs-float 2-loop-branch-recursion 3-memory-operations
SRC_FILES := $(foreach dir,$(DIRS),$(wildcard $(dir)/*.c))
TARGETS := $(notdir $(SRC_FILES:.c=.out))  # 타겟 이름을 .out 파일명으로 변경

.PHONY: all clean run-% record-% full-%

all: prepare_dirs $(addprefix $(OUT_DIR)/,$(TARGETS))

prepare_dirs:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(LOG_DIR)

$(OUT_DIR)/%.out:
	@src=$(firstword $(filter %/$*.c,$(SRC_FILES))); \
	echo "Compile $(CC) $(CFLAGS) -o $@ $$src $(LIBS)"; \
	$(CC) $(CFLAGS) -o $@ $$src $(LIBS)

run-%:
	@echo "🚀 [실행] $*"
	/usr/bin/time -v $(OUT_DIR)/$*.out 2>&1 | tee $(LOG_DIR)/$*_time.log
	perf stat $(OUT_DIR)/$*.out 2>&1 | tee $(LOG_DIR)/$*_perf.log
	@echo "✅ [$* 완료]"

record-%:
	@./record.sh $*

full-%: run-% record-%
	@echo "🚀 Full run for $* completed."

clean:
	rm -f $(OUT_DIR)/*.out

re: clean all
