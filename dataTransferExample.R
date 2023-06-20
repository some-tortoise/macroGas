library(shiny)

ui1 <- function(id){
  tagList(
    selectInput(NS(id,'sel'), 'select', choices = c(1, 5))
  )
}

ui2 <- function(id){
  tagList(
    selectInput(NS(id,'sel'), 'select', choices = c(3, 9))
  )
}

inputModule <- function(input, output, session){
  vals <- reactive({input$sel})
  return(vals)
}

ui3 <- function(id){
  textOutput('sum')
}

runDemo <- function(){
  ui <- fluidPage(
    ui1('first'),
    ui2('second'),
    ui3('third')
  )
  server <- function(input, output, session){
    proxy1 <- callModule(inputModule, 'first')
    proxy2 <- callModule(inputModule, 'second')
    output$sum <- renderText({
      glue::glue("{proxy1()} + {proxy2()} is {as.numeric(proxy1())+as.numeric(proxy2())}")
    })
  }
  shinyApp(ui, server)
}

runDemo()