div(class = 'view page',
    div(class = 'view--intro-container',
        div(class = 'view--intro',
            selectInput('view_site', div('Choose Site'), c('NHC', 'France')),
            dateRangeInput('view_dateRange', 'Enter Date Range')
        )
    ),
    div(class = 'view--main',
        div(class = 'view--type-container',
            h1('Dissolved Oxygen (DO)'),
            tabPanel('Graph',plotlyOutput('view_plot'))
        )
    )
)
