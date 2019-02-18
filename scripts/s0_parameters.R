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
# packages(RCurl)
# packages(hexbin)
# packages(devtools)
# packages(gdata)
# install_github('yfinegold/gfcanalysis')
# packages(gfcanalysis)
# packages(tidyverse)
# packages(readxl)
# packages(ggplot2)

### Load necessary packages
packages(raster)
packages(rgeos)
packages(rgdal)
# packages(stringr)


## Set the working directory
rootdir       <- "~/prims/"

## Set two downloads directories
gfcstore_dir  <- "~/downloads/gfc_2017/"


## Set the country code
countrycode <- "IDN"

## Go to the root directory
setwd(rootdir)
rootdir <- paste0(getwd(),"/")

scriptdir <- paste0(rootdir,"scripts/")
data_dir  <- paste0(rootdir,"data/")
gadm_dir  <- paste0(rootdir,"data/gadm/")
gfc_dir   <- paste0(rootdir,"data/gfc/")
moz_dir   <- paste0(rootdir,"data/mosaic/")
seg_dir   <- paste0(rootdir,"data/segments/")
dd_dir    <- paste0(rootdir,"data/dd_map/")
tile_dir  <- paste0(rootdir,"data/tiling/")
tab_dir   <- paste0(rootdir,"data/tables/")
aoi_dir   <- paste0(rootdir,"data/aoi/")
gwl_dir   <- paste0(rootdir,"data/data_gwl/")
dam_dir   <- paste0(rootdir,"data/data_canals/3.AREA_RENCANA_KONTIJENSI_2017/")

dir.create(data_dir,showWarnings = F)
dir.create(gadm_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(moz_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(dd_dir,showWarnings = F)
dir.create(gfcstore_dir,showWarnings = F)
dir.create(tile_dir,showWarnings = F)
dir.create(gwl_dir,showWarnings = F)

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
