require(data.table)
require(dplyr)
require(stringr)
library(readr)

folder_path <- "./gas_app/cb/"
file_list = list.files(path = folder_path, 
                      pattern = '*.csv$', 
                      full.names = FALSE)

files <- list()
clean_dfs <- list()
for(i in 1:length(file_list)){
  filePath <- paste0(folder_path,file_list[i])
  files[[i]] <- read_csv(filePath, skip = 1, col_types = cols())
  siteGuess <- str_split(file_list[i], '_')[[1]][2]
  stationGuess <- str_split(file_list[i], '_')[[1]][3]
  
  file_data <- files[[i]]
  
  keywords <- c("DO", "Date", "Range", "Temp", "Abs")
  clean_df <- NULL  # Initialize an empty vector to store filtered column names
  for (i in colnames(file_data)) {
    for (keyword in keywords) {
      if (str_detect(i, keyword)) {
        colToAdd <- as.vector(file_data[,i])
        if(is.null(clean_df)){
          clean_df <- data.frame(colToAdd)
          names(clean_df)[1] <- keyword
        }else{
          clean_df[keyword] <- colToAdd  # Append filtered column name to the vector
        }
      }
    }
  }
  
  clean_df['station'] <- stationGuess
  clean_df['site'] <- siteGuess
  
  clean_dfs[[i]] <- clean_df
}

