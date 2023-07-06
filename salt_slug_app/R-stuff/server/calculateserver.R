#
# BASIC UI STUFF
#
{
  
  output$start_time <- renderUI({
    if (!is.null(goop$combined_df)) {
      default_value <- as.character(goop$combined_df$Date_Time[1])
    } else {
      default_value <- ""
    }
    textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
  }) #start time renderUI
  
  output$end_time <- renderUI({
    if (!is.null(goop$combined_df)) {
      default_value <- as.character(goop$combined_df$Date_Time[1])
    } else {
      default_value <- ""
    }
    textInput("end_datetime", "End Date and Time", value = default_value)
  }) #end time renderUI
  
  output$background_out <- renderUI({
    req(goop$calc_curr_station_df)
    numericInput("background", label = "Enter background conductivity here", value = mean(goop$calc_curr_station_df$Low_Range))
  })
  
  output$calc_station <- renderUI({
    if(!is.null(goop$combined_df)){
      selectInput("calc_station_picker", label = "Choose A Station", sort(unique(goop$combined_df$station)))
    }else{
      HTML("<label>Choose A Station<br></br></label>")
    }
  })
}

#
# PLOT STUFF
#
{
    
  observe({
    goop$calc_curr_station_df <- goop$combined_df[goop$combined_df$station %in% input$calc_station_picker, ]
  }) #filters to the subset of rows that has the correct station the user inputs, then stores in goop$calc_curr_station_df
  
  observe({
    goop$calc_curr_station_df$Date_Time <- goop$calc_curr_station_df$Date_Time
  })
  
  observe({
    goop$calc_xValue <- goop$calc_curr_station_df$Date_Time
    goop$calc_yValue <- goop$calc_curr_station_df$Low_Range
  }) #assigns date/time to the x-axis, conductivity to the y-axis 
  
  observe({
    goop$calc_xLeft <- goop$calc_xValue[1]
    goop$calc_xRight <- goop$calc_xValue[length(goop$calc_xValue) - 1]
    goop$calc_xOne <- as.numeric(goop$calc_xValue[1])
  })
  
  observeEvent(input$background,{
    goop$background <- input$background
  })
  
  observeEvent(input$calc_station_picker, {
    goop$calc_curr_station_df <- goop$combined_df[goop$combined_df$station %in% input$calc_station_picker, ]
  })
  
  # this observe makes the left bar manually inputtable as well
  observeEvent(input$start_datetime, {
    print(goop$calc_xLeft)
    print(input$start_datetime)
    inputtedLeft <- ymd_hms(input$start_datetime, tz = 'GMT')
    if(!is.null(inputtedLeft)){
      goop$calc_xLeft <- inputtedLeft
    }
  })
  
  # this observe makes the right bar manually inputtable as well
  observeEvent(input$end_datetime, {
    print(goop$calc_xRight)
    print(input$end_datetime)
    inputtedLeft <- ymd_hms(input$end_datetime, tz = 'GMT')
    if(!is.null(inputtedLeft)){
      goop$calc_xLeft <- inputtedLeft
    }
  })
  
  output$dischargecalcplot <- renderPlotly({
    
    req(goop$calc_curr_station_df)
    req(goop$calc_xLeft)
    req(goop$calc_xRight)
    
    xVal <- goop$calc_curr_station_df$Date_Time
    yVal <- goop$calc_curr_station_df$Low_Range
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
             y0 = 0, y1 = 1, yref = "paper"),
        list(type = "line", x0 = xLeft, x1 = xRight,
             y0 = goop$background, y1 = goop$background)
      )) %>%
      config(edits = list(shapePosition = TRUE))
    
    event_data("plotly_relayout", source = "dischargecalcplot")
    p <- event_register(p, 'plotly_relayout')
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
    }else if(barNum == 2){
      new_background <- ed[grepl("^shapes.*y0$", names(ed))][[1]]
      goop$background <- 0
      goop$background <- new_background
    }
  })
}

