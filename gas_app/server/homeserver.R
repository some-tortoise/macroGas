import_from_drive <- function(gdrive_link) {
  file_id <- sub('.*\\/d\\/([^\\/]+).*', '\\1', gdrive_link)
  if (file_id == gdrive_link) 
    return(NULL)
  file_name = drive_get(as_id(file_id))[["name"]]
  file_type = tail(unlist(strsplit(file_name, "\\.")),n=1)
  if(file_type=="csv"){
    temp_file <- tempfile(fileext = ".csv")
    drive_download(as_id(file_id), path = temp_file)
    tryCatch({data <- read.csv(temp_file)}, error = function(e) data<-NULL)
    unlink(temp_file)
    return(list(data, file_name)) 
  }
  else
    return(NULL)
}