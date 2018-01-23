#!/bin/bash

ROOTDIR="/cluster/scratch/moellesi/ps/guinea/"
CHAIN=50000000
for STEPS in 13 14 15 16; do
	for MODEL in "bd" "bdsky" "const_coal" "sky_coal" "exp_coal" "struct_coal"; do
		bsub -W 00:15 python path_sampling.py guinea/"$MODEL".xml "$ROOTDIR""$MODEL"/ $CHAIN $STEPS
	done
done

ROOTDIR="/cluster/scratch/moellesi/ps/gire/"
CHAIN=50000000
for STEPS in 13 14 15 16; do
	for MODEL in "bd" "bdsky" "const_coal" "sky_coal" "exp_coal" "struct_coal"; do
		bsub -W 00:15 python path_sampling.py gire/"$MODEL".xml "$ROOTDIR""$MODEL"/ $CHAIN $STEPS
	done
done

