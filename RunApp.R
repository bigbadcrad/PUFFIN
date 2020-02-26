##### Notes ------------------------------------------------------
# - Probabilistic Urban Flash Flood Information Nexus (PUFFIN)
# - Author: Conrad Brendel, cbrendel@vt.edu

rm(list=ls()) # Clear Environment

##### Get Directory of the R Script and set as working directory -----------------------------------------------------------------
ez.csf = function() {
  # http://stackoverflow.com/a/32016824/2292993
  cmdArgs = commandArgs(trailingOnly = FALSE)
  needle = "--file="
  match = grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript via command line
    return(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    ls_vars = ls(sys.frames()[[1]])
    if ("fileName" %in% ls_vars) {
      # Source'd via RStudio
      return(normalizePath(sys.frames()[[1]]$fileName))
    } else {
      if (!is.null(sys.frames()[[1]]$ofile)) {
        # Source'd via R console
        return(normalizePath(sys.frames()[[1]]$ofile))
      } else {
        # RStudio Run Selection
        # http://stackoverflow.com/a/35842176/2292993
        pth = rstudioapi::getActiveDocumentContext()$path
        if (pth!='') {
          return(normalizePath(pth))
        } else {
          # RStudio Console
          tryCatch({
            pth = rstudioapi::getSourceEditorContext()$path
            pth = normalizePath(pth)
          }, error = function(e) {
            # normalizePath('') issues warning/error
            pth = ''
          }
          )
          return(pth)
        }
      }
    }
  }
}

### Set Working Directory
setwd(dirname(ez.csf()))

##### Load Packages  ---------------------------------------------------

# Activate Local Packages
source("renv/activate.R")

# Shiny/UI
library(shiny)
library(shinyWidgets)
library(shinyjs)

# SWMM
library(swmmr)

# Data Wrangling
library(plyr)
library(dplyr)
library(data.table)
library(purrr)
library(reshape2)

# Data Retrieval
library(rNOMADS)
library(rvest)

# Spatial Manipulation
library(rgdal)
library(rgeos)
library(geosphere)
library(sp)

# Temporal Manipulation
library(lubridate)
library(xts)
library(lutz)

# Output
library(ggplot2)
library(leaflet)
library(DT)

# Other
library(feather) # Save/Load dataframes
library(R.utils)
library(sfsmisc) # Use to integrate ANC intensity timeseries to create ANC volume timeseries with constant time step
library(stringr) # Manipulate strings
library(jsonlite)# Read JSON data

##### Create Functions ---------------------------------------------------
### Create Function to Write Transects to SWMM .inp File
add_transects=function(file,transects){
  inp_file=read.delim(file,header=F,sep="\t",col.names="INP")
  position=which(inp_file=="[TIMESERIES]")
  inp_file=rbind(data.frame("INP"=inp_file[1:position-1,]),transects,data.frame("INP"=inp_file[position:nrow(inp_file),]))
  write.table(inp_file,file=file,append=F,row.names=F,col.names=F,quote=F)
}

### Function to retrieve precipitation depths from rain gauges and calculate precipitation time series for subcatchment
idw_function=function(ts,sc,model,interpolate,source,data,shp_data){ # ts=time step, sc=subcatchment, model=SREF model, interpolate=choose to interpolate time series or use value from nearest cell,source=SREF or ANC
  # Get Data from SREF or ANC dataframe
  if(source=="SREF"|source=="HRRR"){
    ts_precip=data[which(grepl(model,data$model.run.date)==T&data$forecast.date==ts),c("forecast.date","lon","lat","value")] # Get SREF/HRRR forecast for the timestep from each grid cell
  }else if(source=="ANC"|source=="HREF"){
    ts_precip=data[which(data$forecast.date==ts),c("forecast.date","lon","lat","value")] # Get ANC forecast for the timestep from each grid cell
  }
  
  # If all values are equal, then don't run interpolation
  if(length(unique(ts_precip$value))==1){
    idw_precip=ts_precip$value[1]
  }else{ # If all values aren't equal, then run IDW interpolation or get value from nearest grid cell
    coordinates(ts_precip)=~lon+lat
    proj4string(ts_precip)=CRS("+proj=longlat +datum=WGS84 +no_defs")
    
    sc_centroid=data.frame(long=shp_data[which(shp_data$Name==sc),"longitude"],lat=shp_data[which(shp_data$Name==sc),"latitude"])
    coordinates(sc_centroid)=~long+lat
    proj4string(sc_centroid)=CRS("+proj=longlat +datum=WGS84 +no_defs")
    
    # Interpolate precip
    if(interpolate==T){
      idw=gstat::idw(formula=ts_precip$value~1,locations=ts_precip,newdata=sc_centroid)
      idw_precip=idw@data$var1.pred
    }
    # Use nearest precip
    else{
      ts_precip$distance=spDistsN1(pts=ts_precip,pt=sc_centroid) # Calculate distance from subcatchment centroid to center of each grid cell
      idw_precip=mean(ts_precip[which(ts_precip$distance==min(ts_precip$distance)),"value"][["value"]]) # Take value of closest grid cell or mean value if grid cells are same distance
    }
  }
}

