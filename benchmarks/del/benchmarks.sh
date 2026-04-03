
COMMAND="metasp solve clingo 0 --meta-config config.yml instances/elevator/encoding.lp instances/elevator/instance.lp --stats -q"
OPTS=(
    "5 8" "5 9" "5 10" "5 11" "5 12"
    "7 11" "7 12" "7 13" "7 14" "7 15"
    "9 14" "9 15" "9 16" "9 17" "9 18"
    "11 17" "11 18" "11 19" "11 20" "11 21"
)
eval "cd ../../examples/del"
OUTFILE="../../benchmarks/del/results_elevator_out.txt"
rm -f "$OUTFILE"
for opt in "${OPTS[@]}"; do
    set -- $opt
    X=$1
    Y=$2
    echo "------ nfloors=$X  horizon=$Y ------" >> "$OUTFILE"
    echo "--- With control ">> "$OUTFILE"
    eval $COMMAND" -c n=$Y -c nfloors=$X" | grep "Choices\|Conflicts\|Constraints\|Models" >> "$OUTFILE"
    echo "--- No control ">> "$OUTFILE"
    eval $COMMAND" -c n=$Y -c nfloors=$X -c use_control=false" | grep "Choices\|Conflicts\|Constraints\|Models" >> "$OUTFILE"
done
