#!/bin/bash

# this script processes the results of the path sampling analysis
# and creates a summary file for each dataset called likelihood_summary.txt

#MODELSELECTIONPATH="/home/zenabi/.beast/2.4/MODEL_SELECTION/lib/MODEL_SELECTION.addon.jar"
#BEASTCOREPATH="/home/zenabi/.beast/2.4/BEAST/lib/beast.jar"
#BEASTLABPATH="/home/zenabi/.beast/2.4/BEASTLabs/lib/BEASTlabs.addon.jar"

ROOTDIR="../results/"
ALPHA=0.3
BURNIN=20
CLASSPATH="$MODELSELECTIONPATH":"$BEASTCOREPATH":"$BEASTLABPATH"

DATA="guinea"
CHAIN=50000000
for MODEL in "bd" "bdsky" "const_coal" "sky_coal" "exp_coal" "struct_coal"; do
	for STEPS in 13 14 15 16; do
		DIR="$ROOTDIR""$DATA"/path_sampling/"$MODEL"/"$STEPS"_steps
		java -cp $CLASSPATH beast.app.tools.PathSampleAnalyser -nrOfSteps $STEPS -alpha $ALPHA -rootdir $DIR -burnInPercentage $BURNIN > "$DIR"/analysis_raw.txt
	done
done
`(cd "$ROOTDIR""$DATA"/path_sampling/ && grep -r "marginal L estimate" . | gsed -r 's/.\/([^\/]*)\/([^_]*)_steps\/analysis_raw.txt:marginal L estimate = ([^ ]*)/\1 \2 \3/' > likelihood_summary.txt)`

DATA="gire"
CHAIN=50000000
for MODEL in "bd" "bdsky" "const_coal" "sky_coal" "exp_coal" "struct_coal"; do
#for MODEL in "struct_coal_modified" "struct_coal_modified_onlySL"; do
	for STEPS in 13 14 15 16; do
		DIR="$ROOTDIR""$DATA"/path_sampling/"$MODEL"/"$STEPS"_steps
		java -cp $CLASSPATH beast.app.tools.PathSampleAnalyser -nrOfSteps $STEPS -alpha $ALPHA -rootdir $DIR -burnInPercentage $BURNIN > "$DIR"/analysis_raw.txt
	done
done
`(cd "$ROOTDIR""$DATA"/path_sampling/ && grep -r "marginal L estimate" . | gsed -r 's/.\/([^\/]*)\/([^_]*)_steps\/analysis_raw.txt:marginal L estimate = ([^ ]*)/\1 \2 \3/' > likelihood_summary.txt)`

