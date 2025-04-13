CC = gcc
CFLAGS = -O2
OUT_DIR = outputs
LOG_DIR = $(OUT_DIR)/logs
RESULT_FILE = results.md

# 🔍 실험 디렉토리
DIRS := 1-basic-operations 2-syscalls
SRC_FILES := $(foreach dir,$(DIRS),$(wildcard $(dir)/*.c))
TARGETS := $(notdir $(SRC_FILES:.c=))

.PHONY: all clean $(TARGETS) run-% record-% full-%

all: prepare_dirs $(TARGETS)

prepare_dirs:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(LOG_DIR)

$(TARGETS):
	@src=$(call find_src,$@); \
	echo "🔧 [컴파일] $$src → $(OUT_DIR)/$@.out"; \
	$(CC) $(CFLAGS) -o $(OUT_DIR)/$@.out $$src

run-%:
	@echo "🚀 [실행] $@"
	/usr/bin/time -v $(OUT_DIR)/$*.out 2>&1 | tee $(LOG_DIR)/$*_time.log
	perf stat $(OUT_DIR)/$*.out 2>&1 | tee $(LOG_DIR)/$*_perf.log
	@echo "✅ [$* 완료]"

record-%:
	@./record.sh $*

full-%: run-% record-%

clean:
	rm -f *.log $(RESULT_FILE)

find_src = $(firstword $(filter %/$1.c,$(SRC_FILES)))

