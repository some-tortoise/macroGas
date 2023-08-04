#
# UI
#

# Modal dialog for entering salt slug mass and salt slug in-time (since these don't change by station)
observeEvent(input$navbar, {
  if (input$navbar == "calculatetab" && !is.null(goop$combined_df)) {
    showModal(modalDialog(
      p("Please enter the mass of your salt slug and the time it was added to the stream below before continuing to the rest of the calculate page:"),
      uiOutput("salt_out"),
      uiOutput("injectiontime_out"),
      footer = modalButton("Done"), size = "l"
    ))
  }
})

# A renderUI for entering mass of the salt slug
output$salt_out <- renderUI({
  req(goop$calc_curr_station_df)
  req(goop$calc_curr_station_df_use)
  numericInput("salt_mass", label = "NaCl Mass, (g):", value = 0)
}) 

# A renderUI for entering the time the salt slug went in
output$injectiontime_out <- renderUI({
  req(goop$calc_curr_station_df)
  req(goop$calc_curr_station_df_use)
  fluidRow(
    column(width = 8,
           timeInput("injectiontime", label = "Time of injection:", value = "00:00:00"),
    )
  )
}) 

# A renderUI that creates a dropdown to select from the stations that have been uploaded
output$calc_station <- renderUI({
  if(!is.null(goop$combined_df)){
    selectInput("calc_station_picker", label = "Choose A Station:", sort(unique(goop$combined_df$station)))
  }else{
    HTML("<label>Choose A Station<br></br></label>")
  }
})

# A renderUI for the background conductivity input
output$background_out <- renderUI({
  req(goop$calc_curr_station_df)
  req(goop$calc_curr_station_df_use)           
  numericInput("background", label = "Background conductivity, (µS/cm):", value = 0)
}) 

# A renderUI for entering stream width 
output$width_out <- renderUI({
  req(goop$calc_curr_station_df)
  req(goop$calc_curr_station_df_use)
  numericInput("width", label = "Stream width, (m):", value = 0)
}) 

# A renderUI for entering distance from station 1 
output$distance_out <- renderUI({
  req(goop$calc_curr_station_df)
  req(goop$calc_curr_station_df_use)
  numericInput("distance", label = "Distance from injection, (m):", value = 0)
}) 

#
# PLOT 
#

# Filters to the subset of rows that has the correct station the user inputs, then stores in goop$calc_curr_station_df
observeEvent(input$calc_station_picker, {
  goop$calc_curr_station_df <- goop$combined_df[goop$combined_df$station %in% input$calc_station_picker, ]
  goop$calc_curr_station_df <- na.omit(goop$calc_curr_station_df)
})

# Excludes 'bad' flags from calculation if user selects the checkbox
observeEvent(c(input$excludeflags, goop$calc_curr_station_df), {
  if(input$excludeflags == TRUE){
    bad_dates <- goop$bad_dates
    goop$calc_curr_station_df_use <- goop$calc_curr_station_df[!((goop$calc_curr_station_df$Date_Time %in% bad_dates$Date_Time) & (goop$calc_curr_station_df$station %in% bad_dates$Station)), ]
  }else{
    goop$calc_curr_station_df_use <- goop$calc_curr_station_df
  }
})

# Assigns Date_Time to the x-axis, Low_Range to the y-axis 
observe({
  goop$calc_xValue <- goop$calc_curr_station_df_use$Date_Time
  goop$calc_yValue <- goop$calc_curr_station_df_use$Low_Range
}) 

# Setting the indices of the left and right trim bars 
observe({
  goop$calc_xLeft <- goop$calc_xValue[1] # Left bar
  goop$calc_xRight <- goop$calc_xValue[length(goop$calc_xValue) - 1] # Right bar
}) 

# Setting the background conductivity to a rough mean of the data
observeEvent(input$calc_station_picker, {
  goop$background <- round(((mean(goop$calc_curr_station_df_use$Low_Range)) - 5), 2)
}) 

