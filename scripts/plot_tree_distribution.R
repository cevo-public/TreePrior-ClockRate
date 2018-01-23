# Treescape is no longer supported, force install of old version
# library(devtools)
# install_version("treescape","1.10.18")
#
# This requires rgl to be installed which requires Xquartz to be installed before it will work.

library(ggplot2)
library(treescape)

plot_tree_distribution <- function(results_dir="../results/", output_dir="../figures/", nruns=10, seq_lengths = c(0, 100, 500, 1000, 15000), rate="", lambda=0) {
    
    data_pre = "ebola_"
    ntrees_per_file = 91
    
    # load data
    for (i in 0:(nruns-1)) {
      
        df = data.frame(A1=numeric(), A2=numeric(), id=numeric(), seq_length=numeric(), run = numeric())
        filename = paste(results_dir, "combined_",rate,i,".trees", sep = "")
        res = treescape(read.nexus(filename), nf=2, lambda=lambda)
        df = as.data.frame(res$pco$li)
        if (nrow(df) != length(seq_lengths)*ntrees_per_file + 1) {
          print("Careful! Number of trees in file is different from what is expected.")
        }
        df$id = floor(0:(nrow(df)-1)/ntrees_per_file)
        df$id = df$id %% 6
        df$seq_length = as.factor(as.numeric(lapply(df$id, function(x) seq_lengths[x+1])))
        
        qplot(x = A1, y = A2, data = subset(df, id != 5), color = seq_length) + scale_color_discrete(name="Sequence\nlength") +
          theme_bw(base_size = 10) + xlab("First component") + ylab("Second component") +
          guides(colour = guide_legend(override.aes = list(size=4))) +
          geom_point(aes(A1, A2), data = subset(df, id == 5), color = "red", shape = 4, size = 5)
        ggsave(paste(output_dir, "topology_distribution_",rate,i,".pdf", sep = ""), width = 8.5, height = 6, units = "cm")
    }
}


# Simulation
rates <- c("0.1_", "0.01_", "0.001_")
for (rate in rates) 
  plot_tree_distribution(results_dir=paste0("../results/results_simulation/"), output_dir=paste0("../figures/simulation/"), rate=rate, lambda=0)


# Extra simulation variations
analyses <- c("bdsky_est", "bdsky_largeRe", "bdsky_smallRe", "exp_growth_est", "exp_growth_fast", "exp_growth_slow", 
              "precision1", "precision2", "uniform")

# Topology only
for (analysis in analyses) 
  plot_tree_distribution(results_dir=paste0("../results/results_",analysis,"/"), output_dir=paste0("../figures/",analysis,"/"), lambda=0)

# Branch lengths only
analyses <- c("fixedtopology")
for (analysis in analyses) 
  plot_tree_distribution(results_dir=paste0("../results/results_",analysis,"/"), output_dir=paste0("../figures/",analysis,"/"), lambda=1)