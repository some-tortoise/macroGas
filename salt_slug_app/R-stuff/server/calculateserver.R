#
# BASIC UI STUFF
#
{
  
  # output$start_time <- renderUI({
  #   if (!is.null(goop$combined_df)) {
  #     default_value <- as.character(goop$combined_df$Date_Time[1])
  #   } else {
  #     default_value <- ""
  #   }
  #   textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
  # }) #start time renderUI
  # 
  # output$end_time <- renderUI({
  #   if (!is.null(goop$combined_df)) {
  #     default_value <- as.character(goop$combined_df$Date_Time[1])
  #   } else {
  #     default_value <- ""
  #   }
  #   textInput("end_datetime", "End Date and Time", value = default_value)
  # }) #end time renderUI
  
  output$background_out <- renderUI({
    req(goop$calc_curr_station_df)
    fluidRow(
      column(width = 8,
             numericInput("background", label = "Background conductivity:", value = goop$background)
      ),
      column(width = 2,
             actionButton("question", label = "", icon = icon("question")),
             bsTooltip(id = "question", "We provide a baseline for this value by calculating the mean of the conductivity prior to the breakthrough curve, though it can be changed manually as well.", placement = "bottom", trigger = "hover", options = list(container = "body"))
      )
    )
  }) #a renderUI for the background conductivity input, as well as explanation of how we calculate it
  
  output$calc_station <- renderUI({
    if(!is.null(goop$combined_df)){
      selectInput("calc_station_picker", label = "Choose A Station", sort(unique(goop$combined_df$station)))
    }else{
      HTML("<label>Choose A Station<br></br></label>")
    }
  }) #station picking
}

