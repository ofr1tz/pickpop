server <- function(input, output, session) {
	
	# hide lat/lon numeric input on mobile (see https://g3rv4.com/2017/08/shiny-detect-mobile-browsers) 
	observe({ toggleElement(id = "latlon", condition = !input$isMobile) })
	
	
	# parse input parameters from url (see https://stackoverflow.com/a/65552636)
	observe({
		query <- parseQueryString(session$clientData$url_search)
		if (!is.null(query[["lat"]])) {
			updateNumericInput(session, "lat", value = as.numeric(query[["lat"]]))
		}
		if (!is.null(query[["lon"]])) {
			updateNumericInput(session, "lon", value = as.numeric(query[["lon"]]))
		}
		if (!is.null(query[["radius"]])) {
			updateNumericInput(session, "radius", value = as.numeric(query[["radius"]]))
		}
	})
	
	# update url query string
	observe({
		updateQueryString(
			glue("?lat={input$lat}&lon={input$lon}&radius={input$radius}")
		)
		
	})

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
			htmlwidgets::onRender(
				"function(el, x) { L.control.zoom({ position: 'topright' }).addTo(this) }"
			) %>%
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
		people <- round(response()$sum.worldpop2020)
		glue("{format(people, big.mark = ',')} {ifelse(people == 1, 'person', 'people')}")
	})
	

}