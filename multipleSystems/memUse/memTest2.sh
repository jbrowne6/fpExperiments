#!/bin/bash

	for algname in "rfBase" "rerf" "binnedBase" "binnedBaseRerF"
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




#echo $var
#printf $memUsed

#/usr/bin/time -v Rscript testFastRF.R | sed '/Maximum resident/g' 
