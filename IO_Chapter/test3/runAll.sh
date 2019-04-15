#!/bin/bash

mv bench.csv bench.csv.old
rm test3.log

echo "starting fastCores" >> test3.log 2>&1
Rscript fastRF.R >> test3.log 2>&1

~/.scripts/nDone.sh test3
