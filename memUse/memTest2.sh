#!/bin/bash


for dataset in "Higgs" "mnist" "p53"
do
	for numCores in 32 16 8 4 2 1
	do
		echo "$dataset,$var,XGBoost,$numCores"
		var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,XGBoost,$numCores" >> memUse.txt
	done
done




for dataset in "mnist" "Higgs" "p53"
do
	for numCores in 32 16 8 4 2 1
	do
		echo "$dataset,$var,R-RerF,$numCores"
#		var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
#		echo "$dataset,$var,R-RerF,$numCores" >> memUse.txt

	done
done




#echo $var
#printf $memUsed

#/usr/bin/time -v Rscript testFastRF.R | sed '/Maximum resident/g' 
