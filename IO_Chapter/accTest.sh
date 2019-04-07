#!/bin/bash

~/.scripts/nDone.sh

echo 'starting test3'
cd test3
rm bench.csv
./accTest.sh
~/.scripts/nDone.sh
cd ..


echo 'starting test4'
cd test4
rm bench.csv
./accTest.sh
~/.scripts/nDone.sh
cd ..


echo 'starting test2'
cd test2
rm bench.csv
./runAll.sh
~/.scripts/nDone.sh
cd ..


echo 'starting test5'
cd test5
rm bench.csv
./paramTest
~/.scripts/nDone.sh
cd ..
