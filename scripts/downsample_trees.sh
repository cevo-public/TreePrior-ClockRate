#!/bin/bash

# Add to path, change this to the path to Beast 2 
export PATH=/Users/user/Documents/Packages/BEASTv2.4.7/bin:$PATH

logcombiner -log ../results/ebola_0_0.1_0.trees -resample 600000 -o ../results/ebola_0_0.1_0.downsampled1000.trees
logcombiner -log ../results/ebola_100_0.1_0.trees -resample 100000 -o ../results/ebola_100_0.1_0.downsampled1000.trees
logcombiner -log ../results/ebola_500_0.1_0.trees -resample 100000 -o ../results/ebola_500_0.1_0.downsampled1000.trees
logcombiner -log ../results/ebola_1000_0.1_0.trees -resample 100000 -o ../results/ebola_1000_0.1_0.downsampled1000.trees
logcombiner -log ../results/ebola_15000_0.1_0.trees -resample 60000 -o ../results/ebola_15000_0.1_0.downsampled1000.trees

logcombiner -log ../results/ebola_0_0.1_0.trees -resample 6000000 -o ../results/ebola_0_0.1_0.downsampled.trees
logcombiner -log ../results/ebola_100_0.1_0.trees -resample 1000000 -o ../results/ebola_100_0.1_0.downsampled.trees
logcombiner -log ../results/ebola_500_0.1_0.trees -resample 1000000 -o ../results/ebola_500_0.1_0.downsampled.trees
logcombiner -log ../results/ebola_1000_0.1_0.trees -resample 1000000 -o ../results/ebola_1000_0.1_0.downsampled.trees
logcombiner -log ../results/ebola_15000_0.1_0.trees -resample 600000 -o ../results/ebola_15000_0.1_0.downsampled.trees
logcombiner -log ../results/ebola_0_0.1_0.downsampled.trees -log ../results/ebola_100_0.1_0.downsampled.trees -log ../results/ebola_500_0.1_0.downsampled.trees -log ../results/ebola_1000_0.1_0.downsampled.trees -log ../results/ebola_15000_0.1_0.downsampled.trees -b 0 -o ../results/combined.trees