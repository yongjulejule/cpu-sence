CC = gcc
CFLAGS = -O2
OUT_DIR = ./outputs
LOG_DIR = $(OUT_DIR)/logs

$(shell mkdir -p $(OUT_DIR) $(LOG_DIR))


DIRS := 1-basic-operations # 2-syscalls

SRC_FILES := $(foreach dir,$(DIRS),$(wildcard $(dir)/*.c))

TARGETS := $(notdir $(SRC_FILES:.c=))


.PHONY: all clean $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	@src=$(call find_src,$@); \
	echo "🔧 [컴파일] $$src → $(OUT_DIR)/$@.out"; \
	$(CC) $(CFLAGS) -o $(OUT_DIR)/$@.out $$src

run-%:
	@echo "🚀 [실행] $@"
	/usr/bin/time -v $(OUT_DIR)/$*.out 2>&1 | tee $(LOG_DIR)/$*_time.log
	perf stat $(OUT_DIR)/$*.out 2>$(LOG_DIR)/$*_perf.log
	@echo "✅ [$* 완료]"

clean:
	rm -f $(LOG_DIR)/*.log

fclean:
	rm -f $(OUT_DIR)/*.out
	rm -rf $(LOG_DIR)/*.log
	@echo "✅ [정리 완료]"

re: fclean all

# 🔧 유틸: 파일 이름만 보고 전체 경로 찾기
find_src = $(firstword $(filter %/$1.c,$(SRC_FILES)))
