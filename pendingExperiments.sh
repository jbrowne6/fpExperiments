#!/bin/bash

cd accMtry
echo "starting accMtry"
Rscript fastRF.R
cd ../binMultiCore
echo "starting fastCores"
Rscript fastCores.R
cd ../growTreeBins
echo "starting growTrees"
Rscript growTrees.R
