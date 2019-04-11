#!/bin/bash
mv bench.csv bench.csv.old

taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30 Rscript Ranger.R
taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30 Rscript testLightGBM.R
taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30 Rscript fastRF.R
taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30 Rscript XGBoost.R
~/.scripts/nDone.sh test4

Rscript printResults.R
