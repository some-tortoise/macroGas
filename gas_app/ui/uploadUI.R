# div(class = 'upload page',
#     div(class = "upload-box-container",
#       div(class="area",
#           div(class = 'area-back',
#               ),
#           tags$input(type="file", id="upload")
#       )
#       )
#     ,
# tags$script(
#   HTML("
# 
# var upload = document.getElementById('upload');
# 
# function onFile() {
#     var me = this,
#         file = upload.files[0],
#         name = file.name.replace(/.[^/.]+$/, '');
#     console.log('upload code goes here', file, name);
# }
# 
# upload.addEventListener('dragenter', function (e) {
#     upload.parentNode.className = 'area dragging';
# }, false);
# 
# upload.addEventListener('dragleave', function (e) {
#     upload.parentNode.className = 'area';
# }, false);
# 
# upload.addEventListener('dragdrop', function (e) {
#     onFile();
# }, false);
# 
# upload.addEventListener('change', function (e) {
#     onFile();
# }, false);
#        
# ")
#   )
# )


div(class = 'upload page',
  div(class = 'upload-box-1',
      div(class = 'upload--box1-1',
        div('Choose a CSV file'),
        fileInput("df_upload", "",
                  multiple = FALSE,
                  accept = c("text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv")
        )
      ),
      div(class = 'upload--box1-2',
        div(class = 'upload--site-label',
            'Site'),
        uiOutput("siteNameUI")
      ),
      div(class = 'upload--box1-3',
          div(class = 'upload--station-label',
              'Station'),
          uiOutput("stationNameUI")
      ),
      actionButton("df_delete", "Add dataset")
      ),
  div(class = 'upload-box-2',
      uiOutput("guesses")
  ),
  div(class = 'upload-box-3',
      DTOutput("contents")
      ),
  div(class = 'upload-box-4',
      p('when you have finished uploading, move on to QAQC.')
      )
  )