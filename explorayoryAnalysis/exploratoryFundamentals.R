setwd("C:/Uni/Berkeley/2nd Semester/STAT222/")
library(ncdf4)
library(maptools)
library(lattice)
library(RColorBrewer)
rawData <- nc_open("./cmip5-ng/tas/tas_ann_ACCESS1-0_1pctCO2_r1i1p1_g025.nc")



####################Using ncdf4 package#######
data <- ncvar_get(rawData)
#Data consists of longitude, latitude and temperature at given longitude and latitude.
str(data)
#equivalently: only type data

#plot the predicted surface temp. for the northpole
plot(data[1,1,]-272, ylab = "degrees in Celsius")

#for some other coordinate
plot(data[40,40,]-272, ylab = "degrees in Celsius")


#some useful command
ncatt_get(rawData, "tas")

#open another dataset
rawData2 <- nc_open("./cmip5-ng/tas/tas_ann_ACCESS1-0_1pctCO2_r1i1p1_native.nc")
ncatt_get(rawData, "tas")

#plot the temperature for one timepoint.
#Which timepoint am I plotting? Also, why is Antartica red? (maybe bc missing values are 1^20?)
image(rawData$dim$lon$vals-180, rawData$dim$lat$vals,data[,,1])
data(wrld_simpl)
plot(wrld_simpl, add = TRUE)

data2 <- ncvar_get(rawData2)
image(rawData2$dim$lon$vals-180, rawData2$dim$lat$vals,data2[,,1])
data(wrld_simpl)
plot(wrld_simpl, add = TRUE)



#############NARCCAP Data######
narData <- nc_open("./NARCCAP data/sic_CRCM_ncep_1979010106.nc")


#######Do an online example######
tmp_array = data
lon = rawData$dim$lon$vals-180
lat = rawData$dim$lat$vals
m <- 1
tmp_slice <- tmp_array[,,m]
tmp_array2 = data2
tmp_slice2 <- data2[,,m]
image(lon,lat,tmp_slice, col=rev(brewer.pal(10,"RdBu")))

#not entirely sure about how to add the contours of the world here. doesn't matter
grid <- expand.grid(lon=lon, lat=lat)
cutpts <- seq(from = 220, to = 330, by = 10)
levelplot(tmp_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))))


lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)

#dataframe with lon, lat and temperature at the first timepoint.
tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste("temp",as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)




#######################Compare two different scenarios of one Model#################
scen1 <- nc_open("./cmip5-ng/tas/tas_ann_CCSM4_rcp26_r4i1p1_native.nc")
scen2 <- nc_open("./cmip5-ng/tas/tas_ann_CCSM4_rcp85_r4i1p1_native.nc")

dat1 <- ncvar_get(scen1) 
dat2 <- ncvar_get(scen2)

#look at the data for one timepoint (beginning) and compare
image(scen1$dim$lon$vals-180, scen1$dim$lat$vals,dat1[,,1])
plot(wrld_simpl, add = TRUE)

image(scen2$dim$lon$vals-180, scen2$dim$lat$vals,dat2[,,1])
plot(wrld_simpl, add = TRUE)


#towards the end:
image(scen1$dim$lon$vals-180, scen1$dim$lat$vals,dat1[,,231])
plot(wrld_simpl, add = TRUE)

#plot the differences
image(scen1$dim$lon$vals-180, scen1$dim$lat$vals,dat1[,,231] - dat2[,,231])
plot(wrld_simpl, add = TRUE)

image(scen2$dim$lon$vals-180, scen2$dim$lat$vals,dat2[,,231])
plot(wrld_simpl, add = TRUE)


plot(dat1[1,1,], ylim= c(222,234))
points(dat2[1,1,], col = "red")

#median difference for all scenarios zero (at least in this care, when compared to rcp26)
summary(dat1[60,40,]-dat2[60,40,])
#forecasts only start to differ late in the forecast period (which is why the median is always the same)
(dat1[1,1,]==dat2[1,1,])

#compare two models, with same scenario and ensemble.
newscen1 <- nc_open("./cmip5-ng/tas/tas_ann_CSIRO-Mk3-6-0_rcp26_r4i1p1_native.nc")
datNew1 <- ncvar_get(newscen1)
summary(dat1[1,1,]-datNew1[1,1,])
summary(dat1[40,40,]-datNew1[40,40,])

#that is some difference here....
plot(dat1[40,40,],ylim= c(270,300))
points(datNew1[40,40,], col = "red")
#is the data from newscen1 maybe for 2050-2080 or something and scen1 from 2020-2050? So are it just different timeframes?
#datNew1 gives no interpretation here. Says: units: days since 1800-01-01 00:00:00
#according to newscen1$dim$year$vals[1]/365 and scen1$dim$year$vals[1]/365 timeframe is the same. So why the big difference?
plot(diff(dat2[80,40,]), type = "l", col = "red")
lines(diff(dat1[80,40,]), type = "l", col = "blue")
summary(diff(dat2[80,40,]))

acf(dat2[80,40,1:100])
pcf(dat2[80,40,1:100])

ar.test <- ar(dat2[80,40,])
str(ar.test)
#doesn't seem to fit very well...
plot(ar.test$resid, type = "l")
#lag plot
lag.plot(dat1[80,40,], type = "p")
#lag plot of differences. Structure seems to be constant over coordinates.
lag.plot(diff(dat1[80,40,]), type = "p")
