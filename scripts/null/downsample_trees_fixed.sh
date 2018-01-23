#!/bin/bash

# Add to path
export PATH=/Users/user/Documents/Packages/BEASTv2.4.7/bin:$PATH

for i in {0..9}
do
	logcombiner -log ../../results/results_nullfixed/ebola_0_0.1_${i}.trees -resample 1000000 -o ../../results/results_nullfixed/ebola_0_0.1_${i}.downsampled.trees
done
logcombiner -log ../../results/results_nullfixed/ebola_0_0.1_0.trees -resample 10000000 -o ../../results/results_nullfixed/ebola_0_0.1_0.downsampled10.trees
logcombiner -log ../../results/results_nullfixed/ebola_0_0.1_0.log -resample 10000000 -o ../../results/results_nullfixed/ebola_0_0.1_0.downsampled10.log
