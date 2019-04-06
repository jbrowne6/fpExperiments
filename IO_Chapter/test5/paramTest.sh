#!/bin/bash

nTimes=2
#start with varying cores
#echo "writing file"
#Rscript createDS.R -1 -1 -1
#echo "done writing"

rm bench.csv

nSample=60000
nFeature=1024
nClass=5


testName="classes"
for nClass in 2 3 4 5 6 7 8 9 10
#for nClass in 2 3 4
do
  echo "writing file"
  Rscript createDS.R $nClass -1 -1
  echo "done writing"
  #nSample=60000
  nSample=6000
  #nFeature=1024
  nFeature=128


  for algname in "rfBase" "rerf"		
  do
    for dataset in "svhn"
    do
      for numCores in 16
      do
        Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature $testName
      done
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do
      Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done

done


testName="observations"
for nSample in 30000 60000 90000 120000 150000 180000
#for nSample in 300 600 900 1200 1500 1800
do
  echo "writing file"
  Rscript createDS.R -1 $nSample -1
  echo "done writing"
  nClass=5
  #nFeature=1024
  nFeature=128

  for algname in "rfBase" "rerf"		
  do
    for dataset in "svhn"
    do
      for numCores in 16
      do

        Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature $testName
      done
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done

  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done

done


testName="features"
for nFeature in 250 500 1000 1500 2250 3072
#for nFeature in 25 50 100 150 225 307
do
  echo "writing file"
  Rscript createDS.R -1 -1 $nFeature
  echo "done writing"
  nClass=5
  #nSample=60000
  nSample=6000

  for algname in "rfBase" "rerf"
  do
    for dataset in "svhn"
    do
      for numCores in 16
      do

        Rscript fastRF.R $algname $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

      done
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript XGBoost.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript Ranger.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName
    done
  done


  for dataset in "svhn"
  do
    for numCores in 16
    do

      Rscript lightGBM.R $dataset $numCores $nTimes $nClass $nSample $nFeature $testName

    done
  done


done

Rscript printResults.R
