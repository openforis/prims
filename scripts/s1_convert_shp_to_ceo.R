####################################################################################################
####################################################################################################
## READ DAM LOCATION SHAPEFILE AND GENERATE INPUT FOR CEO
## Contact remi.dannunzio@fao.org 
## 2019/02/19
####################################################################################################
####################################################################################################

############## SET THE WORKING DIRECTORY
setwd(dam_dir)

############## READ THE SHAPEFILE
pts <- readOGR(paste0(dam_dir,"Arahan_Sekatkanal_RK2017_SSaleh_SSugihan.shp"))

############## PLOT THE POINTS
plot(pts)

############## REPROJECT INTO WGS84 Latitude / Longitude
pts_geo <- spTransform(pts,CRS('+init=epsg:4326'))

############## EXAMINE THE OBJECT SLOTS
slotNames(pts_geo)

############## VISUALIZE THE FIRST LINES OF THE COORDINATES FILE
head(pts_geo@coords)

############## APPEND A UNIQUE ID COLUMN (PLOT ID) & THE ORIGINAL DBF FILE
out <- cbind(pts_geo@coords[,1:2],
             1:nrow(pts),
             pts@data)

############## GIVE SPECIFIC NAMES (CEO-COMPATIBLE)
names(out) <- c("LONGITUDE","LATITUDE","PLOTID",names(pts))

e<-extent(pts_geo)

poly <- Polygons(list(Polygon(cbind(
  c(e@xmin,e@xmin,e@xmax,e@xmax,e@xmin),
  c(e@ymin,e@ymax,e@ymax,e@ymin,e@ymin))
)),"file")

lp <- append(lp,list(poly))
}

## Transform the list into a SPDF
stnl_idx <-SpatialPolygonsDataFrame(
  SpatialPolygons(lp,1:length(lp)), 
  data.frame(list_s2), 
  match.ID = F
)


############## EXPORT AS CSV FILE
write.csv(out,paste0(dam_dir,"dams_",Sys.Date(),".csv"),row.names = F)
