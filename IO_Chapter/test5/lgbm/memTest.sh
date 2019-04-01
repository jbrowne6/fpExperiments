#!/bin/bash

nTimes=1
#start with varying cores
echo "writing file"
Rscript createDS.R -1 -1 -1
echo "done writing"


nSample=60000
nFeature=1024
nClass=5

testName="cores"
for nTimesLoop in {1..5}
do
	for dataset in "svhn"
	do
		for numCores in 32 16 8 4 2 1
		do

			var=`/usr/bin/time -v Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
			echo "$dataset,$var,$testName,lightGBM,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

		done
	done

done



testName="classes"
for nClass in 2 3 4 5 6 7 8 9 10
do
	echo "writing file"
	Rscript createDS.R $nClass -1 -1
	echo "done writing"
	nSample=60000
	nFeature=1024

	for nTimesLoop in {1..5}
	do

		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$testName,lightGBM,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done

	done

done

testName="observations"
for nSample in 30000 60000 90000 120000 150000 180000
do
	echo "writing file"
	Rscript createDS.R -1 $nSample -1
	echo "done writing"
	nClass=5
	nFeature=1024

	for nTimesLoop in {1..5}
	do

		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$testName,lightGBM,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done

	done

done


testName="features"
for nFeature in 250 500 1000 1500 2250 3072
do
	echo "writing file"
	Rscript createDS.R -1 -1 $nFeature
	echo "done writing"
	nClass=5
	nSample=60000

	for nTimesLoop in {1..5}
	do

		for dataset in "svhn"
		do
			for numCores in 16
			do

				var=`/usr/bin/time -v Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature 2>&1 >/dev/null | awk -F: '/Maximum resident/ {print $2}'`
				echo "$dataset,$var,$testName,lightGBM,$numCores,$nClass,$nSample,$nFeature" >> memUse.txt

			done
		done

	done

done
