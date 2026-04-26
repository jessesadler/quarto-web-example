# Geographic data #

library(readr)
library(dplyr)
library(tidygeocoder)
library(sf)
library(terra)
library(tidyterra)
library(elevatr)
library(rnaturalearth)
library(here)

# Geocoding ---------------------------------------------------------------

locations_vector <- c(
  "Antwerp", "Bremen", "Cologne", "Frankfurt", "Stade", "Utrecht", "Leiden",
  "Dordrecht", "Haarlem", "London", "Venice", "Verona", "Naples", "Amsterdam",
  "Middelburg", "Hamburg", "Strasbourg", "Augsburg", "Nuremberg", "Seville",
  "Lisbon", "Kortrijk", "Valenciennes", "Breda", "Oudenaarde", "Lier", "Hulst",
  "Zutphen", "Bruges", "Ghent", "Brussels", "Mechelen", "Nijmegen", "Delft",
  "Geertruidenberg", "Enkhuizen"
)

# geocode locations vector
locations_geo <- geo(locations_vector)
# Convert to sf object and project to 3034: https://epsg.io/3034
locations_sf <- locations_geo |>
  st_as_sf(coords = c("long", "lat"), crs = 4236) |> 
  st_transform(crs = "EPSG:3034")

# Add back in lat and long columns with new coordinates using st_coordinates()
# These are helpful for labeling the points
locations_sf <- locations_sf |> 
  mutate(long = st_coordinates(locations_sf)[ , 1], # long is first set of coords
         lat  = st_coordinates(locations_sf)[ , 2], # lat is second set of coords
         .after = address)

# Save file as geojson: This preserves geometry column
st_write(locations_sf, here("data", "locations.geojson"))

# Europe base map ---------------------------------------------------------

# Create a sf object that is a rectangle of the area you want to map

euro_bbox <- st_bbox(c(xmin = -11, xmax = 24, # Create the rectangle
                       ymax = 58, ymin = 34),
                     crs = st_crs(4326)) |>
  st_as_sfc() |> # Make it a geometry column
  st_as_sf() # Make it an sf object with only a geometry column


# Get the raster
euro_raster <- get_elev_raster(st_as_sf(euro_bbox), z = 5)

# Make it into a terra object and reproject
euro_raster <- euro_raster |>
  rast() |>
  project("EPSG:3034")

# Remove negative elevation
names(euro_raster)
names(euro_raster) <- "altitude"
euro_raster # Note that minimum altitude is quite low

# Fix with if else statement
euro_raster <- euro_raster |>
  mutate(altitude = if_else(condition = altitude < 0,
                            true = 0,
                            false = altitude))

writeRaster(euro_raster, here("data", "euro.tif"))

# Northwest Europe base map -----------------------------------------------

nw_bbox <- st_bbox(c(xmin = -2, xmax = 12, ymax = 55, ymin = 49),
                   crs = st_crs(4326)) |>
  st_as_sfc() |> 
  st_as_sf()

nw_raster <- get_elev_raster(nw_bbox, z = 6)
nw_raster <- nw_raster |>
  rast() |>
  project("EPSG:3034")

# Remove negative elevation
names(nw_raster) <- "altitude"
nw_raster <- nw_raster |>
  mutate(altitude = if_else(condition = altitude < 0,
                            true = 0,
                            false = altitude))

writeRaster(nw_raster, here("data", "northwest.tif"))

# Low Countries base map --------------------------------------------------

lc_bbox <- st_bbox(c(xmin = 0, xmax = 8, ymax = 54, ymin = 49),
                   crs = st_crs(4326)) |>
  st_as_sfc() |> 
  st_sf()

lc_raster <- get_elev_raster(lc_bbox, z = 6)

lc_raster <- lc_raster |>
  rast() |>
  project("EPSG:3034")

# Remove negative elevation
names(lc_raster) <- "altitude"
lc_raster <- lc_raster |>
  mutate(altitude = if_else(condition = altitude < 0,
                            true = 0,
                            false = altitude))

writeRaster(lc_raster, here("data", "lowcountries.tif"))


# Vector data -------------------------------------------------------------

# Ocean
ocean <- ne_download(scale = 10,
            category = "physical",
            type = "ocean")

# Reproject using euro_bbox
ocean <- st_transform(ocean, crs = "EPSG:3034")
euro_bbox_3034 <- st_transform(euro_bbox, crs = "EPSG:3034")
euro_ocean <- st_crop(ocean, euro_bbox_3034)

# Save as geojson
st_write(euro_ocean, here("data", "oceans.geojson"))

# River
rivers <- ne_download(scale = 10,
                     category = "physical",
                     type = "rivers_lake_centerlines_scale_rank")

rivers <- st_transform(rivers, crs = "EPSG:3034")
euro_rivers <- st_crop(rivers, euro_bbox_3034)

# Clean column names
euro_rivers <- euro_rivers |> 
  select(featurecla, scalerank, rivernum, name, name_en, strokeweig, geometry)

# Save as geojson
st_write(euro_rivers, here("data", "rivers.geojson"), delete_dsn = TRUE)
