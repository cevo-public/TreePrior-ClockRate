library(coda)
library(ggplot2)
library(scales)
library(reshape2)

my_summary = function(s) {
  q = HPDinterval(mcmc(s))
  return (data.frame(y = median(s), ymin = min(q[1],q[2]), ymax = max(q[1],q[2])))
}

my_summary2 = function(s) {
  mm = mean(s)
  ss = sd(s)
  return(data.frame(y=mm, ymin=mm-ss, ymax=mm+ss))
}

get_hpd_stats = function(data, variable, run, seq_length, dummy) {
  truth  = dummy$value[which(dummy$variable == variable & dummy$run == run & dummy$seq_length == seq_length)]
  subset = which(data$variable == variable & data$run == run & data$seq_length == seq_length)
  hpd = my_summary(data$value[subset])
  
  coverage  <- (hpd$ymin <= truth & hpd$ymax >= truth)
  hpdwidth  <- abs(hpd$ymax-hpd$ymin)/abs(truth)
  bias      <- hpd$y-truth
  relbias   <- (hpd$y-truth)/truth
  rmsd      <- sqrt(mean((hpd$y - truth)^2))
  
  result = data.frame(statistic = c("Coverage", "Relative HPD width", "Bias", "Relative bias", "RMSD"), 
                      value     = c(coverage, hpdwidth, bias, relbias, rmsd))
  
  #result$run = as.factor(run)
  result$seq_length = as.factor(seq_length)
  result$variable = as.factor(variable)
  
  return(result)
}

load_data = function(filename, colless, sackin) {
  data = read.table(paste0(filename,".log"), header=TRUE, quote="\"")
  n = nrow(data)
  if (n > 10001) {
    return ()
  } else {
    # Pre-processing
    names(data)[names(data) == 'TreeHeight.ebola'] = 'treeHeight'
    names(data)[names(data) == 'becomeUninfectiousRate.s.tree'] = 'becomeUninfectiousRate'
    names(data)[names(data) == 'samplingProportion.s.tree'] = 'samplingProportion'
    names(data)[names(data) == 'R0.s.tree'] = 'R0.s.tree'
    names(data)[names(data) == 'popSize.ebola'] = 'popSize'
    
    # Calculate total evolution
    data$totalEvolution = data$clockRate * data$treeLength
    
    # Select relevant and discard burnin (+1 so the same number of rows are selected as in colless and sackin)
    data = data[as.integer(0.1*n+1):n,c("clockRate", "treeHeight", "treeLength", "posterior","totalEvolution")]
    
    # Post-processing  
    colnames(data) = c('Clock rate', 'Tree height', 'Tree length', 'Posterior', 'Total divergence')
    data = melt(data, measure.vars = 1:ncol(data))
    return (data)
  }
}

