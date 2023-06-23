div(class = 'order-panel-container panel-container', 
    fluidRow(
      column(width = 6,
             rank_list(
               text = "Reorder your stations as peaks appear earliest to latest on the graph",
               labels = c("Red", "Orange", "Green", "Blue", "Purple"),
               input_id = "rank_list",
               options = sortable_options(swap = FALSE)
               )
             ), 
      column(width = 6,
             actionButton("station_reorder", label = "Submit Station Reorder")
             )
      ),
    fluidRow(
       column(width = 11,
        plotOutput("orig_plot", height = "300px",  width = "900px"),
       textOutput("reorder_complete")
)
)
)