#
# PLOT STUFF
#
{
  
  observeEvent(input$calc_station_picker, {
    goop$calc_curr_station_df <- goop$combined_df[goop$combined_df$station %in% input$calc_station_picker, ]
  }) #filters to the subset of rows that has the correct station the user inputs, then stores in goop$calc_curr_station_df
  
  observe({
    goop$calc_xValue <- goop$calc_curr_station_df$Date_Time
    goop$calc_yValue <- goop$calc_curr_station_df$Low_Range
  }) #assigns date/time to the x-axis, conductivity to the y-axis 
  
  observe({
    goop$calc_xLeft <- goop$calc_xValue[1] # This is our starting guess for the left bar
    goop$calc_xRight <- goop$calc_xValue[length(goop$calc_xValue) - 1] #  This is our starting guess for the right bar
  })
  
  # observeEvent(input$calc_station_picker,{
  #   req(goop$calc_xLeft)
  #   req(goop$calc_xValue)
  #   start_time <- goop$calc_xLeft
  #   print('GORILLAS')
  #   startVal <- as.numeric(goop$calc_xLeft)
  #   bottomVal <- as.numeric(goop$calc_xValue[1])
  #   topVal <- as.numeric(goop$calc_xValue[length(goop$calc_xValue)])
  #   minDist <- bottomVal
  #   minVal <- bottomVal
  #   index_start_time <- 0
  #   for(x in bottomVal:topVal){
  #     if(abs(startVal-x) <= minDist){
  #       index_start_time <- x-bottomVal
  #       minDist <- abs(startVal-x)
  #       minVal <- x
  #     }
  #   }
  #   #print(as.POSIXct(minVal, tz = 'GMT', origin = "1970-01-01"))
  #   background_cond <- mean(goop$trimmed_slug$Low_Range[(index_start_time - 20):index_start_time])
  #   print(background_cond)
  #   goop$background <- background_cond
  # })
  
  observeEvent(input$calc_station_picker, {
    goop$background <- round(((mean(goop$calc_curr_station_df$Low_Range)) - 10), 2)
  })
  
  observeEvent(input$background,{
    goop$background <- input$background
  })
  
  # this observe makes the left bar manually inputtable as well
  # observeEvent(input$start_datetime, {
  #   inputtedLeft <- ymd_hms(input$start_datetime, tz = 'GMT')
  #   if(!is.null(inputtedLeft)){
  #     goop$calc_xLeft <- inputtedLeft
  #   }
  # })
  
  # this observe makes the right bar manually inputtable as well
  # observeEvent(input$end_datetime, {
  #   inputtedLeft <- ymd_hms(input$end_datetime, tz = 'GMT')
  #   if(!is.null(inputtedLeft)){
  #     goop$calc_xLeft <- inputtedLeft
  #   }
  # })
  
  output$dischargecalcplot <- renderPlotly({
    
    req(goop$calc_curr_station_df)
    req(goop$calc_xLeft)
    req(goop$calc_xRight)
    
    #some relabeling for shorter code
    xVal <- goop$calc_xValue
    yVal <- goop$calc_yValue
    xLeft <- goop$calc_xLeft
    xRight <- goop$calc_xRight
    
    goop$calc_curr_station_df$xfill <- ifelse(
      as.numeric(xVal) > as.numeric(xLeft) & as.numeric(xVal) < as.numeric(xRight),
      xVal,
      NA
    )
    
    xLeft <- as.POSIXct(xLeft, tz = 'GMT', origin = "1970-01-01")
    xRight <- as.POSIXct(xRight, tz = 'GMT', origin = "1970-01-01")
    
    p <- plot_ly(goop$calc_curr_station_df, x = ~Date_Time, y = ~Low_Range, 
            type = 'scatter', mode = 'lines', source = "R") %>%
      add_trace(x = ~as.POSIXct(goop$calc_curr_station_df$xfill, tz = 'GMT', origin = "1970-01-01"), y = ~Low_Range) %>%
      add_trace(x = ~as.POSIXct(goop$calc_curr_station_df$xfill, tz = 'GMT', origin = "1970-01-01"), y = ~goop$background, fill = 'tonextx', fillcolor = 'rgba(255, 165, 0, 0.3)', line = list(color = 'black')) %>%
      layout(showlegend = FALSE, shapes = list(
        # left line
        list(type = "line", x0 = xLeft, x1 = xLeft,
             y0 = 0, y1 = 1, yref = "paper"),
        # right line
        list(type = "line", x0 = xRight, x1 = xRight,
             y0 = 0, y1 = 1, yref = "paper")
        # background conductivity
        # list(type = "line", x0 = xLeft, x1 = xRight,
        #      y0 = goop$background, y1 = goop$background)
      )) %>%
      config(edits = list(shapePosition = TRUE))
    
    p
  })
  
  
  observeEvent(event_data("plotly_relayout", source = "R"), { #R is the name of the plot
    ed <- event_data("plotly_relayout", source = "R")
    shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
    
    if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
    barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
    if(is.na(barNum)){ return() } # just some secondary error checking to see if we got any NAs. This line should never be called
    
    row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # get shape number
    
    pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'GMT', origin = "1970-01-01")
    
    
    if(barNum == 0){
      goop$calc_xLeft <- 0
      goop$calc_xLeft <- pts[1]
    }else if(barNum == 1){
      goop$calc_xRight <- 0
      goop$calc_xRight <- pts[1]
    }
    # else if(barNum == 2){
    #   new_background <- ed[grepl("^shapes.*y0$", names(ed))][[1]]
    #   goop$background <- 0
    #   goop$background <- new_background
    # }
  })
}

