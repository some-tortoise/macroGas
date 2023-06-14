library(shiny)

div(
  div(class = 'navbar-container',
      div(class = 'block-thing'),
      div(class = 'nav-el upload-nav-el',
          div(class = 'nav-el-circle',
              onclick="openCity(event, 'upload')",
              id = 'open-nav-el'
              )
          ),
      div(class = 'nav-el flag-nav-el',
          div(class = 'nav-el-circle',
              onclick="openCity(event, 'flag')"
              )
          ),
      div(class = 'nav-el calculate-nav-el',
          div(class = 'nav-el-circle',
              onclick="openCity(event, 'calculate')"
              )
          ),
      div(class = 'nav-el visualize-nav-el',
          div(class = 'nav-el-circle',
              onclick="openCity(event, 'visualize')"
              )
          )
      )
)

