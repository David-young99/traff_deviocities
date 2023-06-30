## Load packages
#Mapbox is for the API facilities and settings
#Library sf allow to edit, modify, export geospatial files, in this case a GeoJSON or Shapefile
library(mapboxapi)
library(googletraffic)
library(dplyr)
library(sf)

## Set API key (This API key must be with the Mapbox account based on the GeoAdaptive google account)
#mapbox_key <- "pk.eyJ1IjoiZHlvdW5nOTkiLCJhIjoiY2xqY3Zpaml6MjRsazNxcWcybGk3aGczdiJ9.30a_QLXc7Obxj3Ugx7lJAg"
mapbox_key = "pk.eyJ1IjoiZGF2aWR5ZmxvbCIsImEiOiJjamdyNmRqMnAwMzBhMnhsb2oyNWx0aWk4In0.Zw_q8QejxpFOcuJJ_lWwjA"


##Un/comment this path if you are running the code in windows (please change the path for your computer)

input_path = "C:\\Users\\David\\Dropbox (GeoAdaptive)\\2022_INI-04_DEVELOPMENT DASHBOARD\\DOCS\\Project development\\R code\\Traffic_DeVioCities\\traff_deviocities\\inputs\\"
output_path = "C:\\Users\\David\\Dropbox (GeoAdaptive)\\2022_INI-04_DEVELOPMENT DASHBOARD\\DOCS\\Project development\\R code\\Traffic_DeVioCities\\traff_deviocities\\outputs\\"

##Un/comment this path if you are running the code in VM (If you are using the GeoAdaptive GCP Instance do not change)

#input_path = "/home/dyoung/gitrepo/gt/Archivo_CA/"
#output_path = "/home/dyoung/gitrepo/gt/Ouputs/traffic_congestion_vect/"


## Grab shapefile, in this case I'm using just the Central America Shapefile
raw_polygon <- st_read(paste0(input_path, "CitiesADM2.shp"))
ca_polygon <- st_make_valid(raw_polygon)

## Query traffic data using googletraffic library methods (pay attention to the zoom, this will be the road congestion data detail: more zoom more detail but more processing time)
ca_conf_poly <- get_vector_tiles(      # From here, the code gets the data in tiles for later vector exportation
  tileset_id = "mapbox.mapbox-traffic-v1",
  location = ca_polygon,
  zoom = 15,
  access_token = mapbox_key
)$traffic

## Get from mapbox the data based on the previous settings and the 4 different traffic levels
ca_conf_poly <- ca_conf_poly %>%
  mutate(congestion = congestion %>% 
           tools::toTitleCase() %>%
           factor(levels = c("Low", "Moderate", "Heavy", "Severe")))

## Export to GeoJSON (un-comment in case that you want export in this format)
#st_write(ca_conf_poly, output_path, geojson_test", driver = "GeoJSON", append = TRUE)

## Export to Shapefile
st_write(ca_conf_poly, output_path, "DeVio_Cities", driver = "ESRI Shapefile", append = TRUE)