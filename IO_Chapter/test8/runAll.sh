#!/bin/bash

mv bench.csv bench.csv.old
rm test7.log

echo "starting fastCores" >> test7.log 2>&1
Rscript fastRF.R >> test7.log 2>&1

~/.scripts/nDone.sh test7
