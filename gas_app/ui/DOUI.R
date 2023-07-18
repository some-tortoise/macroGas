fluidPage(
  sidebarLayout(
    sidebarPanel("",
                 uiOutput("do_date_viewer"),
                 uiOutput("station"),
                 uiOutput("site"),
                 numericInput("hypoxia_math", "Input your hypoxia baseline here", value = 2)
                 ),
                  
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

