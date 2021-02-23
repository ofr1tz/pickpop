server <- function(input, output, session) {
	
	# get pop data with geometry from api
	response <- reactive({
		lat <- replace_na(input$lat, 0)
		lon <- replace_na(input$lon, 0)

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
		leaflet(options = leafletOptions(zoomControl = FALSE)) %>% 
			htmlwidgets::onRender("function(el, x) { L.control.zoom({ position: 'topright' }).addTo(this) }") %>%
			addProviderTiles(providers$CartoDB.Positron) %>%
			addTiles(urlTemplate = "", attribution = pop_attribution) %>%
			setView(10, 25, zoom = 3) %>%
			setMaxBounds(lng1 = -180, lat1 = 90, lng2 = 180, lat2 = -90)
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
		
		clicklat <- click$lat
		clicklon <- click$lng
		if(clicklon > 180) clicklon <-  clicklon-360
		if(clicklon < -180) clicklon <-  clicklon+360
		
		updateNumericInput(session, "lat", value = round(clicklat, 6))
		updateNumericInput(session, "lon", value = round(clicklon, 6))
	})
	
	# print pop
	output$pop <- renderText({
		glue("{format(round(response()$sum.worldpop2020), big.mark = ',')} people")
	})
	

}