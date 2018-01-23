# The impact of the tree prior on estimating clock rates during epidemic outbreaks

### Simon Möller, Louis du Plessis and Tanja Stadler

This file is supposed to help anyone who is trying to reproduce the results in this paper. Naturally, some scripts will need adjustments of paths or cluster settings. All this should be easy to spot, though. Just have a brief look at each file before executing it. Some scripts also have a `--local` flag so you can try things on your own machine.

## Required R packages:
- coda
- ggplot2
- scales
- reshape2
- ape
- treescape (deprecated)
- apTreeShape
- laser (deprecated)

## Other requirements:
- Set working directory to source file location for (most) R-scripts
- Python scripts are for Python 2.7.6
- Gnu-sed (gsed) is needed for some scripts (by default OSX uses Bsd-sed). If sed returns an error replace sed in the script with gsed.

## Raw data:
- Guinea: data from Tong et al. (2015) Nature and Simon-Loriere et al. (2015) Nature
- Gire: data from Gire et al. (2014) Science. (Extracted from 2014_GN.SL_SRD.HKY_strict_ctmc.exp.xml)


----

## Simulation study:

### Simulation on empirical tree:
- execute: `BEAST pre_simulation_analysis.xml` and extract the MCC tree - this should be _roughly_ something like the tree stored in `tree.nwk` which was used for the simulation study
- execute: `python run_experiment.py ebola_analysis_tempate.xml ../results/``
- changing templates (e.g. to `ebola_analysis_template_exp_growth_fast.xml`) allows to reproduce the results in the supplementary materials
- execute: R-script `plot_experiment_results.R` and `plot_experiment_results_treestats.R`

### Simulation on trees sampled from prior:
- Sampling 10 trees from the prior to simulate on:
	- cd to `scripts/null/`
	- execute: `python run_experiment_prior_fixed.py ebola_analysis_template_fixed.xml ../results/null/results_fixed/`
	- execute: `downsample_trees_fixed.sh`
	- manual intervention: load `ebola_0_0.1_0.downsampled10.trees` in IcyTree and save each tree as a separate newick file in `scripts/null/` as `tree_<i>_fixed.nwk`, eg. `tree_0_fixed.nwk`
	- Remove quotes - execute (adjust filename): ``for i in `ls *fixed.nwk`; do sed -i .bak s/"\""//g $i; done``
- Simulating along 10 prior trees and estimating parameters:
	- execute: `python run_experiment.py ebola_analysis_template.xml ../null/results/`
	- execute: `R-script plot_null_results.R` and `plot_null_results_treestats.R`

### Treescape analyses:
- tree distribution:
    - execute: `downsample_trees.sh`
    - manual intervention: execute: `python get_tree_with_mapping.py` and manually copy output as additional tree state to `combined.trees` **or** execute: `python get_tree_with_mapping.py > tree_mapped.nwk` and then `downsample_trees_new.sh`
    - execute: `Rscript plot_tree_distribution.R`

### apTreeShape analysis:
- Execute: `extract_treestats.R`

### RAxML confirmatory analyses:
- execute: `python run_rax_experiment.py ebola_analysis_template.xml ../results/rax --cluster`
- parse the LSD output to create `rax_rate_estimates.txt` (e.g. with `grep "^rate " #.lsd.job | sed -r 's/ebola_([0-9]+)_0.1_[0-9]#.lsd.job:rate 0.([0-9]+).#/\1 0.\2/' > rax_rate_estimates.txt`)
- execute: `Rscript plot_rax_results.R`


----

## Empirical analyses:

### Empirical analyses:
- for all analyses the xml analysis files were prepared by hand in BEAUti with possibly some manual adjustments
- execute analysis files
- execute Rscript `plot_results.R` and `plot_results_treestats.R`

### Path sampling analysis:
- execute: `bash path_sampling.sh` (after adjusting cluster settings)
- manual intervention: copy relevant results from cluster to local machine (relevant results are essentially only the likelihood.log files)
- execute: `bash path_sampling_analysis.sh` (after adjusting path settings)
- execute: `Rscript path_sampling_plotting.R`
- execute: `python path_sampling_ess_analysis.py` to obtain summary ESS statistics

### Random deme assignments:
- execute:
	- `python ../run_struct_coal.py struct_coal_template.xml ./ 3,6,28,44 5
	- `python ../run_struct_coal.py struct_coal_template.xml ./ 20,20,20,21 5`
- manual intervention: Copy relevant files across (only the log files) and combine log files
- run: `plot_randomdeme_results.R`
