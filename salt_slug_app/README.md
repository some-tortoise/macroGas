  # Salt Slug App
  Welcome to the Salt Slug App repository!

  ## About
The Salt Slug App has been designed to provide users with a convenient way to analyze their conservative tracer/salt slug data. It allows users to upload their data from either Google Drive or locally, flag points of interest, visualize their data, and perform calculations for discharge and time to half height.

This app was created for the Bernhardt Lab at Duke University, with the aim of assisting researchers in their analysis of tracer data.

  ## Features and Instructions
**Home**

The home page serves as a hub for the Salt Slug App. It includes a [resource link](http://dx.doi.org/10.1029/2011WR010942) to the publication by *Covino et al. (2011)* where our calculation methods are used, along with any other relevant information.
  
**Upload**

The upload page supports two types of data uploads, CSVs exported from HOBOware and CSVs that adhere to a specific format ('clean CSVs'). Users are guided through the process of formatting and uploading their data files. Here are some important instructions for using the upload page:

1. If you wish to upload 'clean' CSVs, press the "Download File" button to see the 'clean CSVs'.
2. If you upload HOBO data, it will be cleaned to meet the app's standards before continuing.
3. When uploading HOBO data, make sure to enter the correct station number before uploading each new file.
4. Clean CSVs can be uploaded as individual files for each station or as one CSV file that identifies each station correctly within the station column.
5. If you accidentally upload the wrong file, simply select it within the 'Your uploaded files' dropdown and choose 'Remove selected dataset'.

   *This app is designed to handle data from one experiment at a time. Please avoid uploading data from multiple salt slug experiments.*

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

Calculate page performs *discharge*, *groundwater excharge*  and *time to half height* calculations. Here's how you can use this page:

1. Manually enter the background conductivity, found by looking at the graph and seeing the baseline of conductivity before the curve.
2. Enter the mass of salt used in your salt slug.
3. Double click to zoom out of the graph and hover over a point to see its values.
4. Do this process in full for each station. When finished with all stations, the average discharge and groundwater exchange across all sites will be displayed.

## Getting Started
To get started with the Salt Slug App, make sure you have R Studio installed on your computer. Then, clone the repository by running the following command: 
'git clone https://github.com/some-tortoise/macroGas/edit/main/salt_slug_app.git'

#
*Please refer to the app itself for detailed instructions and each page’s functionalities.*

*(Feel free to modify and expand upon this README!)*
