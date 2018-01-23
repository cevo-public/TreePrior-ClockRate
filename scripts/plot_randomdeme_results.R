library(coda)
library(ggplot2)
library(scales)
library(reshape2)

my_summary = function(s) {
  q = HPDinterval(mcmc(s))
  return (data.frame(y = median(s), ymin = q[1], ymax = q[2]))
}

load_data = function(filename) {
  data = read.table(filename, header=TRUE, quote="\"")
  n = nrow(data)
  if (n < 10001) {
    print("Returning...")
    return ()
  } else {
    names(data)[names(data) == 'treeHeight.t.tree'] = 'treeHeight'
    names(data)[names(data) == 'TreeHeight'] = 'treeHeight'
    names(data)[names(data) == 'treeHeight.t.tree'] = 'treeHeight'
    names(data)[names(data) == 'treeHeight.t.guinea_sequences'] = 'treeHeight'
    names(data)[names(data) == 'treeLength.t.tree'] = 'treeLength'
    names(data)[names(data) == 'treeLength.t.guinea_sequences'] = 'treeLength'
    names(data)[names(data) == 'clockRate.c.clock'] = 'clockRate'
    names(data)[names(data) == 'clockRate.c.influenza_1_full'] = 'clockRate'
    names(data)[names(data) == 'clockRate.c.guinea_sequences'] = 'clockRate'
    data = data[as.integer(0.1*n):n,c("clockRate", "treeHeight", "treeLength", "posterior")]
    data$totalEvolution = data$clockRate * data$treeLength
    colnames(data) = c('Clock rate', 'Tree height', 'Tree length', 'Posterior', 'Total divergence')
    data = melt(data, measure.vars = 1:ncol(data))
    return (data)
  }
}

datasets = c("gire")

replicates = c(0,1,2,3,6,10,11,14,17,19)

for (dataset in datasets) {
    
    # specify some parameters
    setups = c("struct_coal")
    results_dir = paste0("../results/", dataset, "/")
    output_dir = "../figures/"
    data_pre = "struct_coal_randomdeme_"
    rates = c(0.00131)
    #nruns = 20
    if (dataset == 'gire') 
        deme_sizes = c("20-20-20-21", "3-6-28-44")
    else
    if (dataset =='guinea')
        deme_sizes = c("59-59-59-59", "174-18-23-21")
    else
        deme_sizes = c("136-137", "122-151")
      
    df = data.frame()
    
    filename = paste(results_dir, "struct_coal.log", sep = "")
    if (file.exists(filename)) {
      print(filename)
      data = load_data(filename)
      if (!is.null(data)) {
        data$run = as.factor(5)
        data$deme_sizes = as.factor("clades")
        data$interval = as.factor(rates[1])
        data$setup = as.factor(setups[1])
        df = rbind(df, data)
      }
    } else {
      print(paste("File not found:", filename))
    }
    
    for (s in setups) {
      for (i in replicates) {
        for (d in deme_sizes) {
          for (r in rates) {
            filename = paste(results_dir, "/randomdeme_combined/", data_pre, d, "_", i, ".combined.log", sep = "")
            if (file.exists(filename)) {
              print(filename)
              data = load_data(filename)
              if (!is.null(data)) {
                data$run = as.factor(i)
                data$deme_sizes = as.factor(d)
                data$interval = as.factor(r)
                data$setup = as.factor(s)
                df = rbind(df, data)
              }
            } else {
              print(paste("File not found:", filename))
            }
          }
        }
      }
    }
        
    ggplot(aes(x = deme_sizes, y = value, group = run), data = subset(df, variable != 'Posterior')) +
      stat_summary(fun.data = my_summary, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'free') + xlab('Sequence length') + ylab('') +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, dataset,"_randomdeme_summary.pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
}