# Renders the plot of the breakthrough curve data
output$dischargecalcplot <- renderPlotly({
  
  #requirements 
  req(goop$calc_curr_station_df) 
  req(goop$calc_curr_station_df_use)
  req(goop$calc_xLeft) 
  req(goop$calc_xRight)
  
  #relabeling for shorter code
  xVal <- goop$calc_xValue
  yVal <- goop$calc_yValue
  xLeft <- goop$calc_xLeft
  xRight <- goop$calc_xRight
  
  #creates xfill column that assigns xVal if it's w/in range set by xLeft and xRight, fills NA otherwise
  #gets used later to addtrace
  goop$calc_curr_station_df_use$xfill <- ifelse(
    as.numeric(xVal) > as.numeric(xLeft) & as.numeric(xVal) < as.numeric(xRight),
    xVal,
    NA
  )
  
  # Converts xLeft and xRight to as.POSIXct date/time values
  xLeft <- as.POSIXct(xLeft, tz = 'EST', origin = "1970-01-01")
  xRight <- as.POSIXct(xRight, tz = 'EST', origin = "1970-01-01")
  
  # Plot is based on goop$calc_curr_station_df
  p <- plot_ly(goop$calc_curr_station_df_use, x = ~Date_Time, y = ~Low_Range, 
               type = 'scatter', mode = 'lines', source = "R") %>%
    # Trace and fill added where xfill isn't NA (between two vertical lines)
    add_trace(x = ~as.POSIXct(goop$calc_curr_station_df_use$xfill, tz = 'EST', origin = "1970-01-01"), y = ~Low_Range) %>%
    add_trace(x = ~as.POSIXct(goop$calc_curr_station_df_use$xfill, tz = 'EST', origin = "1970-01-01"), y = ~goop$background, fill = 'tonextx', fillcolor = 'rgba(255, 165, 0, 0.3)', line = list(color = 'black')) %>%
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
# SAVE INPUTS TO OUTPUT DF
#

# Changes goop$background based on user input and saves to output df
observeEvent(input$background,{
  goop$background <- input$background
  background_cond <- goop$background
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'bkgnd_uS'] <- background_cond 
  
}) 

# Assigns salt mass to goop$Mass_NaCL and saves to every row of output df
observeEvent(input$salt_mass,{
  goop$Mass_NaCl <- input$salt_mass
  mass_nacl <- goop$Mass_NaCl
  goop$dischargeDF$slug_mass_g <- mass_nacl
  
}) 

# Assigns width of stream to output table
observeEvent(input$width, {
  goop$width <- input$width
  width <- goop$width
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'width_m'] <- width
})

# Assigns distance from injection to output table
observeEvent(input$distance, {
  goop$distance <- input$distance
  distance <- goop$distance
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'station_distance'] <- distance
})

# Add calculate velocity to output df based on distance and travel time
observeEvent(goop$dischargeDF, {
  for (i in 1:nrow(goop$dischargeDF)) {
    goop$dischargeDF$velocity_ms[i] <- (goop$dischargeDF$station_distance[i] / goop$dischargeDF$travel_time_sec[i])
  }
})


# Assigns injection time to output table
observeEvent(input$injectiontime, {
  goop$injectiontime <- input$injectiontime
  injectiontime <- goop$injectiontime
  injectiontime <- ymd_hms(injectiontime)
  injectiontime <- format(injectiontime, format = "%H:%M:%S")
  goop$dischargeDF$slug_in_time <- injectiontime
  })


#
# OUTPUT, MATH, TABLE
#

# Creates new dataframe to store discharge and time to half height values, assigns to goop$dischargeDF
observeEvent(c(goop$combined_df), {
  zero <- c()
  which_station <- c()
  
  for(i in unique(goop$combined_df$station)){
    zero <- c(zero, 0) #assigns discharge value of 0 initially to each column
    which_station <- c(which_station, paste0('Station ', i))
  } #for loop to name the columns after each unique station in goop$combined_df 

  a <- data.frame('Date' = "-",
                  'Site' = "-",  
                  'Station' = which_station, # done
                  'station_distance' = zero, # done
                  'slug_mass_g' = zero, # done
                  'slug_in_time' = zero, # done
                  'integration_start_time' = zero, # done
                  'integration_end_time' = zero, # done
                  'integral' = zero, # done
                  "half_peak_time" = zero, 
                  'peak_time' = zero, # done
                  "discharge_Ls" = zero, # done
                  "gw_discharge_Ls" = zero, # done
                  "overall_gw_discharge_Ls" = "", # done
                  "travel_time_sec" = zero, # done
                  "velocity_ms" = zero, # done
                  "width_m" = zero, # done
                  "bkgnd_uS" = zero, # done
                  "peak_uS" = zero, # done
                  "slug_recovered_g" = zero) # just leave blank so done
  
  goop$dischargeDF <- a
  
}) 

