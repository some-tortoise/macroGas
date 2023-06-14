library(shiny)

div(
  div(class = 'navbar-container',
      div(class = 'block-thing'),
      div(class = 'nav-el home-nav-el',
          div(class = 'nav-el-circle active-nav-el',
              onclick="openTab(event, 'home')"
          ),
          div(class = 'nav-text active-nav-text', 'Home')
      ),
      div(class = 'nav-el upload-nav-el',
          div(class = 'nav-el-circle',
              onclick="openTab(event, 'upload')"
          ),
          div(class = 'nav-text', 'Upload')
      ),
      div(class = 'nav-el flag-nav-el',
          div(class = 'nav-el-circle',
              onclick="openTab(event, 'flag')"
          ),
          div(class = 'nav-text', 'Flag')
      ),
      div(class = 'nav-el calculate-nav-el',
          div(class = 'nav-el-circle',
              onclick="openTab(event, 'calculate')"
          ),
          div(class = 'nav-text', 'Calculate')
      ),
      div(class = 'nav-el visualize-nav-el',
          div(class = 'nav-el-circle',
              onclick="openTab(event, 'visualize')"
          ),
          div(class = 'nav-text', 'Visualize')
      )
  )
)

