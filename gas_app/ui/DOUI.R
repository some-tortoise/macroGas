fluidPage(
  sidebarLayout(
    sidebarPanel("",
                 uiOutput("do_date_viewer"),
                 numericInput("h_threshold", "Input hypoxia threshold (mg/L)", value = 2),
                 conditionalPanel(
                   condition = "input.tabs == 'hypoxiatab'",
                    timeInput("sunrise", "Input sunrise time", value = hms::as_hms("06:00:00"), seconds = FALSE),
                    timeInput("sunset", "Input sunset time", value = hms::as_hms("20:00:00"), seconds = FALSE)
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
                        # plotlyOutput("do_plot_hypoxia"),
                         plotlyOutput("light"),
                         dataTableOutput("do_hypoxia_metrics"))
                )
            )
    )
)