# Creates goop$trimmed_slug that only contains values between the left and right bars to do calculations with later
# And gets the start/end integration time and adds to output table
observe({
  if(is.null(goop$calc_curr_station_df)) return()
  if(is.null(goop$calc_curr_station_df_use)) return()
  if(is.null(goop$calc_xLeft)) return()
  goop$calc_xValue <- goop$calc_curr_station_df_use$Date_Time
  goop$trimmed_slug <- goop$calc_curr_station_df_use[
    (as.numeric(goop$calc_xValue) >= as.numeric(goop$calc_xLeft)) &
      (as.numeric(goop$calc_xValue) <= as.numeric(goop$calc_xRight)),
  ]
  
  # get integration start time
  int_start_datetime <- goop$calc_xLeft
  int_start_datetime <- ymd_hms(int_start_datetime)
  int_start_time <- format(int_start_datetime, format = "%H:%M:%S")
  
  # get integration end time
  int_end_datetime <- goop$calc_xRight
  int_end_datetime <- ymd_hms(int_end_datetime)
  int_end_time <- format(int_end_datetime, format = "%H:%M:%S")
  
  
  # Assign the start and end times to the dataframe
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'integration_start_time'] <- int_start_time 
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'integration_end_time'] <- int_end_time 
  
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
  # Adds both discharge and integral to output DF
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'discharge_Ls'] <- Discharge 
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'integral'] <- Area 
  
  return(paste0('Discharge: ', Discharge, ' L/s')) 
   
 }) 

# Math to calculate time to half height and half peak time
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
  
  # Identify the max conductivity and its index
  Cmax <- max(station_slug$Low_Range)
  index_Cmax <- which(station_slug$Low_Range == Cmax)[1]

  # Identify the index of the beginning of the salt slug (using the start time from the left vertical bar)
  index_start_time <- which.min(abs(station_slug$Date_Time - start_time))

  # Calculates the half height conductivity value 
  Chalf <- (goop$background + (1/2)*(Cmax - goop$background))
  
  if(is.na(index_start_time) || is.null(index_start_time) || is.na(Chalf) || is.null(Chalf)){
    return('Time to half height: N/A')
  }
  
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
  goop$time_to_half <- time_to_half
  
  if(is.na(time_to_half) || is.null(time_to_half) || length(time_to_half) == 0){
    return(paste0('Time to half height: ', "NA seconds"))
  }
  
  # Update Half_Height in goop for the rows where station column matches the user input in calc_station_picker
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'travel_time_sec'] <- time_to_half 
  
  # half_peak_time (easiest to do in this observe block bc of index_Chalf)
  half_peak_date_time <- station_slug$Date_Time[index_Chalf]
  half_peak_date_time <- ymd_hms(half_peak_date_time)
  half_peak_time <- format(half_peak_date_time, format = "%H:%M:%S")
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'half_peak_time'] <- half_peak_time
  
  
  # have to run the return last so back to printing time to half onto the page
  return(paste0('Time to half height: ', time_to_half, " seconds"))

})

# Math to calculate overall groundwater exchange
output$groundwaterOutput <- renderUI({
  req(goop$combined_df)
  
  first_station <-min(as.numeric(unique(goop$combined_df$station))) # Gets the first station number from minimum numeric value in the 'station' column
  last_station <- max(as.numeric(unique(goop$combined_df$station))) # Gets the last station number from the max

  # Need more than 1 station, checks that only station available isn't just 'station 1'
  if(last_station == first_station){
    return(p('Need more than one station.'))
  } 
  
  # Gets discharge values from goop$dischargeDF for the first and last stations
  first_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', first_station), 'discharge_Ls'])
  last_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', last_station), 'discharge_Ls'])
  
  if(first_station_discharge == 0 || last_station_discharge == 0){
    return(p('NA -- please finish calculating discharge for every station.'))
  }
  
  # Calculate exchange by subtracting last station from first station discharge
  diff <- last_station_discharge - first_station_discharge
  
  #Assign to last column of output df
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', first_station), 'overall_gw_discharge_Ls'] <- diff 
  
  p(paste0(diff, ' L/s'))
})

