#
# BASIC UI 
#

# A renderUI for the background conductivity input, as well as explanation of how we calculate it
output$background_out <- renderUI({
  req(goop$calc_curr_station_df)
  fluidRow(
    column(width = 8,
           numericInput("background", label = "Background conductivity, (µS/cm):", value = goop$background)
    ),
    column(width = 2,
           actionButton("enterbackground", label = "Enter")
    )
  )
}) 


output$salt_out <- renderUI({
  req(goop$calc_curr_station_df)
  fluidRow(
    column(width = 8,
           numericInput("salt_mass", label = "NaCl Mass (g):", value = 0)
    ),
    column(width = 2,
           actionButton("entersalt", label = "Enter")
    )
  )
}) 


# A renderUI that creates a dropdown to select from the stations that have been uploaded
output$calc_station <- renderUI({
  if(!is.null(goop$combined_df)){
    selectInput("calc_station_picker", label = "Choose A Station", sort(unique(goop$combined_df$station)))
  }else{
    HTML("<label>Choose A Station<br></br></label>")
  }
}) 


#
# PLOT 
#

# Filters to the subset of rows that has the correct station the user inputs, then stores in goop$calc_curr_station_df
observeEvent(input$calc_station_picker, {
  goop$calc_curr_station_df <- goop$combined_df[goop$combined_df$station %in% input$calc_station_picker, ]
})

# Assigns Date_Time to the x-axis, Low_Range to the y-axis 
observe({
  goop$calc_xValue <- goop$calc_curr_station_df$Date_Time
  goop$calc_yValue <- goop$calc_curr_station_df$Low_Range
}) 

# Setting the indices of the left and right trim bars 
observe({
  goop$calc_xLeft <- goop$calc_xValue[1] # Left bar
  goop$calc_xRight <- goop$calc_xValue[length(goop$calc_xValue) - 1] # Right bar
}) 

# Setting the background conductivity to a rough mean of the data
observeEvent(input$calc_station_picker, {
  goop$background <- round(((mean(goop$calc_curr_station_df$Low_Range)) - 5), 2)
}) 

# Assigns what the user inputs to the background conductivity numericInput to the reactive value goop$background (overwrites our guess)
observeEvent(input$enterbackground,{
  goop$background <- input$background
}) 

# Assigns what the user inputs to the background conductivity numericInput to the reactive value goop$background (overwrites our guess)
observeEvent(input$entersalt,{
  goop$Mass_NaCl <- input$salt_mass
}) 

# Renders the plot of the breakthrough curve data
output$dischargecalcplot <- renderPlotly({
  
  #requirements 
  req(goop$calc_curr_station_df) 
  req(goop$calc_xLeft) 
  req(goop$calc_xRight)
  
  #relabeling for shorter code
  xVal <- goop$calc_xValue
  yVal <- goop$calc_yValue
  xLeft <- goop$calc_xLeft
  xRight <- goop$calc_xRight
  
  #creates xfill column that assigns xVal if it's w/in range set by xLeft and xRight, fills NA otherwise
  #gets used later to addtrace
  goop$calc_curr_station_df$xfill <- ifelse(
    as.numeric(xVal) > as.numeric(xLeft) & as.numeric(xVal) < as.numeric(xRight),
    xVal,
    NA
  )
  
  # Converts xLeft and xRight to as.POSIXct date/time values
  xLeft <- as.POSIXct(xLeft, tz = 'EST', origin = "1970-01-01")
  xRight <- as.POSIXct(xRight, tz = 'EST', origin = "1970-01-01")
  
  # Plot is based on goop$calc_curr_station_df
  p <- plot_ly(goop$calc_curr_station_df, x = ~Date_Time, y = ~Low_Range, 
          type = 'scatter', mode = 'lines', source = "R") %>%
    # Trace and fill added where xfill isn't NA (between two vertical lines)
    add_trace(x = ~as.POSIXct(goop$calc_curr_station_df$xfill, tz = 'EST', origin = "1970-01-01"), y = ~Low_Range) %>%
    add_trace(x = ~as.POSIXct(goop$calc_curr_station_df$xfill, tz = 'EST', origin = "1970-01-01"), y = ~goop$background, fill = 'tonextx', fillcolor = 'rgba(255, 165, 0, 0.3)', line = list(color = 'black')) %>%
    layout(
      xaxis = list(title = "Date and Time"), 
      yaxis = list(title = "Low Range Conductivity"),
      showlegend = FALSE, shapes = list(
      # Left vertical line
      list(type = "line", x0 = xLeft, x1 = xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # Right vertical line
      list(type = "line", x0 = xRight, x1 = xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    # Gets rid of Plotly modebar and allows the vertical lines to be editable by user
    config(displayModeBar = FALSE, edits = list(shapePosition = TRUE))
  
  p
}) 

# Updating the vertical bar positions based on the user interaction
observeEvent(event_data("plotly_relayout", source = "R"), { 
  ed <- event_data("plotly_relayout", source = "R")   # Retrieves  event data when the user interacts with the Plotly ('r' is plot)
  shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))] # Extracts shape anchors from event data
  
  if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # Checks if the event data contains shapes to get rid of NA error when user isn't clicking a shape
  barNum <- as.numeric(substring(names(ed)[1],8,8)) # Get the bar number (0 for left bar and 1 for right bar) from the first shape name
  if(is.na(barNum)){ return() } # Secondary error checking to see if we got any NAs. This line should never be called
  
  row_index <- unique(readr::parse_number(names(shape_anchors)) + 1)   # Get the index of the row (shape number) from the shape anchors
  
  pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'EST', origin = "1970-01-01") # convert shape anchors to date-time format 
  
  # Updates the left or right bar position based on the user interaction
  if(barNum == 0){
    goop$calc_xLeft <- 0
    goop$calc_xLeft <- pts[1]
  }else if(barNum == 1){
    goop$calc_xRight <- 0
    goop$calc_xRight <- pts[1]
  }
}) 

