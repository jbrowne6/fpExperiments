#!/bin/bash
rm test3a.log

Rscript fastRF.R >> test3a.log 2>&1

~/.scripts/nDone.sh test3a

