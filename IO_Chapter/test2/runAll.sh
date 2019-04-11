#!/bin/bash
nTime=1
mv bench.csv bench.csv.old

Rscript testFastRF.R $nTime >> test2.log 2>&1
Rscript testRanger.R $nTime >> test2.log 2>&1
Rscript testLightGBM.R $nTime >> test2.log 2>&1
Rscript testXGBoost.R $nTime >> test2.log 2>&1
