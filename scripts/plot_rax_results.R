library(ggplot2)

df <- read.table("../results/rax_rate_estimates.txt", quote="\"", comment.char="")
colnames(df) = c("seqLength", "clockRate")
ggplot(aes(x = as.factor(seqLength), y = clockRate), data = df) + geom_boxplot() + geom_hline(aes(yintercept = 0.1), linetype = 3) + xlab("Sequence length") + ylab("Clock rate") + theme_bw(base_size = 10)
ggsave("../figures/suppl_rax.pdf", width = 8.5, height = 6, units = "cm")