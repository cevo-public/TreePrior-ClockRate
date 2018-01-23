library(ggplot2)
library(xtable)

expand_model_names = function(df) {
  models = vector(mode = "list", length = 6)
  names(models) = c('bd', 'bdsky', 'const_coal', 'exp_coal', 'sky_coal', 'struct_coal')
  models[['bd']] = 'Birth death'
  models[['bdsky']] = 'Birth death skyline'
  models[['const_coal']] = 'Constant coalescent'
  models[['exp_coal']] = 'Exp. growth coalescent'
  models[['sky_coal']] = 'Skyline coalescent'
  models[['struct_coal']] = 'Structured coalescent'
  
  for (m in levels(df$Model)) {
    levels(df$Model)[levels(df$Model) == m] = models[[m]]
  }
  
  return(df)
}

create_plot = function(data_name) {
  df <- read.table(paste("../results/", data_name, "/path_sampling/likelihood_summary.txt", sep="/"), quote="\"", comment.char="")
  names(df) = c("Model", "Steps", "Likelihood")
  df$Steps = as.factor(df$Steps)
  for (s in levels(df$Steps)) {
    df[df$Steps==s,"Likelihood"] = df[df$Steps==s,"Likelihood"] - df[df$Model=="struct_coal"&df$Steps==s,"Likelihood"]
  }
  df = expand_model_names(df)
  
  ggplot(aes(Model, Likelihood), data = df) +
    geom_bar(stat = "identity", position = "dodge") + ylab("log Bayes Factor") + 
    theme_bw(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), axis.title.x=element_blank())+
    facet_grid(. ~ Steps)
  ggsave(paste("../figures/suppl_", data_name, "_likelihoods.pdf", sep=""), height = 7, width = 17, units = "cm")

  ggplot(aes(Model, Likelihood), data = subset(df, Steps == 16)) +
    geom_bar(stat = "identity", position = "dodge") + ylab("log Bayes Factor") + 
    theme_bw(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), axis.title.x=element_blank())
  ggsave(paste("../figures/", data_name, "_likelihoods.pdf", sep=""), height = 7, width = 8.5, units = "cm")
  
  return(df)
}

create_table = function(df) {
  rnames = c()
  cnames = paste(levels(df$Steps), "steps")
  result = c()
  for (model in levels(df$Model)) {
      rnames = c(rnames, model)
      bfs = c()
      for (steps in levels(df$Steps)) {
          bfs = c(bfs, df$Likelihood[which(df$Model == model & df$Steps == steps)])   
      }
      result = rbind(result, bfs)
  }
  rownames(result) = rnames
  colnames(result) = cnames
  return(result)
}

for (data_name in c('guinea', 'gire')) {
  df <- create_plot(data_name)
  print.xtable(xtable(create_table(df), align="lrrrr", label=paste0("table:",data_name,"_likelihoods"), caption=data_name), file=paste0("../figures/",data_name,"_likelihoods.tex"))
}