#!/bin/bash
# https://github.com/arminbiere/runlim

CAT="../../../../../../../../../../programs/gcat.sh"

cd "$(dirname $0)"

runner=( "../../../../../../../../../../programs/runlim" \
  --single \
  --space-limit=20000 \
  --output-file=runsolver.watcher \
  --real-time-limit=1200 \
  "../../../../../../../../../../programs/metasp-1" \
  clingo --stats 1 -q --meta-config ../../../../../../../../../../../examples/tel/config.yml -c n=34 \
     )

input=( "../../../../../../../../../../instances/tel/instances/visitall/0030-visitall-39-1.asp" "../../../../../../../../../../instances/tel/encodings/visitall-metasp.lp" )

if [[ ! -e .finished ]]; then
  {
    if file -b --mime-type -L  "${input[@]}" | grep -qv "text/"; then
      "$CAT" "${input[@]}" | "${runner[@]}"
    else
      "${runner[@]}" "${input[@]}"
    fi
  } > runsolver.solver
fi

touch .finished
