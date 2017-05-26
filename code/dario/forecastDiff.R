library(gridExtra)
library(grid)
#Make a gif to compare the two "most different" models according to Yoni's PCA
mod1 <- nc_open("C:/Uni/Berkeley/2nd Semester/STAT222/gitrepo/dataPipeline/cmip5-ng/tas/tas_mon_BNU-ESM_rcp26_r1i1p1_g025.nc")
mod2 <- nc_open("C:/Uni/Berkeley/2nd Semester/STAT222/gitrepo/dataPipeline/cmip5-ng/tas/tas_mon_CNRM-CM5_rcp26_r1i1p1_g025.nc")

#This doesn't make any sense: 7000 years? something wrong there...
(max(mod1$dim$time$vals) - min(mod1$dim$time$vals))/365


data1 <- ncvar_get(mod1)
data1 <- melt(data1)
colnames(data1) <- c("lon", "lat", "time", "temp")
data1$lon <- data1$lon/max(data1$lon)*360 - 180
data1$lat<- data1$lat/max(data1$lat)*180 -90
data1$temp <- data1$temp - 272

data1$lon <- ifelse(data1$lon>0, data1$lon - 180, data1$lon +180)


data2 <- ncvar_get(mod2)
data2 <- melt(data2)
colnames(data2) <- c("lon", "lat", "time", "temp")
data2$lon <- data2$lon/max(data2$lon)*360 - 180
data2$lat<- data2$lat/max(data2$lat)*180 -90
data2$temp <- data2$temp - 272

data2$lon <- ifelse(data2$lon>0, data2$lon - 180, data2$lon +180)
indices <- seq(1,max(data2$time), by = 12)
for(i in indices){
  if (i < 10) {name = paste('pcadiff000',i,'plot.png',sep='')}
  
  if (i < 100 && i >= 10) {name = paste('pcadiff00',i,'plot.png', sep='')}
  if (i < 1000 && i>= 100) {name = paste('pcadiff0', i,'plot.png', sep='')}
  if (i > 1000) {name = paste('pcadiff', i,'plot.png', sep='')}
  tbp <- cbind(data1[data1$time ==i, c("lon","lat","time")], data1[data1$time ==i,"temp"] - data2[data2$time == i,"temp"])
  colnames(tbp) <- c(colnames(tbp)[-length(colnames(tbp))],"temp")
  plot3 <- ggplot()  + geom_tile(data = tbp, mapping = aes(x = lon, y = lat, color = temp)) +
  coord_fixed(1.4)+  scale_color_gradient("Temp. diff in K",low="blue", high="yellow", limits = c(-40, 40)) +
  geom_polygon(data = world, aes(x=long, y = lat, group = group), fill = NA, color = "black") +
    annotation_custom(grob = textGrob(paste(c("Year: ",(i-1)/12),collapse = "")),  
                      xmin = -10, xmax = -10, ymin = -50, ymax = -50)
  ggsave(filename = name, plot = plot3, path = "./pcagif/")
}



=======
#Make a gif to compare the two "most different" models according to Yoni's PCA
mod1 <- nc_open("C:/Uni/Berkeley/2nd Semester/STAT222/gitrepo/dataPipeline/cmip5-ng/tas/tas_mon_BNU-ESM_rcp26_r1i1p1_g025.nc")
mod2 <- nc_open("C:/Uni/Berkeley/2nd Semester/STAT222/gitrepo/dataPipeline/cmip5-ng/tas/tas_mon_CNRM-CM5_rcp26_r1i1p1_g025.nc")

#This doesn't make any sense: 7000 years? something wrong there...
(max(mod1$dim$time$vals) - min(mod1$dim$time$vals))/12


data1 <- ncvar_get(mod1)
data1 <- melt(data1)
colnames(data1) <- c("lon", "lat", "time", "temp")
data1$lon <- data1$lon/max(data1$lon)*360 - 180
data1$lat<- data1$lat/max(data1$lat)*180 -90
data1$temp <- data1$temp - 272

data1$lon <- ifelse(data1$lon>0, data1$lon - 180, data1$lon +180)


data2 <- ncvar_get(mod2)
data2 <- melt(data2)
colnames(data2) <- c("lon", "lat", "time", "temp")
data2$lon <- data2$lon/max(data2$lon)*360 - 180
data2$lat<- data2$lat/max(data2$lat)*180 -90
data2$temp <- data2$temp - 272

data2$lon <- ifelse(data2$lon>0, data2$lon - 180, data2$lon +180)
indices <- seq(1,max(data2$time), by = 12)
for(i in indices){
  if (i < 10) {name = paste('pcadiff000',i,'plot.png',sep='')}
  
  if (i < 100 && i >= 10) {name = paste('pcadiff00',i,'plot.png', sep='')}
  if (i < 1000 && i>= 100) {name = paste('pcadiff0', i,'plot.png', sep='')}
  if (i > 1000) {name = paste('pcadiff', i,'plot.png', sep='')}

  tbp <- cbind(data1[data1$time ==i, c("lon","lat","time")], data1[data1$time ==i,"temp"] - data2[data2$time == 1,"temp"])
  colnames(tbp) <- c(colnames(tbp)[-length(colnames(tbp))],"temp")
  plot3 <- ggplot()  + geom_tile(data = tbp, mapping = aes(x = lon, y = lat, color = temp)) +
  coord_fixed(1.4)+  scale_color_gradient(low="blue", high="yellow", limits = c(-40, 40)) +
  geom_polygon(data = world, aes(x=long, y = lat, group = group), fill = NA, color = "black")
  ggsave(filename = name, plot = plot3, path = "./pcagif/")
}



