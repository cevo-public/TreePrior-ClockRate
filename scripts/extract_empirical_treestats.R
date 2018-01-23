rm(list = ls())
library(ape)
library(apTreeshape)
library(TreeSim)
library(laser)

# load data
extract_data = function(data_name) {
  models = vector(mode = "list", length = 6)
  #names(models) = c('bd', 'bdsky', 'const_coal', 'exp_coal', 'sky_coal', 'struct_coal')
  names(models) = c('sky_coal')
  df = data.frame()
  for (m in names(models)) {
    filename = paste('../results/', data_name, '/', m, sep='')
    if (file.exists(paste0(filename,".trees"))) {
      print(filename)
      if (m == 'struct_coal') 
          trees = read.nexus(paste0(filename,".typedNode.trees"))
      else
          trees = read.nexus(paste0(filename,".trees"))
      if (!is.null(data)) {
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

for (data_name in c('guinea', 'gire')) {
  extract_data(data_name)
}

