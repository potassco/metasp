#!/bin/bash
# https://github.com/arminbiere/runlim

CAT="{root}/programs/gcat.sh"

cd "$(dirname $0)"

runner=( "{root}/programs/runlim" \
  {options} \
  --space-limit={memout} \
  --output-file=runsolver.watcher \
  --real-time-limit={timeout} \
  "{root}/programs/{solver}" \
  {sys_cmd} {setting_cmd} {inst_cmd} \
  {sys_cmd_post} {setting_cmd_post} {inst_cmd_post} )

input=( {files} {encodings} )

if [[ ! -e .finished ]]; then
  {{
    if file -b --mime-type -L  "${{input[@]}}" | grep -qv "text/"; then
      "$CAT" "${{input[@]}}" | "${{runner[@]}}"
    else
      "${{runner[@]}}" "${{input[@]}}"
    fi
  }} > runsolver.solver
fi

touch .finished