#
# OUTPUT, MATH, TABLE
#

# Creates goop$trimmed_slug based on goop$calc_curr_station_df that only contains values between the left and right bars 
observe({
  goop$trimmed_slug <- goop$calc_curr_station_df[(as.numeric(goop$calc_xValue) >= as.numeric(goop$calc_xLeft)) & (as.numeric(goop$calc_xValue) <= as.numeric(goop$calc_xRight)), ]
}) 

# Creates new dataframe to store discharge and time to half height values, assigns to goop$dischargeDF
observeEvent(goop$combined_df, {
  zero <- c()
  which_station <- c()
  
  for(i in unique(goop$combined_df$station)){
    zero <- c(zero, 0) #assigns discharge value of 0 initially to each column
    which_station <- c(which_station, paste0('Station ', i))
  } #for loop to name the columns after each unique station in goop$combined_df 

  a <- data.frame('Station' = which_station,
                  'Discharge' = zero,
                  'Half_Height' = zero)
  goop$dischargeDF <- a
}) 

# Math to calculate discharge
output$dischargeOutput <- renderText({
  
  # Requirements
  req(goop$combined_df)
  req(goop$trimmed_slug)
  
  # Returns N/A if no data is uploaded
  if(is.null(goop$combined_df) || is.null(goop$trimmed_slug)){
    return('Discharge: N/A')
  }
  
  # Renaming reactives
  station_slug <- goop$trimmed_slug # using trimmed_slug which is only the values between two vertical bars
  
  # Get how many seconds are between consecutive observations (important to calculate area under the curve)
  diff_time_btwn_observations = as.numeric(goop$combined_df$Date_Time[2]) - as.numeric(goop$combined_df$Date_Time[1])
  
  # Creates/calculates an NaCl_Conc and Area column at each observation
  station_slug <- station_slug %>%
    mutate(NaCl_Conc = 
             ifelse((Low_Range - as.numeric(goop$background)) > 0, 
                    (Low_Range - as.numeric(goop$background)) * 0.00047, # .00047 is a constant to convert to NaCl concentration
                    0),
           Area = NaCl_Conc * diff_time_btwn_observations) 
  
  Area <- sum(station_slug$Area) # Area under the curve is the sum of the Area column
  
  if(is.null(goop$Mass_NaCl)){
    Discharge = 0
    }else{
    Discharge = round(goop$Mass_NaCl / Area, 2)
    } # Round the discharge to 2 points
  
  # Updates the 'Discharge' column in goop$dischargeDF for the rows where the 'Station' column matches the selected station name from the input 'calc_station_picker'
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'Discharge'] <- Discharge 
  
  return(paste0('Discharge: ', Discharge, ' L/s')) 
   
 }) 

