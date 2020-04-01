ui=tagList(
  tags$head(
    useShinyjs(), # Set up Shinyjs
    # Script to track if map clicked vs. dropdown menu clicked for updating plot/buttons
    tags$script(HTML("$(document).on('click', '.last_input', function () {
                                Shiny.onInputChange('last_click',this.id);
                             });")),
    
    # Script & CSS Stylesheets for Sliders
    tags$script(src="GUI/js/ion.rangeSlider.min.js"),
    HTML('<link rel="stylesheet" href="GUI/css/ion.rangeSlider.css"/>'),
    HTML('<link rel="stylesheet" href="GUI/css/ion.rangeSlider.skinShiny.css"/>'),
    
    tags$title("PUFFIN | Probabilistic Urban Flash Flood Information Nexus"),
    tags$style(HTML(".navbar-default {display:none;}", # Hide NavBar by Default
                    ".help-button {color:black;}", # Text Color for help buttons on tabs
                    ".help-button:hover {color:gray;}", #Hover Text Color for help buttons on tabs
                    ".help-button:focus {color:black;outline:0;}", #Changes help buttons back to black after clicking on them

                    # CSS for sliders
                    ".irs-from {color: #333; background: rgba(0,0,0,0.25);font-weight: bold;}",
                    ".irs-to {color: #333; background: rgba(0,0,0,0.25);font-weight: bold;}",
                    ".irs-min {font-size: 11px; font-weight: bold;}",
                    ".irs-max {font-size: 11px; font-weight: bold;}",
                    ".irs-line-left {background: #66b032;width: 50%;}",
                    ".irs-line-mid {background: #FFBF00;width:0 !important;}",
                    ".irs-line-right {background: #FF0000;width: 50%;}",
                    ".irs-bar {background: #FFBF00 !important;border: 0;}",
                    ".color-slider {border:0 !important;}",
                    
                    "#group_analysis_table th {text-align: center !important;}", # Center Group Analysis Table Headers
                    
                    # Reduce Margin on group analysis checkboxes
                    ".checkbox {margin-bottom:0px !important;margin-top:0px !important}",
                    "#group_sc .form-group{margin-bottom:0px}",
                    "#group_link .form-group{margin-bottom:0px}", 
                    "#group_node .form-group{margin-bottom:0px}", 

                    ".shiny-output-error { visibility: hidden; }",         # Hide Error Messages
                    ".shiny-output-error:before { visibility: hidden; }"   # Hide Error Messages
    )),
    
    # Add Icon for Website
    tags$link(rel = "shortcut icon", href = "GUI/favicon-puffin.ico"),
    tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "GUI/favicon-puffin.ico"),
    tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "GUI/favicon-32x32.png"),
    tags$link(rel = "icon", type = "image/png", sizes = "16x16", href = "GUI/favicon-16x16.png")
  ),
  navbarPage('PUFFIN',id="Pages",collapsible=T,
             tabPanel(title="Home",value="home",
                      div(style='background-image: url("GUI/Background.png");background-size:100% 100%;width:100%;height:100%;position:absolute;left:0',
                          div(class="flex-container",style="display:flex;flex-direction:row;flex-wrap:wrap;justify-content:flex-start;font-size:120%;margin-left:20px",
                              div(HTML('<div><img style="min-width:150px;max-width:375px;top:1vh;padding:10px;margin-bottom:-10px" src="GUI/Puffin.png" alt="Puffin"></div>')),
                              div(
                                HTML('<div>
                                        <span style="line-height:11vmin;font-size:6vmin;position:relative;top:2vh;white-space:nowrap"><b>Welcome To</b></span><br>
                                        <span style="font-family:Impact;font-size:15vmin;line-height:15vmin;position:relative;"><b>PUFFIN</b></span><br>
                                        <p style="line-height:3vmin;font-size:3vmin;max-width:44vmax"><b>Probabilistic Urban Flash Flood Information Nexus</b></p>
                                      </div>')
                              )
                          ),
                          HTML('<img style="position:absolute;top:0.5vh;right:1vw;min-width:100px;display:inline-block;vertical-align:top;width:13.5%;float:right" src="GUI/Logos.png" alt="Logos">'),
                          HTML('&nbsp'),
                          HTML('<h3></h3>'),
                          div(style="text-align:center;font-size:5vh;",HTML('<p><b>What Would You Like To View?</b></p>')),
                          div(style="text-align:center;",
                              div(style="display:inline-block;padding:20px",actionButton('button_forecast', label=NULL,style="width:30vh;height:35vh;min-width:200px;min-height:233px;background:url('GUI/Forecast_Button.png');background-size:cover;background-position:center")),
                              div(style="display:inline-block;padding:20px",actionButton('button_settings', label=NULL,style="width:30vh;height:35vh;min-width:200px;min-height:233px;background:url('GUI/Settings_Button.png');background-size:cover;background-position:center"))
                          ),
                          hr(),
                          HTML('<h3 align=center><b>For Questions, Please Contact <a href="mailto:cbrendel@vt.edu">cbrendel@vt.edu</a></b></h3>'))
                      ),
             tabPanel(title="Forecast",value="forecast",
                      div(style="display:inline-block;vertical-align:top;width:23em;line-height:90%",
                          div(div(style="display:inline-block",h4(tags$b("Update Forecasts:"))),div(style="display:inline-block",actionButton("help_update_forecasts",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          div(
                            div(style="display:inline-block",actionButton('update_forecast',label="Manual Update")),
                            div(style="display:inline-block",prettySwitch('auto_update',label="Auto Update?",fill=T,status="primary",inline=T,bigger=T))
                          ),
                          div(style="font-size:80%;",
                            DT::dataTableOutput("forecast_summary")
                          ),
                          div(div(style="display:inline-block",h4(tags$b("Find SWMM Object:"))),div(style="display:inline-block",actionButton("help_find_object",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          div(style="padding:0px",
                            div(style="display:inline-block;vertical-align:top;width:150px;",
                                div(id="type",class="last_input",selectInput('swmm_object_type',label="Type:",choices=c("Subcatchment","Link","Node")))),
                            div(style="display:inline-block;vertical-align:top;width:150px",uiOutput("plot_id"))
                          ),
                          div(div(style="display:inline-block",h4(tags$b("Map/Plot Settings:"))),div(style="display:inline-block",actionButton("help_map_plot",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          HTML('<div id="plot_forecasts" class="form-group shiny-input-checkboxgroup shiny-input-container shiny-input-container-inline">
                            <label class="control-label" for="plot_forecasts">Select Forecasts to Map/Plot:</label>
                            <div class="shiny-options-group">
                              <div class="pretty p-default">
                                <input type="checkbox" name="plot_forecasts" value="anc" checked="checked"/>
                                <div class="state p-danger">
                                  <label>
                                    <span>ANC</span>
                                  </label>
                                </div>
                              </div>
                              <div class="pretty p-default">
                                <input type="checkbox" name="plot_forecasts" value="hrrr" checked="checked"/>
                                <div class="state p-warning">
                                  <label>
                                    <span>HRRR</span>
                                  </label>
                                </div>
                              </div>
                              <div class="pretty p-default">
                                <input type="checkbox" name="plot_forecasts" value="href" checked="checked"/>
                                <div class="state p-success">
                                  <label>
                                    <span>HREF</span>
                                  </label>
                                </div>
                              </div>
                              <div class="pretty p-default">
                                <input type="checkbox" name="plot_forecasts" value="sref" checked="checked"/>
                                <div class="state p-info">
                                  <label>
                                    <span>SREF</span>
                                  </label>
                                </div>
                              </div>
                            </div>
                          </div>'),
                          div(
                            div(style="display:inline-block;vertical-align:middle;width:80%",uiOutput("plot_vars_sc")),
                            div(style="display:inline-block;vertical-align:middle;padding-top:20px",prettySwitch("symbolize_sc",bigger=T,label=NULL,fill=T,status="primary",inline=T))
                          ),
                          div(id="sc_slider",uiOutput("map_colors_sc")),
                          div(
                            div(style="display:inline-block;vertical-align:middle;width:80%",uiOutput("plot_vars_link")),
                            div(style="display:inline-block;vertical-align:middle;padding-top:20px",prettySwitch("symbolize_link",bigger=T,label=NULL,fill=T,status="primary",inline=T))
                          ),
                          div(id="link_slider",uiOutput("map_colors_link")),
                          div(
                            div(style="display:inline-block;vertical-align:middle;width:80%",uiOutput("plot_vars_node")),
                            div(style="display:inline-block;vertical-align:middle;padding-top:20px",prettySwitch("symbolize_node",bigger=T,label=NULL,fill=T,status="primary",inline=T))
                          ),
                          div(id="node_slider",uiOutput("map_colors_node")),
                          div(div(style="display:inline-block",h4(tags$b("Select View:"))),div(style="display:inline-block",actionButton("help_view",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          radioButtons("tabview",label=NULL,choices=c("Map/Plots","Group Analysis"),inline=T)
                      ),
                      div(style="display:inline-block;width: calc(100vw - 27em);min-width:500px", #Set Width to 100% of View Width -27em
                          div(id="group_analysis",class="outer",tags$style(type="text/css",".outer{position:fixed;top:5em;left:25em;right:1em;bottom:1em;overflow-y:scroll;padding:0}"),
                              div(div(style="display:inline-block",h4(tags$b("Group Analysis Summary:"))),div(style="display:inline-block",actionButton("help_group_analysis",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                              div(id="group_analysis_table",style="white-space:pre-wrap;padding-right:15px",DT::dataTableOutput("group_analysis")),
                              HTML('<div class="container">
                               <img style="display:block;margin-left:auto;margin-right:auto;width:500px;padding:10px" src="GUI/GroupAnalysis.png" alt="Group Analysis">
                               </div>'),
                              hr(),
                              div(class="flex-container",style="display:flex;flex-direction:row;flex-wrap:wrap;justify-content:space-around;",
                                  div(id="group_sc",style="font-size:80%;line-height:80%",
                                      div(div(style="display:inline-block;vertical-align:middle",h4(tags$b("Selected Subcatchments:"))),div(style="display:inline-block;vertical-align:middle",actionButton("clear_sc",label="Clear All Subcatchments",style="font-size:95%;"))),
                                      DT::dataTableOutput("group_analysis_sc")
                                  ),
                                  div(id="group_link",style="font-size:80%;line-height:80%",
                                      div(div(style="display:inline-block;vertical-align:middle",h4(tags$b("Selected Links:"))),div(style="display:inline-block;;vertical-align:middle",actionButton("clear_link",label="Clear All Links",style="font-size:95%;"))),
                                      DT::dataTableOutput("group_analysis_link")
                                  ),
                                  div(id="group_node",style="font-size:80%;line-height:80%",
                                      div(div(style="display:inline-block;vertical-align:middle",h4(tags$b("Selected Nodes:"))),div(style="display:inline-block;;vertical-align:middle",actionButton("clear_node",label="Clear All Nodes",style="font-size:95%;"))),
                                      DT::dataTableOutput("group_analysis_node")
                                  )
                              )
                          ),
                          div(id="map_plot",class="last_input",
                            div(class="outer",tags$style(type="text/css",".outer{position:fixed;top:5em;left:25em;right:1em;bottom:1em;overflow-y:scroll;padding:0;background-color:white}"),
                                leafletOutput("map",height="70%"),
                                div(style="display:flex;height:30%",
                                div(style="position:relative;text-align:left;max-width:20%;font-size:85%;",
                                    div(id="selected_table",DT::dataTableOutput("selected_summary")),
                                    div(style="text-align:center;padding-top:10px",uiOutput("group_button"))
                                ),
                                div(style="position:relative;margin-left:auto;width:87.5%;min-width:67.5%",
                                  plotOutput("plot",height="100%",hover=hoverOpts("plot_hover",delay=100,delayType="debounce")),
                                  uiOutput("hover_info")),
                                div(style="position:relative;margin-left:auto;width:12.5%;min-width:160px",
                                    plotOutput("boxplot",height="100%",hover=hoverOpts("boxplot_hover",delay=100,delayType="debounce")),
                                    uiOutput("boxplot_hover_info"))
                                )
                            )
                          )
                      )
             ),
             tabPanel(title="Settings",value="settings",
                      div(class="flex-container",style="display:flex;flex-direction:row;flex-wrap:wrap;justify-content:space-around;font-size:120%",
                        div(
                          div(div(style="display:inline-block",HTML('<h3 style="font-weight:bold;text-decoration:underline">Input Files:</h3>')),div(style="display:inline-block",actionButton("help_input_files",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          fileInput('upload_inp',label="Select SWMM .inp",accept=c(".inp")),
                          fileInput('upload_shp',label="Select Subcatchments Shapefile",multiple=T),
                          div(
                            div(div(style="display:inline-block",HTML('<h3 style="font-weight:bold;text-decoration:underline">SWMM Settings:</h3>')),div(style="display:inline-block",actionButton("help_swmm_settings",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                            selectInput('report_ts',label="Reporting Time Step (h:m:s)",
                                        choices=c("00:10:00","00:15:00","00:20:00","00:30:00","01:00:00"),
                                        selected=report_ts),
                            numericInput('SWMM_SCF',label="Snow Catch Factor",value=SWMM_SCF,step=0.001)
                          )
                        ),
                        div(
                          div(div(style="display:inline-block",HTML('<h3 style="font-weight:bold;text-decoration:underline">ANC Forecast Settings:</h3>')),div(style="display:inline-block",actionButton("help_anc_settings",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          radioButtons('ANC_coefficients',label="Assign NWS coefficients",
                                       choices=c("Manually"=F,"Automatically"=T),
                                       selected=auto_coefficient),
                          div(id="anc_manual",
                              numericInput('a',label='NWS "a" Coefficient',value=a,step=0.001),
                              numericInput('b',label='NWS "b" Coefficient',value=b,step=0.001)
                          ),
                          div(id="anc_auto",
                              selectInput("nws_region",label="Select NWS River Forecast Center",
                                          choices=c("Middle Atlantic","Ohio","Lower Mississippi"),
                                          selected=auto_center),
                              uiOutput("anc_id"),
                              uiOutput("anc_values")
                          )
                        ),
                        div(
                          div(div(style="display:inline-block",HTML('<h3 style="font-weight:bold;text-decoration:underline">PUFFIN Precipitation Settings:</h3>')),div(style="display:inline-block",actionButton("help_interpolation",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          radioButtons('interpolate_precip',label="Select Spatial Method",
                                       choices=c("Interpolate"=T,"Nearest"=F),
                                       selected=interpolate_precip),
                          div(
                            div(style="display:inline-block",HTML('<label class="control-label">Warn Me If Forecast Peak Precipitation Intensities Exceed Threshold?</label>')),
                            div(style="display:inline-block",prettySwitch('precip_warning',label=NULL,fill=T,status="primary",inline=T,bigger=T)),
                            uiOutput("threshold")
                          ),
                          div(div(style="display:inline-block",HTML('<h3 style="font-weight:bold;text-decoration:underline">PUFFIN/SWMM Output Parameters:</h3>')),div(style="display:inline-block",actionButton("help_outputs",label="",icon=icon("question-circle"),class="help-button",style="height:0px;width:0px;padding:0px;padding-bottom:25px;border:none;background:none"))),
                          div(style="display:inline-block;vertical-align:top",
                            checkboxGroupInput('sc_vars',label="SWMM Subcatchment Summary Parameters",
                                               choices=c("Rainfall Rate"=0,
                                                         "Snow Depth"=1,
                                                         "Evaporation Loss"=2,
                                                         "Infiltration Loss"=3,
                                                         "Runoff Flow"=4,
                                                         "Groundwater Flow Into Drainage Network"=5,
                                                         "Groundwater Elevation"=6,
                                                         "Soil Moisture in Unsaturated Groundwater Zone"=7
                                               ),
                                               selected=sc_vars)
                          ),
                          div(style="display:inline-block;vertical-align:top",
                              checkboxGroupInput('link_vars',label="SWMM Link Summary Parameters",
                                                 choices=c("Flow Rate"=0,
                                                           "Average Water Depth"=1,
                                                           "Flow Velocity"=2,
                                                           "Volume of Water"=3,
                                                           "Capacity"=4
                                                 ),
                                                 selected=link_vars)
                          ),
                          div(style="display:inline-block;vertical-align:top",
                              checkboxGroupInput('node_vars',label="SWMM Node Summary Parameters",
                                                 choices=c("Water Depth"=0,
                                                           "Hydraulic Head"=1,
                                                           "Stored Water Volume"=2,
                                                           "Lateral Inflow"=3,
                                                           "Total Inflow"=4,
                                                           "Surface Flooding"=5
                                                 ),
                                                 selected=node_vars)
                          )
                        )
                      ),
                      div(style="text-align:center;",
                          div(style="display:inline-block;padding:20px",actionButton('button_save_settings',label="Save Default Settings",style="width:200px;height:60px;font-size:120%;font-weight:bold;background-color:rgba(0,153,204,0.6)")),
                          div(style="display:inline-block;padding:20px",actionButton('button_clear',label="Clear PUFFIN Data",style="width:200px;height:60px;font-size:120%;font-weight:bold;background-color:rgba(255,0,0,0.6)"))
                      )
             )
           )
)