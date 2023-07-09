  # Salt Slug App
  Welcome to the Salt Slug App repository!

  ## About
The Salt Slug App has been designed to provide users with a convenient way to analyze their conservative tracer/salt slug data. It allows users to upload their data from either Google Drive or locally, flag points of interest, visualize their data, and perform calculations for discharge and time to half height.

This app was created for the Bernhardt Lab at Duke University, with the aim of assisting researchers in their analysis of tracer data.

  ## Features and Instructions
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
3. Click on a point or select multiple points on the plot to the right.
4. Use the buttons on the left to flag the selected points.

**Calculate**

Calculate page performs area calculations. Users can visualize the data, manually adjust parameters for calculation, and observe the corresponding results. An output table will display the calculated discharges for each stations.

## Getting Started
To get started with the Salt Slug App, make sure you have R Studio installed on your computer. Then, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/salt_slug_app.git'

#
*Please refer to the app itself for detailed instructions and each page’s functionalities.*

*(Feel free to modify and expand upon this README!)*
