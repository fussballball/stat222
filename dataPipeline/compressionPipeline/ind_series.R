library(MASS)
library(plyr)

############################################################
## generate some smoothed series
############################################################
models <- letters
ts.data <- ldply(models, function(model_i){
    series <- mvrnorm(1631, mu = rep(0,2),
                      Sigma = matrix(c(1, 0, 0, 1), 2, 2, byrow = TRUE))
    series[,1] <- filter(series[,1], filter = c(.5, .7, .9, .7, .5))
    series[,2] <- filter(series[,2], filter = c(.5, .7, .9, .7, .5))
    colnames(series) <- c("X", "Y")
    data.frame(model = model_i, t = 1:nrow(series), series,
               stringsAsFactors = FALSE)
})

##############################
## visualize the series
##############################
obs.dat <- ts.data[ts.data$model == "a", ]
plot3d(obs.dat$X, obs.dat$Y, obs.dat$t,
           col = "black", type = "l")

for(mod in unique(ts.data$model)[-1]){
    rand_color <- colors()[sample(10:100, 1)]
    mod.dat <- ts.data[ts.data$model == mod, ]
    plot3d(mod.dat$X, mod.dat$Y, mod.dat$t,
           col = rand_color, type = "l", add = TRUE)
}



