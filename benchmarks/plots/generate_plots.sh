#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for m in time stime rules choices conflicts gtime; do
    python3 plot_comparison.py "$m"
done

python3 plot_time_stime.py
