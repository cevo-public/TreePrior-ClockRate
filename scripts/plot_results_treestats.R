library(coda)
library(ggplot2)
library(scales)
library(reshape2)

my_summary = function(s) {
  q = HPDinterval(mcmc(s))
  return (data.frame(y = median(s), ymin = q[1], ymax = q[2]))
}

load_data = function(filename) {
  data = read.table(paste0(filename,".log"), header=TRUE, quote="\"")
  tree = read.table(paste0(filename,".treestat"), header=TRUE, sep="\t")
  n = nrow(data)
  m = nrow(tree)
  if (n < 10001 || n != m) {
    print(n)
    print(m)
    return ()
  } else {
    names(data)[names(data) == 'treeHeight.t:tree'] = 'treeHeight'
    names(data)[names(data) == 'treeHeight.t.tree'] = 'treeHeight'
    names(data)[names(data) == 'TreeHeight'] = 'treeHeight'
    names(data)[names(data) == 'treeHeight.t.guinea_sequences'] = 'treeHeight'
    names(data)[names(data) == 'treeLength.t:tree'] = 'treeLength'
    names(data)[names(data) == 'treeLength.t.tree'] = 'treeLength'
    names(data)[names(data) == 'treeLength.t.guinea_sequences'] = 'treeLength'
    names(data)[names(data) == 'clockRate.c:clock'] = 'clockRate'
    names(data)[names(data) == 'clockRate.c.clock'] = 'clockRate'
    names(data)[names(data) == 'clockRate.c.influenza_1_full'] = 'clockRate'
    names(data)[names(data) == 'clockRate.c.guinea_sequences'] = 'clockRate'
    # Not necessary anymore, I reran it with treeLength logged - Louis
    #if (file.exists(gsub(".log", "_tree_length.txt", filename))) {
    #  x = read.table(gsub(".log", "_tree_length.txt", filename), header = TRUE)
    #  data$treeLength = x$total_tree_length
    #}
    
    # Calculate total evolution
    data$totalEvolution = data$clockRate * data$treeLength
    
    # Add tree statistics
    data$colless = tree$Colless
    data$sackin  = tree$Sackin
    data$gamstat = tree$Gamma.statistic
    
    # Select relevant and discard burnin (+1 so the same number of rows are selected as in colless and sackin)
    data = data[as.integer(0.1*n+1):n,c("clockRate", "treeHeight", "treeLength", "totalEvolution", "colless", "sackin", "gamstat")]
    
    # Post-processing  
    colnames(data) = c('Clock rate', 'Tree height', 'Tree length', 'Total divergence', "Colless", "Sackin", "Gamma statistic")
    data = melt(data, measure.vars = 1:ncol(data))
    return (data)
  }
}

# specify some parameters

create_plot = function(data_name) {
  models = vector(mode = "list", length = 6)
  names(models) = c('bd', 'bdsky', 'const_coal', 'exp_coal', 'sky_coal', 'struct_coal')
  models[['bd']] = 'Birth death'
  models[['bdsky']] = 'Birth death skyline'
  models[['const_coal']] = 'Constant coalescent'
  models[['exp_coal']] = 'Exp. growth coalescent'
  models[['sky_coal']] = 'Skyline coalescent'
  models[['struct_coal']] = 'Structured coalescent'
  df = data.frame()
  for (m in names(models)) {
    filename = paste('../results/', data_name, '/', m, sep='')
    if (file.exists(paste0(filename,".log")) && file.exists(paste0(filename,".treestat"))) {
      print(filename)
      data = load_data(filename)
      if (!is.null(data)) {
        data$model = as.factor(models[[m]])
        data$guinea = T
        df = rbind(df, data)
      }
    } else {
      print(paste("File not found:", filename))
    }
  }
  
  range_clockrate  <- data.frame(model = models[[1]], value = c(0.0005,0.003), variable='Clock rate')

  ggplot(aes(x = model, y = value), data = df) +
    stat_summary(fun.data = my_summary, position = position_dodge(width = 0.3), size = 0.5, fatten = 1.2) +
    facet_grid(variable ~ ., scales = 'free') + theme_bw(base_size = 10) +
    geom_blank(data=range_clockrate) + 
    theme(legend.position = 'none', axis.text.x = element_text(angle = 45, hjust = 1), axis.title.x=element_blank(), axis.title.y=element_blank()) 
  ggsave(paste('../figures/', data_name, '_treestats.pdf', sep = ''), width = 8.5, height = 19.5, units = 'cm')
}

for (data_name in c('guinea', 'gire')) {
  create_plot(data_name)
}

# this is some additional data that could be added to the Gire plot
# most recent sequence in data is from 18 June 2014
# reference date from Louis:
# 26 December 2013 - Symptom onset in index case 
# so 89 days or 0.4767 years later
# a lower bound is provided by the oldest sequence in
# the data from 17 March 2014 (0.2548)
# 10 May - Funeral of traditional healer (seeding Sierra leone outbreak) (0.1068)
# oldest sequence in Sierra Leone: 25.05. (0.0658)
dummy_df_gire = data.frame(variable = 'Tree height',
                           value = c(0.2548, 0.4767, 0.1068, 0.0658),
                           event = c('Oldest sequence (Guinea)', 'Index case', 'Healer funeral', 'Oldest sequence\n(Sierra Leone)'))

