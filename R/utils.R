logit = function(x) log(x) - log1p(-x)
expit = function(x) 1 / (1 + exp(-x))
output_dir = "~/rds/hpc-work/PhD_survival_analysis/"