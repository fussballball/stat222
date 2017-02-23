
setwd("/Users/Lee/Google Drive/UCB/climate/data")

# package install and require
install.packages("ncdf4")
library("ncdf4")


# compress 2.5 by 2.5 grid data into 5 by 5
# here input data should be 72*144*84: from 1979/01-1985/12
# output as one dimension: value per month data.frame
month<-c()
for (i in 1979:1985){
  ii<-1
  while (ii<=12){
    if (ii<10){
      month<-c(month,paste0(i,"0",ii))
    }else{
      month<-c(month,paste0(i,ii))
    }
    ii<-ii+1
  }
}
transform_5by5<-function(data){
  month_col<-c(rep(1,72*36*84))
  data_col<-c(rep(1,72*36*84))
  count<-0
  for (i in 1:length(data[1,1,])){
    for (a in 1:72){
      for (b in 1:36){
        count<-count+1
        month_col[count]<-month[i]
        data_col[count]<-mean(data[(2*a-1),(2*b-1),i],data[(2*a),(2*b-1),i],data[(2*a-1),(2*b),i],data[(2*a),(2*b),i])
      }
    }
  }
  output<-data.frame("month"=month_col,"data"=data_col)
  return(output)
}
transform_05to5<-function(data){
  month_col<-c(rep(1,72*36*84))
  data_col<-c(rep(1,72*36*84))
  count<-0
  for (i in 1:length(data[1,1,])){
    for (a in 1:72){
      for (b in 1:36){
        count<-count+1
        month_col[count]<-month[i]
        data_col[count]<-mean(data[(10*a-9):(10*a),(10*b-9):(10*b),i])
      }
    }
  }
  output<-data.frame("month"=month_col,"data"=data_col)
  return(output)
}

transform_1to5<-function(data){
  month_col<-c(rep(1,72*36*84))
  data_col<-c(rep(1,72*36*84))
  count<-0
  for (i in 1:length(data[1,1,])){
    for (a in 1:72){
      for (b in 1:36){
        count<-count+1
        month_col[count]<-month[i]
        # reverse: tas land is from south to north
        data_col[count]<-mean(data[(5*a-4):(5*a),(5*b-4):(5*b),i])
      }
    }
  }
  output<-data.frame("month"=month_col,"data"=data_col)
  return(output)
}
# here input data should be 36*172*84: from 1979/01-1985/12
# output as one dimension: value per month data.frame
transform<-function(data){
  month_col<-c(rep(1,72*36*84))
  data_col<-c(rep(1,72*36*84))
  count<-0
  for (i in 1:length(data[1,1,])){
    for (a in 1:72){
      for (b in 1:36){
        count<-count+1
        month_col[count]<-month[i]
        data_col[count]<-data[a,b,i]
      }
    }
  }
  output<-data.frame("month"=month_col,"data"=data_col)
  return(output)
}
models<-read.csv("his_model.txt",header=FALSE,stringsAsFactors = F)[,1]

# variable name
var="pr"
dir<-paste0("./",var,"-his/",var)
data_list<-list.files(dir)
data_r <- nc_open(paste0(dir,"/",data_list[1]))
data <- ncvar_get(data_r)
data_r 
# 3 dimensions:
# time  Size:1632  
#   calendar: standard
# units: days since 1850-01-01 00:00:00
# lat  Size:72
# lon  Size:144
# units: kg m-2 s-1
# long_name: Precipitation
# standard_name: precipitation_flux
str(data) #num [1:144, 1:72, 1:1632]

# for each model, transfer into 5by5_one_dimension output csv
# obtain month from 1979/01-1985/12

dir.create(paste0(var,"-1d"))
for (i in 1:length(models)){
  file<-data_list[grep(models[i],data_list)]
  data_r <- nc_open(paste0(dir,"/",file))
  data <- ncvar_get(data_r)
  # to ge the 1979/01-1985/12 84 months data
  #(1980-1850)*12
  data<-data[,,((1979-1850)*12+1):((1979-1850)*12+84)]
  write.csv(transform_5by5(data),paste0(var,"-1d/",models[i],".csv"),row.names=FALSE)
}





