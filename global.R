# prerequisites
require(tidyverse)
require(sf)
require(glue)
require(leaflet)
require(shiny)
require(shinyWidgets)
require(shinyjs)

require(conflicted)
conflict_prefer("addLegend", "leaflet")
conflict_prefer("filter", "dplyr")

pop_attribution = paste0(
	"Population Data: ",
	"<a href = 'https://www.worldpop.org/' target='_blank'>WorldPop</a> ",
	"(",
	"<a href = 'https://creativecommons.org/licenses/by/4.0/' target='_blank'>CC BY 4.0</a>",
	")"
	
)

# detect mobile (https://github.com/g3rv4/mobileDetect)
mobileDetect <- function(inputId, value = 0) {
	tagList(
		singleton(tags$head(tags$script(src = "mobile.js"))),
		tags$input(id = inputId, class = "mobile-element", type = "hidden")
	)
}