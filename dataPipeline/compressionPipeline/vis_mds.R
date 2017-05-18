library(rgl)
load("mds_data.rda")

####################
## clean time var
####################
time <- sort(rep(1:length(unique(mds.data$time)),
                 unique(unname(table(mds.data$time)))))
mds.data$t <- time

save(mds.data, file = "mds_data.rda")

####################
## Plot observation
####################
obs.dat <- mds.data[mds.data$model == "obs", ]
plot3d(obs.dat$X, obs.dat$Y, obs.dat$t,
           col = "black", type = "l")

for(mod in unique(mds.data$model)[-1]){
    rand_color <- colors()[sample(10:100, 1)]
    mod.dat <- mds.data[mds.data$model == mod, ]
    plot3d(mod.dat$X, mod.dat$Y, mod.dat$t,
           col = rand_color, type = "l", add = TRUE)
}