PR<- nc_open("pr_obs.nc") 
# there's something wrong with the description
# Temporal Coverage: data coverage should be Monthly values 1979/01 through Aug 2016
# Spatial Coverage: 2.5 degree latitude x 2.5 degree longitude global grid (144x72)
data <- ncvar_get(PR)
# 4 dimensions:
# units: mm/day
# lat  Size:72
# lon  Size:144
# time  Size:452  
data<-data[,,1:84]
write.csv(transform_5by5(data),"pr_obs_1d.csv",row.names=FALSE)

# form a matrix of precipitation
prep<-read.csv("pr_obs_1d.csv",stringsAsFactors = F)
# different units: obs:mm/day # units: kg m-2 s-1 # google:kg/m^2/s - the same as mm/s
for (i in 1:length(models)){
  mod<-read.csv(paste0("pr-1d/",models[i],".csv"),stringsAsFactors = F)[,2]
  # unit change
  mod<-mod*24*60*60
  prep<-cbind(prep,mod)
}
names(prep)<-c("month","obs",models)
write.csv(prep,"prep_obs_models.csv",row.names = F)

sapply(prep[,2:21],mean)
sapply(prep[,2:21],sd)



prep_dis<-diag(20)
rownames(prep_dis)<-c("obs",models)
colnames(prep_dis)<-c("obs",models)
for (i in 2:21){
  for (j in 2:21){
    prep_dis[i-1,j-1]<-sqrt(sum((prep[,i] - prep[,j]) ^ 2))
  }
}

write.csv(prep_dis,"prep_distance_noscale.csv",row.names = F)

# standardize each model with obs. mean and obs. sd
mean_o<-mean(prep$obs); sd_o<-sd(prep$obs)
for (i in 2:21){
  prep[,i]<-(prep[,i]-mean_o)/sd_o
}

prep_dis<-diag(20)
rownames(prep_dis)<-c("obs",models)
colnames(prep_dis)<-c("obs",models)
for (i in 2:21){
  for (j in 2:21){
    prep_dis[i-1,j-1]<-sqrt(sum((prep[,i] - prep[,j]) ^ 2))
  }
}
write.csv(prep_dis,"prep_distance_scale.csv",row.names = F)
mds<-cmdscale(prep_dis, eig = TRUE, k = 2)
points<-data.frame(mds$points)
points[,1]<-points[,1]-points[1,1]
points[,2]<-points[,2]-points[1,2]
names(points)<-c("x","y")
points$names<-row.names(points)

library(ggplot2)
library(ggthemes)
ggplot()+geom_point(data=points,aes(x=x,y=y,shape=names,color=names),size=3)+
  xlim(-max(abs(c(points[,1],points[,1])))*1.2, max(abs(c(points[,1],points[,1])))*1.2)+
  ylim(-max(abs(c(points[,2],points[,2])))*1.2, max(abs(c(points[,2],points[,2])))*1.2)+
  guides(color = guide_legend(keywidth = 0.3, keyheight = 0.3))+
  theme(legend.text=ggplot2::element_text(size=10),legend.title=ggplot2::element_blank())+
  scale_shape_manual(values=seq(0,20))+
  annotate("segment", x=-Inf,xend=Inf,y=0,yend=0,arrow=arrow(length=ggplot2::unit(0.3,"cm")),size=0.5,color="grey60") +
  annotate("segment", y=-Inf,yend=Inf,x=0,xend=0,arrow=arrow(length=ggplot2::unit(0.3,"cm")),size=0.5,color="grey60")+
  ggtitle(paste0("PR-HistoricalGHG vs Observation"))



# observational data : surface temperature

TS<- nc_open("tas_obs1_land.nc")
data <- ncvar_get(TS)
# 
# 4 dimensions:
# latitude  Size:36
# longitude  Size:72
# time  Size:2004 
# start_year: 1979
# end_year: 2016
# observational data : precipitation
# units: K
data<-data[,,((1979-1900)*12+1):((1979-1900)*12+84)]

data_land<-transform_05to5(data)


