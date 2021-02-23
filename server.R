server <- function(input, output, session) {
	
	# get pop data with geometry from api
	response <- reactive({
		lon <- ifelse(is.na(input$lon), 0, input$lon)
		lat <- ifelse(is.na(input$lat), 0, input$lat)
		
		url <- glue(
			"https://api.oliverfritz.de/exact_extract/circle/worldpop",
			"?lon={lon}",
			"&lat={lat}",
			"&radius={format(input$radius*1000, scientific = F)}",
			"&geom=true"
		)
		read_sf(url) %>% mutate(id = "pickpop")
	})
	
	# prepare map
	output$map <- renderLeaflet({
		leaflet() %>% 
			addProviderTiles(providers$CartoDB.Positron) %>%
			addTiles(urlTemplate = "", attribution = pop_attribution) %>%
			setView(10, 25, zoom = 3)
	})
	
	# update map
	observe({
		leafletProxy("map", data = response()) %>%
			addPolygons(
				layerId = ~id, 
				# label = ~paste0(name, ": ", case_when(mobility > 0 ~ "+", mobility < 0 ~ "-", TRUE ~ ""), abs(mobility), "%"),
				fillColor =  "DodgerBlue",
				stroke = F, fillOpacity = .66
			)
	})
	
	# update lat/lon on map click
	observe({
		click <- input$map_click
		if(is.null(click)) return()
		
		updateNumericInput(session, "lat", value = round(click$lat, 6))
		updateNumericInput(session, "lon", value = round(click$lng, 6))
	})
	
	# print pop
	output$pop <- renderText({
		glue("{format(round(response()$sum.worldpop2020), big.mark = ',')} people")
	})
	

}