##############################################################################
# Mapping in R, using a leaflet and a choropleth
#
# Source of some of this: https://rstudio.github.io/leaflet/choropleths.html
#
# Date: February 2020
# Author: Karen
##############################################################################

library(tidyverse)
library(sf)
library(leaflet)
library(htmltools)

# Read in shapefile. This shows local authority boundaries
# Source: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-december-2018-boundaries-uk-buc
las = sf::st_read("~/LA_UK_Dec18_shapefile_ultra/Local_Authority_Districts_December_2018_Boundaries_UK_BUC.shp")

# The projection (proj4string) here uses Ordnance Survey National Grid (+datum=OSGB36). Actually the
# shapefile uses the British National Grid so we need to convert that to WGS84 using the odd strings below
las_trans <- sf::st_transform(las, "+proj=longlat +datum=WGS84")

# Read in data about average house prices in November 2019
# Source: https://www.gov.uk/government/collections/uk-house-price-index-reports
prices <- readr::read_csv("~/Average_house_prices_LA_nov19.csv")

# Merge spatial polygon with prices data
las_trans <- sp::merge(x=las_trans, y=prices, by.x="lad18cd", by.y="Area_Code")

# Prepare prices bins
bins <- c(0, 100000, 150000, 200000, 300000, 400000, 600000, 1000000, Inf)
pal <- colorBin("YlOrRd", domain = las_trans$Average_price, bins = bins)

# Create hover-over labels
labels <- sprintf(
  "<strong>%s</strong><br/>£ %g",
  las_trans$Area_Name, las_trans$Average_Price
) %>% lapply(htmltools::HTML)

# Create the map
m <- leaflet(las_trans) %>%
  setView(lng = -5, lat = 55, zoom = 5) %>%
  addTiles() %>%
  addPolygons(  fillColor = ~pal(Average_Price),
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
  addLegend(pal = pal, values = ~Average_Price, opacity = 0.7, title = NULL,
            position = "bottomright")
m