# Add each station's discharge to output df
observeEvent(goop$dischargeDF, {
  # Check if goop$dischargeDF has more than 1 row
  if (nrow(goop$dischargeDF) > 1) {
    # For loop to calc gw discharge for as many rows as present starting at row 2
    for (i in 2:nrow(goop$dischargeDF)) {
      goop$dischargeDF$gw_discharge_Ls[i] <- goop$dischargeDF$discharge_Ls[i] - goop$dischargeDF$discharge_Ls[i - 1]
    }
  } else {
      goop$dischargeDF$gw_discharge_Ls <- "NA"
      }
})

# Calculate peak and peak time and add to output table
observeEvent(goop$trimmed_slug, {
  
  # Peak Conductivity
  station_slug <- goop$trimmed_slug
  peak <- max(station_slug$Low_Range)
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'peak_uS'] <- peak 
  
  # Peak time
  index_peak <- which(station_slug$Low_Range == peak)[1]
  peak_date_time <- (station_slug$Date_Time[index_peak])
  peak_date_time <- ymd_hms(peak_date_time)
  peak_time <- format(peak_date_time, format = "%H:%M:%S")
  goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'peak_time'] <- peak_time
  
})

# Show final output table
observeEvent(goop$combined_df, {
  output$dischargetable <- function() {
    discharge_table <- goop$dischargeDF
    discharge_table %>%
      select(-c(Date, Site)) %>%  # What columns to exclude from view
      knitr::kable("html") %>%
      kable_styling("striped", full_width = T)
  }
})

#
# DOWNLOAD OUTPUT
#

# Function to create file name for download
new_filename <- function() {
  filename <- uploaded_data$csv_names[1]
  pattern <- "station_[0-9]_"
  station_string <- str_extract(filename, pattern)
  output_filename <- str_replace(filename, pattern, "")
  return(output_filename)
}
  
# Function to get site name from filename
get_site_name <- function() {
  filename <- uploaded_data$csv_names[1]
  pattern <- "mgas_(.*?)_station"
  site_name <- regmatches(filename, regexpr(pattern, filename))
  if (length(site_name) > 0) {
    return(gsub("mgas_|_station", "", site_name))
  } else {
    return(NULL)
  }
}

# Function to get date from filename
extract_date <- function() {
  filename <- uploaded_data$csv_names[1]
  pattern <- "\\d{4}-\\d{2}-\\d{2}"
  date <- regmatches(filename, regexpr(pattern, filename))
  if (length(date) > 0) {
    return(date)
  } else {
    return(NULL)
  }
}

# Modal dialog for downloading 
observeEvent(input$downloadOutputTable, {
  showModal(modalDialog(
    title = 'Download',
    textInput("stationinput", label = "File name:", value = new_filename()), 
    br(),
    p("Check the following site and date pulled from the filename are correct before downloading your data.
      If you are from outside the Bernhardt Lab or uploaded files without the MacroGas naming convention, 
      please add your site and date below so they appear correctly:"),
    textInput("outputsite", label = "Site:", value = get_site_name()),
    textInput("outputdate", label = "Date:", value = extract_date()),
    tags$b(p("Download output table:")),
    hr(),
    downloadButton('downloadBtnDischarge', 'Download'),
    easyClose = FALSE,
    footer = tagList(
      modalButton("Close")
    )
  ))
})

# Put site and date into final output table based on our guess/if changed by user
observeEvent(input$outputsite, {
  site <- input$outputsite
  goop$dischargeDF$Site <- site 
})

observeEvent(input$outputdate, {
  date <- input$outputdate
  goop$dischargeDF$Date <- date 
})

# Download handler to write the csv
output$downloadBtnDischarge <- downloadHandler(
  filename = function() {
    paste0(input$stationinput)  
  },
  content = function(file) {
    write.csv(goop$dischargeDF, file, row.names = FALSE)
  }
)

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


