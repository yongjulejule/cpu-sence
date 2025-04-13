#!/usr/bin/env bash

set -e

echo "🧱 업데이트 및 필수 패키지 설치"
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git make curl unzip man-db gcc

echo "🧰 perf, time, strace 설치"
sudo apt install -y linux-tools-common linux-tools-$(uname -r) time strace

# ...
