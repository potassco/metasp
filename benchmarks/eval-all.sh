btool eval runscripts/runscript-metasp-tel.xml > results/metasp-tel.xml
btool conv results/metasp-tel.xml -m "time,stime,status,rules,choices,conflicts,memout" -o results/metasp-tel.xlsx

btool eval runscripts/runscript-telingo-tel.xml > results/telingo-tel.xml
btool conv results/telingo-tel.xml -m "time,stime,status,rules,choices,conflicts,memout" -o results/telingo-tel.xlsx

btool eval runscripts/runscript-metasp-del.xml > results/metasp-del.xml
btool conv results/metasp-del.xml -m "time,models,choices,constraints" -o results/metasp-del.xlsx

btool eval runscripts/runscript-telingo-del.xml > results/telingo-del.xml
btool conv results/telingo-del.xml -m "time,models,choices,constraints" -o results/telingo-del.xlsx
