  # MacroGas Project
  
  Welcome to the MacroGas Project repository!

  ## About

The MacroGas project is dedicated to developing two R Shiny Apps that cater to the needs of stream ecologists for data analysis. These apps aim to streamline and enhance the process of cleaning, visualizing, performing quality assurance/quality control (QA/QC), and conducting calculations to gain deeper insights into the chemistry of New Hope Creek.

The Salt Slug App has been designed for NaCl conservative tracer (also known as salt slugs) injection studies. It allows researchers to upload their data, perform QA/QC functions, then calculate stream discharge (Q), groundwater exchange  (Q<sub>n</sub> - Q<sub>1</sub>), and time to half height (t<sub>1/2</sub>).

The HydroGas App is designed to visualize uploaded variables, such as dissolved oxygen (DO), greenhouse gases (GHGs) like CO<sub>2</sub> and CH<sub>4</sub>, water temperature, conductivity, pressure, and salinity, then perform QA/QC functions, download the melted data, and view DO and hypoxia metrics and visualizations.

Both apps will create a more efficient and user-friendly platform for analyzing data, thereby contributing to the advancement of stream ecology research and environmental understanding.


  ## Salt Slug App Functions
**Home**

The home page serves as a hub for the Salt Slug App. It includes a [resource link](http://dx.doi.org/10.1029/2011WR010942) to the publication by *Covino et al. (2011)* where our calculation methods are used, along with any other relevant information.
  
**Upload**

The upload page allows users to import two types of data into the app: CSVs exported from HOBOware and CSVs that adhere to a specific format.
Here are some instructions for using this page:

1. **'Clean' CSVs Upload**: To upload 'clean' CSVs, simply press the "Download File" button to access the 'clean CSVs'. These CSVs have already been formatted to meet the app's standards.

2. **HOBO Data Upload**: If you are uploading HOBO data, rest assured that the app will automatically clean and adjust the data to meet the required standards. When uploading HOBO data, please ensure to enter the correct station number before uploading each new file. 

3. **Multiple Stations Upload**: Clean CSVs can be uploaded either as individual files for each station or as a single CSV file that correctly identifies each station within the station column.

4. **Remove Incorrect Files**: In case of accidental uploads of the wrong files, you can easily rectify the situation. Just select the incorrect dataset within the 'Your uploaded files' dropdown and choose 'Remove selected dataset'.

   *This app is designed to handle data from one experiment at a time. Please avoid uploading data from multiple salt slug experiments.*

**Trim**

The Trim page provides the function of cleaning the data you uploaded. It displays a plot showing the data points for all stations that you have uploaded. Here's how you can use the trim page:

1. **Move the Vertical Bars**: To remove excess data from the breakthrough curves, drag the vertical bars to encompass the relevant portions you want to keep. As you move the bars, the graph on the right will automatically update to reflect the changes you've made. This trimmed data will be carried forward and used throughout the rest of the app.

2. **Continue**: Once you are happy with the trim you've made, simply press the "Continue" button to proceed with the trimmed data. Please be aware that the data will be permanently updated. If you wish to make the selected bounds larger after continuing, you will need to re-upload the data. 

**QA/QC**

Quality Assurance/Quality Control page allows you to efficiently flag data points to ensure data accuracy. Here's a quick overview of the QA/QC page:

1. **Select Station**: Choose the station you wish to view and analyze from the available options.

2. **Select Variable**: Once you've selected a station, you can easily switch between different variables to view the associated data for each one.

3. **Flag Data Points**: Ensure that the 'box select' option is chosen from the top right of the graph. After box selecting the points you want to flag, choose from 'interesting', 'bad', or 'questionable' options, and then click on 'Flag selected points'.

4. **Remove Flagged Points**: To do this, simply repeat the same process but set the flag type to 'NA'.

5. **Zoom for Precision**: For more precise flagging, zoom in to specific areas before box selecting points to ensure accurate data flagging.

**Calculate**

The Calculate page enables users to calculate stream discharge (Q), groundwater exchange (Q<sub>n</sub> - Q<sub>1</sub>), and time to half height (t<sub>1/2</sub>). An output summary table will display the result. Users can download flagged dataset and summary table. Here's how you can effectively use this page:

1. **Visualize Data**: You can visualize the data and observe breakthrough curves on this page. Additionally, you can manually adjust parameters for calculation to tailor the analysis to their specific needs.

2. **Enter Background Conductivity**: Background conductivity can be obtained by observing the graph and identifying the baseline value before the curve.

3. **Enter Salt Slug Mass**: Provide the mass of salt used in your salt slug experiment.

4. **Graph Interaction**: Interact with the graph by double-clicking to zoom out and hover over data points to view their values.

     *For comprehensive analysis, follow this process for each station you wish to evaluate.*

6. **Download Output Table**: Once calculations are completed for all stations, an output table containing summary statistics will be presented. To retain a complete record of your analysis, download this table.

  ## HydroGas App Functions
    
**Upload**

The Upload page allows users to upload csv files. Once the file has been uploaded, you can choose 'Skip First Row' to remove the first row of the datatable.  Enter a station and site name, then dataset can be added. 

**QA/QC**

The QA/QC page allows you to efficiently flag data points on the plot for further analysis and identification. Follow these steps to make the most of this page:

1. **Variable Display**: Once your data is uploaded, the variables will be displayed below for your reference.

2. **Summary Statistics**: Select the 'Summary' tabset to view summary statistics of each variable, including mean, median, maximum, minimum, standard deviation, 25<sup>th</sup>, 50<sup>th</sup> and 75<sup>th</sup> quartiles.

3. **Flag Points**: To flag data points, ensure that the "box select" option is chosen from the top-right corner of the graph. Then, choose from the options 'interesting', 'bad', or 'questionable', and click 'Flag selected points'. The flagged points will be highlighted in a new color on the graph.

4. **Remove Flagged Points**: To remove flagged points, repeat the same process but set the flag type to 'NA'.

5. **Save the data**: When you are finished flagging, you can save your data to Google Drive.

**View**

This page allows you to conveniently view variables associated with your selected site and station from all processed files within the google drive. To get started, simply choose the date range you want to view the data from.

**DO Data and Metrics**

The DO Data and Metrics page displays mean, minimum, maximum, amplitude, and probability of hypoxia across selected range of data, it provides functionality to assess hypoxia probability and summary statistics within your dataset. You have the flexibility to input the hypoxia threshold (in mg/L) for conducting thorough analyses. 

## Missing Data Imputation

Missing data imputation is a statistical technique used to predict or estimate missing values in a dataset. In our field data, missing data points can arise due to various reasons, such as malfunctioning sensors, data collection errors, and technical issues.

To address missing data, we have tested several imputation methods: 
1. **K-Nearest Neighbors (KNN)**: This method estimates missing values by considering the values of neighboring locations. It assumes that similar locations have similar values, making it suitable for spatial data.

2. **Regression Imputation**: This method utilizes regression models to predict missing values based on other variables in the dataset. It captures relationships between variables to impute missing data accurately.

3. **Mean Imputation**: This simple method replaces missing values with the mean values of observed data for the respective variable. It is a quick approach but may not capture underlying patterns in the data.

In the gap_filling folder, we have imputation codes in gap-filling.Rmd file. In this file, we tested filling a dataset which we manually deleted some DO values with all the three methods, and the results are all pretty good. The Mean Squared Error(MSE) of each method are around 0.2. For imputation work in the future, you just need to upload your own csv file with missing values to replace the Test.csv in the gap-filling.Rmd. However, our models are mostly based on time of a day and temperature. If you want to include more variables for imputation or prediction, you may need to adjust the format of the current models.

## Dependencies

To run this project successfully, you will need to have **R Studio** installed on your system. Additionally, ensure that the following R packages are installed:

- shiny
- reactlog
- plotly
- DT
- htmlwidgets
- shinyjs
- shinyFiles
- shinyTime
- sortable
- googledrive
- readr
- shinyBS
- tidyverse
- dplyr
- shinythemes
- lubridate
- knitr
- kableExtra
- reshape2
- ggplot2
- data.table
- janitor
- remotes
- streamMetabolizer

If any of these packages are missing, you can install them using the `install.packages()` function in R.

## Getting Started

1. Make sure you have R Studio and required packages installed on your computer. 
2. To get started with the Salt Slug App, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/salt_slug_app.git'
3. To get started with the Gas App, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/gas_app.git'
4. To carry out missing data imputations, clone the repository by running the following command: 'git clone https://github.com/some-tortoise/macroGas/edit/main/gap_filling.git'

## Acknowledgments

Project Lead: Emily Bernhardt, Ph.D. 

Project Manager: Nick Marzolf, Ph.D.

Project Contributers: Alejandro Breen, Anna Spitzer, Kaley Sperling, Qinhan Wen, Yiliang Yuan


