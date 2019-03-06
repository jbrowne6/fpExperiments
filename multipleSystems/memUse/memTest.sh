#!/bin/bash

nTimes=1
#start with varying cores
echo "writing file"
Rscript createDS.R -1 -1 -1
echo "done writing"


nSample=60000
nFeature=1024
nClass=5


for algname in "rfBase" "rerf" "binnedBase" "binnedBaseRerF"
do
	for dataset in "svhn"
	do
		for numCores in 32 16 8 4 2 1
		do

			var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,$algname,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done
done


for dataset in "svhn"
do
	for numCores in 32 16 8 4 2 1
	do

		var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,XGBoost,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

	done
done


for dataset in "svhn"
do
	for numCores in 32 16 8 4 2 1
	do

		var=`/usr/bin/time -v Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
		echo "$dataset,$var,Ranger,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

	done
done


if false
then
	for dataset in "svhn"
	do
		for numCores in 32 16 8 4 2 1
		do

			var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,R-RerF,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done
fi





for nClass in 2 3 4 5 6 7 8 9 10
do
	echo "writing file"
	Rscript createDS.R $nClass -1 -1
	echo "done writing"
	nSample=60000
	nFeature=1024

	for algname in "rfBase" "rerf" "binnedBase" "binnedBaseRerF"
	do
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$algname,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,XGBoost,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,Ranger,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	if false
	then
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,R-RerF,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	fi

done



for nSample in 30000 60000 90000 120000 150000 180000 210000
do
	echo "writing file"
	Rscript createDS.R -1 $nSample -1
	echo "done writing"
	nClass=5
	nFeature=1024

	for algname in "rfBase" "rerf" "binnedBase" "binnedBaseRerF"
	do
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$algname,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,XGBoost,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,Ranger,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	if false
	then
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,R-RerF,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	fi

done



for nFeature in 250 500 1000 1500 2250 3072
do
	echo "writing file"
	Rscript createDS.R -1 -1 $nFeature
	echo "done writing"
	nClass=5
	nSample=60000

	for algname in "rfBase" "rerf" "binnedBase" "binnedBaseRerF"
	do
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$algname,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,XGBoost,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	for dataset in "svhn"
	do
		for numCores in 16
		do

			var=`/usr/bin/time -v Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,Ranger,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done


	if false
	then
		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript RerF.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,R-RerF,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done
	fi


done
