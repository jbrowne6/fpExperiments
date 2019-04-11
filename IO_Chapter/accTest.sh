#!/bin/bash


echo 'starting test3'
cd test3
if [ -f bench.csv ] 
then
	mv bench.csv bench.csv.old
fi
./accTest.sh
~/.scripts/nDone.sh test3
cd ..


echo 'starting test4'
cd test4
if [ -f bench.csv ]
then
	mv bench.csv bench.csv.old
fi
./accTest.sh
~/.scripts/nDone.sh test4
cd ..


echo 'starting test2'
cd test2
if [ -f bench.csv ]
then
	mv bench.csv bench.csv.old
fi
./runAll.sh
~/.scripts/nDone.sh test2
cd ..


echo 'starting test5'
cd test5
if [ -f bench.csv ]
then
	mv bench.csv bench.csv.old
fi
./paramTest.sh
~/.scripts/nDone.sh test5
cd ..

