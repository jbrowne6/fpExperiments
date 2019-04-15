#!/bin/bash
nTime=5
mv bench.csv bench.csv.old
rm test2.log

echo "starting fastRF" >> test2.log 2>&1
Rscript testFastRF.R $nTime >> test2.log 2>&1
echo "starting Ranger" >> test2.log 2>&1
Rscript testRanger.R $nTime >> test2.log 2>&1
echo "starting LightGBM" >> test2.log 2>&1
Rscript testLightGBM.R $nTime >> test2.log 2>&1
echo "starting XGB" >> test2.log 2>&1
Rscript testXGBoost.R $nTime >> test2.log 2>&1


~/.scripts/nDone.sh test2
