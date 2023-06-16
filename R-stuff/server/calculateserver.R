library(shiny)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

calculateserver <- function(input, output, session){
  
}