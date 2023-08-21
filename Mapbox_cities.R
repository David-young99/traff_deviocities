## Load packages
#Mapbox is for the API facilities and settings
#Library sf allow to edit, modify, export geospatial files, in this case a GeoJSON or Shapefile
library(mapboxapi)
library(dplyr)
library(sf)

##
#This sections get the day and time of the current code ejecution, this is for a custom name file save.
current_date = Sys.Date()
day = format(current_date, "%d")

month_num = format(current_date, "%m")
month = month.name[as.integer(month_num)]

year = format(current_date, "%Y")

da_te = paste0(day, "_", month)

hora_actual <- format(Sys.time(), format = "%H:%M:%S")


## Set API key (This API key must be with the Mapbox account based on the GeoAdaptive google account)
#mapbox_key <- "pk.eyJ1IjoiZHlvdW5nOTkiLCJhIjoiY2xqY3Zpaml6MjRsazNxcWcybGk3aGczdiJ9.30a_QLXc7Obxj3Ugx7lJAg"
mapbox_key = "pk.eyJ1IjoiZGFyZG85MyIsImEiOiJjbGttcnI0NmswbmNwM2VtdjYzeTF1bWI3In0.rGczuUVhhVqO3WzKajrLSA"


##Un/comment this path if you are running the code in windows (please change the path for your computer)

#input_path = "C:\\Users\\David\\Dropbox (GeoAdaptive)\\2022_INI-04_DEVELOPMENT DASHBOARD\\DOCS\\Project development\\R code\\Traffic_DeVioCities\\traff_deviocities\\inputs\\"
#output_pathyear = paste0("C:\\Users\\David\\Desktop\\testcities\\", year)
#output_pathdate = paste0(output_pathyear, "\\", da_te)
#output_path = paste0("C:\\Users\\David\\Desktop\\testcities\\", year,"\\", da_te, "\\")

##Un/comment this path if you are running the code in VM (If you are using the GeoAdaptive GCP Instance do not change)

input_path = "/home/dyoung/gitrepos/traff_deviocities/inputs/"
output_pathyear = paste0("/home/dyoung/gitrepos/traff_deviocities/outputs/", year)
output_pathdate = paste0(output_pathyear, da_te)

output_path = "/home/dyoung/gitrepos/traff_deviocities/outputs/"



#Verifying if the year folder already exist

if (dir.exists(output_pathyear)){
  print("-")
  print("-")
  print("Folder Already exist, jumping creation of the year folder!")
  print("-")
  print("-")
}else{
  dir.create(output_pathyear)
  
  print("-")
  print("-")
  print("New year folder created, ¡Happy new year!")
  print("-")
  print("-")
}

dir.create(output_path)


## Grab shapefile, in this case I'm using just the Central America Shapefile
raw_polygon <- st_read(paste0(input_path, "CitiesLim.shp"))
ca_polygon <- st_make_valid(raw_polygon)

for (i in 1:nrow(ca_polygon)) {
  adm = ca_polygon[i, ]
  
  adm_code = adm$UC_IDs
  
  tryCatch({
    ## Query traffic data using googletraffic library methods (pay attention to the zoom, this will be the road congestion data detail: more zoom more detail but more processing time)
    ca_conf_poly <- get_vector_tiles(      # From here, the code gets the data in tiles for later vector exportation
      tileset_id = "mapbox.mapbox-traffic-v1",
      location = adm,
      zoom = 10,
      access_token = mapbox_key
    )$traffic
    
    if (!is.null(ca_conf_poly)) {  # Check if data is available for this area
      ## Get from mapbox the data based on the previous settings and the 4 different traffic levels
      ca_conf_poly <- ca_conf_poly %>%
        mutate(congestion = congestion %>% 
                 tools::toTitleCase() %>%
                 factor(levels = c("Low", "Moderate", "Heavy", "Severe")))
      
      ## Export to GeoJSON (un-comment in case that you want export in this format)
      #st_write(ca_conf_poly, output_path, geojson_test", driver = "GeoJSON", append = TRUE)
      
      export_name = paste("DeVioCity_", adm_code)
      print(paste0("Exported in: ", da_te, ", hour: ", hora_actual))
      
      ## Export to Shapefile
      st_write(ca_conf_poly, output_path, export_name, driver = "ESRI Shapefile", append = TRUE)
      
      print(paste0("DeVioCity", adm_code, " exported successfully!"))
    } else {
      print(paste0("No traffic data found for area ", adm_code))
    }
  }, error = function(e) {
    print(paste0("Error processing ", adm_code, ": ", conditionMessage(e)))
  })
}