### OUTPUT/TABLE STUFF
{
  
  observe({
    goop$trimmed_slug <- goop$calc_curr_station_df[(as.numeric(goop$calc_xValue) >= as.numeric(goop$calc_xLeft)) & (as.numeric(goop$calc_xValue) <= as.numeric(goop$calc_xRight)), ]
  }) #creates goop$trimmed_slug based on goop$calc_curr_station_df that only contains values between the left and right bars (calc_xLeft and calc_xRight)
  
  
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
  
  
  output$dischargeOutput <- renderText({
    
    #requirements
    
    req(goop$combined_df)
    req(goop$trimmed_slug)
    
    if(is.null(goop$combined_df) || is.null(goop$trimmed_slug)){
      return('Discharge: N/A')
    }
    
    #basic renaming
    
    station_slug <- goop$trimmed_slug #using trimmed_slug which is only the values between two vertical bars
    
    #grab how many seconds are between consecutive observations
    diff_time_btwn_observations = as.numeric(goop$combined_df$Date_Time[2]) - as.numeric(goop$combined_df$Date_Time[1])
    
    station_slug <- station_slug %>%
      mutate(NaCl_Conc = 
               ifelse((Low_Range - as.numeric(goop$background)) > 0, 
                      (Low_Range - as.numeric(goop$background)) * 0.00047,
                      0),
             Area = NaCl_Conc * diff_time_btwn_observations)
    
    Area <- sum(station_slug$Area)
    Mass_NaCl <- as.numeric(input$salt_mass)
    Discharge <- round(Mass_NaCl / Area, 2)
    
    goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'Discharge'] <- Discharge 
    
    return(paste0('Discharge: ', Discharge, ' L/s')) 
     
   }) #the math.R stuff that prints a final discharge value
  
  output$halfheightOutput <- renderText({
    
    #requirements
    
    req(goop$combined_df)
    req(goop$trimmed_slug)
    
    if(is.null(goop$combined_df) || is.null(goop$trimmed_slug)){
      return('Time to half height: N/A')
    }
    
    #basic renaming
    station_slug <- goop$trimmed_slug
    start_time <- goop$calc_xLeft
    
    
    Cmax <- max(station_slug$Low_Range)
    index_Cmax <- which(station_slug$Low_Range == Cmax)[1]

    index_start_time <- which.min(abs(station_slug$Date_Time - start_time))

    Chalf <- (goop$background + (1/2)*(Cmax - goop$background))
    
    if(index_start_time >= index_Cmax){
      return(paste0('Time to half height: ', "NA seconds"))
    }
    
    index_Chalf <- which.min(abs(station_slug$Low_Range[index_start_time:index_Cmax] - Chalf)) #identifies the index of the smallest difference -- the point closest to being half height

    start_time <- station_slug$Date_Time[index_start_time]
    Chalf_time <- station_slug$Date_Time[index_Chalf]
    time_to_half <- ((as.numeric(Chalf_time) - as.numeric(start_time)))
    
    goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ',input$calc_station_picker), 'Half_Height'] <- time_to_half 
    
    return(paste0('Time to half height: ', time_to_half, " seconds"))
    
  
  }) #half height math
  
  output$groundwaterOutput <- renderUI({
    req(goop$combined_df)
    if(!('1' %in% unique(goop$combined_df$station))){
      return(p('Please make sure you have a station 1.'))
    }
    
    last_station <- max(as.numeric(unique(goop$combined_df$station)))
    
    if(last_station == 1){
      return(p('Need more than one station.'))
    }
    
    first_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == 'Station 1', 'Discharge'])
    last_station_discharge <- as.numeric(goop$dischargeDF[goop$dischargeDF$Station == paste0('Station ', last_station), 'Discharge'])
    
    if(first_station_discharge == 0 || last_station_discharge == 0){
      return(p('NA'))
    }
    
    diff <- first_station_discharge - last_station_discharge
    
    p(paste0(diff, ' L/s'))
  })
  
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
  
  observeEvent(goop$combined_df, {
    output$dischargetable <- function() {
      goop$dischargeDF %>%
        knitr::kable("html", col.names =
                       c("Station", "Discharge (L/s)", "Time to Half Height (sec)")) %>%
        kable_styling("striped", full_width = F)
    }
  })
}

#
#DOWNLOAD STUFF
#
{
upload_csv_file <- function(clean_df, name, folder_path){
  file <- paste('processed_',name, sep='')
  file <- drive_put(
    media = file,
    name = file,
    type = 'csv',
    path = as_id(folder_path))
  return('success')
}

turn_file_to_csv <- function(clean_df, name){
  write.csv(clean_df, paste('./processed_',name, sep=''), row.names=FALSE)
}

observeEvent(input$downloadFlaggedDataset, {
  showModal(modalDialog(
    title = 'How do you want to download your dataset?',
    downloadButton('downloadBtn', 'Download'),
    actionButton('upload_to_gdrive', 'Upload to Google Drive'),
    easyClose = FALSE,
    footer = tagList(
      modalButton("Close")
    )
  ))
})

observeEvent(input$downloadOutputTable, {
  showModal(modalDialog('This feature is still being worked on.'))
})


output$downloadBtn <- downloadHandler(
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
}

