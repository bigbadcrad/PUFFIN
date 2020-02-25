##### Set Default Settings -----------------------------------------------
### SWMM Reporting Time Step
#   - Needs to be >= 10 minutes because ANC forecast time step is 10 minutes and SWMM requires reporting time step to be >= precipitation time step
#   - Choose a larger value to reduce run time
#   - Format is Hours:Minutes:Seconds
report_ts=00:10:00
### SWMM Snow Catch Factor
#  - Factor that corrects gage readings for snowfall
#  - Use 1.0 for no adjustment
SWMM_SCF=1
### Choose whether to interpolate precipitation time series for each subcatchment or use time series from nearest SREF/ANC grid cell
#   T=Interpolate precipitation time series from SREF grid
#   F=Use precipitation from nearest SREF grid/average from nearest grids if multiple grids are same distance
interpolate_precip=FALSE
### Precipitation Warning Message Threshold
precip_threshold=2.5
### Choose whether to manually set NWS a and b coefficient values or to automatically retrieve them for the NWS empirical relationship between reflectivity and rainfall: R=aZ^b
#   T=automatically retrieve coefficient
#   F=manually set coefficient
auto_coefficient=TRUE
### If automatically retrieving coefficient, then specify NWS river forecast center and Radar ID
# Center options are: Middle Atlantic,Ohio,Lower Mississippi
auto_center="Middle Atlantic"
auto_id="FCX (Blacksburg)"
### If manually retrieving coefficient, then specify a and b values
a=300
b=1.4
### Default SWMM Subcatchment Summary Parameters
#   - 0: Rainfall Rate, 1: Snow Depth, 2: Evaporation Loss, 3: Infiltration Loss, 4: Runoff Flow, 5: Groundwater Flow Into Drainage Network
#     6: Groundwater Elevation, 7: Soil Moisture in Unsaturated Groundwater Zone
sc_vars=c(0, 4)
### Default SWMM Link Summary Parameters
#   - 0: Flow Rate, 1: Average Water Depth, 2: Flow Velocity, 3: Volume of Water, 4: Capacity
link_vars=c(0, 4)
### Default SWMM Node Summary Parameters
#   - 0: Water Depth, 1: Hydraulic Head, 2: Stored Water Volume, 3: Lateral Inflow, 4: Total Inflow, 5: Surface Flooding
node_vars=c(0, 5)
