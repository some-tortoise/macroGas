div(class = 'order-panel-container panel-container', 
    column(width = 5,
           rank_list(
             text = "Reorder your stations as peaks appear earliest to latest on the graph",
             labels = c("Red", "Orange", "Green", "Blue", "Purple"),
             input_id = "rank_list",
             options = sortable_options(swap = FALSE)
           ),
           actionButton("station_reorder", label = "Submit Station Reorder")
),
column(width=7,
       plotOutput("orig_plot"),
       textOutput("reorder_complete")
       )
)
