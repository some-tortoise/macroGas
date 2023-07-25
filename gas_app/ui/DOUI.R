fluidPage(
  sidebarLayout(
    sidebarPanel("",
                 uiOutput("do_date_viewer"),
                 uiOutput("station"),
                 uiOutput('site'),
                 numericInput("h_threshold", "Input hypoxia threshold (mg/L)", value = 2),
                 conditionalPanel(
                   condition = "input.tabs == 'hypoxiatab'",
                    numericInput("latitude", "Latitude:", value = "35")
                 )
    ),
               
    mainPanel("",
              tabsetPanel(id = "tabs",
                tabPanel("Selected Range",
                         plotlyOutput("do_plot_range"),
                         dataTableOutput("do_metrics_range")),
                tabPanel("Full Range",
                         plotlyOutput("do_plot_full"),
                         dataTableOutput("do_metrics_full")),
                tabPanel("Hypoxia Metrics", value = "hypoxiatab",
                         plotlyOutput("light_kernel"),
                         plotlyOutput("dark_kernel"),
                         dataTableOutput("do_hypoxia_metrics"))
                )
            )
    )
)


