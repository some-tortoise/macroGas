div(class = 'trim panel-container',
    div(class = 'trim--text-container',
        div(class = 'trim--text-title-container',
            h1('Trim the salt slug'),
            div(class = 'style-bar trim--bar1')
            ),
        div(class = 'trim--main-text',
            p('The below plot displays all of the stations that you have uploaded. Please move the vertical bars around relevant breakthrough curves in order to trim out excess data.
                  This data will be carried forward through the rest of the app. Please be aware that once you choose to continue, data will have to be re-uploaded if you wish to make the selected bounds larger.'))
        ),
    plotlyOutput('trim_plot'),
    div(class = 'trim--continue-container',
        p('When you are happy with your trim, press continue'),
        actionButton('trimContinue', class='continue-btn', 'Continue')
        )
)

