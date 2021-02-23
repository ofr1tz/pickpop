ui <- bootstrapPage(
	tags$head(tags$style(HTML(
		'html, body {width:100%;height:100%; font-family:Consolas, "Ubuntu Mono", monospace;}',
		"#dropdown-menu-controls {background-color:rgba(255,255,255,0.7) !important;padding:15px;border-radius:10px;}",
		'div.info.legend.leaflet-control {margin-bottom:37px; font-family:Consolas, "Ubuntu Mono", monospace;}'
	))),
	leafletOutput("map", width = "100%", height = "100%"),
	absolutePanel(
		top = 20, left = 30, draggable = T,
		titlePanel("pickPop"),
		helpText(
			"Click on the map, choose a radius", br(), 
			"and find out how many people live", br(), 
			"in the area."
		),
		fixedRow(
			column(3,numericInput("lat", "Latitude", value = 0, min = -90, max = 90)),
			column(3, numericInput("lon", "Longitude", value = 0, min = -180, max = 180))
		),
		sliderInput("radius", "Buffer Radius (km)", value = 100, min = 1, max = 1000, step = .1, ticks = F),
		textOutput("pop"),
		tags$head(tags$style("#pop{font-size: 25px;font-style: bold;}"))
		
	) #, 
	# absolutePanel(
	# 	top = 20, right = 80,
	# 	circleButton(
	# 		inputId = "about", icon = icon("question"),
	# 		onclick ="window.open('link to portfolio article', '_blank')"
	# 	)
	# )
)