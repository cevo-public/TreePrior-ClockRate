rm(list = ls())
library(ape)
library(apTreeshape)
library(TreeSim)
library(laser)



# specify some parameters
args = commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  results_dir = args[1]
  output_dir = args[1]
} else {
  results_dir = "../results/results_bdsky_est/"
  output_dir = "../results/results_bdsky_est/"
}
  
data_pre = "ebola_"
nruns = 10
seq_lengths = c(0, 100, 500, 1000, 15000)
rates = 0.1

# load data
for (i in 0:(nruns-1)) {
  for (l in seq_lengths) {
    for (r in rates) {
      filename = paste(results_dir, data_pre, l, "_", r, "_", i, sep = "")
      if (file.exists(paste0(filename,".trees"))) {
        print(filename)
        trees = read.nexus(paste0(filename,".trees"))
        
        if (!is.null(trees)) {
          data  = matrix(0, nrow=length(trees), ncol=5)
          colnames(data) <- c("Tree height", "Tree length", "Colless", "Sackin", "Gamma statistic")
          
          for (tree in 1:length(trees)) {
            treeshape   <- as.treeshape(trees[[tree]]) 
            branchtimes <- getx(trees[[tree]],1)[,1]
            data[tree,] <- c(max(branchtimes), sum(trees[[tree]]$edge.length), colless(treeshape), sackin(treeshape), gamStat(branchtimes, return.list=FALSE))
          }
          write.table(data,  paste0(filename,".treestat"),  sep="\t", quote=FALSE, row.names = FALSE)
        }
      } else {
        print(paste("File not found:", filename))
      }
    }
  }
}