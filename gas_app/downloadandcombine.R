library(tidyverse)

folder_path <- "gas_app/cb"
file_names <- list.files(path = folder_path, full.names = TRUE)

data_list <- list()
filtered_columns <- list()  # Initialize a list to store filtered columns

for (file_name in file_names) {
  base_name <- basename(file_name)  # Extract the file name from the full path
  file_data <- read.csv(file_name, header = FALSE)  # Change the function according to the file type
  file_data <- file_data[-1]  # Deleting the first column
  file_data <- slice(file_data, -(1)) #deleting the first row
  new_col_names <- sapply(file_data, function(x) as.character(x[1]))
  colnames(file_data) <- new_col_names
  data_list[[base_name]] <- file_data  # Store the data using the extracted file name
  
  keywords <- c("DO", "Date", "Range", "Temp", "Abs")
  
  filtered_cols <- c()  # Initialize an empty vector to store filtered column names
  
  for (i in colnames(file_data)) {
    for (keyword in keywords) {
      if (str_detect(i, keyword)) {
        filtered_cols <- c(filtered_cols, i)  # Append filtered column name to the vector
      }
    }
  }
  
  filtered_columns[[base_name]] <- filtered_cols  # Store filtered column names for each file
}

df_list <- list()  # Initialize an empty list to store filtered data frames

for (file_name in file_names) {
  base_name <- basename(file_name)
  filtered_cols <- filtered_columns[[base_name]]  # Retrieve filtered column names for the file
  file_data <- data_list[[base_name]]  # Retrieve the file's data
  
  if (length(filtered_cols) > 0) {
    filtered_data <- file_data[, filtered_cols, drop = FALSE]  # Filter the data frame based on filtered column names
    df_list[[base_name]] <- filtered_data  # Store the filtered data frame in the list
  }
}

df <- bind_rows(df_list)  # Combine the filtered data frames into a single data frame
stacked_data <- gather(df, key = "Variable", value = "Value", -1)
stacked_data <- slice(stacked_data, -(1))
stacked_data$Variable <- ifelse(grepl("Temp C", stacked_data$Variable), "Temp_C", stacked_data$Variable)
stacked_data$Variable <- ifelse(grepl("Low Range", stacked_data$Variable), "Low_Range", stacked_data$Variable)
stacked_data$Variable <- ifelse(grepl("High Range", stacked_data$Variable), "High_Range", stacked_data$Variable)
stacked_data$Variable <- ifelse(grepl("Full Range", stacked_data$Variable), "Full_Range", stacked_data$Variable)
stacked_data$Variable <- ifelse(grepl("Abs", stacked_data$Variable), "Abs_Pres", stacked_data$Variable)
stacked_data$Variable <- ifelse(grepl("DO", stacked_data$Variable), "DO_Conc", stacked_data$Variable)

view(stacked_data)