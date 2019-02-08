#!/bin/bash


for algname in "rfBase" "rerf" "inPlace" "inPlaceRerF" "binnedBase" "binnedBaseRerF"
do
	for dataset in "mnist" "Higgs" "p53"
	do
		for numCores in 1 2 4 8 16 32
		do

			var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,$algname,$numCores" >> memUse.txt

		done
	done
done


for dataset in "mnist" "Higgs" "p53"
do
	for numCores in 1 2 4 8 16 32
	do

		var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,XGBoost,$numCores" >> memUse.txt

	done
done


for dataset in "mnist" "Higgs" "p53"
do
	for numCores in 1 2 4 8 16 32
	do


		var=`/usr/bin/time -v Rscript Ranger.R $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,Ranger,$numCores" >> memUse.txt

	done
done



for dataset in "mnist" "Higgs" "p53"
do
	for numCores in 1 2 4 8 16 32
	do

		var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,RerF,$numCores" >> memUse.txt

	done
done


#echo $var
#printf $memUsed

#/usr/bin/time -v Rscript testFastRF.R | sed '/Maximum resident/g' 
