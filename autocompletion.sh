_make_complete_targets() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # 1. Makefile에서 DIRS 파싱
  local dirs
  dirs=$(grep '^DIRS *:=' Makefile | sed 's/.*:=//')
  [[ -z "$dirs" ]] && dirs="1-basic-operations"

  # 2. .c 파일 기반 실험 타겟 추출
  local files=""
  for d in $dirs; do
    files="$files $(find "$d" -maxdepth 1 -name '*.c' -exec basename {} .c \; 2>/dev/null)"
  done

  local dynamic_targets=""
  for t in $files; do
    dynamic_targets="$dynamic_targets $t run-$t record-$t full-$t"
  done

  # 3. Makefile 안의 일반 타겟도 함께 추출
  local declared_targets
  declared_targets=$(grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1 | grep -vE '^\.' | sort -u)

  # 4. 합치기
  local all_targets="$dynamic_targets $declared_targets"

  COMPREPLY=( $(compgen -W "$all_targets" -- "$cur") )
}

complete -F _make_complete_targets make
