####################################################################################################
####################################################################################################
## READ DAM LOCATION AND GENERATE INPUT FOR CEO
## Contact remi.dannunzio@fao.org 
## 2018/08/22
####################################################################################################
####################################################################################################

setwd(dam_dir)
df <- readOGR(paste0(dam_dir,"Arahan_Sekatkanal_RK2017_SSaleh_SSugihan.shp"))
df_geo <- spTransform(df,CRS('+init=epsg:4326'))
head(df_geo@coords)
head(df)

out <- cbind(df_geo@coords[,1:2],1:nrow(df),df@data)
names(out) <- c("LONGITUDE","LATITUDE","PLOTID",names(df))
write.csv(out,paste0(dam_dir,"dams.csv"),row.names = F)