plot_results <- function(results_dir="../results/", output_dir="../results/", nruns = 10, seq_lengths = c(0, 100, 500, 1000, 15000), rates = c(0.1)) {

    # specify some parameters (the same for all)
    setups = c("const_coal")
    data_pre = "ebola_"
    
    # create output directory
    dir.create(output_dir, showWarnings = FALSE)   
    
    
    # load data
    df = data.frame()
    for (s in setups) {
      for (i in 0:(nruns-1)) {
        for (l in seq_lengths) {
          for (r in rates) {
            filename = paste(results_dir, data_pre, l, "_", r, "_", i, sep = "")
            if (file.exists(paste0(filename,".log"))) {
              print(filename)
              data = load_data(filename)
              if (!is.null(data)) {
                data$run = as.factor(i)
                data$seq_length = as.factor(l)
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
    
    dummy_df = expand.grid(seq_lengths, rates, 0:(nruns-1), setups)
    colnames(dummy_df) = c("seq_length", "rate", "run", "setup")
    dummy_df$clockRate = dummy_df$rate
    dummy_df$treeHeight = 1.083
    dummy_df$treeLength = 23.8288
    dummy_df$totalEvolution = dummy_df$clockRate * dummy_df$treeLength
    colnames(dummy_df) = c("seq_length", "rate", "run", "setup", 'Clock rate', 'Tree height', 'Tree length', 'Total divergence')
    dummy_df = melt(dummy_df, id.vars = 1:4)
    
    # Do plots
    ggplot(aes(x = seq_length, y = value, group = run), data = subset(df, variable != 'Posterior' & seq_length != 0)) +
      stat_summary(fun.data = my_summary, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'free') + xlab('Sequence length') + ylab('') +
      geom_hline(data = dummy_df, aes(yintercept = value), linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_summary_",rates[1],".pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    ggplot(aes(x = seq_length, y = value, group = run), data = subset(df, variable != 'Posterior' & seq_length != 1)) +
      stat_summary(fun.data = my_summary, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'free') + xlab('Sequence length') + ylab('') +
      geom_hline(data = dummy_df, aes(yintercept = value), linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_summary_prior_",rates[1],".pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    # Extract statistics
    data_stats = data.frame()
    for (var in levels(dummy_df$variable))  {
        for (seq_length in levels(df$seq_length)) {
            for (run in levels(df$run)) {
                stats = get_hpd_stats(df, var, run, seq_length, dummy_df)
                data_stats = rbind(data_stats, stats)
            }
        }
    }
    
    # Do statistics
    ggplot(aes(x = seq_length, y = value, group = run), data = subset(data_stats, statistic == "Coverage")) +
      geom_col(size = 0.2, width=0.25) +
      facet_grid(variable ~ ., scales = 'fixed') + xlab('Sequence length') + ylab('') +
      geom_hline(yintercept=0, linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_coverage.pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    ggplot(aes(x = seq_length, y = value), data = subset(data_stats, statistic == "Relative HPD width" & seq_length != 0)) +
      stat_summary(fun.data = my_summary2, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'fixed') + xlab('Sequence length') + ylab('') +
      geom_hline(yintercept=0, linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_relhpdwidth.pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    ggplot(aes(x = seq_length, y = value), data = subset(data_stats, statistic == "Relative bias" & seq_length != 0)) +
      stat_summary(fun.data = my_summary2, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'fixed') + xlab('Sequence length') + ylab('') +
      geom_hline(yintercept=0, linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_relbias.pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    ggplot(aes(x = seq_length, y = value), data = subset(data_stats, statistic == "RMSD" & seq_length != 0)) +
      stat_summary(fun.data = my_summary2, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'fixed') + xlab('Sequence length') + ylab('') +
      geom_hline(yintercept=0, linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_RMSD.pdf", sep = ""), width = 8.5, height = 10, units = "cm")
    
    ggplot(aes(x = seq_length, y = value), data = subset(data_stats, statistic == "Relative bias")) +
      stat_summary(fun.data = my_summary2, geom = 'pointrange', size = 0.4, fatten = 1, position = position_dodge(width = 0.4)) +
      facet_grid(variable ~ ., scales = 'fixed') + xlab('Sequence length') + ylab('') +
      geom_hline(yintercept=0, linetype = 3) +
      theme_bw(base_size = 10)
    ggsave(paste(output_dir, "simulation_relbias_prior.pdf", sep = ""), width = 8.5, height = 10, units = "cm")

}

# Plot figures
analyses <- c("bdsky_est", "bdsky_largeRe", "bdsky_smallRe", "exp_growth_est", "exp_growth_fast", "exp_growth_slow", 
              "fixedtopology", "precision1", "precision2")

for (analysis in analyses) 
  plot_results(results_dir=paste0("../results/results_",analysis,"/"), output_dir=paste0("../figures/",analysis,"/"))

plot_results(results_dir="../results/results_simulation/", output_dir="../figures/simulation/", rates = c(0.1))
plot_results(results_dir="../results/results_simulation/", output_dir="../figures/simulation/", rates = c(0.01))
plot_results(results_dir="../results/results_simulation/", output_dir="../figures/simulation/", rates = c(0.001))


