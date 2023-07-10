fluidPage(
  sidebarLayout(
    sidebarPanel("",
                 dateRangeInput("do_date_viewer", "Select Date(s) To View/Calculate")),
    mainPanel("",
              tabsetPanel(
                tabPanel("Selected Range",
                         plotlyOutput("do_plot"),
                         tableOutput("do_metrics"))
              )
              )
  )
)

