#!/bin/bash
mv bench.csv bench.csv.old
Rscript Ranger.R >> test3.log 2>&1
Rscript XGBoost.R >> test3.log 2>&1
Rscript testLightGBM.R >> test3.log 2>&1
Rscript fastRF.R >> test3.log 2>&1

Rscript printResults.R >> test3.log 2>&1
