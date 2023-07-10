fluidPage(
  sidebarLayout(
    sidebarPanel("",
                 dateRangeInput("do_date_viewer", "Select Date(s) To View/Calculate")),
    mainPanel("",
              tabsetPanel(
                tabPanel("Selected Range",
                         plotlyOutput("do_plot_range"),
                         dataTableOutput("do_metrics_range")),
                tabPanel("Full Range",
                         plotlyOutput("do_plot_full"),
                         dataTableOutput("do_metrics_full"))
                )
              )
              )
)

