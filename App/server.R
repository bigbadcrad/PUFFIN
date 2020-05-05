server=function(input,output,session){
  ##### Load Previous Outputs if Files Exist ----------------------------------------------------
  withProgress(message="Loading Previous Results",value=0,{
    if(file.exists("www/Output/SREF_data.feather")){
      Output_SREF_data=read_feather("www/Output/SREF_data.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/SREF_SC_results.feather")){
      Output_SREF_SC_results=read_feather("www/Output/SREF_SC_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/SREF_Node_results.feather")){
      Output_SREF_Node_results=read_feather("www/Output/SREF_Node_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/SREF_Link_results.feather")){
      Output_SREF_Link_results=read_feather("www/Output/SREF_Link_results.feather")
    }
    if(file.exists("www/Output/HRRR_data.feather")){
      Output_HRRR_data=read_feather("www/Output/HRRR_data.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HRRR_SC_results.feather")){
      Output_HRRR_SC_results=read_feather("www/Output/HRRR_SC_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HRRR_Node_results.feather")){
      Output_HRRR_Node_results=read_feather("www/Output/HRRR_Node_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HRRR_Link_results.feather")){
      Output_HRRR_Link_results=read_feather("www/Output/HRRR_Link_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/ANC_data.feather")){
      Output_ANC_data=read_feather("www/Output/ANC_data.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/ANC_SC_results.feather")){
      Output_ANC_SC_results=read_feather("www/Output/ANC_SC_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/ANC_Node_results.feather")){
      Output_ANC_Node_results=read_feather("www/Output/ANC_Node_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/ANC_Link_results.feather")){
      Output_ANC_Link_results=read_feather("www/Output/ANC_Link_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HREF_data.feather")){
      Output_HREF_data=read_feather("www/Output/HREF_data.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HREF_SC_results.feather")){
      Output_HREF_SC_results=read_feather("www/Output/HREF_SC_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HREF_Node_results.feather")){
      Output_HREF_Node_results=read_feather("www/Output/HREF_Node_results.feather")
    }
    incProgress(1/16)
    if(file.exists("www/Output/HREF_Link_results.feather")){
      Output_HREF_Link_results=read_feather("www/Output/HREF_Link_results.feather")
    }
    incProgress(1/16)
  })
  
  ### Get paths for existing files
  withProgress(message="Loading SWMM Model",value=0,{
    inp_path=Sys.glob(file.path("www/Model/","*.inp")) # SWMM .inp
    incProgress(1)
  })

  withProgress(message="Loading Shapefiles for Map",value=0,{
    if(length(Sys.glob(file.path("www/SHP/","*.shp")))>0){
      shp_path=sub(pattern="(.*)\\..*$",replacement="\\1",basename(Sys.glob(file.path("www/SHP/","*.shp")))) # Name of Subcatchments Shapefile
      subcatchments_shp=readOGR("www/SHP",shp_path) # Read .shp
      subcatchments_shp_crs=proj4string(subcatchments_shp) # Get Spatial Refrence of uploaded Subcatchments Shapefile
      
      if(is.na(subcatchments_shp_crs)){
        if(length(inp_path)==0){
          sendSweetAlert(session,
                         title="Missing SWMM Model and Uploaded Subcatchment Shapefile has no Spatial Reference",
                         type="error",
                         text="Please Upload a SWMM Model and a new Subcatchment Shapefile from the Settings Page")
        } else{
          sendSweetAlert(session,
                         title="Uploaded Subcatchment Shapefile has no Spatial Reference",
                         type="error",
                         text="Please Upload a new Subcatchment Shapefile from the Settings Page")
        }
        subcatchments_shp=NULL
      } else{
        subcatchments_shp=spTransform(subcatchments_shp,CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to lat/lon for processing SREF/ANC data
        if(length(inp_path)==0){
          sendSweetAlert(session,
                         title="Missing SWMM Model",
                         type="error",
                         text="Please Upload a SWMM Model from the Settings Page")
        }
      }
 
    } else{
      if(length(inp_path)==0){
        sendSweetAlert(session,
                       title="Missing SWMM Model and Subcatchments Shapefile",
                       type="error",
                       text="Please Upload a SWMM Model and a Subcatchments Shapefile on the Settings Page")
      } else{
        sendSweetAlert(session,
                       title="Missing Subcatchments Shapefile",
                       type="error",
                       text="Please Upload a Subcatchment Shapefile from the Settings Page")
      }
      shp_path=NULL
      subcatchments_shp=NULL
      subcatchments_shp_crs=NULL
    }
    incProgress(1/8)

    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_polygon.shp")){
      map_sc_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_polygon"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_sc_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_link.shp")){
      map_link_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_link"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_link_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_point.shp")){
      map_node_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_point"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_node_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_orifices.shp")){
      map_orifice_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_orifices"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_orifice_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_outfall.shp")){
      map_outfall_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_outfall"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_outfall_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_storages.shp")){
      map_storage_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_storages"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_storage_shp=NULL
    }
    incProgress(1/8)
    
    if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_weir.shp")){
      map_weir_shp=spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_weir"),CRS("+proj=longlat +datum=WGS84 +no_defs")) # Apply projection to plot in Leaflet
    } else{
      map_weir_shp=NULL
    }
    incProgress(1/8)
  })
  
  inp_path=reactiveVal(inp_path) # SWMM .inp
  shp_path=reactiveVal(shp_path) # Name of Subcatchments .shp file
  
  ##### Server Settings ----------------------------------------------------
  options(shiny.maxRequestSize=100*1024^2) # Set File Upload Limit to 100MB
  
  ##### Reactive UI & Navigation -----------------------------------------------------------
  ### Hide Navbar on home page but display on Other Pages
  observe({
    if(input$Pages=="home"){
      runjs("var all = document.getElementsByClassName('navbar-default');
            for (var i = 0; i < all.length; i++) {
            all[i].style.display = 'none';
      }")
    }
    else{
      runjs("var all = document.getElementsByClassName('navbar-default');
            for (var i = 0; i < all.length; i++) {
            all[i].style.display = 'block';
      }")
    }
  })
  
  ### Home Page Buttons
  # Button to go to Rain Page
  observeEvent(input$button_forecast, {
    updateTabsetPanel(session, "Pages",
                      selected = "forecast")
  })
  
  # Button to go to Flood Page
  observeEvent(input$button_settings, {
    updateTabsetPanel(session, "Pages",
                      selected = "settings")
  })
  
  ### Switch Between Map/Plots and Group Analysis Views
  observe({
    if(input$tabview=="Map/Plots"){
      shinyjs::show(id="map_plot")
    }
    else if(input$tabview=="Group Analysis"){
      shinyjs::hide(id="map_plot")
    }
  })
  
  ### Warning message that SWMM subcatchment name not found in subcatchments shapefile
  observe({
    req(inp(),subcatchments_shp())
    if(input$Pages=="forecast"){
      inp_name=as.character(inp()$subcatchments$Name)
      shp_name=as.character(subcatchments_shp()@data$Name)
      
      if(any(!inp_name%in%shp_name)==T){ # At least one SWMM subcatchment name not found in the subcatchments shapefile
        sendSweetAlert(session,
                       title="SWMM subcatchment(s) not found in subcatchments shapefile",
                       type="error",
                       text=paste("Please check subcatchments shapefile for subcatchments:",toString(inp_name[which(!inp_name%in%shp_name)])))
      }
    }
  })
  
  ### Hide ANC Forecast Inputs depending on selection
  observe({
    if(input$ANC_coefficients==T){
      shinyjs::show(id="anc_auto")
      shinyjs::hide(id="anc_manual")
    }
    else{
      shinyjs::hide(id="anc_auto")
      shinyjs::show(id="anc_manual")
    }
  })
  
  ### Help Buttons
  observeEvent(input$help_update_forecasts,{
    sendSweetAlert(session,
                   title="Update Forecasts",
                   type="info",
                   text='Use the "Manual Update" button to manually check for new forecasts or use the "Auto Update?" switch to automatically check for new forecasts every five minutes. Forecast information is summarized in the table. Note that the maximum precipitation intensity represents the maximum intensity for the entire spatial extent of the forecast downloaded including the areas outside of the watershed.')
  })
  
  observeEvent(input$help_find_object,{
    sendSweetAlert(session,
                   title="Find SWMM Object",
                   type="info",
                   text="Select a Subcatchment, Link, or Node and specify its SWMM Object ID to center the map on the object and to plot its results.")
  })
  
  observeEvent(input$help_map_plot,{
    sendSweetAlert(session,
                   title="Map/Plot Settings",
                   type="info",
                   text="Use checkboxes to select the forecasts that are included in the plots and used to symbolize the map. Use the dropdown menus to control the parameter plotted for the Subcatchments, Links, and Nodes. Use the switches to enable custom map symbology in which objects can be symbolized according to green, yellow, and red groups by adjusting color sliders.")
  })
  
  observeEvent(input$help_view,{
    sendSweetAlert(session,
                   title="Select View",
                   type="info",
                   text='Use radio buttons to switch between Map/Plots view and Group Analysis View.')
  })
  
  observeEvent(input$help_group_analysis,{
    sendSweetAlert(session,
                   title="Group Analysis Summary",
                   type="info",
                   text='The group analysis summary table presents the PUFFIN results for the selected subcatchments, links, and nodes based on the Green, Yellow, and Red ranges specified using the sliders. Subcatchments, links, and nodes can be selected using the checkboxes in the tables below, and the sliders can be enabled by toggling the switches by the Subcatchment, Link, and Node Parameter inputs.')
  })

  observeEvent(input$help_input_files,{
    sendSweetAlert(session,
                   title="Input Files",
                   type="info",
                   text='Use the inputs to upload a new SWMM Model .inp file and/or a new shapefile containing the location and name of the SWMM subcatchments.')
  })
  
  observeEvent(input$help_swmm_settings,{
    sendSweetAlert(session,
                   title="SWMM Settings",
                   type="info",
                   text='Specify the SWMM reporting/output time step and Snow Catch Factor.')
  })
  
  observeEvent(input$help_anc_settings,{
    sendSweetAlert(session,
                   title="ANC Forecast Settings",
                   type="info",
                   text='The precipitation depths for the ANC forecast are calculated using the National Weather Service Z-R Relationship between Radar Reflectivity and Rainfall Intensity. Choose whether to manually specify the "a" and "b" coefficients or to retrive the current coefficients from the NWS based on River Forecast Center and Radar ID.')
  })
  
  observeEvent(input$help_interpolation,{
    sendSweetAlert(session,
                   title="PUFFIN Precipitation Settings",
                   type="info",
                   text='Choose how precipitation time series are created for each SWMM subcatchment. Options are:
                   1) Use inverse distance weighting (IDW) to interpolate the precipitation depth applied to each subcatchment from the precipitation depths for each forecast grid cell, and
                   2) Apply the precipitation depth from the nearest forecast grid cell to each subcatchment. You can also choose to have PUFFIN display a warning message if the peak precipitation intensity for any forecast exceeds a specified threshold.')
  })
  
  observeEvent(input$help_outputs,{
    sendSweetAlert(session,
                   title="PUFFIN/SWMM Output Parameters",
                   type="info",
                   text='Select the Subcatchment, Link, and Node parameters to simulate using SWMM.')
  })
  
  ### Precipitation Threshold Warning
  output$threshold=renderUI({
    div(
      p({if(!is.na(SWMM_units())){
        if(SWMM_units()=="SI"){
          "Peak Precipitation Threshold (mm/hr):"
        }
        else if (SWMM_units()=="US"){
          "Peak Precipitation Threshold (in/hr):"
        }
      } else{
        "Peak Precipitation Threshold (in/hr):"
      }}),
      numericInput("precip_threshold",label=NULL,value=precip_threshold,min=0,step=0.1)
    )
  })
  
  # Send Warning Message
  threshold_Value=reactiveVal(precip_threshold) # Setup Reactive Val to store threshold value
  observeEvent(input$precip_threshold,{threshold_Value(input$precip_threshold)}) # Update threshold value
  
  observe({
    req(threshold_Value(),forecast_summary())
    if(input$Pages=="forecast"){
      if(any(!is.na(forecast_summary()[,3]))){
        if(any(forecast_summary()[which(!is.na(forecast_summary()[,3])),3]>=threshold_Value())){
          sendSweetAlert(session,
                         title="Peak Precipitation Intensity Threshold Exceeded",
                         type="warning",
                         text="")
        }
      }
    }
  })
  
  ### Button to clear all App Data/Outputs
  observeEvent(input$button_clear,{
    confirmSweetAlert(session,
                      inputId="clear",
                      title="Clear PUFFIN Data",
                      text="Do you really want to remove all PUFFIN forecast and simulation data?",
                      btn_labels=c("No","Yes")
                      )
  })
  
  ##### Import Files & Settings -----------------------------------------------------------

  ### Create Reactive Value to trigger generating shapefiles from SWMM model
  trigger_new_shp=reactiveVal({0})
  refresh_plot=reactiveVal({0}) # Reactive Value to Refresh Plot when new settings saved

  ### Create Reactive Value to determine whether or not to run SWMM model
  run_swmm_sref=reactiveVal({F})
  run_swmm_hrrr=reactiveVal({F})
  run_swmm_anc=reactiveVal({F})
  run_swmm_href=reactiveVal({F})
  
  ### Create Reactive Value to determine whether or not to make new SWMM Shapefiles
  new_swmm_shp=reactiveVal({F})

  ### Create Reactive Values to store paths and filenames of uploads
  upload_inp_path=reactiveVal(NULL)
  upload_inp_name=reactiveVal(NULL)
  upload_shp_path=reactiveVal(NULL)
  upload_shp_name=reactiveVal(NULL)
  
  ### Update reactive values for uploads
  observeEvent(input$upload_inp, {
    upload_inp_path(input$upload_inp$datapath)
    upload_inp_name(input$upload_inp$name)
  })
  
  observeEvent(input$upload_shp, {
    upload_shp_path(input$upload_shp$datapath)
    upload_shp_name(input$upload_shp$name)
  })
  
  ### Save Default Settings if user clicks button
  observeEvent(input$button_save_settings, {

    # Save New SWMM .inp
    if(length(upload_inp_path())>0){
      # Delete Old SWMM files
      file.remove(list.files("www/Model",full.names=T))
      
      # Copy File to Model Folder
      file.copy(from=upload_inp_path(),
                to=paste0("www/Model/",upload_inp_name()),
                overwrite=T)
      
      # Update SWMM .inp path with new name
      inp_path(Sys.glob(file.path("www/Model/","*.inp")))
      
      new_swmm_shp(T) # Generate New SWMM Shapefiles
      trigger_new_shp(trigger_new_shp()+1)
    } else{
      new_swmm_shp(F) # Don't make New SWMM Shapefiles
      trigger_new_shp(trigger_new_shp()+1)
    }
    
    # Create List of Error Codes to Display Messages
    error_code=c()
    
    # Save New Subcatchment .shp
    if(length(upload_shp_path())>0){
      withProgress(message="Uploading New Shapefile",value=0,{
        
        # Rename Uploaded files so they can be read
        new_path=paste(dirname(upload_shp_path()),upload_shp_name(),sep="//")
        file.rename(from=upload_shp_path(),
                    to=new_path)
        
        # Get Spatial Refrence of uploaded Subcatchments Shapefile
        SR=proj4string(readOGR(unique(dirname(upload_shp_path())),gsub(".shp","",upload_shp_name()[grep(".shp$",upload_shp_name())])))
        
        # Read .shp and apply projection to lat/lon for processing SREF/ANC data
        if(is.na(SR)){
          error_code=4 #No Spatial Reference
        } else{
          # Delete Old Shapefile
          file.remove(list.files("www/SHP",full.names=T))
          incProgress(1/4)

          # Copy File to Model Folder
          file.copy(from=new_path,
                    to=paste0("www/SHP/",upload_shp_name()),
                    overwrite=T)
          incProgress(1/4)

          # Update SWMM .shp path with new name
          shp_path(sub(pattern="(.*)\\..*$",replacement="\\1",basename(Sys.glob(file.path("www/SHP/","*.shp")))))
          incProgress(1/4)

          # Update Reactive Values
          subcatchments_shp_crs(proj4string(readOGR("www/SHP",shp_path())))
          subcatchments_shp(spTransform(readOGR("www/SHP",shp_path()),CRS("+proj=longlat +datum=WGS84 +no_defs")))
          incProgress(1/4)
        }
      })
    }
    
    # Check if No SWMM .inp
    if(!length(inp_path())>0){
      error_code=c(error_code,1)
    }
    
    # Check if No Subcatchment Shapefile
    if(!length(shp_path())>0){
      error_code=c(error_code,2)
    }
    
    # Check if No Spatial Reference
    if(is.null(subcatchments_shp_crs())){
      error_code=c(error_code,3)
    } else if(is.na(subcatchments_shp_crs())){
      error_code=c(error_code,3)
    }
    
    # Clean Up Messages
    if(4%in%error_code){
      error_code=3 # Only display message about uploaded Subcatchment Shapefile Spatial Reference
    }
    if(all(c(2,3)%in%error_code)){
     error_code=error_code[!error_code%in%3]  # If no Subcatchments Shapefile, then don't display message about missing spatial reference
    }
    
    # Display Messages
    # No Errors
    if(is.null(error_code)){
      confirmSweetAlert(session,inputId="refresh",
                        title="Settings Updated",
                        type="success",
                        text="Would you like to update the precipitation forecasts and SWMM model simulations using the new settings?",
                        btn_labels=c("No","Yes"))
    }
    # Only One Error
    else if(length(error_code)==1){
      if(error_code==1){
        sendSweetAlert(session,
                       title="No SWMM Model Uploaded",
                       type="error",
                       text="Please Upload a new SWMM Model")
      } else if (error_code==2){
        sendSweetAlert(session,
                       title="No Subcatchments Shapefile Uploaded",
                       type="error",
                       text="Please Upload a new Subcatchment Shapefile")
      } else if (error_code==3){
        sendSweetAlert(session,
                       title="Uploaded Subcatchment Shapefile has no Spatial Reference",
                       type="error",
                       text="Please Upload a new Subcatchment Shapefile")
      }
    }
    # Multiple Errors
    else if(length(error_code)>1){
      message=""
      if(1%in%error_code){
        message=paste(message,"- No SWMM Model Uploaded
                      ")
      }
      if(2%in%error_code){
        message=paste(message,"- No Subcatchments Shapefile Uploaded
                      ")
      }
      if(3%in%error_code){
        message=paste(message,"- No Spatial Reference for Subcatchments Shapefile
                      ")
      }
      sendSweetAlert(session,
                     title="Errors",
                     type="error",
                     text=message)
    }
    
    # Save Default Settings
    default=read.delim("default_settings.r",header=F,col.names="line") # Read default settings
    
    # Replace default setting values with user selected values
    levels(default$line)[grep("report_ts",levels(default$line))]=paste0("report_ts=",input$report_ts) # SWMM Reporting Time Step
    levels(default$line)[grep("SWMM_SCF",levels(default$line))]=paste0("SWMM_SCF=",input$SWMM_SCF) # SWMM Snow Catch Factor
    levels(default$line)[grep("interpolate_precip",levels(default$line))]=paste0("interpolate_precip=",input$interpolate_precip) # Interpolate Precipitation Time Series
    levels(default$line)[grep("precip_threshold",levels(default$line))]=paste0("precip_threshold=",input$precip_threshold) # Precipitation Warning Threshold
    levels(default$line)[grep("auto_coefficient=",levels(default$line))]=paste0("auto_coefficient=",input$ANC_coefficients) # Manual/Auto Set NWS Coefficients
    levels(default$line)[grep("auto_center=",levels(default$line))]=paste0("auto_center=",'"',input$nws_region,'"') # NWS River Forecast Center
    levels(default$line)[grep("auto_id=",levels(default$line))]=paste0("auto_id=",'"',input$anc_id,'"') # NWS Radar ID
    levels(default$line)[grep("a=",levels(default$line))]=paste0("a=",input$a) # NWS a coefficient
    levels(default$line)[grep("b=",levels(default$line))]=paste0("b=",input$b) # NWS b coefficient
    levels(default$line)[grep("sc_vars",levels(default$line))]=paste0("sc_vars=c(",toString(input$sc_vars),")") # SWMM Subcatchment Parameters
    levels(default$line)[grep("link_vars",levels(default$line))]=paste0("link_vars=c(",toString(input$link_vars),")") # SWMM Link Parameters
    levels(default$line)[grep("node_vars",levels(default$line))]=paste0("node_vars=c(",toString(input$node_vars),")") # SWMM Link Parameters
    
    # Write new file
    write.table(default,file="default_settings.r",append=F,row.names=F,col.names=F,quote=F)

    # Clear Uploads
    upload_inp_path(NULL)
    upload_shp_path(NULL)
    shinyjs::reset('upload_inp')
    shinyjs::reset('upload_shp')
    
    # Refresh Plot
    refresh_plot(refresh_plot()+1)
  })
  
  ### Refresh app if user selects yes
  refresh=reactiveVal(0) # Using a reactive value so that forecasts are only redownloaded after user selects "Yes"; otherwise downloads would get triggered when modal popped up
  
  observeEvent(input$refresh, {
    if(input$refresh==T){
      new_sref(T) # Get new SREF forecast
      new_hrrr(T) # Get new HRRR forecast
      new_anc(T)  # Get new ANC forecast
      new_href(T) # Get new HREF forecast
      refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
    }
    else if(input$refresh==F){
      new_sref(F)
      new_hrrr(F)
      new_anc(F)
      new_href(F)
      run_swmm_sref(F)
      run_swmm_hrrr(F)
      run_swmm_anc(F)
      run_swmm_href(F)
      refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
    }
  })
  
  ### Clear all app data/outputs if user selects button
  observeEvent(input$clear,{
    if(input$clear==T){
      
      # Update Values in model_runs.R file
      runs=read.delim("model_runs.r",header=F,col.names="line") 
      levels(runs$line)[grep("sref_url",levels(runs$line))]=paste0("sref_url='","'")
      levels(runs$line)[grep("sref_model_runs",levels(runs$line))]=gsub(", ","','",paste0("sref_model_runs=c('","')"))
      levels(runs$line)[grep("hrrr_url",levels(runs$line))]=paste0("hrrr_url='","'")
      levels(runs$line)[grep("hrrr_model_runs",levels(runs$line))]=gsub(", ","','",paste0("hrrr_model_runs=c('","')"))
      levels(runs$line)[grep("anc_model_runs",levels(runs$line))]=gsub(", ","','",paste0("anc_model_runs=c('","')"))
      levels(runs$line)[grep("href_url",levels(runs$line))]=paste0("href_url='","'")
      levels(runs$line)[grep("href_model_runs",levels(runs$line))]=gsub(", ","','",paste0("href_model_runs=c('","')"))
      
      # Write new file
      write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
      
      # Update Reactive Values
      sref_url("")
      sref_model_runs("")
      hrrr_url("")
      hrrr_model_runs("")
      anc_model_runs("")
      href_url("")
      href_model_runs("")
      
      SREF_data(NA)
      ANC_data(NA)
      HRRR_data(NA)
      HREF_data(NA)
      
      SREF_SC_results(NA)
      SREF_Link_results(NA)
      SREF_Node_results(NA)
      
      HRRR_SC_results(NA)
      HRRR_Link_results(NA)
      HRRR_Node_results(NA)
      
      ANC_SC_results(NA)
      ANC_Link_results(NA)
      ANC_Node_results(NA)
      
      HREF_SC_results(NA)
      HREF_Link_results(NA)
      HREF_Node_results(NA)
      
      # Remove Forecast and Simulation files
      file.remove(list.files("www/Output",full.names=T))
      file.remove(list.files("www/Gribs/ANC",full.names=T))
      file.remove(list.files("www/Gribs/HREF",full.names=T))
      
      sendSweetAlert(session,
                     title="Cleared PUFFIN Data",
                     type="success")
    }
  })
  
  ### Read SWMM .inp
  inp=reactive({
    if(length(inp_path())>0){
      read_inp(inp_path())
    }
  })
  
  ### Get SWMM units
  SWMM_units=reactive({
    units=inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"]
    
    # If SWMM Model Exists
    if(!is.null(units)){
      if(units%in%c("CFS","GPM","MGD")){
        SWMM_units="US"
      }
      else if(units%in%c("CMS","LPS","MLD")){
        SWMM_units="SI"
      }
    }
    # SWMM Model Doesn't Exist
    else{
      SWMM_units=NA
    }
    SWMM_units
  })
  
  ### Get Transects from SWMM .inp
  transects=reactive({
    inp_txt=readLines(inp_path()) # Read SWMM .inp as text
    sections=grep("\\[",inp_txt,value=T) # Get SWMM .inp section names
    section_lines=grep("\\[",inp_txt,value=F) # Get line numbers of each SWMM .inp section
    start_line=section_lines[which(sections=="[TRANSECTS]")] # Line where Transects section begins
    end_line=section_lines[which(sections=="[TRANSECTS]")+1]-1 # Line where Transects section ends
    transects=as.data.frame(inp_txt[start_line:end_line]) # Get Transects section
    colnames(transects)="INP" # Rename Column
    transects
  })
  
  ### Get SWMM Snow Catch Factor from .inp
  SWMM_SCF=reactive({input$SWMM_SCF})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value

  ### Import Shapefiles
  # Uploaded Subcatchments
  subcatchments_shp=reactiveVal(subcatchments_shp)
  subcatchments_shp_crs=reactiveVal(subcatchments_shp_crs)

  # App Generated Shapefiles for Map
  map_sc=reactiveVal(map_sc_shp)
  map_link=reactiveVal(map_link_shp)
  map_node=reactiveVal(map_node_shp)
  map_orifice=reactiveVal(map_orifice_shp)
  map_outfall=reactiveVal(map_outfall_shp)
  map_storage=reactiveVal(map_storage_shp)
  map_weir=reactiveVal(map_weir_shp)
  
  ### Get User Selected SWMM Reporting Time Step
  report_ts=reactive({input$report_ts})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  ### Get Interpolate Precipitation Option
  interpolate_precip=reactive({input$interpolate_precip})
  
  ### Get ID and update ReactiveVal
  NWS_id=reactiveVal(auto_id)
  
  observeEvent(input$anc_id,{
    NWS_id(input$anc_id)
  })
  
  ### Get a & b coefficients for NWS empirical relationship between reflectivity and rainfall and convert from Z=aR^b format to R=aZ^b format
  manual_a=reactive({input$a})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  manual_b=reactive({input$b})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  ### Get NWS ZR Data from NWS websites
  NWS_table=reactive({
    # Set URL depending on NWS Region
    url=switch(input$nws_region,
               "Middle Atlantic"="https://www.weather.gov/marfc/ZR_Relationships",
               "Ohio"="https://www.weather.gov/ohrfc/ZRRelationships",
               "Lower Mississippi"="https://www.weather.gov/lmrfc/experimental_ZR_relationships")
    
    # Get table HTML from URL
    json=read_html(url)%>% 
      html_nodes(css='td')%>%.[1]
    
    # Remove HTML Tags
    json=sub('<td id="json">',"",json)
    json=sub("\n</td>","",json)
    
    # Read JSON data
    data=fromJSON(json)
    
    # Format Table
    table=as.data.frame(data$zrData)
  })

  ### Outputs for NWS Radar ID and Coefficients
  output$anc_id=renderUI({
    selectInput("anc_id",label="Choose Radar ID",choices=NWS_table()$id,selected=auto_id)
  })
  
  output$anc_values=renderUI({
    div(
      p(paste0(NWS_id(),' "a" Coefficient = ',NWS_table()[which(NWS_table()$id==NWS_id()),"zrCoef"])),
      p(paste0(NWS_id(),' "b" Coefficient = ',NWS_table()[which(NWS_table()$id==NWS_id()),"zrExp"]))
    )
  })
  
  ### Get Selected Forecasts to Map/Plot
  plot_forecasts=reactive({input$plot_forecasts})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  ### Get SWMM Parameters to Summarize
  # Subcatchments
  sc_vars=reactive({input$sc_vars})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  # Links
  link_vars=reactive({input$link_vars})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  # Nodes
  node_vars=reactive({input$node_vars})%>%debounce(2000) # Apply delay so app doesn't immediately recalculate everything in case user is still adjusting value
  
  ###### Create Shapefiles for Map ---------------------------------------------------------
  
  ### Check if Shapefiles Exist when loading App
  observe({
    if(length(inp_path())>0){ # INP should exist
      if(is.null(map_sc())&is.null(map_link())&is.null(map_node())&is.null(map_orifice())&is.null(map_outfall())&is.null(map_storage())&is.null(map_weir())){ # Missing SWMM Shapefiles
        if(!is.null(subcatchments_shp_crs())){ # Subcatchments Shapefile Exists and Has Spatial Reference
          if(!is.na(subcatchments_shp_crs())){ 
            new_swmm_shp(T)
            trigger_new_shp(trigger_new_shp()+1)
          }
        }
      }
    }
  })
  
  ### Create New Shapefiles
  observe({
    trigger_new_shp()
    if(!is.null(subcatchments_shp_crs())){
      if(!is.na(subcatchments_shp_crs())){ # Subcatchments Shapefile Exists and Has Spatial Reference
        if(new_swmm_shp()==T){
          withProgress(message="Generating Shapefiles for Map",value=0,{
            # Remove Existing SWMM shapefiles
            file.remove(list.files("www/Output/SWMM_shapefiles/",full.names=T,recursive=T))
            
            # Convert SWMM model to shapefiles
            inp_to_files(inp(),name="SWMM_Model",path_out="www/Output/SWMM_shapefiles/")
            
            # Create List of exported shapefiles
            shp_list=list.files("www/Output/SWMM_shapefiles/shp",".shp$",full.names=T)
            
            # Update Projection
            for(shp in shp_list){
              file=readOGR(shp)
              proj4string(file)=CRS(subcatchments_shp_crs())
              writeOGR(file,shp,"SWMM","ESRI Shapefile")
              incProgress(1/length(shp_list)) # Update Progress Bar
            }
            
            # Reload Shapefiles for Map
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_polygon.shp")){
              map_sc(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_polygon"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_sc(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_link.shp")){
              map_link(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_link"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_link(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_orifices.shp")){
              map_orifice(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_orifices"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_orifice(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_weir.shp")){
              map_weir(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_weir"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_weir(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_point.shp")){
              map_node(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_point"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_node(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_outfall.shp")){
              map_outfall(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_outfall"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_outfall(NULL)
            }
            
            if(file.exists("www/Output/SWMM_shapefiles/shp/SWMM_Model_storages.shp")){
              map_storage(spTransform(readOGR("www/Output/SWMM_shapefiles/shp","SWMM_Model_storages"),CRS("+proj=longlat +datum=WGS84 +no_defs")))
            } else{
              map_storage(NULL)
            }
          })
        }
      }
    }
  })

  ##### Calculate Centroid of Each Subcatchment --------------------------------------------------------------------------------------------------------------
  centroid_data=reactive({
    if(!is.null(subcatchments_shp())){
      centroid=coordinates(gCentroid(subcatchments_shp(),byid=T)) # Get centroids
      centroid_data=as.data.frame(centroid)
      setnames(centroid_data,old=c("x","y"),new=c("longitude","latitude"))
      centroid_data
    } else{
      NULL
    }
  })
  
  shp_data=reactive({
    shp_data=as.data.frame(subcatchments_shp())
    shp_data=cbind(shp_data,centroid_data()) # Create dataframe of subcatchment names and centroid coordinates
    shp_data[which(shp_data$longitude<0),"longitude"]=shp_data[which(shp_data$longitude<0),"longitude"]+360 # SREF longitudes are reported in 0-360 degree form, so convert longitudes from -180 to 180 form into 0-360 form
    shp_data
  })
  
  ##### Determine Time Zone of Watershed based on Subcatchment Centroids --------------------------------------------------------------------------------------------------------------
  watershed_tz=reactive({
    if(!is.null(centroid_data())){
      centroids_spatial=SpatialPoints(data.frame(lon=centroid_data()$longitude,lat=centroid_data()$latitude),proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs")) # Create Spatial Points dataframe of subcatchment centroids
      watershed_tz=tz_lookup(centroids_spatial,method="accurate") # Get timezone(s) that watershed is in
      watershed_tz=names(which(max(table(watershed_tz))==table(watershed_tz))) # Most frequent time zone
    } else{ # No Subcatchments Shapefile, so don't change timezone
      watershed_tz="UTC"
    }
    watershed_tz
  })
  
  ##### Get Spatial Extent of SWMM model -------------------------------------------------------
  subcatchments_extent=reactive({
    if(!is.null(subcatchments_shp())){
      bbox(subcatchments_shp())
    } else{
      NULL
    }
  }) # Get extent of subcatchments shapefile

  # Minimum and Maximum Latitude
  swmm_lat_min=reactive({subcatchments_extent()["y","min"]})
  swmm_lat_max=reactive({subcatchments_extent()["y","max"]})
  
  # Minimum and Maximum Longitude
  swmm_lon_min=reactive({
    swmm_lon_min=subcatchments_extent()["x","min"]
    if(swmm_lon_min<0){swmm_lon_min=swmm_lon_min+360} # SREF longitudes are reported in 0-360 degree form, so convert longitudes from -180 to 180 form into 0-360 form
    swmm_lon_min
  })
  swmm_lon_max=reactive({
    swmm_lon_max=subcatchments_extent()["x","max"]
    if(swmm_lon_max<0){swmm_lon_max=swmm_lon_max+360} # SREF longitudes are reported in 0-360 degree form, so convert longitudes from -180 to 180 form into 0-360 form
    swmm_lon_max
  })
  
  swmm_lon_min_hrrr=reactive({swmm_lon_min=subcatchments_extent()["x","min"]})
  swmm_lon_max_hrrr=reactive({swmm_lon_max=subcatchments_extent()["x","max"]})
  
  ##### Determine Latest Forecasts ------------------------------------------------------
  sref_url=reactiveVal(sref_url) # Create reactive value to store URL for latest SREF model runs
  sref_model_runs=reactiveVal(sref_model_runs) # Create reactive value to store latest SREF model runs; default to last model run retrieved
  hrrr_url=reactiveVal(hrrr_url) # Create reactive value to store URL for latest HRRR model runs
  hrrr_model_runs=reactiveVal(hrrr_model_runs) # Create reactive value to store latest HRRR model runs; default to last model run retrieved
  anc_model_runs=reactiveVal(anc_model_runs) # Create reactive value to store latest ANC model runs; default to last model run retrieved
  href_url=reactiveVal(href_url) # Create reactive value to store URL for latest HREF model runs
  href_model_runs=reactiveVal(href_model_runs) # Create reactive value to store latest HREF model runs; default to last model run retrieved
  new_sref=reactiveVal(F) # Create reactive value to store if there is a new forecast available
  new_hrrr=reactiveVal(F) # Create reactive value to store if there is a new forecast available
  new_anc=reactiveVal(F)  # Create reactive value to store if there is a new forecast available
  new_href=reactiveVal(F)  # Create reactive value to store if there is a new forecast available
  
  ### Output Datatable of forecast summary
  forecast_summary=reactive({

    # Get Times of last forecast used
    anc_time=ymd_hms(str_split(anc_model_runs()[length(anc_model_runs())],"_|\\.")[[1]][6])
    hrrr_time=ymd_hms(paste0(gsub("hrrr","",tail(str_split(hrrr_url(),"/")[[1]],1))," ",regmatches(hrrr_model_runs(),regexpr("[[:digit:]]+",hrrr_model_runs())),":00:00"))
    href_time=ymd_hms(paste0(regmatches(href_url(),regexpr("[[:digit:]]+",href_url()))," ",regmatches(href_model_runs()[1],regexpr("[[:digit:]]+",href_model_runs()[1])),":00:00"))
    sref_time=ymd_hms(paste0(sub("sref","",str_split(sref_url(),"/")[[1]][6])," ",str_sub(sref_model_runs()[1],-3,-2),":00:00"))

    # Get maximum precipitation intensity of forecast
    if(any(!is.na((ANC_data())))){
      anc_max=max(ANC_data()$value,na.rm=T)
      if(SWMM_units()=="US"){anc_max=anc_max/25.4} # Convert ANC units from mm/hr to in/hr if SWMM uses US units
    } else{
      anc_max=NA
    }

    if(any(!is.na(HRRR_data()))){
      hrrr_max=max(HRRR_data()$value,na.rm=T)
      if(SWMM_units()=="US"){hrrr_max=hrrr_max/25.4} # Convert HRRR units from mm/hr to in/hr if SWMM uses US units
    } else{
      hrrr_max=NA
    }

    if(any(!is.na(HREF_data()))){
      href_max=max(HREF_data()$value,na.rm=T)
      if(SWMM_units()=="US"){href_max=href_max/25.4} # Convert HREF units from mm/hr to in/hr if SWMM uses US units
    } else{
      href_max=NA
    }

    if(any(!is.na(SREF_data()))){
      sref_max=max(SREF_data()$value,na.rm=T)
      if(SWMM_units()=="US"){sref_max=sref_max/25.4} # Convert SREF units from mm to in if SWMM uses US units
      sref_max=sref_max/3 # Convert depth to intensity/hr
    } else{
      sref_max=NA
    }

    if(!is.na(SWMM_units())){
      if(SWMM_units()=="SI"){
        name="Peak Intensity (mm/hr)"
      } else if(SWMM_units()=="US"){
        name="Peak Intensity (in/hr)"
      }
    } else{
      name="Peak Intensity"
    }


    table=tibble("Forecast"=c("ANC","HRRR","HREF","SREF"),
                     "Run"=as.character(c(anc_time,hrrr_time,href_time,sref_time)),
                     "Max"=c(anc_max,hrrr_max,href_max,sref_max))
    colnames(table)=c("Forecast","Run Used (UTC)",name)
    table
  })

  output$forecast_summary=DT::renderDataTable(datatable(forecast_summary(),
                                                        rownames=F,
                                                        options=list(dom="t",columnDefs=list(list(className="dt-center",targets="_all"))))%>%
                                                formatRound(3,2)%>%
                                                formatStyle("Run Used (UTC)","white-space"="nowrap")%>%
                                                formatStyle(0,target="row","line-height"="80%"))
  
  ### Manually Update Forecasts
  observeEvent(input$update_forecast, {
    hide_model_message(T) # Hide refresh model runs message b/c model is rerun anyway
    
    withProgress(message="Checking Forecasts",value=0,{
      ### SREF
      sref_urls=GetDODSDates("sref") # Get URLs of all model runs
      latest_sref_url=tail(sref_urls$url,1) # Get URL of latest model runs
      latest_sref_runs=GetDODSModelRuns(latest_sref_url) # Find available model runs for latest date
      latest_sref_runs=grep("na132",latest_sref_runs$model.run,value=T) # Get all model runs for Grid 132 (16km Grid)
  
      # Determine latest SREF Forecast Hour; SREF runs model four times per day (03, 09, 15, 21 UTC)
      SREF_FH=sapply(latest_sref_runs,function(x)c(grepl("03",x),grepl("09",x),grepl("15",x),grepl("21",x))) # Test name of each model run to see if it includes Forecast Hour
      SREF_FH=c("03","09","15","21")[max(which(sapply(1:nrow(SREF_FH),function(x)any(SREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
  
      # Get all model runs for latest forecast hour
      latest_sref_runs=grep(SREF_FH,latest_sref_runs,value=T)
      incProgress(1/4)
      
      ### HRRR
      hrrr_urls=GetDODSDates("hrrr") # Get URLs of all model runs
      latest_hrrr_url=tail(hrrr_urls$url,1) # Get URL of latest model runs
      latest_hrrr_runs=GetDODSModelRuns(latest_hrrr_url) # Find available model runs for latest date
      latest_hrrr_runs=tail(grep("hrrr_sfc",latest_hrrr_runs$model.run,value=T),1) # Get latest model run for Continental US
      incProgress(1/4)
  
      ### ANC
      ANC_runs=html_attr(html_nodes(read_html("https://mrms.ncep.noaa.gov/data/2D/ANC/MRMS_ANC_FinalForecast/"),"a"),"href")
      ANC_runs=as.data.frame(unlist(ANC_runs[grepl("MRMS_ANC",ANC_runs)]))
      colnames(ANC_runs)="link"
      ANC_runs$model.run.date=ymd_hms(gsub("MRMS_ANC_FinalForecast_00.00*[_]([^.]+)[.].*", "\\1",ANC_runs$link))
      ANC_runs$model.forecast.date=ANC_runs$model.run.date+3600
  
      # Get name of ANC Runs for past hour
      Current_UTC=with_tz(Sys.time(),tzone="UTC") # Get current UTC time
  
      # Get links for ANC forecasts for current time or later
      latest_anc_runs=as.character(ANC_runs[which(ANC_runs$model.forecast.date>=Current_UTC),"link"])
      incProgress(1/4)
      
      ### HREF
      # Get links from HREF server
      href_server="https://nomads.ncep.noaa.gov/pub/data/nccf/com/hiresw/prod/"
      href_runs=html_attr(html_nodes(read_html(href_server),"a"),"href") # Get model run dates
      links=grep("href",href_runs,value=T) # Get only HREF model links
      latest_href_url=paste0(href_server,links[which.max(ymd(links))],"ensprod/")
      
      latest_href_runs=html_attr(html_nodes(read_html(latest_href_url),"a"),"href") # Get all HREF model run urls
      latest_href_runs=latest_href_runs[which(grepl("conus.pmmn.",latest_href_runs)==T)] # Get Probability Matched Mean Forecasts for CONUS
      
      # Determine latest HREF Forecast Hour; HREF runs model four times per day (00, 06, 12, 18 UTC)
      HREF_FH=sapply(latest_href_runs,function(x)c(grepl("t00",x),grepl("t06",x),grepl("t12",x),grepl("t18",x))) # Test name of each model run to see if it includes Forecast Hour
      HREF_FH=c("t00","t06","t12","t18")[max(which(sapply(1:nrow(HREF_FH),function(x)any(HREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
      
      # Get all model runs for latest forecast hour
      latest_href_runs=grep(HREF_FH,latest_href_runs,value=T)
      incProgress(1/4)
    })

    ### Determine if there are any new forecasts
    if((identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F)){new_sref(T)}else{new_sref(F)}
    if((identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F)){new_hrrr(T)}else{new_hrrr(F)}
    if(identical(latest_anc_runs,anc_model_runs())==F){new_anc(T)}else{new_anc(F)}
    if((identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F)){new_href(T)}else{new_href(F)}
    
    ### Display Messages
    if(any(new_sref(),new_hrrr(),new_anc(),new_href())==T){
      sendSweetAlert(session,
                     title="New Forecasts",
                     type="success")
    } else{
      sendSweetAlert(session,
                     title="No New Forecasts",
                     type="error")
    }
    
    ### Update model_runs.R file

    # Update SREF Model Runs if there are new SREF model runs
    if(identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F){
      # Update Reactive Values
      sref_url(latest_sref_url)
      sref_model_runs(latest_sref_runs)

      # Update Values in model_runs.R file
      runs=read.delim("model_runs.r",header=F,col.names="line") 
      levels(runs$line)[grep("sref_url",levels(runs$line))]=paste0("sref_url='",latest_sref_url,"'")
      levels(runs$line)[grep("sref_model_runs",levels(runs$line))]=gsub(", ","','",paste0("sref_model_runs=c('",toString(latest_sref_runs,sep=""),"')"))

      # Write new file
      write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
    }
    
    # Update HRRR Model Runs if there are new HRRR model runs
    if(identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F){
      # Update Reactive Values
      hrrr_url(latest_hrrr_url)
      hrrr_model_runs(latest_hrrr_runs)
      
      # Update Values in model_runs.R file
      runs=read.delim("model_runs.r",header=F,col.names="line")
      levels(runs$line)[grep("hrrr_url",levels(runs$line))]=paste0("hrrr_url='",latest_hrrr_url,"'")
      levels(runs$line)[grep("hrrr_model_runs",levels(runs$line))]=gsub(", ","','",paste0("hrrr_model_runs=c('",toString(latest_hrrr_runs,sep=""),"')"))
      
      # Write new file
      write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
    }

    # Update ANC Model Runs if there are new ANC model runs
    if(identical(latest_anc_runs,anc_model_runs())==F){
      # Update Reactive Value
      anc_model_runs(latest_anc_runs)

      # Update Values in model_runs.R file
      runs=read.delim("model_runs.r",header=F,col.names="line")
      levels(runs$line)[grep("anc_model_runs",levels(runs$line))]=gsub(", ","','",paste0("anc_model_runs=c('",toString(latest_anc_runs,sep=""),"')"))

      # Write new file
      write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
    }
    
    # Update HREF Model Runs if there are new HREF model runs
    if(identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F){
      # Update Reactive Values
      href_url(latest_href_url)
      href_model_runs(latest_href_runs)
      
      # Update Values in model_runs.R file
      runs=read.delim("model_runs.r",header=F,col.names="line")
      levels(runs$line)[grep("href_url",levels(runs$line))]=paste0("href_url='",latest_href_url,"'")
      levels(runs$line)[grep("href_model_runs",levels(runs$line))]=gsub(", ","','",paste0("href_model_runs=c('",toString(latest_href_runs,sep=""),"')"))
      
      # Write new file
      write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
    }
  })

  ### Automatically Update SREF & ANC Forecasts
  auto_update_timer=reactiveTimer(300000) # Timer that invalidates every 5 minutes to check for new forecasts
  observeEvent(auto_update_timer(), {
    if(input$auto_update==T){
      withProgress(message="Checking Forecasts",value=0,{
        ### SREF
        sref_urls=GetDODSDates("sref") # Get URLs of all model runs
        latest_sref_url=tail(sref_urls$url,1) # Get URL of latest model runs
        latest_sref_runs=GetDODSModelRuns(latest_sref_url) # Find available model runs for latest date
        latest_sref_runs=grep("na132",latest_sref_runs$model.run,value=T) # Get all model runs for Grid 132 (16km Grid)
        
        # Determine latest SREF Forecast Hour; SREF runs model four times per day (03, 09, 15, 21 UTC)
        SREF_FH=sapply(latest_sref_runs,function(x)c(grepl("03",x),grepl("09",x),grepl("15",x),grepl("21",x))) # Test name of each model run to see if it includes Forecast Hour
        SREF_FH=c("03","09","15","21")[max(which(sapply(1:nrow(SREF_FH),function(x)any(SREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
        
        # Get all model runs for latest forecast hour
        latest_sref_runs=grep(SREF_FH,latest_sref_runs,value=T)
        incProgress(1/4)
        
        ### HRRR
        hrrr_urls=GetDODSDates("hrrr") # Get URLs of all model runs
        latest_hrrr_url=tail(hrrr_urls$url,1) # Get URL of latest model runs
        latest_hrrr_runs=GetDODSModelRuns(latest_hrrr_url) # Find available model runs for latest date
        latest_hrrr_runs=tail(grep("hrrr_sfc",latest_hrrr_runs$model.run,value=T),1) # Get latest model run for Continental US
        incProgress(1/4)
        
        ### ANC
        ANC_runs=html_attr(html_nodes(read_html("https://mrms.ncep.noaa.gov/data/2D/ANC/MRMS_ANC_FinalForecast/"),"a"),"href")
        ANC_runs=as.data.frame(unlist(ANC_runs[grepl("MRMS_ANC",ANC_runs)]))
        colnames(ANC_runs)="link"
        ANC_runs$model.run.date=ymd_hms(gsub("MRMS_ANC_FinalForecast_00.00*[_]([^.]+)[.].*", "\\1",ANC_runs$link))
        ANC_runs$model.forecast.date=ANC_runs$model.run.date+3600
        
        # Get name of ANC Runs for past hour
        Current_UTC=with_tz(Sys.time(),tzone="UTC") # Get current UTC time
        
        # Get links for ANC forecasts for current time or later
        latest_anc_runs=as.character(ANC_runs[which(ANC_runs$model.forecast.date>=Current_UTC),"link"])
        incProgress(1/4)
        
        ### HREF
        # Get links from HREF server
        href_server="https://nomads.ncep.noaa.gov/pub/data/nccf/com/hiresw/prod/"
        href_runs=html_attr(html_nodes(read_html(href_server),"a"),"href") # Get model run dates
        links=grep("href",href_runs,value=T) # Get only HREF model links
        latest_href_url=paste0(href_server,links[which.max(ymd(links))],"ensprod/")
        
        latest_href_runs=html_attr(html_nodes(read_html(latest_href_url),"a"),"href") # Get all HREF model run urls
        latest_href_runs=latest_href_runs[which(grepl("conus.pmmn.",latest_href_runs)==T)] # Get Probability Matched Mean Forecasts for CONUS
        
        # Determine latest HREF Forecast Hour; HREF runs model four times per day (00, 06, 12, 18 UTC)
        HREF_FH=sapply(latest_href_runs,function(x)c(grepl("t00",x),grepl("t06",x),grepl("t12",x),grepl("t18",x))) # Test name of each model run to see if it includes Forecast Hour
        HREF_FH=c("t00","t06","t12","t18")[max(which(sapply(1:nrow(HREF_FH),function(x)any(HREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
        
        # Get all model runs for latest forecast hour
        latest_href_runs=grep(HREF_FH,latest_href_runs,value=T)
        incProgress(1/4)
      })
      
      ### Determine if there are any new forecasts
      if((identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F)){new_sref(T)}else{new_sref(F)}
      if((identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F)){new_hrrr(T)}else{new_hrrr(F)}
      if(identical(latest_anc_runs,anc_model_runs())==F){new_anc(T)}else{new_anc(F)}
      if((identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F)){new_href(T)}else{new_href(F)}
      
      ### Display Messages
      if(any(new_sref(),new_hrrr(),new_anc(),new_href())==T){
        sendSweetAlert(session,
                       title="New Forecasts",
                       type="success")
      } else{
        sendSweetAlert(session,
                       title="No New Forecasts",
                       type="error")
      }
      
      ### Update model_runs.R file
      
      # Update SREF Model Runs if there are new SREF model runs
      if(identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F){
        # Update Reactive Values
        sref_url(latest_sref_url)
        sref_model_runs(latest_sref_runs)
        
        # Update Values in model_runs.R file
        runs=read.delim("model_runs.r",header=F,col.names="line")
        levels(runs$line)[grep("sref_url",levels(runs$line))]=paste0("sref_url='",latest_sref_url,"'")
        levels(runs$line)[grep("sref_model_runs",levels(runs$line))]=gsub(", ","','",paste0("sref_model_runs=c('",toString(latest_sref_runs,sep=""),"')"))
        
        # Write new file
        write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
      }
      
      # Update HRRR Model Runs if there are new HRRR model runs
      if(identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F){
        # Update Reactive Values
        hrrr_url(latest_hrrr_url)
        hrrr_model_runs(latest_hrrr_runs)
        
        # Update Values in model_runs.R file
        runs=read.delim("model_runs.r",header=F,col.names="line")
        levels(runs$line)[grep("hrrr_url",levels(runs$line))]=paste0("hrrr_url='",latest_hrrr_url,"'")
        levels(runs$line)[grep("hrrr_model_runs",levels(runs$line))]=gsub(", ","','",paste0("hrrr_model_runs=c('",toString(latest_hrrr_runs,sep=""),"')"))
        
        # Write new file
        write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
      }
      
      # Update ANC Model Runs if there are new ANC model runs
      if(identical(latest_anc_runs,anc_model_runs())==F){
        # Update Reactive Value
        anc_model_runs(latest_anc_runs)
        
        # Update Values in model_runs.R file
        runs=read.delim("model_runs.r",header=F,col.names="line")
        levels(runs$line)[grep("anc_model_runs",levels(runs$line))]=gsub(", ","','",paste0("anc_model_runs=c('",toString(latest_anc_runs,sep=""),"')"))
        
        # Write new file
        write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
      }
      
      # Update HREF Model Runs if there are new HREF model runs
      if(identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F){
        # Update Reactive Values
        href_url(latest_href_url)
        href_model_runs(latest_href_runs)
        
        # Update Values in model_runs.R file
        runs=read.delim("model_runs.r",header=F,col.names="line") 
        levels(runs$line)[grep("href_url",levels(runs$line))]=paste0("href_url='",latest_href_url,"'")
        levels(runs$line)[grep("href_model_runs",levels(runs$line))]=gsub(", ","','",paste0("href_model_runs=c('",toString(latest_href_runs,sep=""),"')"))
        
        # Write new file
        write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
      }
    }
  })
  
  ### Refresh Forecasts
  observeEvent(refresh(), {
    if(refresh()>0){
      if(new_sref()==T){
        withProgress(message="Checking Forecasts",value=0,{
          
          # Clear Reactive Values if NA data so that it will download new forecasts
          if(all(is.na(SREF_data()))){
            sref_model_runs('')
          }
          if(all(is.na(HREF_data()))){
            href_model_runs('')
          }
          if(all(is.na(HRRR_data()))){
            hrrr_model_runs('')
          }
          if(all(is.na(ANC_data()))){
            anc_model_runs('')
          }

          ### SREF
          sref_urls=GetDODSDates("sref") # Get URLs of all model runs
          latest_sref_url=tail(sref_urls$url,1) # Get URL of latest model runs
          latest_sref_runs=GetDODSModelRuns(latest_sref_url) # Find available model runs for latest date
          latest_sref_runs=grep("na132",latest_sref_runs$model.run,value=T) # Get all model runs for Grid 132 (16km Grid)
          
          # Determine latest SREF Forecast Hour; SREF runs model four times per day (03, 09, 15, 21 UTC)
          SREF_FH=sapply(latest_sref_runs,function(x)c(grepl("03",x),grepl("09",x),grepl("15",x),grepl("21",x))) # Test name of each model run to see if it includes Forecast Hour
          SREF_FH=c("03","09","15","21")[max(which(sapply(1:nrow(SREF_FH),function(x)any(SREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
          
          # Get all model runs for latest forecast hour
          latest_sref_runs=grep(SREF_FH,latest_sref_runs,value=T)
          incProgress(1/4)
          
          ### HRRR
          hrrr_urls=GetDODSDates("hrrr") # Get URLs of all model runs
          latest_hrrr_url=tail(hrrr_urls$url,1) # Get URL of latest model runs
          latest_hrrr_runs=GetDODSModelRuns(latest_hrrr_url) # Find available model runs for latest date
          latest_hrrr_runs=tail(grep("hrrr_sfc",latest_hrrr_runs$model.run,value=T),1) # Get latest model run for Continental US
          incProgress(1/4)
          
          ### ANC
          ANC_runs=html_attr(html_nodes(read_html("https://mrms.ncep.noaa.gov/data/2D/ANC/MRMS_ANC_FinalForecast/"),"a"),"href")
          ANC_runs=as.data.frame(unlist(ANC_runs[grepl("MRMS_ANC",ANC_runs)]))
          colnames(ANC_runs)="link"
          ANC_runs$model.run.date=ymd_hms(gsub("MRMS_ANC_FinalForecast_00.00*[_]([^.]+)[.].*", "\\1",ANC_runs$link))
          ANC_runs$model.forecast.date=ANC_runs$model.run.date+3600
          
          # Get name of ANC Runs for past hour
          Current_UTC=with_tz(Sys.time(),tzone="UTC") # Get current UTC time
          
          # Get links for ANC forecasts for current time or later
          latest_anc_runs=as.character(ANC_runs[which(ANC_runs$model.forecast.date>=Current_UTC),"link"])
          incProgress(1/4)
          
          ### HREF
          # Get links from HREF server
          href_server="https://nomads.ncep.noaa.gov/pub/data/nccf/com/hiresw/prod/"
          href_runs=html_attr(html_nodes(read_html(href_server),"a"),"href") # Get model run dates
          links=grep("href",href_runs,value=T) # Get only HREF model links
          latest_href_url=paste0(href_server,links[which.max(ymd(links))],"ensprod/")
          
          latest_href_runs=html_attr(html_nodes(read_html(latest_href_url),"a"),"href") # Get all HREF model run urls
          latest_href_runs=latest_href_runs[which(grepl("conus.pmmn.",latest_href_runs)==T)] # Get Probability Matched Mean Forecasts for CONUS
          
          # Determine latest HREF Forecast Hour; HREF runs model four times per day (00, 06, 12, 18 UTC)
          HREF_FH=sapply(latest_href_runs,function(x)c(grepl("t00",x),grepl("t06",x),grepl("t12",x),grepl("t18",x))) # Test name of each model run to see if it includes Forecast Hour
          HREF_FH=c("t00","t06","t12","t18")[max(which(sapply(1:nrow(HREF_FH),function(x)any(HREF_FH[x,]==T))))] # Get String of Latest Forecast Hour that exists
          
          # Get all model runs for latest forecast hour
          latest_href_runs=grep(HREF_FH,latest_href_runs,value=T)
          incProgress(1/4)
        })
        
        ### Determine if there are any new forecasts
        if((identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F)){new_sref(T)}else{new_sref(F)}
        if((identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F)){new_hrrr(T)}else{new_hrrr(F)}
        if(identical(latest_anc_runs,anc_model_runs())==F){new_anc(T)}else{new_anc(F)}
        if((identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F)){new_href(T)}else{new_href(F)}
        
        ### Display Messages
        if(any(new_sref(),new_hrrr(),new_anc(),new_href())==T){
          sendSweetAlert(session,
                         title="New Forecasts",
                         type="success")
        } else{
          sendSweetAlert(session,
                         title="No New Forecasts",
                         type="error")
        }
        
        ### Update model_runs.R file
        
        # Update SREF Model Runs if there are new SREF model runs
        if(identical(latest_sref_url,sref_url())==F|identical(latest_sref_runs,sref_model_runs())==F){
          # Update Reactive Values
          sref_url(latest_sref_url)
          sref_model_runs(latest_sref_runs)
          
          # Update Values in model_runs.R file
          runs=read.delim("model_runs.r",header=F,col.names="line") 
          levels(runs$line)[grep("sref_url",levels(runs$line))]=paste0("sref_url='",latest_sref_url,"'")
          levels(runs$line)[grep("sref_model_runs",levels(runs$line))]=gsub(", ","','",paste0("sref_model_runs=c('",toString(latest_sref_runs,sep=""),"')"))
          
          # Write new file
          write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
        }
        
        # Update HRRR Model Runs if there are new HRRR model runs
        if(identical(latest_hrrr_url,hrrr_url())==F|identical(latest_hrrr_runs,hrrr_model_runs())==F){
          # Update Reactive Values
          hrrr_url(latest_hrrr_url)
          hrrr_model_runs(latest_hrrr_runs)
          
          # Update Values in model_runs.R file
          runs=read.delim("model_runs.r",header=F,col.names="line") 
          levels(runs$line)[grep("hrrr_url",levels(runs$line))]=paste0("hrrr_url='",latest_hrrr_url,"'")
          levels(runs$line)[grep("hrrr_model_runs",levels(runs$line))]=gsub(", ","','",paste0("hrrr_model_runs=c('",toString(latest_hrrr_runs,sep=""),"')"))
          
          # Write new file
          write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
        }
        
        # Update ANC Model Runs if there are new ANC model runs
        if(identical(latest_anc_runs,anc_model_runs())==F){
          # Update Reactive Value
          anc_model_runs(latest_anc_runs)
          
          # Update Values in model_runs.R file
          runs=read.delim("model_runs.r",header=F,col.names="line") 
          levels(runs$line)[grep("anc_model_runs",levels(runs$line))]=gsub(", ","','",paste0("anc_model_runs=c('",toString(latest_anc_runs,sep=""),"')"))
          
          # Write new file
          write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
        }
        
        # Update HREF Model Runs if there are new HREF model runs
        if(identical(latest_href_url,href_url())==F|identical(latest_href_runs,href_model_runs())==F){
          # Update Reactive Values
          href_url(latest_href_url)
          href_model_runs(latest_href_runs)
          
          # Update Values in model_runs.R file
          runs=read.delim("model_runs.r",header=F,col.names="line") 
          levels(runs$line)[grep("href_url",levels(runs$line))]=paste0("href_url='",latest_href_url,"'")
          levels(runs$line)[grep("href_model_runs",levels(runs$line))]=gsub(", ","','",paste0("href_model_runs=c('",toString(latest_href_runs,sep=""),"')"))
          
          # Write new file
          write.table(runs,file="model_runs.r",append=F,row.names=F,col.names=F,quote=F)
        }
      }
    }
  })

  ##### Get SREF indices of SREF grid cells that contain area of SWMM model ------------------------------------------
  sref_lat_min=reactive({sref_lat$Index[sref_lat$Lat%>%detect_index(function(x)x<swmm_lat_min(),.dir="backward")]})
  sref_lat_max=reactive({sref_lat$Index[sref_lat$Lat%>%detect_index(function(x)x>swmm_lat_max(),.dir="forward")]})
  
  sref_lon_min=reactive({sref_lon$Index[sref_lon$Lon%>%detect_index(function(x)x<swmm_lon_min(),.dir="backward")]})
  sref_lon_max=reactive({sref_lon$Index[sref_lon$Lon%>%detect_index(function(x)x>swmm_lon_max(),.dir="forward")]})
  
  ##### Get HRRR indices of HRRR grid cells that contain area of SWMM model ------------------------------------------
  hrrr_lat_min=reactive({hrrr_lat$Index[hrrr_lat$Lat%>%detect_index(function(x)x<swmm_lat_min(),.dir="backward")]})
  hrrr_lat_max=reactive({hrrr_lat$Index[hrrr_lat$Lat%>%detect_index(function(x)x>swmm_lat_max(),.dir="forward")]})
  
  hrrr_lon_min=reactive({hrrr_lon$Index[hrrr_lon$Lon%>%detect_index(function(x)x<swmm_lon_min_hrrr(),.dir="backward")]})
  hrrr_lon_max=reactive({hrrr_lon$Index[hrrr_lon$Lon%>%detect_index(function(x)x>swmm_lon_max_hrrr(),.dir="forward")]})
  
  ### Display Error Messages and ask User if they would like to retrieve new forecasts or rerun SWMM model if previous data not loaded
  hide_model_message=reactiveVal({F}) # Variable to determine if rerunning SWMM model message should be hidden; hide if refreshing forecasts b/c it reruns model anyway
  
  observe({
    if(input$Pages=="forecast"){
      # Create List of Error Codes to Display Messages
      error_code=c()
      
      # Check if No SWMM .inp
      if(!length(inp_path())>0){
        error_code=c(error_code,1)
      }
      
      # Check if No Subcatchment Shapefile
      if(!length(shp_path())>0){
        error_code=c(error_code,2)
      }
      
      # Check if No Spatial Reference
      if(is.null(subcatchments_shp_crs())){
        error_code=c(error_code,3)
      } else if(is.na(subcatchments_shp_crs())){
        error_code=c(error_code,3)
      }
      
      # If no Subcatchments Shapefile, then don't display message about missing spatial reference
      if(all(c(2,3)%in%error_code)){
        error_code=error_code[!error_code%in%3]  
      }
      
      # Display Messages
      # No Errors
      if(is.null(error_code)){
        # Check if forecast data loaded from previous run
        if(all(is.na(SREF_data()))|all(is.na(HRRR_data()))|all(is.na(ANC_data()))|all(is.na(HREF_data()))){
          confirmSweetAlert(session,inputId="missing_forecast",
                            title="Forecast Data Not Loaded",
                            type="error",
                            text="ANC, HRRR, HREF, and/or SREF forecast data was not loaded from previous run. Would you like to retrieve new forecasts and run SWMM model?",
                            btn_labels=c("No","Yes"))
        }
        else if(all(is.na(SREF_SC_results()))|all(is.na(SREF_Node_results()))|all(is.na(SREF_Link_results()))|
                all(is.na(HRRR_SC_results()))|all(is.na(HRRR_Node_results()))|all(is.na(HRRR_Link_results()))|
                all(is.na(ANC_SC_results()))|all(is.na(ANC_Node_results()))|all(is.na(ANC_Link_results()))|
                all(is.na(HREF_SC_results()))|all(is.na(HREF_Node_results()))|all(is.na(HREF_Link_results()))){
          if(hide_model_message()==F){
            confirmSweetAlert(session,inputId="missing_model",
                              title="SWMM Results Not Loaded",
                              type="error",
                              text="ANC, HRRR, HREF, and/or SREF SWMM results were not loaded from previous run. Would you like to rerun the SWMM model?",
                              btn_labels=c("No","Yes"))
          }
        }
      }
      # Only One Error
      else if(length(error_code)==1){
        if(error_code==1){
          sendSweetAlert(session,
                         title="No SWMM Model Uploaded",
                         type="error",
                         text="Please Upload a new SWMM Model on the Settings Page")
        } else if (error_code==2){
          sendSweetAlert(session,
                         title="No Subcatchments Shapefile Uploaded",
                         type="error",
                         text="Please Upload a new Subcatchment Shapefile on the Settings Page")
        } else if (error_code==3){
          sendSweetAlert(session,
                         title="Uploaded Subcatchment Shapefile has no Spatial Reference",
                         type="error",
                         text="Please Upload a new Subcatchment Shapefile on the Settings Page")
        }
      }
      # Multiple Errors
      else if(length(error_code)>1){
        message=""
        if(1%in%error_code){
          message=paste(message,"- No SWMM Model Uploaded
                      ")
        }
        if(2%in%error_code){
          message=paste(message,"- No Subcatchments Shapefile Uploaded
                      ")
        }
        if(3%in%error_code){
          message=paste(message,"- No Spatial Reference for Subcatchments Shapefile
                      ")
        }
        sendSweetAlert(session,
                       title="Errors",
                       type="error",
                       text=message)
      }
    }
  })

  ### Retrieve new forecasts if previous data not loaded and user wants to get new forecasts
  observeEvent(input$missing_forecast, {
    if(input$missing_forecast==T){
      new_sref(T) # Get new SREF forecast
      new_hrrr(T) # Get new HRRR forecast
      new_anc(T)  # Get new ANC forecast
      new_href(T) # Get new HREF forecast
      
      hide_model_message(T) # Hide refresh model runs message b/c model is rerun anyway
      refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
    }
    else if(input$missing_forecast==F){
      new_sref(F)
      new_hrrr(F)
      new_anc(F)
      new_href(F)
      run_swmm_sref(F)
      run_swmm_hrrr(F)
      run_swmm_anc(F)
      run_swmm_href(F)
      hide_model_message(F)
      refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
    }
  })
  
  ### Rerun SWMM model if previous data not loaded and user wants to rerun model
  observeEvent(input$missing_model, {
    if(input$missing_model==T){
      if(!all(nchar(sref_model_runs())>0)|all(!nchar(hrrr_model_runs())>0)|all(!nchar(anc_model_runs())>0)|all(!nchar(href_model_runs())>0)){
        sendSweetAlert(session,
                       title="Missing Forecast Run Names",
                       type="error",
                       text="ANC, HRRR, HREF, and/or SREF model run names are missing. Names should be added to the anc_model_runs, hrrr_model_runs, href_model_runs, and/or sref_model_runs lists in the model_runs.R file or the forecast data should be updated.")
      } else{
        if(all(is.na(SREF_SC_results()))|all(is.na(SREF_Node_results()))|all(is.na(SREF_Link_results()))){run_swmm_sref(T)}else{run_swmm_sref(F)}
        if(all(is.na(HRRR_SC_results()))|all(is.na(HRRR_Node_results()))|all(is.na(HRRR_Link_results()))){run_swmm_hrrr(T)}else{run_swmm_hrrr(F)}
        if(all(is.na(ANC_SC_results()))|all(is.na(ANC_Node_results()))|all(is.na(ANC_Link_results()))){run_swmm_anc(T)}else{run_swmm_anc(F)}
        if(all(is.na(HREF_SC_results()))|all(is.na(HREF_Node_results()))|all(is.na(HREF_Link_results()))){run_swmm_href(T)}else{run_swmm_href(F)}
        refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
      }
    }
    else if(input$missing_model==F){
      run_swmm_sref(F)
      run_swmm_hrrr(F)
      run_swmm_anc(F)
      run_swmm_href(F)
      refresh(refresh()+1) # Add one to value so that value changes and triggers refresh
    }
  })
  
  ##### Retrieve SREF Data & Process if new SREF forecast or user refreshes app -------------------------------------------------
  SREF_data=reactiveVal({
    if(exists("Output_SREF_data")){
      Output_SREF_data
    }
    else{
      NA
    }
  })
  
  observeEvent(c(sref_url(),
                 sref_model_runs()),{
    # Download SREF data if there is a new forecast available
    if(new_sref()==T){
      sref_model_count=1
      withProgress(message="Retrieving SREF Forecast",value=0,{
        for(sref_model_run in sref_model_runs()){ # Loop through each model run
          # Retrive data from model run
          data=as.data.frame(DODSGrab(model.url=sref_url(),
                                      model.run=sref_model_run,
                                      variables=c("apcpsfc"), # apcpsfc = surface total precipitation [kg/m^2]
                                      ensembles=c(0,0),
                                      time=c(0,29), # Time Step: 0-87 hours in 3 hour increments (3*29=87)
                                      lat=c(sref_lat_min(),sref_lat_max()),
                                      lon=c(sref_lon_min(),sref_lon_max())
          ))
          
          # Format data
          data$model.run.date=as.character(data$model.run.date)
          data$request.url=as.character(data$request.url)
          
          if(sref_model_count==1){ # Create dataframe from first model run
            SREF_data=data
          }
          else{ # Join data from other model runs to the dataframe
            SREF_data=full_join(SREF_data,data,by=c("model.run.date","forecast.date","variables","levels","ensembles","lon","lat","value","request.url"))
          }
          sref_model_count=sref_model_count+1 # Add one to model counter
          incProgress(1/26) # Increment Progress Bar
        }
      })
      
      # SREF longitudes are reported in 0-360 degree form, so convert longitudes back to -180 to 180 form from 0-360 form before interpolation
      SREF_data$lon=as.double(lapply(SREF_data$lon,function(X){ifelse(X>180,X-360,X)}))
      
      SREF_data(SREF_data)
      run_swmm_sref(T) # Retrieved new SREF forecast, so run SWMM model
    }
    else{
      run_swmm_sref(F) # No new SREF forecast, so don't run SWMM model         
    }
  })

  ##### Run SWMM model for each SREF model run ---------------------------------------------------------------------------------------------
  ### Create Reactive Values to Store Results; Default to loaded value or NA if no loaded value
  SREF_SC_results=reactiveVal({
    if(exists("Output_SREF_SC_results")){
      Output_SREF_SC_results
    }
    else{
      NA
    }
  })
  SREF_Node_results=reactiveVal({
    if(exists("Output_SREF_Node_results")){
      Output_SREF_Node_results
    }
    else{
      NA
    }
  })
  SREF_Link_results=reactiveVal({
    if(exists("Output_SREF_Link_results")){
      Output_SREF_Link_results
    }
    else{
      NA
    }
  })
  
  ### Reactive if SREF data changes or user refreshes app
  observeEvent(c(run_swmm_sref()),{
    if(run_swmm_sref()==T){
      withProgress(message="Running SWMM Model for SREF Forecasts",value=0,{
        ### Update SWMM Dates to SREF forecast dates
        inp=inp() # Get SWMM .inp
        SREF_start=sort(SREF_data()$forecast.date)[1]
        SREF_end=sort(SREF_data()$forecast.date,decreasing=T)[1]
        
        start_date=format(SREF_start,format="%m/%d/%Y") # Get Start Date
        inp$options[which(inp$options$Option=="START_DATE"),"Value"]=start_date # Set Start Date
        inp$options[which(inp$options$Option=="REPORT_START_DATE"),"Value"]=start_date # Set Report Start Date
        inp$options[which(inp$options$Option=="SWEEP_START"),"Value"]=sub('/([^/]*)$','',start_date) # Set Sweep Start Date
        
        end_date=format(SREF_end,format="%m/%d/%Y")  # Get End Date
        inp$options[which(inp$options$Option=="END_DATE"),"Value"]=end_date # Set End Date
        inp$options[which(inp$options$Option=="SWEEP_END"),"Value"]=sub('/([^/]*)$','',end_date) # Set Sweep End Date
        
        start_time=sub("^\\S+\\s+",'',SREF_start) # Get Start Time
        inp$options[which(inp$options$Option=="START_TIME"),"Value"]=start_time # Set Start Time
        inp$options[which(inp$options$Option=="REPORT_START_TIME"),"Value"]=start_time # Set Report Start Time
        
        inp$options[which(inp$options$Option=="END_TIME"),"Value"]=sub("^\\S+\\s+",'',SREF_end+60) # Set End Time
        
        inp$options[which(inp$options$Option=="REPORT_STEP"),"Value"]=report_ts() # Set Reporting Time Step
        
        ### Create lists to store data
        SREF_SC_Sim_Data=vector("list")
        SREF_Node_Sim_Data=vector("list")
        SREF_Link_Sim_Data=vector("list")
        
        ### Run SWMM for each SREF model run
        for(model_run in sref_model_runs()){ # Loop through each model run
          Precip_IDW=NULL # Create empty list to store precip data
          inp$raingages=NULL # Clear rain gauges
          inp$timeseries=NULL # Clear timeseries
          
          # Loop through each subcatchment in SWMM .inp file
          for(sc in unlist(unique(inp$subcatchments$Name))){
            
            ### Interpolate Precipitation time Series
            Precip_IDW[[sc]]=data.frame(forecast.date=unique(SREF_data()[which(grepl(model_run,SREF_data()$model.run.date)),"forecast.date"])) # Get Date/Time values from Precipitation Data Frame
            Precip_IDW[[sc]]$Value=as.numeric(lapply(Precip_IDW[[sc]]$forecast.date,idw_function,sc,model_run,interpolate_precip(),"SREF",SREF_data(),shp_data())) # Use function to interpolate precipitation time series
            
            ### Convert SREF Precipitation units (kg/m^2 == mm) to inches of precipitation if SWMM is in US units
            if(SWMM_units()=="US"){
              Precip_IDW[[sc]]$Value=Precip_IDW[[sc]]$Value/25.4
            }
            
            ### Format Precipitation time series
            ts_name=paste0("SC",sc,"_Precip") # Create Name of precipitation time series for subcatchment
            Precip_IDW[[sc]]$Name=ts_name # Get Name
            Precip_IDW[[sc]]$Date=format(Precip_IDW[[sc]]$forecast.date,format="%m/%d/%Y") # Get Date
            Precip_IDW[[sc]]$Time=sub("^\\S+\\s+",'',Precip_IDW[[sc]]$forecast.date) # Get Time
            Precip_IDW[[sc]]=Precip_IDW[[sc]][,c("Name","Date","Time","Value")] # Subset/Rearrange
            
            ### Update SWMM .inp file
            inp$timeseries=rbind(inp$timeseries,Precip_IDW[[sc]]) # Add time series to SWMM .inp file
            gage_name=paste("Subcatchment",sc,sep="_") # Create Name of rain gauge for subcatchment
            inp$raingages=rbind(inp$raingages,c(gage_name,"VOLUME",SREF_interval,SWMM_SCF(),paste("TIMESERIES",ts_name))) # Add rain gauge to SWMM .inp file
            inp$subcatchments[which(inp$subcatchments$Name==sc),"Rain Gage"]=gage_name # Update catchment rain gauge
          }
          
          ### Write New SWMM .inp
          write_inp(inp,"www/Sim/Model.inp") # Save SWMM .inp file
          add_transects("www/Sim/Model.inp",transects()) # Add transects back into SWMM .inp file
          if(file.exists(gsub(".inp",".ini",inp_path()))){ # Copy and rename settings file if it exists
            file.copy(gsub(".inp",".ini",inp_path()),"www/Sim/Model.ini",overwrite=T) # Copy/Rename file
          }
          
          ### Run SWMM Model
          sim_files=run_swmm(inp="www/Sim/Model.inp")
          
          ### Get names of all SWMM subcatchments, links, and nodes
          swmm_ID=get_out_content(sim_files$out)
          
          ### Store subcatchment data
          SREF_SC_Sim_Data[[model_run]]=read_out(sim_files$out,iType=0,object_name=swmm_ID$subcatchments$names,vIndex=as.numeric(sc_vars()))
          
          ### Store node data
          SREF_Node_Sim_Data[[model_run]]=read_out(sim_files$out,iType=1,object_name=swmm_ID$nodes$names,vIndex=as.numeric(node_vars()))
          
          ### Store link data
          SREF_Link_Sim_Data[[model_run]]=read_out(sim_files$out,iType=2,object_name=swmm_ID$links$names,vIndex=as.numeric(link_vars()))
          
          incProgress(1/26) # Increment Progress Bar
        }
      })
      withProgress(message="Reshaping SREF Data",value=1,{
      
      ### Retrieve/Reshape Data
      SREF_SC_data=melt(SREF_SC_Sim_Data)
      colnames(SREF_SC_data)=c("Value","Variable","ID","Run")
  
      SREF_Node_data=melt(SREF_Node_Sim_Data)
      colnames(SREF_Node_data)=c("Value","Variable","ID","Run")
  
      SREF_Link_data=melt(SREF_Link_Sim_Data)
      colnames(SREF_Link_data)=c("Value","Variable","ID","Run")
  
      ### Add Times to Data
      SWMM_sref_times=SREF_SC_Sim_Data[1][[1]][[1]][[1]] # Get Times from SWMM Data for SREF simulations
      tzone(SWMM_sref_times)="UTC" # Set Time Zone to UTC to match data in SC_data, Node_data, and Link_data
  
      # Convert times from UTC (b/c SREF data, ANC data, and SWMM model use UTC time) to time zone of watershed (based on location of subcatchment centroids)
      SREF_SC_data$DateTime=as_datetime(.index(SWMM_sref_times),tz=watershed_tz())
      SREF_Node_data$DateTime=as_datetime(.index(SWMM_sref_times),tz=watershed_tz())
      SREF_Link_data$DateTime=as_datetime(.index(SWMM_sref_times),tz=watershed_tz())
      
      ### Save Data to Reactive Values
      SREF_SC_results(SREF_SC_data)
      SREF_Node_results(SREF_Node_data)
      SREF_Link_results(SREF_Link_data)
      })
    }
  })
  
  ##### Retrieve HRRR Data & Process if new HRRR forecast or user refreshes app -------------------------------------------------
  HRRR_data=reactiveVal({
    if(exists("Output_HRRR_data")){
      Output_HRRR_data
    }
    else{
      NA
    }
  })
  
  observeEvent(c(hrrr_url(),
                 hrrr_model_runs()),{
     # Download HRRR data if there is a new forecast available
     if(new_hrrr()==T){
       hrrr_model_count=1
       withProgress(message="Retrieving HRRR Forecast",value=0,{
         # Retrive data from model run
         HRRR_data=as.data.frame(DODSGrab(model.url=hrrr_url(),
                                          model.run=hrrr_model_runs(),
                                          variables=c("apcpsfc"), # apcpsfc = surface total precipitation [kg/m^2]
                                          time=c(0,18), # Time Step: 0-18 hours in 1 hour increments
                                          lat=c(hrrr_lat_min(),hrrr_lat_max()),
                                          lon=c(hrrr_lon_min(),hrrr_lon_max())
         ))

         # Format data
         HRRR_data$model.run.date=as.character(HRRR_data$model.run.date)
         HRRR_data$request.url=as.character(HRRR_data$request.url)
         HRRR_data$forecast.date=round_date(HRRR_data$forecast.date,unit="hour",week_start=getOption("lubridate.week.start",7)) # Round to nearest hour because some times are reported as HH:59:59 instead of an even hour

         incProgress(1) # Increment Progress Bar
       })
       
       HRRR_data(HRRR_data)
       run_swmm_hrrr(T) # Retrieved new HRRR forecast, so run SWMM model
     }
     else{
       run_swmm_hrrr(F) # No new HRRR forecast, so don't run SWMM model         
     }
   })
  
  ##### Run SWMM model for each HRRR model run ---------------------------------------------------------------------------------------------
  ### Create Reactive Values to Store Results; Default to loaded value or NA if no loaded value
  HRRR_SC_results=reactiveVal({
    if(exists("Output_HRRR_SC_results")){
      Output_HRRR_SC_results
    }
    else{
      NA
    }
  })
  HRRR_Node_results=reactiveVal({
    if(exists("Output_HRRR_Node_results")){
      Output_HRRR_Node_results
    }
    else{
      NA
    }
  })
  HRRR_Link_results=reactiveVal({
    if(exists("Output_HRRR_Link_results")){
      Output_HRRR_Link_results
    }
    else{
      NA
    }
  })
  
  ### Reactive if HRRR data changes or user refreshes app
  observeEvent(c(run_swmm_hrrr()),{
    if(run_swmm_hrrr()==T){
      withProgress(message="Running SWMM Model for HRRR Forecasts",value=0,{

        inp=inp() # Get SWMM .inp
        HRRR_start=sort(HRRR_data()$forecast.date)[1]
        HRRR_end=sort(HRRR_data()$forecast.date,decreasing=T)[1]
        
        start_date=format(HRRR_start,format="%m/%d/%Y") # Get Start Date
        inp$options[which(inp$options$Option=="START_DATE"),"Value"]=start_date # Set Start Date
        inp$options[which(inp$options$Option=="REPORT_START_DATE"),"Value"]=start_date # Set Report Start Date
        inp$options[which(inp$options$Option=="SWEEP_START"),"Value"]=sub('/([^/]*)$','',start_date) # Set Sweep Start Date
        
        end_date=format(HRRR_end,format="%m/%d/%Y")  # Get End Date
        inp$options[which(inp$options$Option=="END_DATE"),"Value"]=end_date # Set End Date
        inp$options[which(inp$options$Option=="SWEEP_END"),"Value"]=sub('/([^/]*)$','',end_date) # Set Sweep End Date
        
        start_time=sub("^\\S+\\s+",'',HRRR_start) # Get Start Time
        inp$options[which(inp$options$Option=="START_TIME"),"Value"]=start_time # Set Start Time
        inp$options[which(inp$options$Option=="REPORT_START_TIME"),"Value"]=start_time # Set Report Start Time
        
        inp$options[which(inp$options$Option=="END_TIME"),"Value"]=sub("^\\S+\\s+",'',HRRR_end+60) # Set End Time
        
        inp$options[which(inp$options$Option=="REPORT_STEP"),"Value"]=report_ts() # Set Reporting Time Step
        
        ### Create lists to store data
        HRRR_SC_Sim_Data=vector("list")
        HRRR_Node_Sim_Data=vector("list")
        HRRR_Link_Sim_Data=vector("list")
        
        ### Run SWMM
        Precip_IDW=NULL # Create empty list to store precip data
        inp$raingages=NULL # Clear rain gauges
        inp$timeseries=NULL # Clear timeseries
        model_run="hrrr"
        
        # Loop through each subcatchment in SWMM .inp file
        for(sc in unlist(unique(inp$subcatchments$Name))){
          
          ### Interpolate Precipitation time Series
          Precip_IDW[[sc]]=data.frame(forecast.date=unique(HRRR_data()[which(grepl(model_run,HRRR_data()$model.run.date)),"forecast.date"])) # Get Date/Time values from Precipitation Data Frame
          Precip_IDW[[sc]]$Value=as.numeric(lapply(Precip_IDW[[sc]]$forecast.date,idw_function,sc,model_run,interpolate_precip(),"HRRR",HRRR_data(),shp_data())) # Use function to interpolate precipitation time series
          
          ### Convert HRRR Precipitation units (kg/m^2 == mm) to inches of precipitation if SWMM is in US units
          if(SWMM_units()=="US"){
            Precip_IDW[[sc]]$Value=Precip_IDW[[sc]]$Value/25.4
          }
          
          ### Format Precipitation time series
          ts_name=paste0("SC",sc,"_Precip") # Create Name of precipitation time series for subcatchment
          Precip_IDW[[sc]]$Name=ts_name # Get Name
          Precip_IDW[[sc]]$Date=format(Precip_IDW[[sc]]$forecast.date,format="%m/%d/%Y") # Get Date
          Precip_IDW[[sc]]$Time=sub("^\\S+\\s+",'',Precip_IDW[[sc]]$forecast.date) # Get Time
          Precip_IDW[[sc]]=Precip_IDW[[sc]][,c("Name","Date","Time","Value")] # Subset/Rearrange
          
          ### Update SWMM .inp file
          inp$timeseries=rbind(inp$timeseries,Precip_IDW[[sc]]) # Add time series to SWMM .inp file
          gage_name=paste("Subcatchment",sc,sep="_") # Create Name of rain gauge for subcatchment
          inp$raingages=rbind(inp$raingages,c(gage_name,"VOLUME",HRRR_interval,SWMM_SCF(),paste("TIMESERIES",ts_name))) # Add rain gauge to SWMM .inp file
          inp$subcatchments[which(inp$subcatchments$Name==sc),"Rain Gage"]=gage_name # Update catchment rain gauge
        }
        
        ### Write New SWMM .inp
        write_inp(inp,"www/Sim/Model.inp") # Save SWMM .inp file
        add_transects("www/Sim/Model.inp",transects()) # Add transects back into SWMM .inp file
        if(file.exists(gsub(".inp",".ini",inp_path()))){ # Copy and rename settings file if it exists
          file.copy(gsub(".inp",".ini",inp_path()),"www/Sim/Model.ini",overwrite=T) # Copy/Rename file
        }
        
        ### Run SWMM Model
        sim_files=run_swmm(inp="www/Sim/Model.inp")
        
        ### Get names of all SWMM subcatchments, links, and nodes
        swmm_ID=get_out_content(sim_files$out)

        ### Store subcatchment data
        HRRR_SC_Sim_Data[[model_run]]=read_out(sim_files$out,iType=0,object_name=swmm_ID$subcatchments$names,vIndex=as.numeric(sc_vars()))
        
        ### Store node data
        HRRR_Node_Sim_Data[[model_run]]=read_out(sim_files$out,iType=1,object_name=swmm_ID$nodes$names,vIndex=as.numeric(node_vars()))
        
        ### Store link data
        HRRR_Link_Sim_Data[[model_run]]=read_out(sim_files$out,iType=2,object_name=swmm_ID$links$names,vIndex=as.numeric(link_vars()))
        
        incProgress(1) # Increment Progress Bar

      })
      withProgress(message="Reshaping HRRR Data",value=1,{
        
        ### Retrieve/Reshape Data
        HRRR_SC_data=melt(HRRR_SC_Sim_Data)
        colnames(HRRR_SC_data)=c("Value","Variable","ID","Run")
        HRRR_SC_data$Run="hrrr"
        
        HRRR_Node_data=melt(HRRR_Node_Sim_Data)
        colnames(HRRR_Node_data)=c("Value","Variable","ID","Run")
        HRRR_Node_data$Run="hrrr"
        
        HRRR_Link_data=melt(HRRR_Link_Sim_Data)
        colnames(HRRR_Link_data)=c("Value","Variable","ID","Run")
        HRRR_Link_data$Run="hrrr"
        
        ### Add Times to Data
        SWMM_hrrr_times=HRRR_SC_Sim_Data[1][[1]][[1]][[1]] # Get Times from SWMM Data for HRRR simulations
        tzone(SWMM_hrrr_times)="UTC" # Set Time Zone to UTC to match data in SC_data, Node_data, and Link_data
        
        # Convert times from UTC (b/c HRRR data, ANC data, and SWMM model use UTC time) to time zone of watershed (based on location of subcatchment centroids)
        HRRR_SC_data$DateTime=as_datetime(.index(SWMM_hrrr_times),tz=watershed_tz())
        HRRR_Node_data$DateTime=as_datetime(.index(SWMM_hrrr_times),tz=watershed_tz())
        HRRR_Link_data$DateTime=as_datetime(.index(SWMM_hrrr_times),tz=watershed_tz())
        
        ### Save Data to Reactive Values
        HRRR_SC_results(HRRR_SC_data)
        HRRR_Node_results(HRRR_Node_data)
        HRRR_Link_results(HRRR_Link_data)
      })
    }
  })
  
  ##### Retrieve ANC Data & Process if new ANC forecast or user refreshes app -------------------------------------------------
  ANC_data=reactiveVal({
    if(exists("Output_ANC_data")){
      Output_ANC_data
    }
    else{
      NA
    }
  })
  
  # Reactive Values to store NWS coefficients
  a=reactiveVal(a)
  b=reactiveVal(b)
  
  observeEvent(c(anc_model_runs()),{
    # Download ANC data if there is a new forecast available
    if(new_anc()==T){
      
      ### Get NWS a and b coefficients
      # Manual
      if(input$ANC_coefficients==F){
        a(manual_a()^(-1/manual_b())) # Convert from Z-R to R-Z form
        b(1/manual_b()) # Convert from Z-R to R-Z form
      }
      # Auto
      else if(input$ANC_coefficients==T){
        withProgress(message="Retrieving NWS Coefficients",value=0,{
          # Set URL depending on NWS Region
          url=switch(input$nws_region,
                     "Middle Atlantic"="https://www.weather.gov/marfc/ZR_Relationships",
                     "Ohio"="https://www.weather.gov/ohrfc/ZRRelationships",
                     "Lower Mississippi"="https://www.weather.gov/lmrfc/experimental_ZR_relationships")
          
          # Get table HTML from URL
          json=read_html(url)%>% 
            html_nodes(css='td')%>%.[1]
          
          # Remove HTML Tags
          json=sub('<td id="json">',"",json)
          json=sub("\n</td>","",json)
          
          # Read JSON data
          data=fromJSON(json)
          
          # Format Table
          table=as.data.frame(data$zrData)

          # Get a and b from table
          a=table[which(table$id==NWS_id()),"zrCoef"]
          b=table[which(table$id==NWS_id()),"zrExp"]
          
          # Convert a and b from Z-R form to R-Z form
          a(as.numeric(a)^(-1/as.numeric(b)))
          b(1/as.numeric(b))

          Sys.sleep(1) # Pause for a bit so you can see message
          
          incProgress(1)
        })
      }
      
      ### Delete Existing Files
      file.remove(list.files("www/Gribs/ANC",full.names=T))
      
      ### Set ANC buffer domain; ANC grid has 0.01 degree spacing, so round subcatchment boundary up/down to nearest 0.01 degree
      anc_domain=c(round_any(swmm_lon_min(),0.01,f=floor), # Left Lon
                   round_any(swmm_lon_max(),0.01,f=ceiling), # Right Lon
                   round_any(swmm_lat_max(),0.01,f=ceiling), # North Lat
                   round_any(swmm_lat_min(),0.01,f=floor)) # South Lat

      ### Download Grib files for ANC forecasts
      ANC_filenames=paste0("www/Gribs/ANC/",anc_model_runs())
      
      anc_model_count=1
      withProgress(message="Retrieving ANC Forecast",value=0,{
      for(ANC_filename in ANC_filenames){
        # Download Grib
        download.file(url=paste0("https://mrms.ncep.noaa.gov/data/2D/ANC/MRMS_ANC_FinalForecast/",anc_model_runs()[anc_model_count]),
                      destfile=ANC_filename)

        # Unzip/Extract Grib
        gunzip(ANC_filename,overwrite=T)

        # Read ANC Grib Data
        data=as.data.frame(ANC_ReadGrib(file.names=gsub(".gz","",ANC_filename),
                                        variables="var discipline=209 center=161 local_table=1 parmcat=13 parm=1",
                                        levels="0-0 m above mean sea level",
                                        forecasts=NULL,   # Get all forecasts
                                        domain=anc_domain, # Lat/Lon of subcatchments
                                        domain.type="latlon",
                                        missing.data=0))  # Set missing values to 0; ANC data doesn't include 0 values, so this adds 0's to ensure that it can be used for interpolation
        # Format data
        data$model.run.date=as.character(data$model.run.date)
        data$forecast.date=as.character(data$forecast.date)

        if(anc_model_count==1){ # Create dataframe from first model run
          ANC_data=data
        }
        else{ # Join data from other model runs to the dataframe
          ANC_data=full_join(ANC_data,data,by=c("model.run.date","forecast.date","variables","levels","lon","lat","value","meta.data","grib.type"))
        }
        anc_model_count=anc_model_count+1 # Add one to model counter
        incProgress(1/length(ANC_filenames)) # Increment Progress Bar
      }
      })
      
      ### Format ANC Dates
      ANC_data$forecast.date=ymd_hms(ANC_data$forecast.date)

      ### Convert ANC Final Forecast values from Decibels of Reflectivity to Precipitation Intensity (mm/h)
      ANC_data[which(ANC_data$value<25),"value"]=0  # Reflectivity values below 25 dBZ assumed to be result of clear-air returns, so set to 0
      ANC_data[which(ANC_data$value>53),"value"]=53 # Apply rain-rate threshold or "hail-cap" because the Z-R power relationship can produce unreasonably high rainfall intensities in the hail cores of thunderstorms. The default threshold value is 53 dBZ (which corresponds to a rainfall intensity of 104 mm h-1) (Fulton et al., 1998).
      ANC_data[which(!ANC_data$value==0),"value"]=a()*((10^(ANC_data[which(!ANC_data$value==0),"value"]/10))^b()) # Convert value from Decibels of Reflectivity to Reflectivity and then to Precipitation Intensity (mm/h)

      ### Clean Up Temporary File
      if(file.exists("my.inv")){
        file.remove("my.inv")
      }
      ANC_data(ANC_data)
      run_swmm_anc(T) # Retrieved new ANC forecast, so run SWMM model
    }
    else{
     run_swmm_anc(F) # No new ANC forecast, so don't run SWMM model
    }
  })
  
  ##### Run SWMM model for each ANC model run ---------------------------------------------------------------------------------------------
  ### Create Reactive Values to Store Results; Default to loaded value or NA if no loaded value
  ANC_SC_results=reactiveVal({
    if(exists("Output_ANC_SC_results")){
      Output_ANC_SC_results
    }
    else{
      NA
    }
  })
  ANC_Node_results=reactiveVal({
    if(exists("Output_ANC_Node_results")){
      Output_ANC_Node_results
    }
    else{
      NA
    }
  })
  ANC_Link_results=reactiveVal({
    if(exists("Output_ANC_Link_results")){
      Output_ANC_Link_results
    }
    else{
      NA
    }
  })
  
  ### Reactive if ANC data changes or user refreshes app
  observeEvent(c(run_swmm_anc()),{
    if(run_swmm_anc()==T){
      withProgress(message="Running SWMM Model for ANC Forecasts",value=0,{
        ### Update SWMM Dates to ANC forecast dates
        inp=inp() # Get SWMM .inp
        ANC_start=sort(ANC_data()$forecast.date)[1]
        ANC_end=ANC_start+3600 # One Hour after ANC start time
        
        start_date=format(ANC_start,format="%m/%d/%Y") # Get Start Date
        inp$options[which(inp$options$Option=="START_DATE"),"Value"]=start_date # Set Start Date
        inp$options[which(inp$options$Option=="REPORT_START_DATE"),"Value"]=start_date # Set Report Start Date
        inp$options[which(inp$options$Option=="SWEEP_START"),"Value"]=sub('/([^/]*)$','',start_date) # Set Sweep Start Date
        
        end_date=format(ANC_end,format="%m/%d/%Y")  # Get End Date
        inp$options[which(inp$options$Option=="END_DATE"),"Value"]=end_date # Set End Date
        inp$options[which(inp$options$Option=="SWEEP_END"),"Value"]=sub('/([^/]*)$','',end_date) # Set Sweep End Date
        
        start_time=sub("^\\S+\\s+",'',ANC_start) # Get Start Time
        inp$options[which(inp$options$Option=="START_TIME"),"Value"]=start_time # Set Start Time
        inp$options[which(inp$options$Option=="REPORT_START_TIME"),"Value"]=start_time # Set Report Start Time
        
        inp$options[which(inp$options$Option=="END_TIME"),"Value"]=sub("^\\S+\\s+",'',ANC_end+60) # Set End Time
        
        inp$options[which(inp$options$Option=="REPORT_STEP"),"Value"]=report_ts() # Set Reporting Time Step
        
        ### Create lists to store data
        ANC_SC_Sim_Data=vector("list")
        ANC_Node_Sim_Data=vector("list")
        ANC_Link_Sim_Data=vector("list")
        
        ### Run SWMM for ANC model
        Precip_IDW=NULL # Create empty list to store precip data
        inp$raingages=NULL # Clear rain gauges
        inp$timeseries=NULL # Clear timeseries
        model_run="anc"
        
        # Loop through each subcatchment in SWMM .inp file
        for(sc in unlist(unique(inp$subcatchments$Name))){

          ### Interpolate Precipitation time Series
          Precip_IDW[[sc]]=data.frame(forecast.date=unique(ANC_data()$forecast.date)) # Get Date/Time values from Precipitation Data Frame
          
          Precip_IDW[[sc]]$Value=as.numeric(lapply(Precip_IDW[[sc]]$forecast.date,idw_function,sc,model_run,interpolate_precip(),"ANC",ANC_data(),shp_data())) # Use function to interpolate precipitation time series
          
          ### Convert ANC Precipitation units (mm/h) to inches/h if SWMM is in imperial units
          if(SWMM_units()=="US"){
            Precip_IDW[[sc]]$Value=Precip_IDW[[sc]]$Value/25.4
          }
  
          ### Add intensity datapoint for end of simulation
          Precip_IDW[[sc]][nrow(Precip_IDW[[sc]])+1,"Value"]=tail(Precip_IDW[[sc]]$Value,n=1)
          Precip_IDW[[sc]][nrow(Precip_IDW[[sc]]),"forecast.date"]=ANC_end
          
          ### Integrate ANC precipitation intensity timeseries to get incremental precipitation volume time series at 10-minute time step b/c ANC not released at a consistent time interval and SWMM requires a constant time step
          integrated=data.frame(forecast.date=seq(ANC_start,ANC_end-600,600),
                                      Value=integrate.xy(x=Precip_IDW[[sc]]$forecast.date,
                                                         fx=Precip_IDW[[sc]]$Value,
                                                         a=as.numeric(seq(ANC_start,ANC_end-600,600)),
                                                         b=as.numeric(seq(ANC_start+600,ANC_end,600)),
                                                         xtol=0)/3600) # set xtol to 0 b/c default value was causing integration to fail; time correction to get volume in units/hour)

          ### The integration can result in funky timeseries when there is little/no rainfall, so set any negative values to zero
          integrated[which(integrated$Value<0),"Value"]=0
          Precip_IDW[[sc]]=integrated

          ### Format Precipitation time series
          ts_name=paste0("SC",sc,"_Precip") # Create Name of precipitation time series for subcatchment
          Precip_IDW[[sc]]$Name=ts_name # Get Name
          Precip_IDW[[sc]]$Date=format(Precip_IDW[[sc]]$forecast.date,format="%m/%d/%Y") # Get Date
          Precip_IDW[[sc]]$Time=sub("^\\S+\\s+",'',Precip_IDW[[sc]]$forecast.date) # Get Time
          Precip_IDW[[sc]]=Precip_IDW[[sc]][,c("Name","Date","Time","Value")] # Subset/Rearrange
  
          ### Update SWMM .inp file
          inp$timeseries=rbind(inp$timeseries,Precip_IDW[[sc]]) # Add time series to SWMM .inp file
          gage_name=paste("Subcatchment",sc,sep="_") # Create Name of rain gauge for subcatchment
          inp$raingages=rbind(inp$raingages,c(gage_name,"VOLUME",ANC_interval,SWMM_SCF(),paste("TIMESERIES",ts_name))) # Add rain gauge to SWMM .inp file
          inp$subcatchments[which(inp$subcatchments$Name==sc),"Rain Gage"]=gage_name # Update catchment rain gauge
          
          incProgress(1/length(unlist(unique(inp$subcatchments$Name)))) # Increment Progress Bar
        }

        ### Write New SWMM .inp
        write_inp(inp,"www/Sim/Model.inp") # Save SWMM .inp file
        add_transects("www/Sim/Model.inp",transects()) # Add transects back into SWMM .inp file
        if(file.exists(gsub(".inp",".ini",inp_path()))){ # Copy and rename settings file if it exists
          file.copy(gsub(".inp",".ini",inp_path()),"www/Sim/Model.ini",overwrite=T) # Copy/Rename file
        }
  
        ### Run SWMM Model
        sim_files=run_swmm(inp="www/Sim/Model.inp")
  
        ### Get names of all SWMM subcatchments, links, and nodes
        swmm_ID=get_out_content(sim_files$out)
  
        ### Store subcatchment data
        ANC_SC_Sim_Data[[model_run]]=read_out(sim_files$out,iType=0,object_name=swmm_ID$subcatchments$names,vIndex=as.numeric(sc_vars()))
  
        ### Store node data
        ANC_Node_Sim_Data[[model_run]]=read_out(sim_files$out,iType=1,object_name=swmm_ID$nodes$names,vIndex=as.numeric(node_vars()))
  
        ### Store link data
        ANC_Link_Sim_Data[[model_run]]=read_out(sim_files$out,iType=2,object_name=swmm_ID$links$names,vIndex=as.numeric(link_vars()))
        
      })
      withProgress(message="Reshaping ANC Data",value=1,{
      
      ### Retrieve/Reshape Data
      ANC_SC_data=melt(ANC_SC_Sim_Data)
      colnames(ANC_SC_data)=c("Value","Variable","ID","Run")
  
      ANC_Node_data=melt(ANC_Node_Sim_Data)
      colnames(ANC_Node_data)=c("Value","Variable","ID","Run")
  
      ANC_Link_data=melt(ANC_Link_Sim_Data)
      colnames(ANC_Link_data)=c("Value","Variable","ID","Run")
  
      ### Add Times to Data
      SWMM_anc_times=ANC_SC_Sim_Data[1][[1]][[1]][[1]] # Get Times from SWMM Data for ANC simulations
      tzone(SWMM_anc_times)="UTC" # Set Time Zone to UTC to match data in SC_data, Node_data, and Link_data
  
      # Convert times from UTC (b/c SREF data, ANC data, and SWMM model use UTC time) to time zone of watershed (based on location of subcatchment centroids)
      ANC_SC_data$DateTime=as_datetime(.index(SWMM_anc_times),tz=watershed_tz())
      ANC_Node_data$DateTime=as_datetime(.index(SWMM_anc_times),tz=watershed_tz())
      ANC_Link_data$DateTime=as_datetime(.index(SWMM_anc_times),tz=watershed_tz())
  
      ### Save Data to Reactive Values
      ANC_SC_results(ANC_SC_data)
      ANC_Node_results(ANC_Node_data)
      ANC_Link_results(ANC_Link_data)
      })
    }
  })
  
  ##### Retrieve HREF Data & Process if new HREF forecast or user refreshes app -------------------------------------------------
  HREF_data=reactiveVal({
    if(exists("Output_HREF_data")){
      Output_HREF_data
    }
    else{
      NA
    }
  })
  
  observeEvent(c(href_url(),
   href_model_runs()),{
     # Download HREF data if there is a new forecast available
     if(new_href()==T){
       withProgress(message="Retrieving HREF Forecast",value=0,{
         ### Delete Existing Files
         file.remove(list.files("www/Gribs/HREF",full.names=T))
         
         ### Subset HREF points to subcatchment domain + buffer distance
         points=href_points[which(href_points$lat<=swmm_lat_max()+href_buffer_dist&
                                         href_points$lat>=swmm_lat_min()-href_buffer_dist&
                                         href_points$lon<=swmm_lon_max_hrrr()+href_buffer_dist&
                                         href_points$lon>=swmm_lon_min_hrrr()-href_buffer_dist
         ),]
         
         ### Calculate distance in meters from subset HREF points to subcatchment
         distance=geosphere::dist2Line(p=SpatialPoints(data.frame(lon=points$lon,lat=points$lat),proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs")), # Convert HREF points to spatial
                                       line=subcatchments_shp()) # Subcatchment shapefile
         
         ### Rename columns
         colnames(distance)=c("distance_m","distance_lon","distance_lat","ID")
         
         ### Add distances to HREF points dataframe
         points=cbind(points,distance)

         ### Subset to only get points within search distance # of grid cell distances away to ensure that watershed is surrounded
         points=points[which(points$distance_m<=(href_search_dist*href_grid_size*1000)),]
         
         ### Define domain used to extract data from HREF Grib files
         href_domain=c(min(points$lon), # Left Lon
                       max(points$lon), # Right Lon
                       max(points$lat), # North Lat
                       min(points$lat)) # South Lat
         
         ### Plot points, subcatchments, and distances
         graphics::plot(points$lon,points$lat,col="red")
         intervals::plot(spTransform(subcatchments_shp(),CRS("+proj=longlat +datum=WGS84 +no_defs")),add=T)
         
         for (i in 1:nrow(points)) {
           graphics::arrows(x0 = points[i,2],
                  y0 = points[i,3],
                  x1 = points[i,5],
                  y1 = points[i,6],
                  length = 0.1,
                  col = "green")
         }
         
         ### Download Grib files for HREF forecasts
         HREF_filenames=paste0("www/Gribs/HREF/",href_model_runs())
         
         ### Subset Data
         HREF_variables=c("APCP") # Specify variables; wgrib2 command -var
         HREF_levels=c("surface") # Specify level of atmosphere; wgrib2 command -lev
         
         href_model_count=1
         for(HREF_filename in HREF_filenames){
           # Download Grib
           download.file(url=paste0(href_url(),href_model_runs()[href_model_count]),
                         destfile=HREF_filename,
                         method="curl")
           
           # Read HREF Grib Data
           data=as.data.frame(ReadGrib(file.names=HREF_filename,
                                       variables=HREF_variables,
                                       levels=HREF_levels,
                                       forecasts=NULL,     # Get all forecasts
                                       domain=href_domain,   # Lat/Lon of subcatchments
                                       domain.type="latlon",
                                       missing.data=NULL)) # HREF includes 0 values, so don't need to add 0's; removes any missing data from dataset
  
           # Format data
           data$model.run.date=as.character(data$model.run.date)
           data$forecast.date=as.character(data$forecast.date)
  
           if(href_model_count==1){ # Create dataframe from first model run
             HREF_data=data
           }
           else{ # Join data from other model runs to the dataframe
             HREF_data=full_join(HREF_data,data,by=c("model.run.date","forecast.date","variables","levels","lon","lat","value","meta.data","grib.type"))
           }
           href_model_count=href_model_count+1 # Add one to model counter
           incProgress(1/length(HREF_filenames)) # Increment Progress Bar
         }
       })
       
       ### Format HREF Dates
       HREF_data$forecast.date=ymd_hms(HREF_data$forecast.date)
       
       ### Clean Up Temporary File
       if(file.exists("my.inv")){
         file.remove("my.inv")
       }
       
       HREF_data(HREF_data)
       run_swmm_href(T) # Retrieved new HREF forecast, so run SWMM model
     }
     else{
       run_swmm_href(F) # No new HREF forecast, so don't run SWMM model         
     }
  })
  
  ##### Run SWMM model for each HREF model run ---------------------------------------------------------------------------------------------
  ### Create Reactive Values to Store Results; Default to loaded value or NA if no loaded value
  HREF_SC_results=reactiveVal({
    if(exists("Output_HREF_SC_results")){
      Output_HREF_SC_results
    }
    else{
      NA
    }
  })
  HREF_Node_results=reactiveVal({
    if(exists("Output_HREF_Node_results")){
      Output_HREF_Node_results
    }
    else{
      NA
    }
  })
  HREF_Link_results=reactiveVal({
    if(exists("Output_HREF_Link_results")){
      Output_HREF_Link_results
    }
    else{
      NA
    }
  })
  
  ### Reactive if HREF data changes or user refreshes app
  observeEvent(c(run_swmm_href()),{
    if(run_swmm_href()==T){
      withProgress(message="Running SWMM Model for HREF Forecasts",value=0,{
        inp=inp() # Get SWMM .inp
        HREF_start=sort(HREF_data()$forecast.date)[1]
        HREF_end=sort(HREF_data()$forecast.date,decreasing=T)[1]
        
        start_date=format(HREF_start,format="%m/%d/%Y") # Get Start Date
        inp$options[which(inp$options$Option=="START_DATE"),"Value"]=start_date # Set Start Date
        inp$options[which(inp$options$Option=="REPORT_START_DATE"),"Value"]=start_date # Set Report Start Date
        inp$options[which(inp$options$Option=="SWEEP_START"),"Value"]=sub('/([^/]*)$','',start_date) # Set Sweep Start Date
        
        end_date=format(HREF_end,format="%m/%d/%Y")  # Get End Date
        inp$options[which(inp$options$Option=="END_DATE"),"Value"]=end_date # Set End Date
        inp$options[which(inp$options$Option=="SWEEP_END"),"Value"]=sub('/([^/]*)$','',end_date) # Set Sweep End Date
        
        start_time=sub("^\\S+\\s+",'',HREF_start) # Get Start Time
        inp$options[which(inp$options$Option=="START_TIME"),"Value"]=start_time # Set Start Time
        inp$options[which(inp$options$Option=="REPORT_START_TIME"),"Value"]=start_time # Set Report Start Time
        
        inp$options[which(inp$options$Option=="END_TIME"),"Value"]=sub("^\\S+\\s+",'',HREF_end+60) # Set End Time
        
        inp$options[which(inp$options$Option=="REPORT_STEP"),"Value"]=report_ts() # Set Reporting Time Step
        
        ### Create lists to store data
        HREF_SC_Sim_Data=vector("list")
        HREF_Node_Sim_Data=vector("list")
        HREF_Link_Sim_Data=vector("list")
        
        ### Run SWMM for HREF model
        Precip_IDW=NULL # Create empty list to store precip data
        inp$raingages=NULL # Clear rain gauges
        inp$timeseries=NULL # Clear timeseries
        model_run="href"
        
        # Loop through each subcatchment in SWMM .inp file
        for(sc in unlist(unique(inp$subcatchments$Name))){

          ### Interpolate Precipitation time Series
          Precip_IDW[[sc]]=data.frame(forecast.date=unique(HREF_data()$forecast.date)) # Get Date/Time values from Precipitation Data Frame
          Precip_IDW[[sc]]$Value=as.numeric(lapply(Precip_IDW[[sc]]$forecast.date,idw_function,sc,model_run,interpolate_precip(),"HREF",HREF_data(),shp_data())) # Use function to interpolate precipitation time series

          ### Convert HREF Precipitation units (kg/m^2 == mm) to inches of precipitation if SWMM is in US units
          if(SWMM_units()=="US"){
            Precip_IDW[[sc]]$Value=Precip_IDW[[sc]]$Value/25.4
          }
          
          ### Format Precipitation time series
          ts_name=paste0("SC",sc,"_Precip") # Create Name of precipitation time series for subcatchment
          Precip_IDW[[sc]]$Name=ts_name # Get Name
          Precip_IDW[[sc]]$Date=format(Precip_IDW[[sc]]$forecast.date,format="%m/%d/%Y") # Get Date
          Precip_IDW[[sc]]$Time=sub("^\\S+\\s+",'',Precip_IDW[[sc]]$forecast.date) # Get Time
          Precip_IDW[[sc]]=Precip_IDW[[sc]][,c("Name","Date","Time","Value")] # Subset/Rearrange
          
          ### Update SWMM .inp file
          inp$timeseries=rbind(inp$timeseries,Precip_IDW[[sc]]) # Add time series to SWMM .inp file
          gage_name=paste("Subcatchment",sc,sep="_") # Create Name of rain gauge for subcatchment
          inp$raingages=rbind(inp$raingages,c(gage_name,"VOLUME",HREF_interval,SWMM_SCF(),paste("TIMESERIES",ts_name))) # Add rain gauge to SWMM .inp file
          inp$subcatchments[which(inp$subcatchments$Name==sc),"Rain Gage"]=gage_name # Update catchment rain gauge
        }
        
        ### Write New SWMM .inp
        write_inp(inp,"www/Sim/Model.inp") # Save SWMM .inp file
        add_transects("www/Sim/Model.inp",transects()) # Add transects back into SWMM .inp file
        if(file.exists(gsub(".inp",".ini",inp_path()))){ # Copy and rename settings file if it exists
          file.copy(gsub(".inp",".ini",inp_path()),"www/Sim/Model.ini",overwrite=T) # Copy/Rename file
        }

        ### Run SWMM Model
        sim_files=run_swmm(inp="www/Sim/Model.inp")

        ### Get names of all SWMM subcatchments, links, and nodes
        swmm_ID=get_out_content(sim_files$out)

        ### Store subcatchment data
        HREF_SC_Sim_Data[[model_run]]=read_out(sim_files$out,iType=0,object_name=swmm_ID$subcatchments$names,vIndex=as.numeric(sc_vars()))

        ### Store node data
        HREF_Node_Sim_Data[[model_run]]=read_out(sim_files$out,iType=1,object_name=swmm_ID$nodes$names,vIndex=as.numeric(node_vars()))

        ### Store link data
        HREF_Link_Sim_Data[[model_run]]=read_out(sim_files$out,iType=2,object_name=swmm_ID$links$names,vIndex=as.numeric(link_vars()))
        
        incProgress(1) # Increment Progress Bar
        
      })
      withProgress(message="Reshaping HREF Data",value=1,{

        ### Retrieve/Reshape Data
        HREF_SC_data=melt(HREF_SC_Sim_Data)
        colnames(HREF_SC_data)=c("Value","Variable","ID","Run")

        HREF_Node_data=melt(HREF_Node_Sim_Data)
        colnames(HREF_Node_data)=c("Value","Variable","ID","Run")

        HREF_Link_data=melt(HREF_Link_Sim_Data)
        colnames(HREF_Link_data)=c("Value","Variable","ID","Run")

        ### Add Times to Data
        SWMM_href_times=HREF_SC_Sim_Data[1][[1]][[1]][[1]] # Get Times from SWMM Data for HREF simulations
        tzone(SWMM_href_times)="UTC" # Set Time Zone to UTC to match data in SC_data, Node_data, and Link_data

        # Convert times from UTC (b/c SREF data, HREF data, and SWMM model use UTC time) to time zone of watershed (based on location of subcatchment centroids)
        HREF_SC_data$DateTime=as_datetime(.index(SWMM_href_times),tz=watershed_tz())
        HREF_Node_data$DateTime=as_datetime(.index(SWMM_href_times),tz=watershed_tz())
        HREF_Link_data$DateTime=as_datetime(.index(SWMM_href_times),tz=watershed_tz())

        ### Save Data to Reactive Values
        HREF_SC_results(HREF_SC_data)
        HREF_Node_results(HREF_Node_data)
        HREF_Link_results(HREF_Link_data)
      })
    }
  })
  
  ##### Join SREF, HRRR, & ANC Data -----------------------------------------------
  SC=reactive({
    bind=c() # Create empty list of datasets to bind
    SC=setNames(data.frame(matrix(ncol=5,nrow=0)),c("ID","Run","Variable","DateTime","Value")) # Create Empty Dataframe
    
    if(all(is.na(SREF_SC_results())==F)){bind=c(bind,"SREF")}
    if(all(is.na(HRRR_SC_results())==F)){bind=c(bind,"HRRR")}
    if(all(is.na(ANC_SC_results())==F)){bind=c(bind,"ANC")}
    if(all(is.na(HREF_SC_results())==F)){bind=c(bind,"HREF")}
    
    if("SREF"%in%bind){SC=bind_rows(SC,SREF_SC_results())}
    if("HRRR"%in%bind){SC=bind_rows(SC,HRRR_SC_results())}
    if("ANC"%in%bind){SC=bind_rows(SC,ANC_SC_results())}
    if("HREF"%in%bind){SC=bind_rows(SC,HREF_SC_results())}

    SC
  })
  
  Link=reactive({
    bind=c() # Create empty list of datasets to bind
    Link=setNames(data.frame(matrix(ncol=5,nrow=0)),c("ID","Run","Variable","DateTime","Value")) # Create Empty Dataframe
    
    if(all(is.na(SREF_Link_results())==F)){bind=c(bind,"SREF")}
    if(all(is.na(HRRR_Link_results())==F)){bind=c(bind,"HRRR")}
    if(all(is.na(ANC_Link_results())==F)){bind=c(bind,"ANC")}
    if(all(is.na(HREF_Link_results())==F)){bind=c(bind,"HREF")}
    
    if("SREF"%in%bind){Link=bind_rows(Link,SREF_Link_results())}
    if("HRRR"%in%bind){Link=bind_rows(Link,HRRR_Link_results())}
    if("ANC"%in%bind){Link=bind_rows(Link,ANC_Link_results())}
    if("HREF"%in%bind){Link=bind_rows(Link,HREF_Link_results())}
    
    Link
  })
  
  Node=reactive({
    bind=c() # Create empty list of datasets to bind
    Node=setNames(data.frame(matrix(ncol=5,nrow=0)),c("ID","Run","Variable","DateTime","Value")) # Create Empty Dataframe
    
    if(all(is.na(SREF_Node_results())==F)){bind=c(bind,"SREF")}
    if(all(is.na(HRRR_Node_results())==F)){bind=c(bind,"HRRR")}
    if(all(is.na(ANC_Node_results())==F)){bind=c(bind,"ANC")}
    if(all(is.na(HREF_Node_results())==F)){bind=c(bind,"HREF")}
    
    if("SREF"%in%bind){Node=bind_rows(Node,SREF_Node_results())}
    if("HRRR"%in%bind){Node=bind_rows(Node,HRRR_Node_results())}
    if("ANC"%in%bind){Node=bind_rows(Node,ANC_Node_results())}
    if("HREF"%in%bind){Node=bind_rows(Node,HREF_Node_results())}
    
    Node
  })

  ###### Plot Data ---------------------------------------------------------
  ### Create Keys
  sc_key=vector(mode="list",length=8)
  names(sc_key)=c("0","1","2","3","4","5","6","7")
  sc_key[["0"]]="Rainfall Rate";sc_key[["1"]]="Snow Depth";sc_key[["2"]]="Evaporation Loss";sc_key[["3"]]="Infiltration Loss";sc_key[["4"]]="Runoff Flow"
  sc_key[["5"]]="Groundwater Flow Into Drainage Network";sc_key[["6"]]="Groundwater Elevation";sc_key[["7"]]="Soil Moisture in Unsaturated Groundwater Zone"

  sc_var_key=vector(mode="list",length=8)
  names(sc_var_key)=c("Rainfall Rate","Snow Depth","Evaporation Loss","Infiltration Loss","Runoff Flow","Groundwater Flow Into Drainage Network","Groundwater Elevation","Soil Moisture in Unsaturated Groundwater Zone")
  sc_var_key[["Rainfall Rate"]]="rainfall_rate";sc_var_key[["Snow Depth"]]="snow_depth";sc_var_key[["Evaporation Loss"]]="evaporation_loss";sc_var_key[["Infiltration Loss"]]="infiltration_loss"
  sc_var_key[["Runoff Flow"]]="runoff_flow";sc_var_key[["Groundwater Flow Into Drainage Network"]]="groundwater_flow_into_the_drainage_network";sc_var_key[["Groundwater Elevation"]]="groundwater_elevation";sc_var_key[["Soil Moisture in Unsaturated Groundwater Zone"]]="soil_moisture_in_the_unsaturated_groundwater_zone"

  link_key=vector(mode="list",length=5)
  names(link_key)=c("0","1","2","3","4")
  link_key[["0"]]="Flow Rate";link_key[["1"]]="Average Water Depth";link_key[["2"]]="Flow Velocity";link_key[["3"]]="Volume of Water";link_key[["4"]]="Capacity"

  link_var_key=vector(mode="list",length=5)
  names(link_var_key)=c("Flow Rate","Average Water Depth","Flow Velocity","Volume of Water","Capacity")
  link_var_key[["Flow Rate"]]="flow_rate";link_var_key[["Average Water Depth"]]="average_water_depth";link_var_key[["Flow Velocity"]]="flow_velocity";link_var_key[["Volume of Water"]]="volume_of_water";link_var_key[["Capacity"]]="capacity"

  node_key=vector(mode="list",length=6)
  names(node_key)=c("0","1","2","3","4","5")
  node_key[["0"]]="Water Depth";node_key[["1"]]="Hydraulic Head";node_key[["2"]]="Stored Water Volume";node_key[["3"]]="Lateral Inflow";node_key[["4"]]="Total Inflow";node_key[["5"]]="Surface Flooding"

  node_var_key=vector(mode="list",length=6)
  names(node_var_key)=c("Water Depth","Hydraulic Head","Stored Water Volume","Lateral Inflow","Total Inflow","Surface Flooding")
  node_var_key[["Water Depth"]]="water_depth";node_var_key[["Hydraulic Head"]]="hydraulic_head";node_var_key[["Stored Water Volume"]]="stored_water_volume"
  node_var_key[["Lateral Inflow"]]="lateral_inflow";node_var_key[["Total Inflow"]]="total_inflow";node_var_key[["Surface Flooding"]]="surface_flooding"
  
  ### Create Reactive List of Parameters Simulated for Selected SWMM Object Type
  sc_var_choices=reactive({
    simulated=unique(SC()$Variable) # Get Variables that have been simulated
    selected=unlist(sc_key[as.character(sc_vars())],use.names=F) # Get Variables that have been selected
    selected_converted=unlist(sc_var_key[as.character(selected)],use.names=F) # Convert selected variables to same form as simulated to compare
    selected[which(selected_converted%in%simulated)]
  })
  
  link_var_choices=reactive({
    simulated=unique(Link()$Variable) # Get Variables that have been simulated
    selected=unlist(link_key[as.character(link_vars())],use.names=F) # Get Variables that have been selected
    selected_converted=unlist(link_var_key[as.character(selected)],use.names=F) # Convert selected variables to same form as simulated to compare
    selected[which(selected_converted%in%simulated)]
    
  })
  
  node_var_choices=reactive({
    simulated=unique(Node()$Variable) # Get Variables that have been simulated
    selected=unlist(node_key[as.character(node_vars())],use.names=F) # Get Variables that have been selected
    selected_converted=unlist(node_var_key[as.character(selected)],use.names=F) # Convert selected variables to same form as simulated to compare
    selected[which(selected_converted%in%simulated)]
  })
  
  ### Create Reactive List of IDs for Selected SWMM Object Type
  ID_choices=reactive({
    switch(input$swmm_object_type,
           "Subcatchment"=unique(SC()$ID),
           "Link"=unique(Link()$ID),
           "Node"=unique(Node()$ID)
    )
  })
  
  ### Create Reactive User Inputs
  output$plot_id=renderUI(div(id="id",class="last_input",selectInput("ID","ID:",choices=ID_choices(),selected=map_id())))
  output$plot_vars_sc=renderUI(div(id="var",class="last_input",selectInput('Variable_sc',label="Subcatchment Parameter",choices=sc_var_choices())))
  output$plot_vars_link=renderUI(div(id="var",class="last_input",selectInput('Variable_link',label="Link Parameter",choices=link_var_choices())))
  output$plot_vars_node=renderUI(div(id="var",class="last_input",selectInput('Variable_node',label="Node Parameter",choices=node_var_choices())))
  
  ### Reactive Values to Store Plot Information
  map_type=reactiveVal()
  map_var=reactiveVal()
  map_id=reactiveVal()
  
  # Initialize Reactive Values on App Load
  observe({
    map_type("Subcatchment")
    map_var(unlist(sc_key[as.character(sc_vars())],use.names=F)[1])
    map_id(if(!all(is.na(SC()))){unique(SC()$ID)[1]})
  })
  
  ### Update Plot Information
  observe({
    # Map and/or Dropdown Menu have been clicked
    if(length(input$last_click)>0){
      
      # Update from Click on Map
      if(input$last_click=="map_plot"){
        if(length(input$map_shape_click)>0){ # Clicked on Something
          click=unlist(input$map_shape_click)[1]
          type=gsub("_.*$","",click)
          map_type(type)
          if(type=="Subcatchment"){
            map_var(input$Variable_sc)
          } else if(type=="Link"){
            map_var(input$Variable_link)
          } else if(type=="Node"){
            map_var(input$Variable_node)
          }
          map_id(gsub("^[^_]*_","",click))
          
          # Update Dropdowns
          updateSelectInput(session,"swmm_object_type",
                            selected=map_type())
          updateSelectInput(session,"ID",
                            selected=map_id())
        }
      }
      # Update from Type Dropdown Menu
      else if(input$last_click=="type"){
        if(input$swmm_object_type!=map_type()){ # Don't do anything if user hasn't changed type yet
          map_type(input$swmm_object_type)
          if(input$swmm_object_type=="Subcatchment"){
            map_var(input$Variable_sc)
            map_id(unique(SC()$ID)[1])
          } else if(input$swmm_object_type=="Link"){
            map_var(input$Variable_link)
            map_id(unique(Link()$ID)[1])
          } else if(input$swmm_object_type=="Node"){
            map_var(input$Variable_node)
            map_id(unique(Node()$ID)[1])
          }
        }
      }
      # Update from Variable Dropdown Menu
      else if(input$last_click=="var"){
        if(input$swmm_object_type=="Subcatchment"){
          map_var(input$Variable_sc)
        } else if(input$swmm_object_type=="Link"){
          map_var(input$Variable_link)
        } else if(input$swmm_object_type=="Node"){
          map_var(input$Variable_node)
        }
      }
      # Update from ID Dropdown Menu
      else if(input$last_click=="id"){
        map_id(input$ID)
      }
    }
  })
  
  ### Reactive Units for Plot Y-axis
  format_units=function(variable){
    if(!is.na(SWMM_units())){
      if(SWMM_units()=="US"){
        if(variable%in%c("Rainfall Rate","Infiltration Loss")){
          plot_units="in/hr"
        }
        else if(variable%in%c("Snow Depth")){
          plot_units="in"
        }
        else if(variable%in%c("Evaporation Loss")){
          plot_units="in/day"
        }
        else if(variable%in%c("Runoff Flow","Groundwater Flow Into Drainage Network","Flow Rate")){
          plot_units=inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"]
        }
        else if(variable%in%c("Groundwater Elevation","Average Water Depth")){
          plot_units="ft"
        }
        else if(variable%in%c("Soil Moisture in Unsaturated Groundwater Zone")){
          plot_units="Volume Fraction"
        }
        else if(variable%in%c("Flow Velocity")){
          plot_units="ft/s"
        }
        else if(variable%in%c("Volume of Water")){
          plot_units="ft^3"
        }
        else if(variable%in%c("Capacity")){
          plot_units="Fraction of Full Area"
        }
        else if(variable%in%c("Water Depth")){
          plot_units="ft above node invert elevation"
        }
        else if(variable%in%c("Hydraulic Head")){
          plot_units="ft, absolute elevation per vertical datum"
        }
        else if(variable%in%c("Stored Water Volume")){
          plot_units="ft^3, including ponded water"
        }
        else if(variable%in%c("Lateral Inflow")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", runoff + all other external inflows")
        }
        else if(variable%in%c("Total Inflow")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", lateral inflow + all other external inflows")
        }
        else if(variable%in%c("Surface Flooding")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", excess overflow when node is at full depth")
        }
      }
      else if(SWMM_units()=="SI"){
        if(variable%in%c("Rainfall Rate","Infiltration Loss")){
          plot_units="mm/hr"
        }
        else if(variable%in%c("Snow Depth")){
          plot_units="mm"
        }
        else if(variable%in%c("Evaporation Loss")){
          plot_units="mm/day"
        }
        else if(variable%in%c("Runoff Flow","Groundwater Flow Into Drainage Network","Flow Rate")){
          plot_units=inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"]
        }
        else if(variable%in%c("Groundwater Elevation","Average Water Depth")){
          plot_units="m"
        }
        else if(variable%in%c("Soil Moisture in Unsaturated Groundwater Zone")){
          plot_units="Volume Fraction"
        }
        else if(variable%in%c("Flow Velocity")){
          plot_units="m/s"
        }
        else if(variable%in%c("Volume of Water")){
          plot_units="m^3"
        }
        else if(variable%in%c("Capacity")){
          plot_units="Fraction of Full Area"
        }
        else if(variable%in%c("Water Depth")){
          plot_units="m above node invert elevation"
        }
        else if(variable%in%c("Hydraulic Head")){
          plot_units="m, absolute elevation per vertical datum"
        }
        else if(variable%in%c("Stored Water Volume")){
          plot_units="m^3, including ponded water"
        }
        else if(variable%in%c("Lateral Inflow")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", runoff + all other external inflows")
        }
        else if(variable%in%c("Total Inflow")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", lateral inflow + all other external inflows")
        }
        else if(variable%in%c("Surface Flooding")){
          plot_units=paste0(inp()$options[which(inp()$options$Option=="FLOW_UNITS"),"Value"],", excess overflow when node is at full depth")
        }
      }
    } else{
      plot_units="" # No SWMM Model Uploaded
    }
  }
  
  plot_units=eventReactive(map_var(),{
    format_units(map_var())
  })
  
  ### Retrieve/Subset Data by Variable - split subsetting into multiple reactives so it doesn't have to subset multiple times
  plot_data_var=eventReactive(c(map_var(),
                                SC(),
                                Link(),
                                Node()),{
    plot_data=switch(map_type(),
                     "Subcatchment"=subset(SC(),SC()$Variable==unlist(sc_var_key[map_var()],use.names=F)),
                     "Link"=subset(Link(),Link()$Variable==unlist(link_var_key[map_var()],use.names=F)),
                     "Node"=subset(Node(),Node()$Variable==unlist(node_var_key[map_var()],use.names=F))
    )
  })
  
  ### Retrieve/Subset Data by ID
  plot_data_id=reactive({
    req(plot_forecasts())
    plot_data=subset(plot_data_var(),plot_data_var()$ID==toString(map_id()),use.names=F)
    
    # Subset to only forecasts selected with checkboxes
    if(nrow(plot_data)>0){
      plot_data=plot_data[which(apply(sapply(plot_forecasts(),grepl,plot_data$Run),1,any)==T),]
    }
    plot_data
  })
  
  ### Generate Plot
  plot=eventReactive(c(plot_data_id(),
                       refresh_plot()), {

    # Get Data
    plot_data=plot_data_id()

    # Convert "Run" to factor and set display order
    plot_data=plot_data%>%mutate(Run=factor(Run),
                                 Run=factor(Run,levels=c(setdiff(unique(plot_data$Run),c("href","hrrr","anc")),"href","hrrr","anc")))

    # Create list of breaks for legend
    breaks=c("anc","hrrr","href",grep("sref",levels(plot_data$Run),value=T)[1])
    
    # Generate Colors, but specify colors for HREF, HRRR, and ANC
    adj_names=sort(setdiff(unique(plot_data$Run),c("href","hrrr","anc")))
    colors=colorRampPalette(c("#2193b0","#6dd5ed"))
    colors=colors(length(adj_names))
    names(colors)=adj_names
    colors=c(colors,c(anc="#ff1f0f",hrrr="#F0AD4E",href="#008a29"))

    # Generate Sizes, but have HREF, HRRR, and ANC be thicker
    sizes=rep(0.1,length(adj_names))
    names(sizes)=adj_names
    sizes=c(sizes,c("anc"=1.25,"hrrr"=1.25,"href"=1.25))
    
    # Plot
    Plot=ggplot(data=plot_data,aes(x=DateTime,y=Value,color=Run,size=Run))+
      geom_line()+
      scale_color_manual(name="Forecast:",breaks=breaks,labels=c("ANC","HRRR","HREF","SREF"),values=colors)+
      scale_size_manual(name="Forecast:",breaks=breaks,labels=c("ANC","HRRR","HREF","SREF"),values=sizes)+
      ggtitle(paste(map_type(),map_id(),map_var()))+
      labs(x=paste0("Date/Time","\n(",watershed_tz(),")"),y=str_wrap(paste0(map_var()," (",plot_units(),")"),width=35))+ # Wrap long y-axis labels
      theme(legend.position="left",
            legend.title=element_text(size=12,face="bold"),
            legend.text=element_text(size=12),
            plot.title=element_text(hjust=0.5,face="bold"))
    
    if(nrow(plot_data)>0){
      Plot=Plot+ylim(0,roundToNice(max(plot_data$Value,na.rm=T)))
    }

    Plot
  })

  output$plot=renderPlot(plot())

  ##### Plot Hover Info; Adapted from https://gitlab.com/snippets/16220 ----------------------------------------------------
  output$hover_info=renderUI({
    # Get Point from Hover
    hover=input$plot_hover

    if(nrow(plot_data_id())>0){
      # Get all points near cursor
      point=nearPoints(plot_data_id(),hover,threshold=5,addDist=T)
      
      # Format Model Run
      req(point$Run)
      
      # If multiple points, then display ANC hover tip first
      if("anc"%in%point$Run){
        point=point[which(point$Run=="anc"),] # Get all ANC points
        point=point[which.min(point$dist_),] # Get closest point to cursor
      }
      # Then display HRRR hover tip second
      else if("hrrr"%in%point$Run){
        point=point[which(point$Run=="hrrr"),] # Get all ANC points
        point=point[which.min(point$dist_),] # Get closest point to cursor
      }
      # Then display HREF hover tip third
      else if("href"%in%point$Run){
        point=point[which(point$Run=="href"),] # Get all ANC points
        point=point[which.min(point$dist_),] # Get closest point to cursor
      }
      # Otherwise display closest point
      else{
        point=point[which.min(point$dist_),] # Get closest point to cursor
      }
      
      model_run=point$Run
      
      # For ANC
      if(grepl("anc",model_run)==T){
        model_run="ANC"
      }
      # For SREF
      else if(grepl("sref",model_run)==T){
        split=strsplit(model_run,"_")[[1]] # Split string by underscore
        model_run=paste("SREF",toupper(paste(split[3],split[4],sep="_")))
      }
      # For HRRR
      else if(grepl("hrrr",model_run)==T){
        model_run="HRRR"
      }
      # For HREF
      else if(grepl("href",model_run)==T){
        model_run="HREF PMMN"
      }
      
      if(nrow(point)==0)return(NULL)
      
      # Calculate cursor position INSIDE the plot as percent of total dimensions; from left (horizontal) and from top (vertical)
      left_pct=(hover$x-hover$domain$left)/(hover$domain$right-hover$domain$left)
      top_pct=(hover$domain$top-hover$y)/(hover$domain$top-hover$domain$bottom)
      
      # Calculate distance from left and bottom side of the plot in pixels
      left_px=hover$range$left+left_pct*(hover$range$right-hover$range$left)
      top_px=hover$range$top+top_pct*(hover$range$bottom-hover$range$top)
      
      # Get/Format Plot Units for tooltip
      units=plot_units()
      if(units%in%c("Volume Fraction","Fraction of Full Area")){units=""}
      else if(units%in%c("ft above node invert elevation","ft, absolute elevation per vertical datum")){units="ft"}
      else if(units%in%c("ft^3, including ponded water")){units="ft^3"}
      else if(units%in%c("m above node invert elevation","m, absolute elevation per vertical datum")){units="m"}
      else if(units%in%c("m^3, including ponded water")){units="m^3"}
      else if(any(grep("runoff +",units),grep("lateral inflow +",units),grep("excess overflow",units))==T){units=gsub("(.*),.*", "\\1", units)}
      
      # Set height of Tooltip based on length of variable name; if length of name + units is 24 characters or greater, then need two lines of text
      if(nchar(map_var())+nchar(units)>=24){
        height=120 # Need two lines of text
      } else{ 
        height=100 # Only need one line of text
      }
      
      # Set Width
      width=260
      
      # Set offsets of tooltip from cursor depending on quadrant
      if(left_pct<=0.5){ # Cursor on left half of plot
        left_offset=2
      } else{ # Cursor on right half of plot
        left_offset=(-1*(width+2))
      }
      if(top_pct<=0.5){ # Cursor on top half of plot
        top_offset=(2)
      } else{ # Cursor on bottom half of plot
        top_offset=(-1*(height+2))
      }
      
      # Create Style Property for tooltip; background color set so tooltip is a bit transparent; z-index set so tooltip will be on top
      style=paste0("position:absolute;z-index:100;background-color:rgba(245,245,245,0.85);",
                   "left:",left_px+left_offset,"px;top:",top_px+top_offset,"px;width:",width,"px;height:",height,"px;") # Set Width and Height so tooltip is always the same size
      
      # Actual tooltip created as wellPanel
      wellPanel(
        style=style,
        p(HTML(paste0("<b> Forecast Model: </b>",model_run,"<br/>",
                      "<b> Date/Time: </b>", format(point$DateTime,"%m/%d %H:%M"), "<br/>",
                      paste0("<b>",map_var(),": ","</b>",round(point$Value,2)," ",units,"<br/>"))))
      )
    }
  })
  
  ##### Create BoxPlot of SREF Maximums ------------------------------------
  
  ### Boxplot
  boxplot_data=reactive({
    data=plot_data_id()%>%
      group_by(Run)%>%
      summarise(Max=max(Value))
    data
  })
  
  ### Boxplot Hover Info
  boxplot=reactive({
    Plot=ggplot()

    if(nrow(boxplot_data())>0){
      # Add data to plot based on forecasts that are selected with checkboxes: SREF Boxplot, SREF Peak, HREF Peak, HRRR Peak, ANC Peak
      if("sref"%in%plot_forecasts()){Plot=Plot+geom_boxplot(data=boxplot_data()[which(grepl("sref",boxplot_data()$Run)),],aes(y=Max),notch=F,outlier.color="black",outlier.size=1.5)}
      if("sref"%in%plot_forecasts()){Plot=Plot+geom_point(data=boxplot_data()[which(grepl("sref",boxplot_data()$Run)),][which.max(unlist(boxplot_data()[which(grepl("sref",boxplot_data()$Run)),"Max"])),],aes(x=(0),y=Max),color="#17a2b8",size=3.5,shape=4,stroke=1.5)}
      if("href"%in%plot_forecasts()){Plot=Plot+geom_point(data=boxplot_data()[which(grepl("href",boxplot_data()$Run)),],aes(x=(0.2),y=Max),color="#008a29",size=3.5,shape=4,stroke=1.5)}
      if("hrrr"%in%plot_forecasts()){Plot=Plot+geom_point(data=boxplot_data()[which(grepl("hrrr",boxplot_data()$Run)),],aes(x=(0),y=Max),color="#F0AD4E",size=3.5,shape=4,stroke=1.5)}
      if("anc"%in%plot_forecasts()){Plot=Plot+geom_point(data=boxplot_data()[which(grepl("anc",boxplot_data()$Run)),],aes(x=(-0.2),y=Max),color="#ff1f0f",size=3.5,shape=4,stroke=1.5)}
      
      Plot=Plot+
        ylim(0,roundToNice(max(boxplot_data()$Max,na.rm=T)))
    }
    Plot=Plot+
      ggtitle("Forecast Run Peaks")+
      labs(x=paste(map_type(),map_id(),"\n",map_var()),y=str_wrap(paste0("Peak ",map_var()," (",plot_units(),")"),width=35))+ # Wrap long y-axis labels
      theme(panel.grid.major.x=element_blank(), # Hide Vertical Grid Lines
            panel.grid.minor.x=element_blank(), # Hide Vertical Grid Lines
            axis.text.x=element_text(color="white"), # Set X-axis labels color to white to hide them while maintaining spacing so plot and boxplot align
            axis.ticks.x=element_blank(), # Hide X-axis tick marks
            legend.position="none",
            legend.text=element_text(size=6),
            plot.title=element_text(hjust=0.5,face="bold"))
    Plot
  })
  
  output$boxplot=renderPlot(boxplot())
  
  ### Boxplot Hover Info
  output$boxplot_hover_info=renderUI({

    # Create Empty Dataframe
    plot_data=setNames(data.frame(matrix(ncol=7,nrow=0)),c("Y","X","Name","Label","Label2","Label_Value","Run"))
    
    # Add correction to grab boxplot data if SREF forecast is displayed because there are two separate ggplot parts for sref (boxplot and maximum)
    if("sref"%in%plot_forecasts()){
      correction=1
    } else{
      correction=0
    }

    ### ANC Data
    if("anc"%in%plot_forecasts()){
      anc=ggplot_build(boxplot())$data[[which(rev(plot_forecasts())=="anc")+correction]]
      anc=anc[,c("y","x")]
      colnames(anc)=c("Y","X")
      anc$Name="ymax"
      anc$Label="ANC Maximum:"
      anc$Label2=NA
      anc$Label_Value=sprintf("%.2f",round(anc$Y,2))
      anc$Run="ANC"
      plot_data=bind_rows(plot_data,anc) # Bind Data
    }


    ### HRRR Data
    if("hrrr"%in%plot_forecasts()){
      hrrr=ggplot_build(boxplot())$data[[which(rev(plot_forecasts())=="hrrr")+correction]]
      hrrr=hrrr[,c("y","x")]
      colnames(hrrr)=c("Y","X")
      hrrr$Name="ymax"
      hrrr$Label="HRRR Maximum:"
      hrrr$Label2=NA
      hrrr$Label_Value=sprintf("%.2f",round(hrrr$Y,2))
      hrrr$Run="HRRR"
      plot_data=bind_rows(plot_data,hrrr) # Bind Data
    }


    ### HREF Data
    if("href"%in%plot_forecasts()){
      href=ggplot_build(boxplot())$data[[which(rev(plot_forecasts())=="href")+correction]]
      href=href[,c("y","x")]
      colnames(href)=c("Y","X")
      href$Name="ymax"
      href$Label="HREF Maximum:"
      href$Label2=NA
      href$Label_Value=sprintf("%.2f",round(href$Y,2))
      href$Run="HREF"
      plot_data=bind_rows(plot_data,href) # Bind Data
    }

    ### SREF Data Boxplot
    if("sref"%in%plot_forecasts()){
      sref=ggplot_build(boxplot())$data[[which(rev(plot_forecasts())=="sref")]]

      x=unlist(sref[,c("x","xmin","xmax")])
      y=unlist(sref[,c("ymin","lower","middle","upper","ymax","outliers")])

      # Reshape Data to have all combinations of x, xmin, xmax and the y-variables; used so that user can hover over edges of box
      sref_reshaped=expand.grid(y,x)
      sref_reshaped$Name=names(y)
      colnames(sref_reshaped)=c("Y","X","Name") # Rename columns

      # Remove xmin and xmax values for outliers and whiskers so that data only appears when user hovers over the point
      remove=which(sref_reshaped$Name%in%c("ymin","ymax",unique(sref_reshaped$Name[grep("outlier",sref_reshaped$Name)]))&
                     sref_reshaped$X%in%c(sref$xmin,sref$xmax))

      sref_reshaped=sref_reshaped[-remove,]

      # Create Labels
      sref_reshaped$Label=NA
      sref_reshaped[which(sref_reshaped$Name=="ymin"),"Label"]="SREF Lower Whisker:"
      sref_reshaped[which(sref_reshaped$Name=="lower"),"Label"]="SREF 25% Quantile:"
      sref_reshaped[which(sref_reshaped$Name=="middle"),"Label"]="SREF Median:"
      sref_reshaped[which(sref_reshaped$Name=="upper"),"Label"]="SREF 75% Quantile:"
      sref_reshaped[which(sref_reshaped$Name=="ymax"),"Label"]="SREF Upper Whisker:"
      sref_reshaped[grep("outlier",sref_reshaped$Name),"Label"]="SREF Outlier:"

      sref_reshaped$Label2=NA
      sref_reshaped[grep("outlier",sref_reshaped$Name),"Label2"]=unlist(lapply(grep("outlier",sref_reshaped$Name),function(X){
        run=toString(boxplot_data()[which(boxplot_data()$Max==sref_reshaped[X,"Y"]),"Run"])
        split=strsplit(run,"_")[[1]] # Split string by underscore
        model_run=toupper(paste(split[3],split[4],sep="_"))
      }))

      sref_reshaped$Label_Value=sprintf("%.2f",round(sref_reshaped$Y,2))
      sref_reshaped$Run="SREF"

      plot_data=bind_rows(plot_data,sref_reshaped) # Bind Data
    }
    
    ### SREF Data Maximum
    if("sref"%in%plot_forecasts()){
      sref=ggplot_build(boxplot())$data[[which(rev(plot_forecasts())=="sref")+correction]]
      sref=sref[,c("y","x")]
      colnames(sref)=c("Y","X")
      sref$Name="ymax"
      sref$Label="SREF Maximum:"
      sref$Label2=NA
      sref$Label_Value=sprintf("%.2f",round(sref$Y,2))
      sref$Run="SREF"
      plot_data=bind_rows(plot_data,sref) # Bind Data
    }

    ### Get/Format Plot Units for tooltip
    units=plot_units()
    if(units%in%c("Volume Fraction","Fraction of Full Area")){units=""}
    else if(units%in%c("ft above node invert elevation","ft, absolute elevation per vertical datum")){units="ft"}
    else if(units%in%c("ft^3, including ponded water")){units="ft^3"}
    else if(units%in%c("m above node invert elevation","m, absolute elevation per vertical datum")){units="m"}
    else if(units%in%c("m^3, including ponded water")){units="m^3"}
    else if(any(grep("runoff +",units),grep("lateral inflow +",units),grep("excess overflow",units))==T){units=gsub("(.*),.*", "\\1", units)}

    # Get all points near cursor
    hover=input$boxplot_hover
    point=nearPoints(plot_data,xvar="X",yvar="Y",hover,threshold=10,addDist=T)
    if(nrow(point)==0)return(NULL)

    # Format Model Run
    req(point$Run)

    # If multiple points, then display ANC hover tip first
    if("ANC"%in%point$Run){
      point=point[which(point$Run=="ANC"),] # Get all ANC points
      point=point[which.min(point$dist_),] # Get closest point to cursor
    }
    # Then display HRRR hover tip second
    else if("HRRR"%in%point$Run){
      point=point[which(point$Run=="HRRR"),] # Get all HRRR points
      point=point[which.min(point$dist_),] # Get closest point to cursor
    }
    # Then display HREF hover tip third
    else if("HREF"%in%point$Run){
      point=point[which(point$Run=="HREF"),] # Get all HREF points
      point=point[which.min(point$dist_),] # Get closest point to cursor
    }
    # Then display SREF maximum hover tip fourth
    else if("SREF Maximum:"%in%point$Label){
      point=point[which(point$Label=="SREF Maximum:"),] # Get SREF Maximum
      point=point[which.min(point$dist_),] # Get closest point to cursor
    }
    # Otherwise display closest point
    else{
      point=point[which.min(point$dist_),] # Get closest point to cursor
    }

    # Create Label Text & Set Tooltip Height & Width
    if(point$Label=="SREF Outlier:"){
      label_text=paste0("<b>",point$Label," </b>",point$Label2,"<br/>",
                        "<b> Value: </b>",point$Label_Value," ",units)
      height=80
      width=260
    } else{
      label_text=paste0("<b>",point$Label," </b>",point$Label_Value," ",units,"<br/>")
      height=60
      width=260
    }

    # Calculate cursor position INSIDE the plot as percent of total dimensions; from left (horizontal) and from top (vertical)
    left_pct=(hover$x-hover$domain$left)/(hover$domain$right-hover$domain$left)
    top_pct=(hover$domain$top-hover$y)/(hover$domain$top-hover$domain$bottom)

    # Calculate distance from left and bottom side of the plot in pixels
    left_px=hover$range$left+left_pct*(hover$range$right-hover$range$left)
    top_px=hover$range$top+top_pct*(hover$range$bottom-hover$range$top)

    # Set offsets of tooltip from cursor depending on quadrant
    left_offset=(-1*(width+2)) # Because boxplot is on right of screen, offset tooltip to left
    if(top_pct<=0.5){ # Cursor on top half of plot
      top_offset=(2)
    } else{ # Cursor on bottom half of plot
      top_offset=(-1*(height+2))
    }

    # Create Style Property for tooltip; background color set so tooltip is a bit transparent; z-index set so tooltip will be on top
    style=paste0("position:absolute;z-index:100;background-color:rgba(245,245,245,0.85);",
                 "left:",left_px+left_offset,"px;top:",top_px+top_offset,"px;width:",width,"px;height:",height,"px;") # Set Width and Height so tooltip is always the same size

    # Actual tooltip created as wellPanel
    wellPanel(
      style=style,
      p(HTML(label_text))
    )
  })
  
  ##### Set Map Colors -----------------------------------------------------
  
  ### Get Maximum Values for Object Types/ID/Variables to use for symbolizing colors
  SC_run_max=reactive({
    if(nrow(SC())>0){
      if(length(plot_forecasts())>=1){
        SC_run_max=SC()[which(apply(sapply(plot_forecasts(),grepl,SC()$Run),1,any)==T),]%>% # Get only values for selected forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      } else{
        SC_run_max=SC()%>% # Values for all forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      }
    } else{
      SC_run_max=NA
    }
    SC_run_max
  })
  SC_max=reactive({
    if(any(!is.na(SC_run_max()))){
      SC_max=SC_run_max()%>%
        group_by(ID,Variable)%>%
        summarise(Max=max(Max))
    }
  })
  
  Link_run_max=reactive({
    if(nrow(Link())>0){
      if(length(plot_forecasts())>=1){
        Link_run_max=Link()[which(apply(sapply(plot_forecasts(),grepl,Link()$Run),1,any)==T),]%>% # Get only values for selected forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      } else{
        Link_run_max=Link()%>% # Values for all forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      }
    } else{
      Link_run_max=NA
    }
    Link_run_max
  })
  Link_max=reactive({
    if(any(!is.na(Link_run_max()))){
      Link_max=Link_run_max()%>%
        group_by(ID,Variable)%>%
        summarise(Max=max(Max))
    }
  })
  
  Node_run_max=reactive({
    if(nrow(Node())>0){
      if(length(plot_forecasts())>=1){
        Node_run_max=Node()[which(apply(sapply(plot_forecasts(),grepl,Node()$Run),1,any)==T),]%>% # Get only values for selected forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      } else{
        Node_run_max=Node()%>% # Values for all forecasts
          group_by(ID,Run,Variable)%>%
          summarise(Max=max(Value))
      }
    } else{
      Node_run_max=NA
    }
    Node_run_max
  })
  Node_max=reactive({
    if(any(!is.na(Node_run_max()))){
      Node_max=Node_run_max()%>%
        group_by(ID,Variable)%>%
        summarise(Max=max(Max))
    }
  })
  
  ### Get Values to create sliders
  slider_sc_max=reactive({
    req(input$Variable_sc)
    max=roundToNice(max(SC_max()[which(SC_max()$Variable==unlist(sc_var_key[input$Variable_sc],use.names=F)),"Max"],na.rm=T))
    max=ifelse(max>0,max,1)
  })
  slider_sc_from=reactive({
    from=roundFromNice(quantile(SC_max()$Max)[[2]]) # Get 25% Quantile and round to nice value
    max=slider_sc_max()
    if(from<0.2*max){from=0.2*max} # Value less than 20% of max value, so set to 20% so colors have larger variety
    else if(from>0.5*max){from=0.5*max} # Value greater than 50% of max value, so set to 50% so colors have larger variety
    from
  })
  slider_sc_to=reactive({
    to=roundToNice(quantile(SC_max()$Max)[[4]]) # Get 75% Quantile and round to nice value
    max=slider_sc_max()
    if(to<0.5*max){to=0.5*max} # Value less than 50% of max value, so set to 50% so colors have larger variety
    else if(to>0.8*max){to=0.8*max} # Value greater than 80% of max value, so set to 80% so colors have larger variety
    to
  })
  slider_sc_step=reactive({
    roundScaleNice(slider_sc_max())
  })
  
  slider_link_max=reactive({
    req(input$Variable_link)
    max=roundToNice(max(Link_max()[which(Link_max()$Variable==unlist(link_var_key[input$Variable_link],use.names=F)),"Max"],na.rm=T))
    max=ifelse(max>0,max,1)
  })
  slider_link_from=reactive({
    from=roundFromNice(quantile(Link_max()$Max)[[2]]) # Get 25% Quantile and round to nice value
    max=slider_link_max()
    if(from<0.2*max){from=0.2*max} # Value less than 20% of max value, so set to 20% so colors have larger variety
    else if(from>0.5*max){from=0.5*max} # Value greater than 50% of max value, so set to 50% so colors have larger 
    from
  })
  slider_link_to=reactive({
    to=roundToNice(quantile(Link_max()$Max)[[4]]) # Get 75% Quantile and round to nice value
    max=slider_link_max()
    if(to<0.5*max){to=0.5*max} # Value less than 50% of max value, so set to 50% so colors have larger variety
    else if(to>0.8*max){to=0.8*max} # Value greater than 80% of max value, so set to 80% so colors have larger 
    to
  })
  slider_link_step=reactive({
    roundScaleNice(slider_link_max())
  })
  
  slider_node_max=reactive({
    req(input$Variable_node)
    max=roundToNice(max(Node_max()[which(Node_max()$Variable==unlist(node_var_key[input$Variable_node],use.names=F)),"Max"],na.rm=T))
    max=ifelse(max>0,max,1)
  })
  slider_node_from=reactive({
    from=roundFromNice(quantile(Link_max()$Max)[[2]]) # Get 25% Quantile and round to nice value
    max=slider_node_max()
    if(from<0.2*max){from=0.2*max} # Value less than 20% of max value, so set to 20% so colors have larger variety
    else if(from>0.5*max){from=0.5*max} # Value greater than 50% of max value, so set to 50% so colors have larger variety
    from
  })
  slider_node_to=reactive({
    to=roundToNice(quantile(Node_max()$Max)[[4]]) # Get 75% Quantile and round to nice value
    max=slider_node_max()
    if(to<0.5*max){to=0.5*max} # Value less than 50% of max value, so set to 50% so colors have larger variety
    else if(to>0.8*max){to=0.8*max} # Value greater than 80% of max value, so set to 80% so colors have larger variety
    to
  })
  slider_node_step=reactive({
    roundScaleNice(slider_node_max())
  })
  
  ### Create Color Inputs
  output$map_colors_sc=renderUI({
    req(c(input$Variable_sc))
    HTML(paste0('<div id="sc_colors">
                <input type="text" class="color-slider" id="sc_color_slider" name="my_range" value=""/>
                <script type="text/javascript">
                var iri_line_left = $(".irs-line-left");
                var iri_line_right = $(".irs-line-right");
                
                $("#sc_color_slider").ionRangeSlider({
                type: "double",
                min: 0,
                max:',slider_sc_max(),',
                from:',slider_sc_from(),',
                to:',slider_sc_to(),',
                step:',slider_sc_step(),',
                grid: true,
                grid_snap: false,
                prettify_enabled: true,
                prettify_separator: ",",
                keyboard: true,
                drag_interval: true,
                onChange: function (data) {
                var leftWidth = Math.ceil(data.from_percent);
                var rightWidth = 100 - leftWidth;
                
                $("#sc_colors .irs-line-left").css("width", leftWidth + "%");
                $("#sc_colors .irs-line-right").css("width", rightWidth + "%");
                
                }
                });
                </script>
                </div>'
    ))
  })
  
  output$map_colors_link=renderUI({
    req(c(input$Variable_link))
    HTML(paste0('<div id="link_colors">
            <input type="text" class="color-slider" id="link_color_slider" name="my_range" value=""/>
            <script type="text/javascript">
              var iri_line_left = $(".irs-line-left");
              var iri_line_right = $(".irs-line-right");

              $("#link_color_slider").ionRangeSlider({
                type: "double",
                min: 0,
                max:',slider_link_max(),',
                from:',slider_link_from(),',
                to:',slider_link_to(),',
                step:',slider_link_step(),',
                grid: true,
                grid_snap: false,
                prettify_enabled: true,
                prettify_separator: ",",
                keyboard: true,
                drag_interval: true,
                onChange: function (data) {
                            var leftWidth = Math.ceil(data.from_percent);
                            var rightWidth = 100 - leftWidth;

                            $("#link_colors .irs-line-left").css("width", leftWidth + "%");
                            $("#link_colors .irs-line-right").css("width", rightWidth + "%");

                }
              });
            </script>
          </div>'
    ))
  })
  
  output$map_colors_node=renderUI({
    req(c(input$Variable_node))
    HTML(paste0('<div id="node_colors">
            <input type="text" class="color-slider" id="node_color_slider" name="my_range" value=""/>
            <script type="text/javascript">
              var iri_line_left = $(".irs-line-left");
              var iri_line_right = $(".irs-line-right");

              $("#node_color_slider").ionRangeSlider({
                type: "double",
                min: 0,
                max:',slider_node_max(),',
                from:',slider_node_from(),',
                to:',slider_node_to(),',
                step:',slider_node_step(),',
                grid: true,
                grid_snap: false,
                prettify_enabled: true,
                prettify_separator: ",",
                keyboard: true,
                drag_interval: true,
                onChange: function (data) {
                          var leftWidth = Math.ceil(data.from_percent);
                          var rightWidth = 100 - leftWidth;

                          $("#node_colors .irs-line-left").css("width", leftWidth + "%");
                          $("#node_colors .irs-line-right").css("width", rightWidth + "%");

                }
              });
            </script>
          </div>'
    ))
  })
  
  ### Hide Sliders if Switch turned off
  observe({
    if(input$symbolize_sc==T){
      shinyjs::show(id="sc_slider")
    }
    else{
      shinyjs::hide(id="sc_slider")
    }
  })
  
  observe({
    if(input$symbolize_link==T){
      shinyjs::show(id="link_slider")
    }
    else{
      shinyjs::hide(id="link_slider")
    }
  })
  
  observe({
    if(input$symbolize_node==T){
      shinyjs::show(id="node_slider")
    }
    else{
      shinyjs::hide(id="node_slider")
    }
  })
  
  ### Colors
  # Create Color Palettes for Map
  pal_green=colorRampPalette(c("#004d00","#00ff00"))
  pal_yellow=colorRampPalette(c("#ffff00","#ff6600"))
  pal_red=colorRampPalette(c("black","#4d0000"))
  
  # Debounce input so it doesn't regenerate colors for every step on the slider
  sc_debounce=reactive({input$sc_color_slider})%>%debounce(500)
  link_debounce=reactive({input$link_color_slider})%>%debounce(500) 
  node_debounce=reactive({input$node_color_slider})%>%debounce(500) 
  
  # Create Reactive Values to track if initial map load or not
  sc_initialize=reactiveVal(0)
  link_initialize=reactiveVal(0)
  orifice_initialize=reactiveVal(0)
  weir_initialize=reactiveVal(0)
  node_initialize=reactiveVal(0)
  outfall_initialize=reactiveVal(0)
  storage_initialize=reactiveVal(0)
  
  # Update Reactive Values after map load
  observeEvent(sc_color(),{sc_initialize(sc_initialize()+1)})
  observeEvent(link_color(),{link_initialize(link_initialize()+1)})
  observeEvent(orifice_color(),{orifice_initialize(orifice_initialize()+1)})
  observeEvent(weir_color(),{weir_initialize(weir_initialize()+1)})
  observeEvent(node_color(),{node_initialize(node_initialize()+1)})
  observeEvent(outfall_color(),{outfall_initialize(outfall_initialize()+1)})
  observeEvent(storage_color(),{storage_initialize(storage_initialize()+1)})
  
  # Format input data from sliders
  sc_slider=reactive({
    req(sc_debounce())
    slider=as.numeric(str_split(sc_debounce(),";")[[1]])
  })
  
  link_slider=reactive({
    req(link_debounce())
    slider=as.numeric(str_split(link_debounce(),";")[[1]])
  })
  
  node_slider=reactive({
    req(node_debounce())
    slider=as.numeric(str_split(node_debounce(),";")[[1]])
  })
  
  # Calculate Colors
  sc_color=reactive({
    if(input$symbolize_sc==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(SC_max(),SC_max()$Variable==unlist(sc_var_key[input$Variable_sc],use.names=F))

      # Reorder data to match labels
      color_data=color_data[match(sc_label(),color_data$ID),]
  
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,sc_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(sc_slider()[1],sc_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                       domain=c(sc_slider()[2],slider_sc_max()),
                       bins=5)
  
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=sc_slider()[1]){
          greens(X)
        }else if(X>sc_slider()[1]&X<=sc_slider()[2]){
          yellows(X)
        }else if(X>sc_slider()[2]){
          reds(X)
        }
      })

      color_data$Color
    }
    else if(input$symbolize_sc==F){ # Use default color
      "#0099cc"
    }
  })
  
  link_color=reactive({
    if(input$symbolize_link==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Link_max(),Link_max()$Variable==unlist(link_var_key[input$Variable_link],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(link_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,link_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(link_slider()[1],link_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(link_slider()[2],slider_link_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=link_slider()[1]){
          greens(X)
        }else if(X>link_slider()[1]&X<=link_slider()[2]){
          yellows(X)
        }else if(X>link_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_link==F){ # Use default color
      "#0066ff"
    }
  })
  orifice_color=reactive({
    if(input$symbolize_link==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Link_max(),Link_max()$Variable==unlist(link_var_key[input$Variable_link],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(link_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,link_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(link_slider()[1],link_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(link_slider()[2],slider_link_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=link_slider()[1]){
          greens(X)
        }else if(X>link_slider()[1]&X<=link_slider()[2]){
          yellows(X)
        }else if(X>link_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_link==F){ # Use default color
      "#0066ff"
    }
  })
  weir_color=reactive({
    if(input$symbolize_link==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Link_max(),Link_max()$Variable==unlist(link_var_key[input$Variable_link],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(link_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,link_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(link_slider()[1],link_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(link_slider()[2],slider_link_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=link_slider()[1]){
          greens(X)
        }else if(X>link_slider()[1]&X<=link_slider()[2]){
          yellows(X)
        }else if(X>link_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_link==F){ # Use default color
      "#0066ff"
    }
  })
  node_color=reactive({
    if(input$symbolize_node==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Node_max(),Node_max()$Variable==unlist(node_var_key[input$Variable_node],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(node_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,node_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(node_slider()[1],node_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(node_slider()[2],slider_node_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=node_slider()[1]){
          greens(X)
        }else if(X>node_slider()[1]&X<=node_slider()[2]){
          yellows(X)
        }else if(X>node_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_node==F){ # Use default color
      "black"
    }
  })
  outfall_color=reactive({
    if(input$symbolize_node==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Node_max(),Node_max()$Variable==unlist(node_var_key[input$Variable_node],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(node_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,node_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(node_slider()[1],node_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(node_slider()[2],slider_node_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=node_slider()[1]){
          greens(X)
        }else if(X>node_slider()[1]&X<=node_slider()[2]){
          yellows(X)
        }else if(X>node_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_node==F){ # Use default color
      "black"
    }
  })
  storage_color=reactive({
    if(input$symbolize_node==T){ # Use Colors from slider
      # Subset data to mapped parameter
      color_data=subset(Node_max(),Node_max()$Variable==unlist(node_var_key[input$Variable_node],use.names=F))
      
      # Reorder data to match labels
      color_data=color_data[match(node_label(),color_data$ID),]
      
      # Bin Colors
      greens=colorBin(palette=pal_green(5),
                      domain=c(0,node_slider()[1]),
                      bins=5)
      yellows=colorBin(palette=pal_yellow(5),
                       domain=c(node_slider()[1],node_slider()[2]),
                       bins=5)
      reds=colorBin(palette=pal_red(5),
                    domain=c(node_slider()[2],slider_node_max()),
                    bins=5)
      
      # Calculate Colors
      color_data$Color=lapply(color_data$Max,function(X){
        if(X<=node_slider()[1]){
          greens(X)
        }else if(X>node_slider()[1]&X<=node_slider()[2]){
          yellows(X)
        }else if(X>node_slider()[2]){
          reds(X)
        }
      })
      
      color_data$Color
    }
    else if(input$symbolize_node==F){ # Use default color
      "black"
    }
  })
  
  ###### Create Map ---------------------------------------------------------
  
  ### Labels
  sc_label=reactive({unique(inp()$subcatchments$Name)})
  link_label=reactive({unique(inp()$conduits$Name)})
  orifice_label=reactive({unique(inp()$orifices$Name)})
  weir_label=reactive({unique(inp()$weirs$Name)})
  node_label=reactive({unique(inp()$junctions$Name)})
  outfall_label=reactive({unique(inp()$outfalls$Name)})
  storage_label=reactive({unique(inp()$storage$Name)})
  
  ### Show/Hide Legend on Maps
  legend=reactiveVal(F) # Create Reactive Value to set show/hide legend
  extents=reactiveVal(F) # Create Reactive Value to show/hide forecast extents
  
  observeEvent(input$legend_button,{
    if(input$legend_button=="show"){
      legend(T)
    }
    else if(input$legend_button=="hide"){
      legend(F)
    }
  })
  
  observeEvent(input$extents_button,{
    if(input$extents_button=="show"){
      extents(T)
    }
    else if(input$extents_button=="hide"){
      extents(F)
    }
  })
  
  
  Groups=reactiveVal(c("Subcatchments","Links","Nodes"))
  observeEvent(input$map_groups,{
    Groups(input$map_groups)
  })
  
  ### Generate Map
  map=eventReactive(c(legend(),
                      extents(),
                      map_sc(),
                      sc_label(),
                      map_link(),
                      link_label(),
                      map_orifice(),
                      orifice_label(),
                      map_weir(),
                      weir_label(),
                      map_node(),
                      node_label(),
                      map_outfall(),
                      outfall_label(),
                      map_storage(),
                      storage_label(),
                      subcatchments_extent()
                      ),{
    map=leaflet()%>%
      addTiles()%>%
    
      # Add Map Panes to set Display Order
      addMapPane("Subcatchments",zIndex=410)%>%
      addMapPane("Links",zIndex=420)%>%
      addMapPane("Nodes",zIndex=430)%>%
      addMapPane("Link Labels",zIndex=450)%>%
      addMapPane("Node Labels",zIndex=450)%>%
      addMapPane("Subcatchment Labels",zIndex=490)
      
      if(legend()==T){
        map=map%>%
          # Layers Control
          addLayersControl(
            baseGroups=c("Map","Topo","Satellite"),
            overlayGroups=c("Subcatchments","Links","Nodes","Subcatchment Labels","Link Labels","Node Labels"),
            options=layersControlOptions(collapsed=F,autoZIndex=F))%>%
          addEasyButton(easyButton(
            states = list(
              easyButtonState(
                stateName="show-legend",
                icon="ion-toggle-filled",
                title="Dynamic Labels",
                onClick = JS("
                           function(btn, map) {
                           Shiny.onInputChange('legend_button', 'hide');
                           btn.state('hide-legend');
                           }")
              )
            )
          ))
      } else{
        map=map%>%
          # Layers Control
          addLayersControl(
            baseGroups=c("Map","Topo","Satellite"),
            overlayGroups=c("Subcatchments","Links","Nodes"),
            options=layersControlOptions(collapsed=F,autoZIndex=F))%>%
          addEasyButton(easyButton(
            states = list(
              easyButtonState(
                stateName="hide-legend",
                icon="ion-toggle",
                title="Static Labels",
                onClick = JS("
                           function(btn, map) {
                           Shiny.onInputChange('legend_button', 'show');
                           btn.state('show-legend');
                           }")
              )
            )
          ))
    }
    
    # Show/Hide Forecast Extents
    if(extents()==T){
      # Add Button
      map=map%>%
        addEasyButton(easyButton(
          states = list(
            easyButtonState(
              stateName="show-extents",
              icon="ion-toggle-filled",
              title="Hide Forecast Extents",
              onClick = JS("
                           function(btn, map) {
                           Shiny.onInputChange('extents_button', 'hide');
                           btn.state('hide-extents');
                           }")
            )
          )
        ))
      
      # Add SREF Extent
      if(!is.na(SREF_data())){
        map=map%>%
          addRectangles(lng1=min(SREF_data()$lon,na.rm=T),
                        lng2=max(SREF_data()$lon,na.rm=T),
                        lat1=min(SREF_data()$lat,na.rm=T),
                        lat2=max(SREF_data()$lat,na.rm=T),
                        label="SREF",
                        color="#17a2b8",
                        fillColor="transparent")
      }
      
      # Add HREF Extent
      if(!is.na(HREF_data())){
        map=map%>%
          addRectangles(lng1=min(HREF_data()$lon,na.rm=T),
                        lng2=max(HREF_data()$lon,na.rm=T),
                        lat1=min(HREF_data()$lat,na.rm=T),
                        lat2=max(HREF_data()$lat,na.rm=T),
                        label="HREF",
                        color="#28a745",
                        fillColor="transparent")
      }
        
      # Add HRRR Extent
      if(!is.na(HRRR_data())){
        map=map%>%
          addRectangles(lng1=min(HRRR_data()$lon,na.rm=T),
                        lng2=max(HRRR_data()$lon,na.rm=T),
                        lat1=min(HRRR_data()$lat,na.rm=T),
                        lat2=max(HRRR_data()$lat,na.rm=T),
                        label="HRRR",
                        color="#ffc107",
                        fillColor="transparent")
      }
      
      # Add ANC Extent
      if(!is.na(ANC_data())){
        map=map%>%
          addRectangles(lng1=min(ANC_data()$lon,na.rm=T),
                        lng2=max(ANC_data()$lon,na.rm=T),
                        lat1=min(ANC_data()$lat,na.rm=T),
                        lat2=max(ANC_data()$lat,na.rm=T),
                        label="ANC",
                        color="#dc3545",
                        fillColor="transparent")
      }
    } else{
      map=map%>%
        addEasyButton(easyButton(
          states = list(
            easyButtonState(
              stateName="hide-extents",
              icon="ion-toggle",
              title="Show Forecast Extents",
              onClick = JS("
                           function(btn, map) {
                           Shiny.onInputChange('extents_button', 'show');
                           btn.state('show-extents');
                           }")
            )
          )
        ))
    }
    
    # Add Different Basemaps
    map=map%>%
      addProviderTiles("Esri.WorldTopoMap",group="Topo")%>%
      addProviderTiles("Esri.WorldImagery",group="Satellite",options=providerTileOptions(maxNativeZoom=18,maxZoom=19))%>%
      addProviderTiles("CartoDB.PositronOnlyLabels",group="Satellite")
      
    
    # Add Subcatchments on initial map load
    if(sc_initialize()<=1&!is.null(map_sc())){
      map=map%>%
        addPolygons(data=map_sc(),
                    group="Subcatchments",
                    options=pathOptions(pane="Subcatchments"),
                    layerId=paste0("Subcatchment_",sc_label()),
                    color="	#202020",
                    fillColor="#0099cc",
                    opacity=0.7, # Border Line Opacity
                    weight=1,  # Border Line Weight
                    fillOpacity=0.3
        )
    }
    
    # Add Subcatchment Labels
    if(!is.null(map_sc())){
      map=map%>%
        addLabelOnlyMarkers(data=coordinates(map_sc()),
                            group="Subcatchment Labels",
                            options=pathOptions(pane="Subcatchment Labels"),
                            label=sc_label(),
                            labelOptions=labelOptions(noHide=T,textOnly=T,
                                                      style=c("color"="black",
                                                              "font-family"="arial",
                                                              "font-weight"="bold",
                                                              "font-size"="12px",
                                                              "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")))
    }
    
    # Add Links on initial map load
    if(link_initialize()<=1&!is.null(map_link())){
      map=map%>%
        addPolylines(data=map_link(),
                     group="Links",
                     options=pathOptions(pane="Links"),
                     layerId=paste0("Link_",link_label()),
                     color="#0066ff",
                     opacity=1,
                     weight=5)
    }
    
    # Add Link Labels
    if(!is.null(map_link())){
      map=map%>%
        addPolylines(data=map_link(), # Can't Use Label only Markers b/c can't get coordinates for Spatial Lines dataset, so create another map layer but hide lines
                   group="Link Labels",
                   options=pathOptions(pane="Link Labels",interactive=F),
                   label=link_label(),
                   labelOptions=labelOptions(noHide=T,textOnly=T,
                                             style=c("color"="black",
                                                     "font-family"="arial",
                                                     "font-weight"="bold",
                                                     "font-size"="8px",
                                                     "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")),
                   opacity=0,
                   weight=5)
    }
    
    # Add Orifices on initial map load
    if(orifice_initialize()<=1&!is.null(map_orifice())){
      map=map%>%
        addPolylines(data=map_orifice(),
                     group="Links",
                     options=pathOptions(pane="Links"),
                     layerId=paste0("Link_",orifice_label()),
                     color="#0066ff",
                     opacity=1,
                     weight=5)
    }
    
    # Add Orifice Labels
    if(!is.null(map_orifice())){
      map=map%>%
        addPolylines(data=map_orifice(), # Can't Use Label only Markers b/c can't get coordinates for Spatial Lines dataset, so create another map layer but hide lines
                     group="Link Labels",
                     options=pathOptions(pane="Link Labels",interactive=F),
                     label=orifice_label(),
                     labelOptions=labelOptions(noHide=T,textOnly=T,
                                               style=c("color"="black",
                                                       "font-family"="arial",
                                                       "font-weight"="bold",
                                                       "font-size"="8px",
                                                       "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")),
                     opacity=0,
                     weight=5)
    }
    
    # Add Weirs on initial map load
    if(weir_initialize()<=1&!is.null(map_weir())){
      map=map%>%
        addPolylines(data=map_weir(),
                     group="Links",
                     options=pathOptions(pane="Links"),
                     layerId=paste0("Link_",weir_label()),
                     color="#0066ff",
                     opacity=1,
                     weight=5)
    }
    
    # Add Weir Labels
    if(!is.null(map_weir())){
      map=map%>%
        addPolylines(data=map_weir(), # Can't Use Label only Markers b/c can't get coordinates for Spatial Lines dataset, so create another map layer but hide lines
                     group="Link Labels",
                     options=pathOptions(pane="Link Labels",interactive=F),
                     label=weir_label(),
                     labelOptions=labelOptions(noHide=T,textOnly=T,
                                               style=c("color"="black",
                                                       "font-family"="arial",
                                                       "font-weight"="bold",
                                                       "font-size"="8px",
                                                       "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")),
                     opacity=0,
                     weight=5)
    }
    
    # Add Nodes on initial map load
    if(node_initialize()<=1&!is.null(map_node())){
      map=map%>%
        addCircles(data=map_node(),
                   group="Nodes",
                   options=pathOptions(pane="Nodes"),
                   layerId=paste0("Node_",node_label()),
                   color="black",
                   opacity=1,
                   radius=1.5)
    }
    
    # Add Node Labels
    if(!is.null(map_node())){
      map=map%>%
        addLabelOnlyMarkers(data=coordinates(map_node()),
                            group="Node Labels",
                            options=pathOptions(pane="Node Labels"),
                            label=node_label(),
                            labelOptions=labelOptions(noHide=T,textOnly=T,
                                                      style=c("color"="black",
                                                              "font-family"="arial",
                                                              "font-weight"="bold",
                                                              "font-size"="8px",
                                                              "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")))
    }
    
    # Add Outfalls on initial map load
    if(outfall_initialize()<=1&!is.null(map_outfall())){
      map=map%>%
        addCircles(data=map_outfall(),
                   group="Nodes",
                   options=pathOptions(pane="Nodes"),
                   layerId=paste0("Node_",outfall_label()),
                   label=if("Nodes"%in%input$map_labels){outfall_label()},
                   labelOptions=labelOptions(noHide=T,textOnly=T),
                   color="black",
                   opacity=1,
                   radius=1.5)
    }
    
    # Add Outfall Labels
    if(!is.null(map_outfall())){
      map=map%>%
        addLabelOnlyMarkers(data=coordinates(map_outfall()),
                            group="Node Labels",
                            options=pathOptions(pane="Node Labels"),
                            label=outfall_label(),
                            labelOptions=labelOptions(noHide=T,textOnly=T,
                                                      style=c("color"="black",
                                                              "font-family"="arial",
                                                              "font-weight"="bold",
                                                              "font-size"="8px",
                                                              "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")))
    }
    
    # Add Storages on initial map load
    if(storage_initialize()<=1&!is.null(map_storage())){
      map=map%>%
        addCircles(data=map_storage(),
                   group="Nodes",
                   options=pathOptions(pane="Nodes"),
                   layerId=paste0("Node_",storage_label()),
                   label=if("Nodes"%in%input$map_labels){storage_label()},
                   labelOptions=labelOptions(noHide=T,textOnly=T),
                   color="black",
                   opacity=1,
                   radius=1.5)
    }
    
    # Add Storage Labels
    if(!is.null(map_storage())){
      map=map%>%
        addLabelOnlyMarkers(data=coordinates(map_storage()),
                            group="Node Labels",
                            options=pathOptions(pane="Node Labels"),
                            label=storage_label(),
                            labelOptions=labelOptions(noHide=T,textOnly=T,
                                                      style=c("color"="black",
                                                              "font-family"="arial",
                                                              "font-weight"="bold",
                                                              "font-size"="8px",
                                                              "text-shadow"="-1px -1px #FFFFFF, 1px -1px #FFFFFF, -1px 1px #FFFFFF, 1px 1px #FFFFFF")))
    }
      
    
    # Set Inital Map Extents
    # If forecast extents displayed
    if(extents()==T&!all(is.na(SREF_data()),is.na(HREF_data()),is.na(HRRR_data()),is.na(ANC_data()))){
      # Create Lists to store extents
      min_lons=c()
      max_lons=c()
      min_lats=c()
      max_lats=c()
      
      # Add SREF extents
      if(!is.na(SREF_data())){
        min_lons=c(min_lons,min(SREF_data()$lon,na.rm=T))
        max_lons=c(max_lons,max(SREF_data()$lon,na.rm=T))
        min_lats=c(min_lats,min(SREF_data()$lat,na.rm=T))
        max_lats=c(max_lats,max(SREF_data()$lat,na.rm=T))
      }
      
      # Add HREF extents
      if(!is.na(HREF_data())){
        min_lons=c(min_lons,min(HREF_data()$lon,na.rm=T))
        max_lons=c(max_lons,max(HREF_data()$lon,na.rm=T))
        min_lats=c(min_lats,min(HREF_data()$lat,na.rm=T))
        max_lats=c(max_lats,max(HREF_data()$lat,na.rm=T))
      }
      
      # Add HRRR extents
      if(!is.na(HRRR_data())){
        min_lons=c(min_lons,min(HRRR_data()$lon,na.rm=T))
        max_lons=c(max_lons,max(HRRR_data()$lon,na.rm=T))
        min_lats=c(min_lats,min(HRRR_data()$lat,na.rm=T))
        max_lats=c(max_lats,max(HRRR_data()$lat,na.rm=T))
      }
      
      # Add ANC extents
      if(!is.na(ANC_data())){
        min_lons=c(min_lons,min(ANC_data()$lon,na.rm=T))
        max_lons=c(max_lons,max(ANC_data()$lon,na.rm=T))
        min_lats=c(min_lats,min(ANC_data()$lat,na.rm=T))
        max_lats=c(max_lats,max(ANC_data()$lat,na.rm=T))
      }
      
      map=map%>%fitBounds(lng1=min(min_lons,na.rm=T),lng2=max(max_lons,na.rm=T),lat1=min(min_lats,na.rm=T),lat2=max(max_lats,na.rm=T))
    }
    # From SWMM Subcatchments Shapefile
    else if(!is.null(map_sc())){ 
      extents=bbox(map_sc())
      map=map%>%fitBounds(lng1=extents["x","min"],lng2=extents["x","max"],lat1=extents["y","min"],lat2=extents["y","max"])
    }
    # From Uploaded Subcatchments Shapefile
    else if(!is.null(subcatchments_extent())){ 
      map=map%>%fitBounds(lng1=subcatchments_extent()["x","min"],lng2=subcatchments_extent()["x","max"],lat1=subcatchments_extent()["y","min"],lat2=subcatchments_extent()["y","max"])
    } else{
      map=map%>%clearBounds()
    }
    
    # Add Scale Bar
    if(SWMM_units()=="SI"){
      map=map%>%addScaleBar(position="bottomright",options=scaleBarOptions(metric=T,imperial=F))
    } else{
      map=map%>%addScaleBar(position="bottomright",options=scaleBarOptions(metric=F,imperial=T))
    }
    
    map # Output
  })
  
  ### Update Subcatchments on Map
  observeEvent(c(sc_color(),
                 input$legend_button),{
     proxy=leafletProxy("map")%>%
       clearGroup("Subcatchments")

     # Add Subcatchments
     if(!is.null(map_sc())){
       proxy%>%
         addPolygons(data=map_sc(),
                     group="Subcatchments",
                     options=pathOptions(pane="Subcatchments"),
                     layerId=paste0("Subcatchment_",sc_label()),
                     color="#202020",
                     fillColor=sc_color(),
                     opacity=0.7, # Border Line Opacity
                     weight=1,  # Border Line Weight
                     fillOpacity=0.3
         )
     }
   })
  
  ### Update Links on Map
  observeEvent(c(link_color(),
                 orifice_color(),
                 weir_color(),
                 input$legend_button),{
     proxy=leafletProxy("map")%>%
       clearGroup("Links")
     
     # Add Links
     if(!is.null(map_link())){
       proxy%>%
         addPolylines(data=map_link(),
                      group="Links",
                      options=pathOptions(pane="Links"),
                      layerId=paste0("Link_",link_label()),
                      color=link_color(),
                      opacity=1,
                      weight=5)
     }
     # Add Orifices
     if(!is.null(map_orifice())){
       proxy%>%
         addPolylines(data=map_orifice(),
                      group="Links",
                      options=pathOptions(pane="Links"),
                      layerId=paste0("Link_",orifice_label()),
                      color=orifice_color(),
                      opacity=1,
                      weight=5)
     }
     # Add Weirs
     if(!is.null(map_weir())){
       proxy%>%
         addPolylines(data=map_weir(),
                      group="Links",
                      options=pathOptions(pane="Links"),
                      layerId=paste0("Link_",weir_label()),
                      color=weir_color(),
                      opacity=1,
                      weight=5)
     }
   })
  
  ### Update Nodes on Map
  observeEvent(c(node_color(),
                 outfall_color(),
                 storage_color(),
                 input$legend_button),{
     proxy=leafletProxy("map")%>%
       clearGroup("Nodes")
     
     # Add Nodes
     if(!is.null(map_node())){
       proxy%>%
         addCircles(data=map_node(),
                    group="Nodes",
                    options=pathOptions(pane="Nodes"),
                    layerId=paste0("Node_",node_label()),
                    color=node_color(),
                    opacity=1,
                    radius=1.5)
     }
     # Add Outfalls
     if(!is.null(map_outfall())){
       proxy%>%
         addCircles(data=map_outfall(),
                    group="Nodes",
                    options=pathOptions(pane="Nodes"),
                    layerId=paste0("Node_",outfall_label()),
                    label=if("Nodes"%in%input$map_labels){outfall_label()},
                    labelOptions=labelOptions(noHide=T,textOnly=T),
                    color=outfall_color(),
                    opacity=1,
                    radius=1.5)
     }
     # Add Storages
     if(!is.null(map_storage())){
       proxy%>%
         addCircles(data=map_storage(),
                    group="Nodes",
                    options=pathOptions(pane="Nodes"),
                    layerId=paste0("Node_",storage_label()),
                    label=if("Nodes"%in%input$map_labels){storage_label()},
                    labelOptions=labelOptions(noHide=T,textOnly=T),
                    color=storage_color(),
                    opacity=1,
                    radius=1.5)
     }
  })
  
  ### Fly to Selected Object
  observeEvent(map_id(),{
    proxy=leafletProxy("map")
    
    # Only Fly if User Selects ID from Dropdown
    if(!is.null(input$last_click)){
      if(input$last_click=="id"){
        if(input$swmm_object_type=="Subcatchment"&!is.null(map_sc())){
          # Get Lat/Lon Coordinates
          coords=coordinates(map_sc())[which(map_sc()$Name==map_id()),] 
          
          # Fly to Subcatchment
          proxy%>%
            # Hide Labels while Flying
            hideGroup("Subcatchment Labels")%>%
            hideGroup("Link Labels")%>%
            hideGroup("Node Labels")
          if(legend()==T){
            proxy%>%
              setView(coords[1],coords[2],16)%>%
              showGroup("Subcatchments")%>% # Make Sure Subcatchments are Displayed
              showGroup("Subcatchment Labels") # Make Sure Subcatchment Labels are Displayed
          } else{
            proxy%>%
              flyTo(coords[1],coords[2],16)%>%
              showGroup("Subcatchments") # Make Sure Subcatchments are Displayed
          }
        }
        else if(input$swmm_object_type=="Link"&!all(is.null(map_link())&is.null(map_orifice())&is.null(map_weir()))){
          files=c(map_link(),map_orifice(),map_weir())
          layer=lapply(files,function(X){map_id()%in%X$Name}) # Determine which Shapefile the Object is in
          
          # Get Lat/Lon Coordinates
          coords=switch(as.character(which(layer==T))[1],
                        "1"=coordinates(map_link())[[which(map_link()$Name==map_id())]][[1]],
                        "2"=coordinates(map_orifice())[[which(map_orifice()$Name==map_id())]][[1]],
                        "3"=coordinates(map_weir())[[which(map_weir()$Name==map_id())]][[1]])
          
          # Fly to Link
          proxy%>%
            # Hide Labels while Flying
            hideGroup("Subcatchment Labels")%>%
            hideGroup("Link Labels")%>%
            hideGroup("Node Labels")
          if(legend()==T){
            proxy%>%
              fitBounds(lng1=min(coords[,1]),
                          lng2=max(coords[,1]),
                          lat1=min(coords[,2]),
                          lat2=max(coords[,2]))%>%
              showGroup("Links")%>% # Make Sure Links are Displayed
              showGroup("Link Labels") # Make Sure Link Labels are Displayed
          } else{
            proxy%>%
              flyToBounds(lng1=min(coords[,1]),
                          lng2=max(coords[,1]),
                          lat1=min(coords[,2]),
                          lat2=max(coords[,2]))%>%
              showGroup("Links") # Make Sure Links are Displayed
          }
        }
        else if(input$swmm_object_type=="Node"&!all(is.null(map_node())&is.null(map_outfall())&is.null(map_storage()))){
          files=c(map_node(),map_outfall(),map_storage())
          layer=lapply(files,function(X){map_id()%in%X$Name}) # Determine which Shapefile the Object is in
          
          # Get Lat/Lon Coordinates
          coords=switch(as.character(which(layer==T))[1],
                        "1"=coordinates(map_node())[which(map_node()$Name==map_id()),],
                        "2"=coordinates(map_outfall())[which(map_outfall()$Name==map_id()),],
                        "3"=coordinates(map_storage())[which(map_storage()$Name==map_id()),])

          # Fly to Node
          proxy%>%
            # Hide Labels while Flying
            hideGroup("Subcatchment Labels")%>%
            hideGroup("Link Labels")%>%
            hideGroup("Node Labels")
            if(legend()==T){
              proxy%>%
                setView(coords[[1]],coords[[2]],18)%>%
                showGroup("Nodes")%>% # Make Sure Nodes are Displayed
                showGroup("Node Labels") # Make Sure Node Labels are Displayed
            } else{
              proxy%>%
                flyTo(coords[[1]],coords[[2]],18)%>%
                showGroup("Nodes") # Make Sure Nodes are Displayed
            }
        }
      }
    }
  })
  
  ### Hide Labels if Layer Turned Off
  old_groups=reactiveVal(NA)
  new_groups=reactiveVal(NA)
  added_groups=reactiveVal(NA)
  removed_groups=reactiveVal(NA)
  label_sc=reactiveVal(NA)
  label_link=reactiveVal(NA)
  label_node=reactiveVal(NA)
  
  observeEvent(c(input$map_groups,
                 legend()),{
    proxy=leafletProxy("map")
    
    old_groups(new_groups())
    new_groups(input$map_groups)
    
    added_groups(setdiff(input$map_groups,old_groups()))   # Layers Added
    removed_groups(setdiff(old_groups(),input$map_groups)) # Layers Removed
    
    # Control Labels for Static Labels View
    if(legend()==T){
      # Turn off Labels if Layer Removed
      if("Subcatchments"%in%removed_groups()){
        if("Subcatchment Labels"%in%old_groups()){label_sc(T)}else{label_sc(F)}
        proxy%>%hideGroup("Subcatchment Labels")
      }
      if("Links"%in%removed_groups()){
        if("Link Labels"%in%old_groups()){label_link(T)}else{label_link(F)}
        proxy%>%hideGroup("Link Labels")
      }
      if("Nodes"%in%removed_groups()){
        if("Node Labels"%in%old_groups()){label_node(T)}else{label_node(F)}
        proxy%>%hideGroup("Node Labels")
      }
      
      # Add Labels if they were turned on before Layer Removed
      if("Subcatchments"%in%added_groups()){
        if(!is.na(label_sc())){
          if(label_sc()==T){
            proxy%>%showGroup("Subcatchment Labels")
          }
        }
      }
      if("Links"%in%added_groups()){
        if(!is.na(label_link())){
          if(label_link()==T){
            proxy%>%showGroup("Link Labels")
          }
        }
      }
      if("Nodes"%in%added_groups()){
        if(!is.na(label_node())){
          if(label_node()==T){
            proxy%>%showGroup("Node Labels")
          }
        }
      }
    }
    # Control Labels for Dynamic View; Display only at certain zoom levels and don't display if layer is hidden
    else{
      proxy%>%groupOptions("Subcatchment Labels",zoomLevels=if("Subcatchments"%in%input$map_groups){13:18}else{NULL})
      proxy%>%groupOptions("Link Labels",zoomLevels=if("Links"%in%input$map_groups){16:18}else{NULL})
      proxy%>%groupOptions("Node Labels",zoomLevels=if("Nodes"%in%input$map_groups){16:18}else{NULL})
    }
  })

  output$map=renderLeaflet({map()})
  

  ##### Summarize Number of Green, Yellow, and Red for Objects -----------------------------------------
  SC_summary=reactive({
    # If Symbolize Turned On
    if((input$symbolize_sc==T)){
      summary=subset(SC_run_max(),SC_run_max()$Variable==unlist(sc_var_key[input$Variable_sc],use.names=F))%>% # Get only selected variable
        group_by(ID,Variable)%>%
        summarise(Green=sum(Max<=sc_slider()[1]),
                  Yellow=sum(Max>sc_slider()[1] & Max<=sc_slider()[2]),
                  Red=sum(Max>sc_slider()[2]))
      # Convert to Percentages
      summary$Green_Pct=summary$Green/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Yellow_Pct=summary$Yellow/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Red_Pct=summary$Red/rowSums(summary[,c("Green","Yellow","Red")])
    }
    # Otherwise empty dataframe
    else{
      summary=setNames(data.frame(matrix(ncol=8,nrow=0)),c("ID","Variable","Green","Yellow","Red","Green_Pct","Yellow_Pct","Red_Pct")) # Create Empty Dataframe
    }
    summary
  })

  Link_summary=reactive({
    # If Symbolize Turned On
    if((input$symbolize_link==T)){
      summary=subset(Link_run_max(),Link_run_max()$Variable==unlist(link_var_key[input$Variable_link],use.names=F))%>% # Get only selected variable
        group_by(ID,Variable)%>%
        summarise(Green=sum(Max<=link_slider()[1]),
                  Yellow=sum(Max>link_slider()[1] & Max<=link_slider()[2]),
                  Red=sum(Max>link_slider()[2]))
      # Convert to Percentages
      summary$Green_Pct=summary$Green/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Yellow_Pct=summary$Yellow/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Red_Pct=summary$Red/rowSums(summary[,c("Green","Yellow","Red")])
    }
    # Otherwise empty dataframe
    else{
      summary=setNames(data.frame(matrix(ncol=8,nrow=0)),c("ID","Variable","Green","Yellow","Red","Green_Pct","Yellow_Pct","Red_Pct")) # Create Empty Dataframe
    }
    summary
  })

  Node_summary=reactive({
    # If Symbolize Turned On
    if((input$symbolize_node==T)){
      summary=subset(Node_run_max(),Node_run_max()$Variable==unlist(node_var_key[input$Variable_node],use.names=F))%>% # Get only selected variable
        group_by(ID,Variable)%>%
        summarise(Green=sum(Max<=node_slider()[1]),
                  Yellow=sum(Max>node_slider()[1] & Max<=node_slider()[2]),
                  Red=sum(Max>node_slider()[2]))
      # Convert to Percentages
      summary$Green_Pct=summary$Green/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Yellow_Pct=summary$Yellow/rowSums(summary[,c("Green","Yellow","Red")])
      summary$Red_Pct=summary$Red/rowSums(summary[,c("Green","Yellow","Red")])
    }
    # Otherwise empty dataframe
    else{
      summary=setNames(data.frame(matrix(ncol=8,nrow=0)),c("ID","Variable","Green","Yellow","Red","Green_Pct","Yellow_Pct","Red_Pct")) # Create Empty Dataframe
    }
    summary
  })

  ### Prepare data table for selected object
  selected_summary=reactive({
    summary=switch(map_type(),
                   "Subcatchment"=subset(SC_summary(),SC_summary()$ID==toString(map_id()),use.names=F),
                   "Link"=subset(Link_summary(),Link_summary()$ID==toString(map_id()),use.names=F),
                   "Node"=subset(Node_summary(),Node_summary()$ID==toString(map_id()),use.names=F))
    # Transpose Data and Rename
    summary=data.frame(t(summary[,c("Green_Pct","Yellow_Pct","Red_Pct")]))
    rownames(summary)=c("Green","Yellow","Red")
    setDT(summary, keep.rownames = TRUE)[]
    
    # Add Min/Max of Range to Table
    green_max=switch(map_type(),
                     "Subcatchment"=sc_slider()[1],
                     "Link"=link_slider()[1],
                     "Node"=node_slider()[1])
    yellow_max=switch(map_type(),
                      "Subcatchment"=sc_slider()[2],
                      "Link"=link_slider()[2],
                      "Node"=node_slider()[2])
    red_max=switch(map_type(),
                   "Subcatchment"=slider_sc_max(),
                   "Link"=slider_link_max(),
                   "Node"=slider_node_max())
    
    summary$Min=c(0,green_max,yellow_max)
    summary$Max=c(green_max,yellow_max,red_max)
    
    # Rename/Reorder Columns
    if(ncol(summary)==4){
      colnames(summary)=c("Range","Percent of Run Peaks","Range Min.","Range Max.")
      summary=summary[,c("Range","Range Min.","Range Max.","Percent of Run Peaks")]
    }
    summary
  })

  ### Render Output Datatable
  output$selected_summary=DT::renderDataTable(datatable(selected_summary(),
                                                        caption=tags$caption(style="text-align:center;padding-bottom:0px;color:#333333 !important;font-weight:bold;font-size:14px;text-decoration:underline",
                                                        str_wrap(paste0(map_type()," ",map_id()," ",map_var()," (",plot_units(),")"),35)),
                                                        rownames=F,
                                                        options=list(dom="t",columnDefs=list(list(className="dt-center",targets="_all"))))%>%
                                                formatRound(2:3,2)%>%
                                                formatPercentage(4,1)%>%
                                                formatStyle(0,target="row","line-height"="80%"))

  ### Hide Table if switches set to off
  observe({
    if((map_type()=="Subcatchment"&input$symbolize_sc==T)|
       (map_type()=="Link"&input$symbolize_link==T)|
       (map_type()=="Node"&input$symbolize_node==T)){
      shinyjs::show(id="selected_summary")
    } else{
      shinyjs::hide(id="selected_summary")
    }
  })
  

  ##### Group Analysis -----------------------------------------------------

  ### Reactive Values to store SWMM objects to use in group analysis
  group_sc=reactiveVal(select_group_sc)
  group_link=reactiveVal(select_group_link)
  group_node=reactiveVal(select_group_node)
  
  ### Create Add/Remove from Group Analysis Button
  output$group_button=renderUI({
    req(map_type(),map_id())
    actionButton('group_button',width="225px",style="white-space:pre-wrap;font-size:95%;font-weight:bold",label={"test"
      if(map_type()=="Subcatchment"){
        if(length(input[[paste0("sc_", map_id())]])>0){
          if(input[[paste0("sc_", map_id())]]==T){
            HTML("Remove Subcatchment From\nGroup Analysis")
          }
          else if(input[[paste0("sc_", map_id())]]==F){
            HTML("Add Subcatchment To\nGroup Analysis")
          }
        } else{
          HTML(" \n ")
        }
      }
      else if(map_type()=="Link"){
        if(length(input[[paste0("link_", map_id())]])>0){
          if(input[[paste0("link_", map_id())]]==T){
            HTML("Remove Link From\nGroup Analysis")
          }
          else if(input[[paste0("link_", map_id())]]==F){
            HTML("Add Link To\nGroup Analysis")
          }
        } else{
          HTML(" \n ")
        }
      }
      else if(map_type()=="Node"){
        if(length(input[[paste0("node_", map_id())]])>0){
          if(input[[paste0("node_", map_id())]]==T){
            HTML("Remove Node From\nGroup Analysis")
          }
          else if(input[[paste0("node_", map_id())]]==F){
            HTML("Add Node To\nGroup Analysis")
          }
        } else{
          HTML(" \n ")
        }
      }
    })
  })
  
  ### Update Inputs when button is clicked
  observeEvent(input$group_button,{
    if(map_type()=="Subcatchment"){
      if(input[[paste0("sc_", map_id())]]==T){
        updateCheckboxInput(session,paste0("sc_", map_id()),value=F)
      }
      else if(input[[paste0("sc_", map_id())]]==F){
        updateCheckboxInput(session,paste0("sc_", map_id()),value=T)
      }
    }
    else if(map_type()=="Link"){
      if(input[[paste0("link_", map_id())]]==T){
        updateCheckboxInput(session,paste0("link_", map_id()),value=F)
      }
      else if(input[[paste0("link_", map_id())]]==F){
        updateCheckboxInput(session,paste0("link_", map_id()),value=T)
      }
    }
    else if(map_type()=="Node"){
      if(input[[paste0("node_", map_id())]]==T){
        updateCheckboxInput(session,paste0("node_", map_id()),value=F)
      }
      else if(input[[paste0("node_", map_id())]]==F){
        updateCheckboxInput(session,paste0("node_", map_id()),value=T)
      }
    }
  })
  
  ### Summary Data Table
  group_analysis=reactive({
    table=setNames(data.frame(matrix(ncol=15,nrow=0)),c("Type","Count","Variable","Green_Min","Green_Max","Green_Pct","Green_Run_Pct","Yellow_Min","Yellow_Max","Yellow_Pct","Yellow_Run_Pct","Red_Min","Red_Max","Red_Pct","Red_Run_Pct")) # Create Empty Dataframe
    
    # Subcatchments
    if(input$symbolize_sc==T){
      # Get Data
      SC_data=subset(SC_summary(),SC_summary()$ID%in%group_sc(),use.names=F)

      # Determine if peak is in Green, Yellow, or Red range
      SC_data$Max=unlist(lapply(SC_data$ID,function(X){
        if(SC_data[which(SC_data$ID==X),"Red"]>0){
          "Red"
        }
        else if(SC_data[which(SC_data$ID==X),"Yellow"]>0){
          "Yellow"
        }
        else if(SC_data[which(SC_data$ID==X),"Green"]>0){
          "Green"
        }
      }))
      
      # Calculate Values
      SC_count=length(group_sc())
      SC_variable=paste0(input$Variable_sc,"\n(",format_units(input$Variable_sc),")")
      SC_green_min=0
      SC_green_max=sc_slider()[1]
      SC_yellow_min=sc_slider()[1]
      SC_yellow_max=sc_slider()[2]
      SC_red_min=sc_slider()[2]
      SC_red_max=slider_sc_max()
      SC_green_pct=length(which(SC_data$Max=="Green"))/SC_count
      SC_yellow_pct=length(which(SC_data$Max=="Yellow"))/SC_count
      SC_red_pct=length(which(SC_data$Max=="Red"))/SC_count
      SC_green_run_pct=sum(SC_data$Green_Pct)/SC_count
      SC_yellow_run_pct=sum(SC_data$Yellow_Pct)/SC_count
      SC_red_run_pct=sum(SC_data$Red_Pct)/SC_count
      
      # Add Data to Table
      table[nrow(table)+1,]=c("Subcatchment",SC_count,SC_variable,SC_green_min,SC_green_max,SC_yellow_min,SC_yellow_max,SC_red_min,SC_red_max,SC_green_pct,SC_yellow_pct,SC_red_pct,SC_green_run_pct,SC_yellow_run_pct,SC_red_run_pct)
    }
    
    # Links
    if(input$symbolize_link==T){
      # Get Data
      Link_data=subset(Link_summary(),Link_summary()$ID%in%group_link(),use.names=F)
      
      # Determine if peak is in Green, Yellow, or Red range
      Link_data$Max=unlist(lapply(Link_data$ID,function(X){
        if(Link_data[which(Link_data$ID==X),"Red"]>0){
          "Red"
        }
        else if(Link_data[which(Link_data$ID==X),"Yellow"]>0){
          "Yellow"
        }
        else if(Link_data[which(Link_data$ID==X),"Green"]>0){
          "Green"
        }
      }))
      
      # Calculate Values
      Link_count=length(group_link())
      Link_variable=paste0(input$Variable_link,"\n(",format_units(input$Variable_link),")")
      Link_green_min=0
      Link_green_max=link_slider()[1]
      Link_yellow_min=link_slider()[1]
      Link_yellow_max=link_slider()[2]
      Link_red_min=link_slider()[2]
      Link_red_max=slider_link_max()
      Link_green_pct=length(which(Link_data$Max=="Green"))/Link_count
      Link_yellow_pct=length(which(Link_data$Max=="Yellow"))/Link_count
      Link_red_pct=length(which(Link_data$Max=="Red"))/Link_count
      Link_green_run_pct=sum(Link_data$Green_Pct)/Link_count
      Link_yellow_run_pct=sum(Link_data$Yellow_Pct)/Link_count
      Link_red_run_pct=sum(Link_data$Red_Pct)/Link_count
      
      # Add Data to Table
      table[nrow(table)+1,]=c("Link",Link_count,Link_variable,Link_green_min,Link_green_max,Link_yellow_min,Link_yellow_max,Link_red_min,Link_red_max,Link_green_pct,Link_yellow_pct,Link_red_pct,Link_green_run_pct,Link_yellow_run_pct,Link_red_run_pct)
    }
    
    # Nodes
    if(input$symbolize_node==T){
      # Get Data
      Node_data=subset(Node_summary(),Node_summary()$ID%in%group_node(),use.names=F)
      
      # Determine if peak is in Green, Yellow, or Red range
      Node_data$Max=unlist(lapply(Node_data$ID,function(X){
        if(Node_data[which(Node_data$ID==X),"Red"]>0){
          "Red"
        }
        else if(Node_data[which(Node_data$ID==X),"Yellow"]>0){
          "Yellow"
        }
        else if(Node_data[which(Node_data$ID==X),"Green"]>0){
          "Green"
        }
      }))
      
      # Calculate Values
      Node_count=length(group_node())
      Node_variable=paste0(input$Variable_node,"\n(",format_units(input$Variable_node),")")
      Node_green_min=0
      Node_green_max=node_slider()[1]
      Node_yellow_min=node_slider()[1]
      Node_yellow_max=node_slider()[2]
      Node_red_min=node_slider()[2]
      Node_red_max=slider_node_max()
      Node_green_pct=length(which(Node_data$Max=="Green"))/Node_count
      Node_yellow_pct=length(which(Node_data$Max=="Yellow"))/Node_count
      Node_red_pct=length(which(Node_data$Max=="Red"))/Node_count
      Node_green_run_pct=sum(Node_data$Green_Pct)/Node_count
      Node_yellow_run_pct=sum(Node_data$Yellow_Pct)/Node_count
      Node_red_run_pct=sum(Node_data$Red_Pct)/Node_count
      
      # Add Data to Table
      table[nrow(table)+1,]=c("Node",Node_count,Node_variable,Node_green_min,Node_green_max,Node_yellow_min,Node_yellow_max,Node_red_min,Node_red_max,Node_green_pct,Node_yellow_pct,Node_red_pct,Node_green_run_pct,Node_yellow_run_pct,Node_red_run_pct)
    }
    table
  })
  
  ### Create Output Table
  output$group_analysis=DT::renderDataTable(datatable(group_analysis(),
                                            rownames=F,
                                            options=list(dom="t",columnDefs=list(list(className="dt-center",targets="_all"))),
                                            container=withTags(table(
                                              class="display",
                                              thead(
                                                tr(
                                                  th(rowspan=2,"Object Type"),
                                                  th(rowspan=2,"Number of Selected Objects"),
                                                  th(rowspan=2,"Parameter"),
                                                  th(colspan=2,"Green Range"),
                                                  th(colspan=2,"Yellow Range"),
                                                  th(colspan=2,"Red Range"),
                                                  th(colspan=3,"Worst-Case Scenario: Overall Peak Value For Each Object (% of Selected Objects)"),
                                                  th(colspan=3,"All Simulations: Individual Timeseries Peaks (% of Timeseries)")
                                                ),
                                                tr(
                                                  lapply(c(rep(c("Min.","Max."),3),rep(c("Green","Yellow","Red"),2)),th)
                                                )
                                              )
                                            )),
                                            caption=tags$caption(
                                              style="caption-side:bottom;text-align:left;white-space:pre-wrap",
                                              em("Range minimums and maximums are based on slider selections\n  Worst-Case Scenario represents the percentage of selected objects with an overall peak simulated value (maximum simulated parameter value from all SWMM simulations) within the Green/Yellow/Red range\n  Individual Timeseries Peaks output represents the percentage of the simulated timeseries for all selected objects (# of SWMM simulations x # of selected objects) with a peak within the Green/Yellow/Red range")
                                            )
                                            )%>%
                                              formatPercentage(10:15,1)%>%
                                              formatStyle(c(5,7),borderRight="1px solid #ddd")%>%
                                              formatStyle(c(3,9,12),borderRight="1px solid black"))
  
  ### Create datatables to select objects for group analysis; adapted from: https://github.com/rstudio/DT/issues/93#issuecomment-111001538
  # create a character vector of shiny inputs
  shinyInput = function(FUN, len, id, value, ...) {
    inputs = character(len)
    for (i in seq_len(len)) {
      inputs[i] = as.character(FUN(id[i], label = NULL, value = value[i], ...))
    }
    inputs
  }
  
  # obtain the values of inputs
  shinyValue = function(id, len) {
    unlist(lapply(seq_len(len), function(i) {
      value = input[[id[i]]]
      if (is.null(value)) NA else value
    }))
  }
  
  ### Create Table of All Subcatchments and whether or not to include in group analysis
  group_analysis_sc=reactive({
    # Get IDs
    ID=unique(SC()$ID)

    # Create Data table with checkbox Input
    table=data.frame(
      ID=ID,
      Selected=shinyInput(checkboxInput,length(ID),paste0("sc_",ID),value=unlist(lapply(ID,function(X){X%in%select_group_sc}))),
      stringsAsFactors=F
    )
  })
  
  output$group_analysis_sc=DT::renderDataTable(group_analysis_sc(),server=F,escape=F,selection="none",
                                               options=list(
                                                 paging=F,
                                                 preDrawCallback=JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
                                                 drawCallback=JS('function() { Shiny.bindAll(this.api().table().node()); } ')
                                               ))
  ### Create Table of All Links and whether or not to include in group analysis
  group_analysis_link=reactive({
    # Get IDs
    ID=unique(Link()$ID)
    
    # Create Data table with checkbox Input
    table=data.frame(
      ID=ID,
      Selected=shinyInput(checkboxInput,length(ID),paste0("link_",ID),value=unlist(lapply(ID,function(X){X%in%select_group_link}))),
      stringsAsFactors=F
    )
  })
  
  output$group_analysis_link=DT::renderDataTable(group_analysis_link(),server=F,escape=F,selection="none",
                                               options=list(
                                                 paging=F,
                                                 preDrawCallback=JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
                                                 drawCallback=JS('function() { Shiny.bindAll(this.api().table().node()); } ')
                                               ))
  ### Create Table of All Nodes and whether or not to include in group analysis
  group_analysis_node=reactive({
    # Get IDs
    ID=unique(Node()$ID)
    
    # Create Data table with checkbox Input
    table=data.frame(
      ID=ID,
      Selected=shinyInput(checkboxInput,length(ID),paste0("node_",ID),value=unlist(lapply(ID,function(X){X%in%select_group_node}))),
      stringsAsFactors=F
    )
  })
  
  output$group_analysis_node=DT::renderDataTable(group_analysis_node(),server=F,escape=F,selection="none",
                                               options=list(
                                                 paging=F,
                                                 preDrawCallback=JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
                                                 drawCallback=JS('function() { Shiny.bindAll(this.api().table().node()); } ')
                                               ))

  
  ### List of whether or not to include subcatchments in group analysis
  selected_sc=reactive({
    ID=unique(SC()$ID)
    table=data.frame(
      ID=ID,
      Selected=shinyValue(paste0("sc_",ID),length(ID)),
      stringsAsFactors=F
    )
    table
  })
  
  ### List of whether or not to include subcatchments in group analysis
  selected_link=reactive({
    ID=unique(Link()$ID)
    table=data.frame(
      ID=ID,
      Selected=shinyValue(paste0("link_",ID),length(ID)),
      stringsAsFactors=F
    )
    table
  })
  
  ### List of whether or not to include nodes in group analysis
  selected_node=reactive({
    ID=unique(Node()$ID)
    table=data.frame(
      ID=ID,
      Selected=shinyValue(paste0("node_",ID),length(ID)),
      stringsAsFactors=F
    )
    table
  })
  
  ### Clear Inputs when buttons are clicked
  shinyClear = function(id, len) {
    lapply(seq_len(len),function(i){updateCheckboxInput(session,id[i],value=F)})
  }
  
  observeEvent(input$clear_sc,{
    ID=unique(SC()$ID)
    shinyClear(paste0("sc_",ID),length(ID))
  })
  
  observeEvent(input$clear_link,{
    ID=unique(Link()$ID)
    shinyClear(paste0("link_",ID),length(ID))
  })
  
  observeEvent(input$clear_node,{
    ID=unique(Node()$ID)
    shinyClear(paste0("node_",ID),length(ID))
  })
  
  ### Update lists for group analysis
  observeEvent(selected_sc(),{group_sc(selected_sc()[which(selected_sc()$Selected==T),"ID"])})
  observeEvent(selected_link(),{group_link(selected_link()[which(selected_link()$Selected==T),"ID"])})
  observeEvent(selected_node(),{group_node(selected_node()[which(selected_node()$Selected==T),"ID"])})

  ##### Save Outputs to Environment Whenever Value Changes -----------------------------------------------
  observeEvent(SREF_data(),{Output_SREF_data<<-as.data.frame(SREF_data())})
  observeEvent(SREF_SC_results(),{Output_SREF_SC_results<<-as.data.frame(SREF_SC_results())})
  observeEvent(SREF_Node_results(),{Output_SREF_Node_results<<-as.data.frame(SREF_Node_results())})
  observeEvent(SREF_Link_results(),{Output_SREF_Link_results<<-as.data.frame(SREF_Link_results())})
  
  observeEvent(HRRR_data(),{Output_HRRR_data<<-as.data.frame(HRRR_data())})
  observeEvent(HRRR_SC_results(),{Output_HRRR_SC_results<<-as.data.frame(HRRR_SC_results())})
  observeEvent(HRRR_Node_results(),{Output_HRRR_Node_results<<-as.data.frame(HRRR_Node_results())})
  observeEvent(HRRR_Link_results(),{Output_HRRR_Link_results<<-as.data.frame(HRRR_Link_results())})
  
  observeEvent(ANC_data(),{Output_ANC_data<<-as.data.frame(ANC_data())})
  observeEvent(ANC_SC_results(),{Output_ANC_SC_results<<-as.data.frame(ANC_SC_results())})
  observeEvent(ANC_Node_results(),{Output_ANC_Node_results<<-as.data.frame(ANC_Node_results())})
  observeEvent(ANC_Link_results(),{Output_ANC_Link_results<<-as.data.frame(ANC_Link_results())})
  
  observeEvent(HREF_data(),{Output_HREF_data<<-as.data.frame(HREF_data())})
  observeEvent(HREF_SC_results(),{Output_HREF_SC_results<<-as.data.frame(HREF_SC_results())})
  observeEvent(HREF_Node_results(),{Output_HREF_Node_results<<-as.data.frame(HREF_Node_results())})
  observeEvent(HREF_Link_results(),{Output_HREF_Link_results<<-as.data.frame(HREF_Link_results())})
  
  observeEvent(group_sc(),{Output_group_sc<<-group_sc()})
  observeEvent(group_link(),{Output_group_link<<-group_link()})
  observeEvent(group_node(),{Output_group_node<<-group_node()})
  
  ##### Save Outputs to File -----------------------------------------------
  session$onSessionEnded(function(){
    
    ### Save Group Analysis File
    group=read.delim("App/group_analysis.r",header=F,col.names="line") # Read group analysis file
    levels(group$line)[grep("select_group_sc",levels(group$line))]=gsub(", ","','",paste0("select_group_sc=c('",toString(Output_group_sc,sep=""),"')")) # Save Subcatchments
    levels(group$line)[grep("select_group_link",levels(group$line))]=gsub(", ","','",paste0("select_group_link=c('",toString(Output_group_link,sep=""),"')")) # Save Links
    levels(group$line)[grep("select_group_node",levels(group$line))]=gsub(", ","','",paste0("select_group_node=c('",toString(Output_group_node,sep=""),"')")) # Save Nodes
    write.table(group,file="App/group_analysis.r",append=F,row.names=F,col.names=F,quote=F) # Write new file
    
    ### Save Outputs
    write_feather(Output_SREF_data,"App/www/Output/SREF_data.feather")
    write_feather(Output_SREF_SC_results,"App/www/Output/SREF_SC_results.feather")
    write_feather(Output_SREF_Node_results,"App/www/Output/SREF_Node_results.feather")
    write_feather(Output_SREF_Link_results,"App/www/Output/SREF_Link_results.feather")
    write_feather(Output_HRRR_data,"App/www/Output/HRRR_data.feather")
    write_feather(Output_HRRR_SC_results,"App/www/Output/HRRR_SC_results.feather")
    write_feather(Output_HRRR_Node_results,"App/www/Output/HRRR_Node_results.feather")
    write_feather(Output_HRRR_Link_results,"App/www/Output/HRRR_Link_results.feather")
    write_feather(Output_ANC_data,"App/www/Output/ANC_data.feather")
    write_feather(Output_ANC_SC_results,"App/www/Output/ANC_SC_results.feather")
    write_feather(Output_ANC_Node_results,"App/www/Output/ANC_Node_results.feather")
    write_feather(Output_ANC_Link_results,"App/www/Output/ANC_Link_results.feather")
    write_feather(Output_HREF_data,"App/www/Output/HREF_data.feather")
    write_feather(Output_HREF_SC_results,"App/www/Output/HREF_SC_results.feather")
    write_feather(Output_HREF_Node_results,"App/www/Output/HREF_Node_results.feather")
    write_feather(Output_HREF_Link_results,"App/www/Output/HREF_Link_results.feather")
  })

}