### Function to Read ANC Grib -- adapted from rNOMADS
ANC_ReadGrib=function (file.names, levels, variables, forecasts = NULL, domain = NULL,
                       domain.type = "latlon", file.type = "grib2", missing.data = NULL){
  if (sum(sapply(file.names, file.exists)) == 0) {
    stop("The specified grib file(s) were not found.")
  }
  if (!(domain.type %in% c("latlon", "index"))) {
    stop(paste("domain.type must be either \"latlon\" or \"index\""))
  }
  if (file.type == "grib2") {
    op <- options("warn")
    options(warn = -1)
    test <- tryCatch(system("wgrib2", intern = TRUE))
    options(op)
    if (attr(test, "status") != 8) {
      stop("wgrib2 does not appear to be installed, or it is not on the PATH variable.\n                You can find wgrib2 here: http://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/.\n                If the binaries don't work, try compiling from source.")
    }
    variables <- stringr::str_replace_all(variables, "[{\\[()|?$^*+.\\\\]", 
                                          "\\$0")
    levels <- stringr::str_replace_all(levels, "[{\\[()|?$^*+.\\\\]", 
                                       "\\$0")
    match.str <- " -match \"("
    for (var in variables) {
      match.str <- paste(match.str, var, "|", sep = "")
    }
    match.str.lst <- strsplit(match.str, split = "")[[1]]
    match.str <- paste(match.str.lst[1:(length(match.str.lst) - 
                                          1)], collapse = "")
    if (length(levels) > 0 & !is.null(levels)) {
      match.str <- paste(match.str, "):(", sep = "")
      for (lvl in levels) {
        match.str <- paste(match.str, lvl, "|", sep = "")
      }
    }
    else {
      match.str <- paste0(match.str, ")")
    }
    match.str.lst <- strsplit(match.str, split = "")[[1]]
    match.str <- paste(match.str.lst[1:(length(match.str.lst) - 
                                          1)], collapse = "")
    if (length(forecasts) > 0 & !is.null(forecasts)) {
      match.str <- paste(match.str, "):(", sep = "")
      for (fcst in forecasts) {
        match.str <- paste(match.str, fcst, "|", sep = "")
      }
    }
    else {
      match.str <- paste0(match.str, ")")
    }
    match.str.lst <- strsplit(match.str, split = "")[[1]]
    match.str <- paste(match.str, "\"", sep = "")
    match.str <- paste(match.str.lst[1:(length(match.str.lst) - 
                                          1)], collapse = "")
    match.str <- paste(match.str, ")\"", sep = "")
    if (!is.null(missing.data) & !is.numeric(missing.data)) {
      warning(paste("Your value", missing.data, " for missing data does not appear to be a number!"))
    }
    if (!(is.null(missing.data))) {
      missing.data.str <- paste0(" -rpn \"sto_1:", missing.data, 
                                 ":rcl_1:merge\"")
    }
    else {
      missing.data.str <- ""
    }
    model.run.date <- c()
    forecast.date <- c()
    variables.tmp <- c()
    levels.tmp <- c()
    lon <- c()
    lat <- c()
    value <- c()
    for (file.name in file.names) {
      if (!file.exists(file.name)) {
        warning(paste("Grib file", file.name, "was not found."))
        next
      }
      if (!is.null(domain)) {
        if (!length(domain) == 4 | any(!is.numeric(domain))) {
          stop("Input \"domain\" is the wrong length and/or consists of something other than numbers.\n                      It should be a 4 element vector: c(LEFT LON, RIGHT LON, TOP LAT, BOTTOM LAT)")
        }
        else {
          if (domain.type == "latlon") {
            uuid <- uuid::UUIDgenerate(use.time = T)
            wg2.pre <- paste0("wgrib2 ", file.name, 
                              " -inv my.inv ", " -small_grib ", domain[1], 
                              ":", domain[2], " ", domain[4], ":", domain[3], 
                              " tmp.grb.", uuid, " && wgrib2 tmp.grb.", 
                              uuid)
          }
          else {
            wg2.pre <- paste0("wgrib2 ", file.name, 
                              " -ijundefine out-box ", domain[1], ":", 
                              domain[2], " ", domain[4], ":", domain[3])
          }
        }
      }
      else {
        wg2.pre <- paste0("wgrib2 ", file.name)
      }
      wg2.str <- paste(wg2.pre, " -inv my.inv", missing.data.str, 
                       " -csv - -no_header", match.str, sep = "")
      if (Sys.info()[["sysname"]] == "Windows") {
        csv.str <- shell(wg2.str, intern = TRUE)
        if (csv.str[1] == "cygwin warning:") {
          csv.str <- csv.str[7:length(csv.str)]
        }
      }
      else {
        csv.str <- system(wg2.str, intern = TRUE)
      }
      if (domain.type == "latlon" & !is.null(domain)) {
        file.remove(paste0("tmp.grb.", uuid))
      }
      model.data.vector <- strsplit(paste(gsub("\"", "", 
                                               csv.str), collapse = ","), split = ",")[[1]]
      #### Added this below! ###
      model.data.vector=model.data.vector[!grepl("Warning",model.data.vector)] # Remove "** Warning: reference time includes non-zero minutes/seconds **" so that indices are correct
      model.data.vector=model.data.vector[!grepl("use -g2clib 0 for WMO standard",model.data.vector)] # Remove "** use -g2clib 0 for WMO standard **" so that indices are correct
      ### Added this above! ###
      
      if (length(model.data.vector) == 0) {
        warning(paste0("No combinations of variables ", 
                       paste(variables, collapse = " "), " and levels ", 
                       paste(levels, collapse = " "), " yielded any data for the specified model and model domain in grib file ", 
                       file.name))
      }
      else {
        chunk.inds <- seq(1, length(model.data.vector) -
                            6, by = 7)
        model.run.date <- c(model.run.date, model.data.vector[chunk.inds])
        forecast.date <- c(forecast.date, model.data.vector[chunk.inds +
                                                              1])
        variables.tmp <- c(variables.tmp, model.data.vector[chunk.inds +
                                                              2])
        levels.tmp <- c(levels.tmp, model.data.vector[chunk.inds +
                                                        3])
        lon <- c(lon, as.numeric(model.data.vector[chunk.inds +
                                                     4]))
        lat <- c(lat, as.numeric(model.data.vector[chunk.inds +
                                                     5]))
        value <- c(value, model.data.vector[chunk.inds +
                                              6])
      }
    }
    model.data=list(model.run.date=model.run.date,
                    forecast.date=forecast.date,
                    variables=variables.tmp,
                    levels=levels.tmp,
                    lon=lon,
                    lat=lat,
                    value=value,
                    meta.data="None - this field is used for grib1 files",
                    grib.type=file.type)
    
    ### Removed below b/c variable name to read data and the variable name that is returned out are different, so it doesn't subset correctly                 
    #     # v.i <- rep(0, length(variables.tmp))
    # l.i <- v.i
    # for (k in 1:length(variables)) {
    #   v.i <- v.i + (variables.tmp == variables[k])
    # }
    # for (k in 1:length(levels)) {
    #   l.i <- l.i + (levels.tmp == stringr::str_replace_all(levels[k],
    #                                                        "\\\\", ""))
    # }
    # k.i <- which(v.i & l.i)
    # model.data <- list(model.run.date = model.run.date[k.i], 
    #                    forecast.date = forecast.date[k.i], variables = variables.tmp[k.i], 
    #                    levels = levels.tmp[k.i], lon = lon[k.i], lat = lat[k.i], 
    #                    value = value[k.i], meta.data = "None - this field is used for grib1 files", 
    #                    grib.type = file.type)
  }
  else if (file.type == "grib1") {
    op <- options("warn")
    options(warn = -1)
    test <- tryCatch(system("wgrib", intern = TRUE))
    options(op)
    if (attr(test, "status") != 8) {
      stop("wgrib does not appear to be installed, or it is not on the PATH variable.\n                  You can find wgrib here: http://www.cpc.ncep.noaa.gov/products/wesley/wgrib.html.\n                  It is also available as an Ubuntu package.")
    }
    meta.data <- NULL
    value <- c()
    variables <- c()
    levels <- c()
    c <- 1
    for (file.name in file.names) {
      if (!file.exists(file.name)) {
        warning(paste("Grib file", file.name, "was not found."))
        next
      }
      for (var in variables) {
        for (lvl in levels) {
          wg.str <- paste0("wgrib -s ", file.name, " | grep \":", 
                           var, ":", lvl, ":\" | wgrib -V -i -text ", 
                           file.name, " -o tmp.txt")
          model.data$meta.data[[c]] <- system(wg.str, 
                                              ignore.stderr = TRUE)
          model.data$value[[c]] <- scan("tmp.txt", skip = 1, 
                                        quiet = TRUE)
          model.data$variables[c] <- var
          model.data$levels[c] <- lvl
          c <- c + 1
        }
      }
    }
    model.data <- list(meta.data = meta.data, value = value, 
                       variables = variables, levels = levels, grib.type = file.type)
  }
  model.data$value <- as.numeric(model.data$value)
  return(model.data)
}

