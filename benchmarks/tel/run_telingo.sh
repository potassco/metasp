#!/usr/bin/env bash

TIMEOUT=600
DOMAINS=(labyrinth hanoi nomystery ricochetrobot sokoban visitall)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV="$SCRIPT_DIR/telingo_results.csv"

echo "domain,instance,choices,conflicts,constraints,time_s,status" > "$CSV"

for domain in "${DOMAINS[@]}"; do
    encoding="$SCRIPT_DIR/encodings/${domain}-telingo.lp"
    for instance in "$SCRIPT_DIR/instances/${domain}"/*.asp; do
        instance_name="$(basename "$instance")"
	horizon_file="$SCRIPT_DIR/horizons/${instance_name}"
        n=$(grep -oP '#const n = \K[0-9]+' "$horizon_file")
        if [ -z "$n" ]; then
            echo "ERROR: could not read horizon for $instance_name, skipping"
            continue
        fi
        echo "Running: telingo 1 -q $instance $encoding"
        output=$(timeout "$TIMEOUT" telingo 1 -q --stats "$instance" "$encoding" 2>&1)
        status=$?

        if [ $status -eq 124 ]; then
            echo "TIMEOUT: $instance"
            row_status="timeout"
        elif [ $status -ne 0 ] && [ $status -ne 10 ] && [ $status -ne 20 ] && [ $status -ne 30 ]; then
            echo "ERROR (exit $status): $instance"
            row_status="error"
        else
            row_status="ok"
        fi

        choices=$(echo "$output"    | grep -oP 'Choices\s*:\s*\K[0-9]+' | head -1)
        conflicts=$(echo "$output"  | grep -oP 'Conflicts\s*:\s*\K[0-9]+' | head -1)
        constraints=$(echo "$output"| grep -oP 'Constraints\s*:\s*\K[0-9]+' | head -1)
        time_s=$(echo "$output"     | grep -oP '^Time\s*:\s*\K[0-9]+\.[0-9]+' | head -1)

        echo "$domain,$instance_name,${choices:-NA},${conflicts:-NA},${constraints:-NA},${time_s:-NA},$row_status" >> "$CSV"
    done
done

echo "Results written to $CSV"
