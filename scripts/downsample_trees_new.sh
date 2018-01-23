#!/bin/bash

# Usage: downsample_trees_new result_dir tree
# where result_dir is the directory storing the trees files and tree is the empirical tree to add to the end


# Add to path
export PATH=/Users/user/Documents/Packages/BEASTv2.4.7/bin:$PATH

for i in {0..9}
do
	logcombiner -log $1/ebola_0_0.1_${i}.trees -resample 6000000 -o $1/ebola_0_0.1_${i}.downsampled.trees
	logcombiner -log $1/ebola_100_0.1_${i}.trees -resample 1000000 -o $1/ebola_100_0.1_${i}.downsampled.trees
	logcombiner -log $1/ebola_500_0.1_${i}.trees -resample 1000000 -o $1/ebola_500_0.1_${i}.downsampled.trees
	logcombiner -log $1/ebola_1000_0.1_${i}.trees -resample 1000000 -o $1/ebola_1000_0.1_${i}.downsampled.trees
	logcombiner -log $1/ebola_15000_0.1_${i}.trees -resample 600000 -o $1/ebola_15000_0.1_${i}.downsampled.trees
	logcombiner -log $1/ebola_0_0.1_${i}.downsampled.trees -log $1/ebola_100_0.1_${i}.downsampled.trees -log $1/ebola_500_0.1_${i}.downsampled.trees -log $1/ebola_1000_0.1_${i}.downsampled.trees -log $1/ebola_15000_0.1_${i}.downsampled.trees -b 0 -o $1/combined_${i}.trees

	head -n 939 $1/combined_${i}.trees > $1/combinedstart
	tail -n 1 $1/combined_${i}.trees > $1/combinedend
	cat $1/combinedstart $2 $1/combinedend > $1/combined_${i}.trees
done

rm $1/combinedstart $1/combinedend