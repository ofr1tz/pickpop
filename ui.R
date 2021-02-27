ui <- bootstrapPage(
	
	useShinyjs(),
	setBackgroundColor("#d4dadc"), 
	setSliderColor("DodgerBlue", 1),
	tags$head(
		tags$style(HTML(
			'html, body {width:100%;height:100%; font-family:Consolas, "Ubuntu Mono", monospace;}',
			'#pop{font-size: 25px;font-style: bold;}',
			'.leaflet-container { background: #d4dadc; }'
	))),
	mobileDetect("isMobile"),
	
	addSpinner(leafletOutput("map", width = "100%", height = "100%")),
	
	absolutePanel(
		width = 275, top = 20, left = 30, draggable = T,
		fixedRow(
		column(10, titlePanel("pickPop")),
		column(2, circleButton(
			inputId = "about", icon = icon("question"), 
			size = "xs",  style = "margin-top: 20px;",
			onclick ="window.open('https://www.oliverfritz.de/portfolio/pickpop', '_blank')"
		))
		),
		helpText(
			"Click on the map, choose a radius ",
			"and find out how many people live ", 
			"in the area."
		),
		fixedRow(
			id = "latlon", hidden = T,
			column(6,numericInput("lat", "Latitude", value = 0, min = -90, max = 90)),
			column(6, numericInput("lon", "Longitude", value = 0, min = -180, max = 180))
		),
		sliderInput("radius", "Radius (km)", value = 100, min = 1, max = 1000, step = 1, ticks = F),
		textOutput("pop")
		
	)
)
