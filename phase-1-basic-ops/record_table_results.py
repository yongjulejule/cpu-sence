#!/usr/bin/env python3
import re
import sys
from pathlib import Path

def parse_perf_log(log_path):
    lines = Path(log_path).read_text().splitlines()
    results = {}
    last_key = None
    ipc_info = None
    stalled_info = None

    for line in lines:
        line = line.strip()

        match = re.match(r'^([0-9.,]+)\s+(msec task-clock|[a-zA-Z0-9\-_]+)\s+#\s+(.+)$', line)
        if match:
            value, key, comment = match.groups()
            clean_comment = re.sub(r'\s{2,}', ' ', comment.strip())
            key = key.replace('msec task-clock', 'task-clock')
            results[key] = f"{value} ({clean_comment})"
            last_key = key

        elif match := re.match(r'^#\s+([0-9.]+)\s+insn per cycle', line):
            ipc_val = re.sub(r'\s{2,}', ' ', match.group(1) + ' insn per cycle')
            ipc_info = ipc_val
            if 'instructions' in results:
                results['instructions'] += f", {ipc_info}"

        elif match := re.match(r'^#\s+([0-9.]+)\s+stalled cycles per insn\s+\((.+)\)', line):
            stall_val = re.sub(r'\s{2,}', ' ', match.group(1) + ' stalled per insn (' + match.group(2) + ')')
            stalled_info = stall_val
            if 'instructions' in results:
                results['instructions'] += f", {stalled_info}"

        elif match := re.match(r'^([0-9.]+)\s+seconds time elapsed', line):
            results['time_elapsed'] = match.group(1) + " s"

        elif match := re.match(r'^([0-9.]+)\s+seconds user', line):
            results['user_time'] = match.group(1) + " s"

        elif match := re.match(r'^([0-9.]+)\s+seconds sys', line):
            results['sys_time'] = match.group(1) + " s"

    return results

def append_to_results_md(results, test_name):
    key_order = [
        "task-clock", "cycles", "instructions", "cache-misses",
        "stalled-cycles-frontend", "stalled-cycles-backend",
        "context-switches", "page-faults", "branches", "branch-misses",
        "user_time", "sys_time", "time_elapsed"
    ]

    result_file = Path("results.md")
    if not result_file.exists():
        header = "| Test | " + " | ".join(key_order) + " |\n"
        separator = "|------|" + "|".join(["-" * len(k) for k in key_order]) + "|\n"
        result_file.write_text(header + separator)

    row = "| " + test_name + " | " + " | ".join(results.get(k, "-") for k in key_order) + " |\n"
    with open(result_file, 'a') as f:
        f.write(row)

def main():
    if len(sys.argv) != 3:
        print("Usage: ./record_table_results.py <perf_log.txt> <test_name>")
        sys.exit(1)

    log_path = Path(sys.argv[1])
    test_name = sys.argv[2]
    results = parse_perf_log(log_path)
    append_to_results_md(results, test_name)
    print("✅ Summary appended to results.md")

if __name__ == "__main__":
    main()

