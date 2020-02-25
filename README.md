# PUFFIN
Probabilistic Urban Flash Flood Information Nexus

This repository holds files necessary to run the Probabilistic Urban Flash Flood Information (PUFFIN) application. The PUFFIN platform integrates hydrologic and hydraulic modeling, high-resolution quantitative precipitation forecasting, and ensemble forecasting into a tool to evaluate the probability of an urban flash flood event and to identify specific infrastructure components at risk.

## Getting Started
These instructions will help you get a copy of PUFFIN up and running on your local machine.

### Required Software
To run PUFFIN, you must have both R and the EPA SWMM model software installed on your local machine.\
PUFFIN was developed and tested using R version 3.6.2.

R: https://www.r-project.org/ \
EPA SWMM: https://www.epa.gov/water-research/storm-water-management-model-swmm

Installing an R environment (e.g. Console R, Rgui, Rstudio, etc.) is optional, but highly recommended.\
RStudio Software: https://www.rstudio.com/products/rstudio/download/

### Download PUFFIN
#### Method 1:
The easiest way to download PUFFIN is by downloading the PUFFIN files from GitHub as a ZIP folder and unzipping it to your desired directory.

#### Setup wgrib2
PUFFIN uses the NCEP wgrib2 program to read and extract forecast data from retrieved GRIB files. An overview of wgrib2 can be found here: https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/

PUFFIN includes a precompiled version of the wgrib2 program. However, in order for PUFFIN to use the program, wgrib2 must be added to your system path. In Windows 10, you can do this by:
1) Open the Start Search, type in "env", and choose "Edit the system environment variables"
2) Click the "Environment Variables..." button
3) Under the "System Variables" section (the lower half), click on the row with "Path" in the first column, and click edit
4) The "Edit environment variable" UI will appear. Click "New" and add the path to the wgrib2 folder included in PUFFIN e.g. "[user path]\PUFFIN\App\www\wgrib2"

### Run PUFFIN
PUFFIN can be run by running the "RunApp.R" script from the R console or through any R environment. RStudio makes it easy to run Shiny apps, and you can run PUFFIN as follows:
1) Open RStudio
2) Open the "PUFFIN.Rproj" R project file
3) Open the "RunApp.R" script
4) Click RStudio's "Run App" button

## Author
* **Conrad Brendel** - cbrendel@vt.edu

## License
This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
