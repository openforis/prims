####################################################################################################
####################################################################################################
## Set environment variables
## Contact remi.dannunzio@fao.org 
## 2018/05/04
####################################################################################################
####################################################################################################

####################################################################################################

### Read all external files with TEXT as TEXT
options(stringsAsFactors = FALSE)

### Create a function that checks if a package is installed and installs it otherwise
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

### Install (if necessary) two missing packages in your local SEPAL environment
packages(Hmisc)
packages(RCurl)
packages(hexbin)
packages(gfcanalysis)

### Load necessary packages
packages(raster)
packages(rgeos)
packages(ggplot2)
packages(rgdal)
packages(dplyr)

## Set the working directory
rootdir       <- "~/ws_uga_20180828/"

## Set two downloads directories
gfcstore_dir  <- "~/downloads/gfc_2016/"
esastore_dir  <- "~/downloads/ESA_2016/"

## Set the country code
countrycode <- "UGA"

## Go to the root directory
setwd(rootdir)
rootdir <- paste0(getwd(),"/")

scriptdir<- paste0(rootdir,"scripts/")
data_dir <- paste0(rootdir,"data/")
gadm_dir <- paste0(rootdir,"data/gadm/")
gfc_dir  <- paste0(rootdir,"data/gfc/")
lsat_dir <- paste0(rootdir,"data/mosaic_lsat/")
seg_dir  <- paste0(rootdir,"data/segments/")
dd_dir   <- paste0(rootdir,"data/dd_map/")
lc_dir   <- paste0(rootdir,"data/forest_mask/")
esa_dir  <- paste0(rootdir,"data/esa/")
tile_dir <- paste0(rootdir,"data/tiling/")
tab_dir  <- paste0(rootdir,"data/tables/")

dir.create(data_dir,showWarnings = F)
dir.create(gadm_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(lsat_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(dd_dir,showWarnings = F)
dir.create(lc_dir,showWarnings = F)
dir.create(esa_dir,showWarnings = F)
dir.create(gfcstore_dir,showWarnings = F)
dir.create(esastore_dir,showWarnings = F)
dir.create(tile_dir,showWarnings = F)

#################### GFC PRODUCTS
gfc_threshold <- 30

#################### PRODUCTS AT THE THRESHOLD
gfc_tc       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_tc.tif")
gfc_ly       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_ly.tif")
gfc_gn       <- paste0(gfc_dir,"gfc_gain.tif")
gfc_16       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_F_2016.tif")
gfc_00       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_F_2000.tif")
gfc_mp       <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,".tif")
gfc_mp_crop  <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,"_crop.tif")
gfc_mp_sub   <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,"_sub_crop.tif")
