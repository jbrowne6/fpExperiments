#!/bin/bash

nTimes=5
#start with varying cores
echo "writing file"
#Rscript createDS.R -1 -1 -1
echo "done writing"


nSample=60000
nFeature=1024
nClass=5
flagNum=2


for algname in "binnedBase" "binnedBaseRerF"
#for algname in "binnedBaseRerF"
do
	for dataset in "svhn"
	do
		for numCores in 32
		#for numCores in 32 16 8 4 2 1
		do
      for prefetchSize in 0 1 2 4 8 16 32 100 200 400 1000 10000
      do

			var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores $nTimes $prefetchSize $flagNum 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,$algname,$numCores,$nClass,$nSample,$nFeature,$prefetchSize" >> memUse.txt

    done
		done
	done
done


