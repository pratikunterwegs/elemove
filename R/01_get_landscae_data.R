#' ---
#' output: html_document
#' editor_options: 
#'   chunk_output_type: console
#' ---
#' 
#' # Getting Data
#' 
#' ## Load libraries
#' 
## -----------------------------------------------------------------------------
# load libs
library(data.table)
library(ggplot2)
library(sf)
library(rnaturalearth)

#' 
#' ## Get ZA
#' 
## -----------------------------------------------------------------------------
# get natural earth data
land <- ne_countries(
  continent = "africa",
  scale = "small",
  returnclass = "sf"
)

# save
st_write(land, "data/za_boundary.gpkg", append = F)

