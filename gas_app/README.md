  # HydroGas App
  
  Welcome to the HydroGas App repository!

  ## About
  
The HydroGas App is a tool designed to analyze sensor data. It provides users with an intuitive interface to visualize their data, conduct user-led quality assurance and quality control checks, calculate key metrics such as discharge, time to half height, and groundwater exchange for a given experiment.

This app was created in collaboration with the Bernhardt Lab at Duke University.

  ## Features and Instructions
  
**Home**

The Home page provides an overview of the app.

**Upload**

The Upload page allows users to upload csv files one at a time. Once the file has been uploaded, you can choose 'Skip First Row' to remove the first row of the datatable. The app will guess the station and site name along with the variable names of the file, but you can also manually enter/set these. After this, the dataset can be added to a combined dataframe. 

**QA/QC**

The QA/QC page allows you to flag data points on the plot. Follow these steps to use this page:

1. The variables will be displayed below once you have uploaded your data.
2. Select "Summary" tabset to view summary statistics of each variable, including mean, median, and standard deviation.
3. To flag points, make sure that the "box select" option is selected in the top-right of the graph. Choose from the options "interesting", "bad", or "questionable" and click "Flag selected points".
The flagged points will be highlighted in a new color on the graph.
4. To remove flagged points, repeat the same process but set the flag type to "NA".

*For more precise flagging, utilize the zoom features in the top-right corner of the graph before selecting points.*

5. Once you finish flagging, remember to save your data.

**View**

This page allows you to view the variables associated with your selected site and station from all processed files in the google drive. To get started, simply choose the date range to view the data.

**DO Data and Metrics**

The DO Data and Metrics page provides functionality to assess hypoxia probability and summary statistics within your dataset. You have the flexibility to input the hypoxia threshold (in mg/L) for conducting thorough analyses. 

## Getting Started
To get started with this app, make sure you have R Studio installed on your computer. Then, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/gas_app.git'

#
*For detailed instructions and information about each page's functionalities, please refer to the app itself!*

*(Feel free to modify and expand upon this README!)*
