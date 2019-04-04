#!/bin/bash

for nTime in 1 2 3 4 5 8 9 10
do
	Rscript testFastRF.R $nTime
done

#Rscript testRanger.R
Rscript testLightGBM.R
Rscript testXGBoost.R
