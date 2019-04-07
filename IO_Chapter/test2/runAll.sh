#!/bin/bash

for nTime in 1 2 
do
	Rscript testFastRF.R $nTime
done

Rscript testRanger.R
Rscript testLightGBM.R
Rscript testXGBoost.R
