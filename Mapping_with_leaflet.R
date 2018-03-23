##############################################################################
# Mapping in R, using a leaflet and a chloropleth
#
# Source of some of this: https://rstudio.github.io/leaflet/choropleths.html
#
# Date: March 2018
# Author: Karen
##############################################################################

library(maptools)
library(leaflet)
library(htmltools)

# Read in shapefile
# Source: http://geoportal.statistics.gov.uk/datasets?q=LAD%20Boundaries%202017&sort=name
las = readShapePoly("C:/Users/ONS-BIG-DATA/Documents/R_mapping/LA_GB_Dec17_shapefile_super/Local_Authority_Districts_December_2017_Super_Generalised_Clipped_Boundaries_in_Great_Britain.shp")

# If type proj4string(las), the projection system is NA. Actually we use the British
# National Grid so need to convert that (http://spatialreference.org/ref/epsg/27700/)
# Then convert to WGS84 using the odd strings below
proj4string(las) <- CRS("+init=epsg:27700")
las_trans <- spTransform(las, CRS("+proj=longlat +datum=WGS84"))

# Read in data about average house prices in December 2017
# Source: https://www.gov.uk/government/collections/uk-house-price-index-reports
prices <- read.csv("C:/Users/ONS-BIG-DATA/Documents/R_mapping/Average_house_prices_LA_dec17.csv",
                   stringsAsFactors = FALSE)

# Merge spatial polygon with prices data
las_trans <- sp::merge(las_trans, prices, by.x="lad17cd", by.y="LA_code")

# Prepare prices bins
bins <- c(0, 100000, 150000, 200000, 300000, 400000, 600000, 1000000, Inf)
pal <- colorBin("YlOrRd", domain = las_trans$Average_price, bins = bins)

# Create hover-over labels
labels <- sprintf(
  "<strong>%s</strong><br/>£ %g",
  las_trans$LA_name, las_trans$Average_price
) %>% lapply(htmltools::HTML)

# Create the map
m <- leaflet(las_trans) %>%
  setView(lng = -5, lat = 55, zoom = 5) %>%
  addTiles(urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
  addPolygons(  fillColor = ~pal(Average_price),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.7,
                highlight = highlightOptions(
                  weight = 5,
                  color = "#666",
                  dashArray = "",
                  fillOpacity = 0.7,
                  bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "15px",
                  direction = "auto")) %>%
  addLegend(pal = pal, values = ~Average_price, opacity = 0.7, title = NULL,
                                                 position = "bottomright")
m