# Math to calculate time to half height
output$halfheightOutput <- renderText({
  
  # Requirements
  req(goop$combined_df)
  req(goop$trimmed_slug)
  
  # Return N/A if data is missing
  if(length(goop$trimmed_slug) <= 1){
    if(is.null(goop$combined_df) || is.null(goop$trimmed_slug) || is.na(goop$trimmed_slug)){ 
      return('Time to half height: N/A')
    }
  }
  
  # Renaming reactive values
  station_slug <- goop$trimmed_slug
  start_time <- goop$calc_xLeft
  
  # Identify the max conductivity (highest point on the BTC) and its index
  Cmax <- max(station_slug$Low_Range)
  index_Cmax <- which(station_slug$Low_Range == Cmax)[1]

  # Identify the index of the beginning of the salt slug (using the start time from the left vertical bar)
  index_start_time <- which.min(abs(station_slug$Date_Time - start_time))

  # Calculates the half height conductivity value 
  Chalf <- (goop$background + (1/2)*(Cmax - goop$background))
  
  # Doesn't calculate if the start time is after the breakthrough curve
  if(index_start_time >= index_Cmax){
    return(paste0('Time to half height: ', "NA seconds"))
  }
  
  # Identifies index of half height by identifying the index of the smallest difference (the point closest to being half height)
  index_Chalf <- which.min(abs(station_slug$Low_Range[index_start_time:index_Cmax] - Chalf)) 

  
  # Calculate the time to half height as Chalf_time - start_time
  start_time <- station_slug$Date_Time[index_start_time] # Extract the start_time from the 'station_slug' data frame using the index 'index_start_time'
  Chalf_time <- station_slug$Date_Time[index_Chalf] # Extract the Chalf_time from the 'station_slug' data frame using the index 'index_Chalf'
  time_to_half <- ((as.numeric(Chalf_time) - as.numeric(start_time))) 
  
  # Update Half_Height in goop for the rows where station column matches the user input in calc_station_picker
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'Half_Height'] <- time_to_half 
  
  return(paste0('Time to half height: ', time_to_half, " seconds"))
  

})

# Math to calculate groundwater exchange
output$groundwaterOutput <- renderUI({
  req(goop$combined_df)
  if(!('1' %in% unique(goop$combined_df$station))){
    return(p('Please make sure you have a station 1.')) # Need to have a station 1 in order to do this calculation, this checks it exists
  }
  
  last_station <- max(as.numeric(unique(goop$combined_df$station))) # Gets the last station number by finding the maximum numeric value in the 'station' column.

  # Need more than 1 station, checks that only station available isn't just 'station 1'
  if(last_station == 1){
    return(p('Need more than one station.'))
  } 
  
  # Gets discharge values from goop$dischargeDF for the first and last stations
  first_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == 'Station 1', 'Discharge'])
  last_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', last_station), 'Discharge'])
  
  if(first_station_discharge == 0 || last_station_discharge == 0){
    return(p('NA'))
  }
  
  # Calculate exchange by subtracting last station from first station discharge
  diff <- first_station_discharge - last_station_discharge
  
  p(paste0(diff, ' L/s'))
})

# Math to calculate average discharge
output$avgDischargeOutput <- renderUI({
  if(length(unique(goop$combined_df$station)) == 0){
    return(p('Need at least one station'))
  }
  
  sum <- 0
  for(i in as.numeric(unique(goop$combined_df$station))){
    curr_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', i), 'Discharge'])
    if(is.null(curr_discharge) || is.na(curr_discharge) || curr_discharge == 0){
      return(p('Get discharge for all stations'))
    }
    sum <- sum + curr_discharge
  }
  
  
  mean <- sum / length(unique(goop$combined_df$station))
  p(paste0(mean,' L/s'))
})

# Updates the output table when goop$combined_df changes and formats it using kableExtra package  
observeEvent(goop$combined_df, {
  output$dischargetable <- function() {
    goop$dischargeDF %>% # Pipes goop$dischargeDF into kable function for style purposes 
      knitr::kable("html", col.names =
                     c("Station", "Discharge (L/s)", "Time to Half Height (sec)")) %>%
      kable_styling("striped", full_width = F)
  }
})


#
# DOWNLOAD OUTPUT
#

# Modal dialog when someone selects download button
observeEvent(input$downloadOutputTable, {
  showModal(modalDialog(
    title = 'How do you want to download your dataset?',
    downloadButton('downloadBtnDischarge', 'Download'),
    actionButton('upload_to_gdrive', 'Upload to Google Drive'),
    easyClose = FALSE,
    footer = tagList(
      modalButton("Close")
    )
  ))
})

# Download handler to write the csv
output$downloadBtnDischarge <- downloadHandler(
  filename = function() {
    # Set the filename of the downloaded file
    "discharge.csv"
  },
  content = function(file) {
    # Generate the content of the file
    write.csv(goop$dischargeDF, file, row.names = FALSE)
  }
)

observeEvent(input$upload_to_gdrive, {
  showModal(modalDialog(
    textInput('drivePath', 'Please enter the path of the folder in your googledrive:'),
    actionButton('path_ok', 'OK')
  ))
})

observeEvent(input$path_ok,{
  name <- 'discharge.csv'
  turn_file_to_csv(goop$dischargeDF, name)
  res = tryCatch(upload_csv_file(goop$dischargeDF, name, input$drivePath), error = function(i) NA)
  if(is.na(res)){
    showModal(modalDialog(
      h3('The path you entered is invalid!'),
      easyClose = FALSE,
      footer = tagList(
        modalButton('Back')
      )
    ))      
  }
  else{
    if(paste0('processed_', name) %in% (drive_ls(input$drivePath)[['name']])){
      showModal(modalDialog(
        h3('File has been uploaded successfully!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
    else{
      showModal(modalDialog(
        h3('File upload failed!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
  }
}
)