TS<- nc_open("tas_obs1_sea.nc")
data <- ncvar_get(TS)
# 
# 4 dimensions:
# latitude  Size:36
# longitude  Size:72
# time  Size:2004 
# start_year: 1850
# end_year: 2016
# observational data : precipitation
# units: K
data<-data[,,((1979-1850)*12+1):((1979-1850)*12+84)]
data_sea<-transform_1to5(data)
write.csv(data_land,"tas_obs_land.csv",row.names=FALSE)


TS<- nc_open("tas_obs.nc")
data <- ncvar_get(TS)
data<-data[,,((1979-1850)*12+1):((1979-1850)*12+84)]
TS<- nc_open("absolute.nc")
abs <- ncvar_get(TS)
abs<-abs+273.15
# add absolute value to anomalies 
for (i in 1:7){
  ii<-1
  while (ii<=12){
  data[,,(12*(i-1)+ii)]<-data[,,(12*(i-1)+ii)]+abs[,,ii]
  ii<-ii+1
  }
}
data<-transform(data)
write.csv(data,"tas_obs_1D.csv",row.names=FALSE)




####################################
# form a matrix of ts
#####################################
tas<-read.csv("tas_obs_1d.csv",stringsAsFactors = F)
for (i in 1:length(models)){
  mod<-read.csv(paste0("tas-1d/",models[i],".csv"),stringsAsFactors = F)[,2]
  tas<-cbind(tas,mod)
}
names(tas)<-c("month","obs",models)
write.csv(tas,"tas_obs_models.csv",row.names = F)
tas<-read.csv("tas_obs_models.csv",stringsAsFactors = F)
tas<-na.omit(tas)
sapply(tas[,2:21],mean)
sapply(tas[,2:21],sd)



tas_dis<-diag(20)
rownames(tas_dis)<-c("obs",models)
colnames(tas_dis)<-c("obs",models)
for (i in 2:21){
  for (j in 2:21){

    tas_dis[i-1,j-1]<-sqrt(sum((tas[,i] - tas[,j]) ^ 2))
  }
}

write.csv(tas_dis,"tas_distance_noscale.csv",row.names = F)

# standardize each model with obs. mean and obs. sd
mean_o<-mean(tas$obs); sd_o<-sd(tas$obs)
for (i in 2:21){
  tas[,i]<-(tas[,i]-mean_o)/sd_o
}

tas_dis<-diag(20)
rownames(tas_dis)<-c("obs",models)
colnames(tas_dis)<-c("obs",models)
for (i in 2:21){
  for (j in 2:21){
    tas_dis[i-1,j-1]<-sqrt(sum((tas[,i] - tas[,j]) ^ 2))
  }
}
tas_dis[1,]<-tas_dis[1,]/3.1
tas_dis[,1]<-tas_dis[,1]/3.1
write.csv(tas_dis,"tas_distance_scale.csv",row.names = F)
mds<-cmdscale(tas_dis, eig = TRUE, k = 2)
points<-data.frame(mds$points)
points[,1]<-points[,1]-points[1,1]
points[,2]<-points[,2]-points[1,2]
names(points)<-c("x","y")
points$names<-row.names(points)

library(ggplot2)
library(ggthemes)
ggplot()+geom_point(data=points,aes(x=x,y=y,shape=names,color=names),size=3)+
  xlim(-max(abs(c(points[,1],points[,1])))*1.2, max(abs(c(points[,1],points[,1])))*1.2)+
  ylim(-max(abs(c(points[,2],points[,2])))*1.2, max(abs(c(points[,2],points[,2])))*1.2)+
  guides(color = guide_legend(keywidth = 0.3, keyheight = 0.3))+
  theme(legend.text=ggplot2::element_text(size=10),legend.title=ggplot2::element_blank())+
  scale_shape_manual(values=seq(0,20))+
  annotate("segment", x=-Inf,xend=Inf,y=0,yend=0,arrow=arrow(length=ggplot2::unit(0.3,"cm")),size=0.5,color="grey60") +
  annotate("segment", y=-Inf,yend=Inf,x=0,xend=0,arrow=arrow(length=ggplot2::unit(0.3,"cm")),size=0.5,color="grey60")+
  ggtitle(paste0("TS-HistoricalGHG vs Observation"))