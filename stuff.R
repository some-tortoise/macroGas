library('googledrive')

macro_folder <- 'https://drive.google.com/drive/folders/1QhIzFToANF5JNOyxp2_q6WGaFrFUM3iA'
folder_id = drive_get(as_id(macro_folder))
files = drive_ls(folder_id)
drive_download(files)
for (i in seq_along(files$name)) {
  #list files
  i_dir = drive_ls(files[i, ])
  
  #mkdir
  dir.create(files$name[i])
  
  #download files
  for (file_i in seq_along(i_dir$name)) {
    #fails if already exists
    try({
      drive_download(
        as_id(i_dir$id[file_i]),
        path = str_c(files$name[i], "/", i_dir$name[file_i])
      )
    })
  }
}

b <- c(as.data.frame(a[1]))
b
drive_download(b[[1]][2], type = "csv")
out <- read.csv(b[[1]][2], header=0)
out

