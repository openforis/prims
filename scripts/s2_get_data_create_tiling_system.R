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

## Get GADM data, check object properties
country         <- getData('GADM',path=gadm_dir , country= countrycode, level=1)

summary(country)
extent(country)
proj4string(country)

## Display the SPDF
plot(country)

##  Export the SpatialPolygonDataFrame as a ESRI Shapefile
writeOGR(country,
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

generate_grid <- function(aoi,size){
### Create a set of regular SpatialPoints on the extent of the created polygons  
sqr <- SpatialPoints(makegrid(aoi,offset=c(0.5,0.5),cellsize = size))

### Convert points to a square grid
grid <- points2grid(sqr)

### Convert the grid to SpatialPolygonDataFrame
SpP_grd <- as.SpatialPolygons.GridTopology(grid)

sqr_df <- SpatialPolygonsDataFrame(Sr=SpP_grd,
                                   data=data.frame(rep(1,length(SpP_grd))),
                                   match.ID=F)

### Assign the right projection
proj4string(sqr_df) <- proj4string(aoi)
sqr_df
}

sqr_df <- generate_grid(country,grid_deg)

nrow(sqr_df)

### Select a vector from location of another vector
aoi <- readOGR(paste0(aoi_dir,"indo_aoi.shp"))

### Select a vector from location of another vector
sqr_df_selected <- sqr_df[aoi,]
nrow(sqr_df_selected)

### Plot the results
plot(sqr_df_selected)
plot(aoi,add=T,border="blue")
plot(country,add=T,border="green")

### Give the output a decent name, with unique ID
sqr_df_selected@data$tileID <- row(sqr_df_selected@data)[,1]



### Export ONE TILE as KML
export_name <- paste0("one_tile_",countrycode)
one_tile <- sqr_df_selected[sqr_df_selected$tileID == 10,]
plot(one_tile,add=T,col="blue")

writeOGR(obj=   one_tile,
         dsn=   paste(tile_dir,export_name,".kml",sep=""),
         layer= export_name,
         driver = "KML",
         overwrite_layer = T)


### Export as KML
export_name <- paste0("tiling_system_",countrycode)

writeOGR(obj=sqr_df_selected,
         dsn=paste(tile_dir,export_name,".kml",sep=""),
         layer= export_name,
         driver = "KML",
         overwrite_layer = T)

### Make a subset of 10 tiles
subset <- sqr_df_selected[sample(1:nrow(sqr_df_selected@data),10),]
plot(subset,col="red",add=T)
