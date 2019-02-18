####################################################################################################
####################################################################################################
## DOWNLOAD GFC DATA IN SEPAL
## Contact remi.dannunzio@fao.org 
## 2017/11/02
####################################################################################################
####################################################################################################

#######################################################################
############  PART I: Check GFC data availability - download if needed
#######################################################################
### Make vector layer of tiles that cover the country
aoi   <- getData('GADM',
                 path=gfcstore_dir, 
                 country= countrycode, 
                 level=0)

aoi <- readOGR(paste0(aoi_dir,"indo_aoi.shp"))
(bb    <- extent(aoi))

tiles <- calc_gfc_tiles(aoi)

proj4string(tiles) <- proj4string(aoi)
tiles <- tiles[aoi,]

### Find the suffix of the associated GFC data for each tile
tmp         <- data.frame(1:length(tiles),rep("nd",length(tiles)))
names(tmp)  <- c("tile_id","gfc_suffix")

for (n in 1:length(tiles)) {
  gfc_tile <- tiles[n, ]
  min_x <- bbox(gfc_tile)[1, 1]
  max_y <- bbox(gfc_tile)[2, 2]
  if (min_x < 0) {min_x <- paste0(sprintf("%03i", abs(min_x)), "W")}
  else {min_x <- paste0(sprintf("%03i", min_x), "E")}
  if (max_y < 0) {max_y <- paste0(sprintf("%02i", abs(max_y)), "S")}
  else {max_y <- paste0(sprintf("%02i", max_y), "N")}
  tmp[n,2] <- paste0("_", max_y, "_", min_x, ".tif")
}

### Store the information into a SpatialPolygonDF
df_tiles <- SpatialPolygonsDataFrame(tiles,tmp,match.ID = F)
rm(tmp)

### Display the tiles and area of interest to check
plot(df_tiles)
plot(aoi,add=T)


### Check if tiles are available and download otherwise : download can take some time
beginCluster()
download_tiles(tiles,
                  gfcstore_dir,
                  images = c("treecover2000","lossyear","gain","datamask"))
endCluster()
df_tiles@data

### GET THE LIST OF TILES INCLUDED IN THE WORK
prefix <- "Hansen_GFC-2017-v1.5_"
tiles  <- unlist(paste0(prefix,"datamask",df_tiles@data$gfc_suffix))
tilesx <- substr(tiles,31,38)

types <- c("treecover2000","lossyear","gain","datamask")

### MERGE THE TILES TOGETHER, FOR EACH LAYER SEPARATELY and CLIP TO THE BOUNDING BOX OF THE COUNTRY
for(type in types){

  print(type)

  to_merge <- paste(prefix,type,"_",tilesx,".tif",sep = "")

  system(sprintf("gdal_merge.py -o %s -v -co COMPRESS=LZW %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfcstore_dir,to_merge,collapse = " ")
  ))

  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfc_dir,"gfc_",type,".tif")
  ))

  system(sprintf("rm %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif")
  ))
  print(to_merge)
}
