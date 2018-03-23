###############################################
# Mapping in R, using a static chloropleth
#
# Date: March 2018
# Author: Karen
###############################################

library(maptools)
install.packages('rgeos', type='source')
install.packages('rgdal', type='source')
library(ggplot2)

# Read in shapefile
# Source: http://geoportal.statistics.gov.uk/datasets?q=LAD%20Boundaries%202017&sort=name
las = readShapePoly("C:/Users/ONS-BIG-DATA/Documents/R_mapping/LA_GB_Dec17_shapefile_super/Local_Authority_Districts_December_2017_Super_Generalised_Clipped_Boundaries_in_Great_Britain.shp")

# Plot this
plot(las)

# Turn the shapefile into a dataframe that can be worked on in R
las <- fortify(las, region="lad17cd")

# Read in data about average house prices in December 2017
# Source: https://www.gov.uk/government/collections/uk-house-price-index-reports
prices <- read.csv("C:/Users/ONS-BIG-DATA/Documents/R_mapping/Average_house_prices_LA_dec17.csv",
                   stringsAsFactors = FALSE)

# Merge with data on prices
las <- merge(las, prices, by.x="id", by.y="LA_code")

# Show chloropleth
ggplot() + geom_polygon(data=las, aes(x=long, y=lat, group=group, fill=Average_price)) +
  theme_void()




