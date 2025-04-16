#!/usr/bin/env bash

set -e

echo "🧱 업데이트 및 필수 패키지 설치"
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git make curl unzip man-db gcc

echo "🧰 perf, time, strace 설치"
sudo apt install -y linux-tools-common linux-tools-$(uname -r) time strace

echo "perf 권한 완화"
echo 'kernel.perf_event_paranoid = -1' | sudo tee /etc/sysctl.d/99-perf.conf
sudo sysctl --system

function 편의기능 {
		echo "OMB 설치"
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
}

편의기능