### Color generating function
gg_color_hue=function(n){
  hues=seq(15,375,length=n+1)
  hcl(h=hues,l=65,c=100)[1:n]
}

### Functions to round values to "nice" values for color sliders and to create a "nice" scale
roundFromNice=function(x,nice=c(1,2,4,5,6,8,10)) {
  round=10^floor(log10(x))*nice[[tail(which(x>=10^floor(log10(x))*nice),1)]]
}

roundToNice=function(x,nice=c(1,2,4,5,6,8,10)) {
  round=10^floor(log10(x))*nice[[which(x<=10^floor(log10(x))*nice)[[1]]]]
}

roundScaleNice=function(x,nice=10^(-10:10)) {
  if(length(x)!=1)stop("'x'must be of length 1")
  if(x%in%nice){
    nice[tail(which(nice<10^floor(log10(x))),1)-1]
  } else{
    nice[tail(which(nice<10^floor(log10(x))),1)]
  }
}

##### Global Settings -----------------------------------------------------------
SREF_interval="3:00" # Time Step for SREF Precip Data
HRRR_interval="1:00" # Time Step for HRRR Precip Data
ANC_interval="0:10"  # Time Step for ANC Precip Data
HREF_interval="1:00" # Time Step for HREF Precip Data

### Read latitude and longitude of SREF grid cells
sref_lat=read_feather("App/www/Grid_Coordinates/SREF_lat.feather")
sref_lon=read_feather("App/www/Grid_Coordinates/SREF_lon.feather")

### Read latitude and longitude of HRRR grid cells
hrrr_lat=read_feather("App/www/Grid_Coordinates/HRRR_lat.feather")
hrrr_lon=read_feather("App/www/Grid_Coordinates/HRRR_lon.feather")

### Read latitude and longitude of HREF grid cells
href_points=read_feather("App/www/Grid_Coordinates/href_grib_latlon.feather") # Read HREF Grib cell coordinates; exported coordinates for all HREF grib cells by importing entire grib dataset for CONUS and exporting lat/lon

### Set HREF Grid Spacing and Distance to search for datapoints near the watershed
href_buffer_dist=0.1   # Degrees lat/lon to search for datapoints near the watershed
href_grid_size=3   # grid spacing in km
href_search_dist=2 # Number of grid cell distances (i.e. 3km) surrounding the watershed to search for HREF points

### Get Default Settings from default.R
source("App/default_settings.r")

### Get information on last SREF/ANC Model runs from model_runs.R
source("App/model_runs.r")

### Get which SWMM objects to use in group analysis
source("App/group_analysis.r")

##### Run App -----------------------------------------------------------------
runApp("App") # Directory containing App Files
