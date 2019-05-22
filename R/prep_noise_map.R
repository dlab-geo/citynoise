##########################################################
# prep_noise_map.R
#
# Author: Patty Frontiera, UC Berkeley D-Lab
# Last updated: 05-22-2019
#
# This script prepares data aggregated to all contiguous USA census tracts
# To be displayed in a webmap using the mapbox gl javascript library.
#
############################################################################
# About the Data
############################################################################
# The original input file with data for all census tracts is in this file
# ct2015_epsg5070.zip
# This file was simplified by 80% and then again by 65% using
# Mapshaper (local install) - https://github.com/mbloch/mapshaper
# which output the file ct2015_epsg5070_20_35.shp
############################################################################

library(tidyverse) 
library(sf)
library(rgdal)
library(htmlwidgets)

setwd("/Users/pattyf/Documents/Dlab/projects/city_noise/dnlproj/indata")

# Read in the simplified polygon data
ct<- st_read("ct2015_epsg5070_20_35.shp")
colnames(ct)
head(ct)
keepcols<-c("GISJOIN","STATEFP", "dnlmean","X_mean", "geometry")

ct2<- ct[keepcols]

summary(ct2$dnlmean) # day means
summary(ct2$X_mean)  # night means

#drop nas - 3 rows
ct3<- subset(ct2,!is.na(dnlmean))

# All cats & vals
# Categorical variable
ct3$cat <- "low"
table(ct3$cat)
ct3$cat <- ifelse(ct3$dnlmean >= 55, "medium",  ct3$cat)
table(ct3$cat)
ct3$cat <- ifelse(ct3$dnlmean > 58, "high", ct3$cat)
table(ct3$cat)

# Compute night categories
# < 40 is  low
# 40 - 43 is med
# > 43 is high
ct3$nightcat <- "low"
table(ct3$nightcat)
ct3$nightcat <- ifelse(ct3$X_mean >= 40, "medium",  ct3$nightcat)
table(ct3$cat)
ct3$nightcat <- ifelse(ct3$X_mean > 43, "high", ct3$nightcat)
table(ct3$nightcat)

head(ct3)

# Order the data from lowest to highest so that the high values
# will display on the map on top of the lower vals
ct3 <- ct3[order(ct3$dnlmean, decreasing = FALSE),]
head(ct3)

# Drop the numeric noise columns
ct4 <- ct3[c("GISJOIN","STATEFP","cat","nightcat","geometry")]
head(ct4)

# Create a points version of the data
# Create a centroid version of the dataset
ct4_pts <- st_centroid(ct4)
head(ct4_pts)

# Transform data to WGS84 (4326)
ct_all_polys_4326 <- st_transform(ct4, 4326)
ct_all_pts_4326 <- st_transform(ct4_pts, 4326)


# Write data objects to a geojson file
#st_write(ct_all_polys_4326, "ct_all_polys_4326.geojson",delete_dsn=TRUE)

# UPDATE working dir for output
setwd("/Users/pattyf/Documents/Dlab/projects/city_noise/dnlproj/geofiles")

# Write POINT data to geojson
st_write(ct_all_pts_4326, "ct_all_pts_4326.geojson",delete_dsn=TRUE)
st_write(ct_all_pts_4326[ct_all_pts_4326$cat=='low',], "ct_all_pts_4326_low.geojson",delete_dsn=TRUE)
st_write(ct_all_pts_4326[ct_all_pts_4326$cat=='medium',], "ct_all_pts_4326_medium.geojson",delete_dsn=TRUE) 
st_write(ct_all_pts_4326[ct_all_pts_4326$cat=='high',], "ct_all_pts_4326_high.geojson",delete_dsn=TRUE)
############################################################
# SPLIT UP THE POLYGON DATA into SMALLER FILES
# SO THEY LOAD MORE QUICKLY in web map
############################################################

# Create a detailed polygon shapefile for each state
# that has a lot of census tracts

#subset the top 10 states into their own shapefiles
sub_states<- c("06","48","36","12","42","17", "39", "26", "37","34")

for (i in sub_states){
  print(i)
  x <-subset(ct_all_polys_4326, STATEFP == i)
  fname <- paste0("ct_all_polys_4326_", i,".geojson")
  print(fname)
  st_write(x, fname ,delete_dsn=TRUE)
}

# Subset the census tracts for the states what we didn't process above
ct_to_divide <- subset(ct_all_polys_4326, !(STATEFP %in% sub_states))

# Add census tract division info to the data
region_lut <- read.csv("statefp_region_lut.csv", 
                   colClasses=c("character","character","character","character"), stringsAsFactors = F, strip.white = T)
head(region_lut)
head(ct_to_divide)
ct_div_polys <- left_join(ct_to_divide, region_lut, by="STATEFP")

# upload geojson to a github repo
head(ct_div_polys)
unique(region_lut$Division)
udiv <- c("1","2","3","4","5","6","7","8","9")
for (i in udiv){
  print(i)
  x <-subset(ct_div_polys, Division == i)
  # keep only subset of columns
  x <- x[c("GISJOIN","cat","nightcat","geometry")]
  fname <- paste0("ct_all_polys_4326_div_", i,".geojson")
  print(fname)
  st_write(x, fname,delete_dsn=TRUE)
}
head(x)
table(x$cat)
table(x$nightcat)

########################################
# POST PROCESS IN Tippecanoe & mapbox
# https://github.com/mapbox/tippecanoe
########################################
# Create mbtiles (vector tiles) using tippecanoe
# We need to use tippecanoe to fine tune the points vector tiles file
# by expanding the zoom level and imposing some clustering/simplification

# LATEST syntax used is listed BELOW
try(system("tippecanoe -o ct_all_pts_4326_clust_low.mbtiles -Z3 -z11 --coalesce -B6 ct_all_pts_4326_low.geojson -r1 -pi --cluster-distance=4 --force", intern=TRUE))
try(system("tippecanoe -o ct_all_pts_4326_clust_med.mbtiles -Z3 -z11 --coalesce -B6 ct_all_pts_4326_medium.geojson -r1 -pi --cluster-distance=4 --force", intern=TRUE))
try(system("tippecanoe -o ct_all_pts_4326_clust_high.mbtiles -Z3 -z11 --coalesce -B6 ct_all_pts_4326_high.geojson -r1 -pi --cluster-distance=3 --force", intern=TRUE))

# Merge the filtered tileset and the tileset of new tracts into a final tileset
try(system("tile-join -o ct_all_pts_4326_clust_all.mbtiles  ct_all_pts_4326_clust_low.mbtiles ct_all_pts_4326_clust_med.mbtiles ct_all_pts_4326_clust_high.mbtiles --force", intern=TRUE))

#
# NEXT STEPS
# Upload mbtiles file to mapbox
# Reference the mapbox vector tileset created from the mbtiles in the html file
# Make sure new tiles load successfull in HTML file

