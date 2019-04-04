#!/bin/bash
rm bench.csv
Rscript Ranger.R
Rscript XGBoost.R
Rscript testLightGBM.R
Rscript fastRF.R

Rscript printResults.R