### OUTPUT/TABLE STUFF
{
  
  observe({
    goop$calc_discharge_table <- NULL
  }) #currently useless
  
  observe({
    goop$trimmed_slug <- goop$calc_curr_station_df[(as.numeric(goop$calc_xValue) >= as.numeric(goop$calc_xLeft)) & (as.numeric(goop$calc_xValue) <= as.numeric(goop$calc_xRight)), ]
  }) #creates goop$trimmed_slug based on goop$calc_curr_station_df that only contains values between the left and right bars (calc_xLeft and calc_xRight)
  
  
  observeEvent(goop$combined_df, {
    st <- c()
    colNames <- c()
    for(i in 1:(length(unique(goop$combined_df$station)))){
      st[i] <- 0
      colNames[i] <- paste0('Station ', i)
    }
    
    a <- data.frame(matrix(st, nrow = 1))
    row.names(a) <- 'Discharge'
    colnames(a) <- colNames
    goop$dichargeDF <- a
    #View(goop$dichargeDF)
  })
  
  
  
  output$dischargeOutput <- renderText({
    if(!is.null(goop$combined_df)){
      station_slug <- goop$trimmed_slug
      
      station_slug <- station_slug %>%
        mutate(NaCl_Conc = NA) %>%
        relocate(NaCl_Conc, .after = Low_Range)
      station_slug <- station_slug %>%
        mutate(Area = NA) %>%
        relocate(Area, .after = NaCl_Conc)
      
      background_cond <- as.numeric(input$background) 
      station_slug <- station_slug %>%
        mutate(NaCl_Conc = (Low_Range - background_cond) * 0.00047) %>%
        mutate(Area = NaCl_Conc * 5)
      
      Area <- sum(station_slug$Area)
      Mass_NaCl <- input$salt_mass
      Discharge <- Mass_NaCl/Area
      goop$dichargeDF[as.numeric(input$calc_station_picker)] <- Discharge
      return(paste0('Discharge: ',Discharge)) 
    }
    else{
      return('Discharge: N/A')
    }
  }) #the math.R stuff that prints a final discharge value
  
  output$halfheightOutput <- renderText({
    if(!is.null(goop$combined_df)){
      station_slug <- goop$trimmed_slug
      
      Cmax <- max(station_slug$Low_Range)
      index_Cmax <- which(station_slug$Low_Range == Cmax)
      
      background_cond <- as.numeric(input$background) 
      Chalf <- (background_cond + (1/2)*(Cmax - background_cond))
      
      poss_indexes_background <- which(station_slug$Low_Range == background_cond)
      index_background <- max(poss_indexes_background[1:index_Cmax]) #this assumes the background conductivity is higher on the backside which isn't a given
      
      distances_to_half_height <- abs(station_slug$Low_Range[index_background:(index_Cmax - 1)] - Chalf)
      index_Chalf <- which.min(distances_to_half_height)
      
      start_time <- station_slug$Date_Time[index_background]
      Chalf_time <- station_slug$Date_Time[index_Chalf]
      time_to_half <- (Chalf_time-start_time)
      return(paste0('Time to half height: ', time_to_half)) 
    }
    else{
      return('Time to half height: N/A')
    }
  }) #half height math
  
  output$dischargetable <- function() {
    goop$dichargeDF |>
      knitr::kable("html") |>
      kable_styling("striped", full_width = F)
  }
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

observeEvent(input$download, {
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

output$downloadBtn <- downloadHandler(
  filename = function() {
    # Set the filename of the downloaded file
    "discharge.csv"
  },
  content = function(file) {
    # Generate the content of the file
    write.csv(goop$dichargeDF, file, row.names = FALSE)
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
  turn_file_to_csv(goop$dichargeDF, name)
  res = tryCatch(upload_csv_file(goop$dichargeDF, name, input$drivePath), error = function(i) NA)
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
