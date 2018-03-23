library(shiny)
library(maptools)
library(htmltools)
library(leaflet)

# Define UI for application that draws a histogram
ui <- fluidPage(
  leafletOutput("mymap", height=750),
  p()
)