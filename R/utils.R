logit = function(x) log(x) - log1p(-x)
expit = function(x) 1 / (1 + exp(-x))