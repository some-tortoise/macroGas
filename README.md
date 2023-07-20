  # MacroGas Project
  
  Welcome to the MacroGas Project repository!

  ## About

The MacroGas project aims to make analyzing stream ecological data easier through the development of two R Shiny apps. 

The Salt Slug App has been designed for conservative tracer injection studies which use NaCl (salt slugs). It allows researchers to upload their data, perform quality assurance/quality control (QA/QC) functions, then calculate stream discharge (Q), groundwater exchange  (Q<sub>n</sub> - Q<sub>1</sub>), and time to half height (t<sub>1/2</sub>).

The GHG Visualization App is designed to take raw sensor data collected about dissolved oxygen (DO) and greenhouse gas (GHG) levels in streams, then perform QA/QC functions, visualize these data, and calculate various metrics such as hypoxia probability and summary statistics.

Both apps will create a more efficient and user-friendly platform for analyzing data, thereby contributing to the advancement of stream ecology research and environmental understanding.


  ## Salt Slug App Functions
**Home**

The home page serves as a hub for the Salt Slug App, providing users with an overview of its features and functionality. It also includes a [resource link](http://dx.doi.org/10.1029/2011WR010942) to the publication by *Covino et al. (2011)* where our calculation methods are used , along with any other relevant information.
  
**Upload**

The upload page allows users to download a data template and import their CSV file(s) into the app, either from Google Drive or locally. Users are guided through the process of formatting and uploading their data files. Here are some important instructions for using the upload page:

1. The "Download File" button contains a CSV with an example breakthrough curve in the required formatting. You can use this data to get familiar with using the app.
2. Match your CSV files to the example formatting. If your data is missing certain fields, you can create the respective column and leave it blank (except for 'Station'). Column naming conventions must match.
   *Please note that only data from a single tracer injection experiment should be uploaded at a time.*
3. If uploading through Google Drive, ensure that the CSV formatting matches the required format. In Google Drive, set the access for each CSV to "Anyone with the link" under the "Share" option. Paste the drive link from the "Copy Link" button within "Share" into the app. Please provide links to individual CSV files, as links to folders will not work.
4. Repeat the process for each station.

**Trim**

The Trim page provides the function of cleaning the data you uploaded. It displays a plot showing the data points for each station that you have uploaded. Here's how you can use the trim page:

1. Adjust the vertical bars on the plot to define the start and end points of the data you want to trim.
2. As you move the bars, a separate plot will update to show the trimmed data in real-time.
3. Fine-tune the position of the bars until you have selected the desired portion of the data.
4. Once you are satisfied with the trim, click the "Continue" button to save your changes and proceed to the QA/QC page.

**QA/QC**

Quality Assurance/Quality Control page allows you to select a station and view the associated data. You can change the variable you are viewing and interact with the plot to flag data points. Here's a quick overview of the QA/QC page:

1. Select a station you would like to view.
2. Once selected, you can change the variable you are viewing.
3. Click on one or multiple points on the plot.
4. Use the button above to flag the selected points.

**Calculate**

Calculate page performs stream discharge (Q), groundwater exchange  (Q<sub>n</sub> - Q<sub>1</sub>), and time to half height (t<sub>1/2</sub>) calculations. Users can visualize the data, manually adjust parameters for calculation, and observe the corresponding results. An output table will display the result. Users can download flagged dataset and output table.


  ## GHG App Functions
    
**Home**

The Home page provides an overview of the app.

**Upload**

The Upload page allows users to upload csv files.

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

This page allows you to view the variables associated with your selected site and station from the uploaded file. To get started, simply choose the date range to view the data.

**DO Data and Metrics**

The DO Data and Metrics page provides functionality to assess hypoxia probability and summary statistics within your dataset. You have the flexibility to input the hypoxia threshold (in mg/L) for conducting thorough analyses. 

## Gap Filling - Missing Values Imputation
  
## Getting Started

1. Make sure you have R Studio installed on your computer. 
2. To get started with the Salt Slug App, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/salt_slug_app.git'
3. To get started with this app, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/gas_app.git'

#
*For detailed instructions and information about each page's functionalities, please refer to the apps.*

