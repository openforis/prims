####################################################################################################
####################################################################################################
## Read, manipulate and write spatial vector data, Get GADM data
## Contact remi.dannunzio@fao.org 
## 2018/08/22
####################################################################################################
####################################################################################################


####################################################################################################
################################### PART I: GET GADM DATA
####################################################################################################

## Get the list of countries from getData: "getData"
(gadm_list  <- data.frame(getData('ISO3')))
?getData

## Get GADM data, check object propreties
aoi         <- getData('GADM',path=gadm_dir , country= countrycode, level=1)

summary(aoi)
extent(aoi)
proj4string(aoi)

## Display the SPDF
#plot(aoi)

##  Export the SpatialPolygonDataFrame as a ESRI Shapefile
writeOGR(aoi,
         paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
         paste0("gadm_",countrycode,"_l1"),
         "ESRI Shapefile",
         overwrite_layer = T)


####################################################################################################
################################### PART II: CREATE A TILING OVER AN AREA OF INTEREST
####################################################################################################

### What grid size do we need ? 
grid_size <- 20000          ## in meters
grid_deg  <- grid_size/111320 ## in degree

### Create a set of regular SpatialPoints on the extent of the created polygons  
sqr <- SpatialPoints(makegrid(aoi,offset=c(0.5,0.5),cellsize = grid_deg))

### Convert points to a square grid
grid <- points2grid(sqr)

### Convert the grid to SpatialPolygonDataFrame
SpP_grd <- as.SpatialPolygons.GridTopology(grid)

sqr_df <- SpatialPolygonsDataFrame(Sr=SpP_grd,
                                   data=data.frame(rep(1,length(SpP_grd))),
                                   match.ID=F)

### Assign the right projection
proj4string(sqr_df) <- proj4string(aoi)

### Select a vector from location of another vector
sqr_df_selected <- sqr_df[aoi,]

### Plot the results
#plot(aoi)
#plot(sqr_df_selected,add=T,col="blue")

### Select a vector from location of another vector
sqr_df_selected <- sqr_df_selected[readOGR(paste0(aoi_dir,"indo_aoi.shp")),]

### Plot the results
plot(sqr_df_selected)
plot(aoi,add=T)


### Give the output a decent name, with unique ID
names(sqr_df_selected) <- "tileID"
sqr_df_selected@data$tileID <- row(sqr_df_selected@data)[,1]

### Check how many tiles will be created
nrow(sqr_df_selected@data)

### Make a subset of 10 tiles
subset <- sqr_df_selected[sample(1:nrow(sqr_df_selected@data),10),]
plot(subset,col="red",add=T)

### Export ONE TILE as KML
base_sqr <- paste0("one_tile_",countrycode)
writeOGR(obj=sqr_df_selected[sqr_df_selected$tileID == 10,],
         dsn=paste(tile_dir,base_sqr,".kml",sep=""),
         layer=base_sqr,
         driver = "KML",
         overwrite_layer = T)


### Export as KML
base_sqr <- paste0("tiling_system_",countrycode)
writeOGR(obj=sqr_df_selected,
         dsn=paste(tile_dir,base_sqr,".kml",sep=""),
         layer=base_sqr,
         driver = "KML",
         overwrite_layer = T)
