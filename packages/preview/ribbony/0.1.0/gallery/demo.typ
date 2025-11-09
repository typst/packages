#import "../src/ribbony.typ": *

#set align(center)
#set page(width: 20cm, height: 36.5cm, margin: (x: 0.5cm, y: 0.5cm))

#sankey-diagram(
	(
		("iPhone", "Products", 44582),
		("Wearables, Home, Accessories", "Products", 7404),
		("Mac", "Products", 8046),
		("iPad", "Products", 6581),
		("Products", "Apple Net Sales Quarter ended 2025-06-28", 800),
		("Products", "Apple Net Sales Quarter ended 2025-06-28", 42820),
		("Services", "Apple Net Sales Quarter ended 2025-06-28", 6698),
		("Products", "Apple Net Sales Quarter ended 2025-06-28", 22993),
		("Services", "Apple Net Sales Quarter ended 2025-06-28", 20725),
		("Apple Net Sales Quarter ended 2025-06-28", "Cost of Sales", 800),
		("Apple Net Sales Quarter ended 2025-06-28", "Cost of Sales", 42820),
		("Apple Net Sales Quarter ended 2025-06-28", "Cost of Sales", 6698),
		("Apple Net Sales Quarter ended 2025-06-28", "Gross Margin", 22993),
		("Apple Net Sales Quarter ended 2025-06-28", "Gross Margin", 20725),
		("Gross Margin", "Research & Development", 8866),
		("Gross Margin", "Selling, General, Administrative", 6650),
		("Gross Margin", "Operating Income", 28202),
		("Operating Income", "Other Expense", 171),
		("Operating Income", "Income before Taxes", 28031),
		("Income before Taxes", "Taxes", 4597),
		("Income before Taxes", "Net Income", 23434)
	),
	layout: layout.auto-linear(node-gap: 1.5),
	draw-label: label.default-linear-label-drawer(formatter: (val) => str(val) + "M"),
)

#chord-diagram(
	(
		matrix: (
			(9.6899, 0.8859, 0.0554, 0.443, 2.5471, 2.4363, 0.5537, 2.5471),
			(0.1107, 1.8272, 0, 0.4983, 1.1074, 1.052, 0.2215, 0.4983),
			(0.0554, 0.2769, 0.2215, 0.2215, 0.3876, 0.8306, 0.0554, 0.3322),
			(0.0554, 0.1107, 0.0554, 1.2182, 1.1628, 0.6645, 0.4983, 1.052),
			(0.2215, 0.443, 0, 0.2769, 10.4097, 1.2182, 0.4983, 2.8239),
			(1.1628, 2.6024, 0, 1.3843, 8.7486, 16.8328, 1.7165, 5.5925),
			(0.0554, 0.4983, 0, 0.3322, 0.443, 0.8859, 1.7719, 0.443),
			(0.2215, 0.7198, 0, 0.3322, 1.6611, 1.495, 0.1107, 5.4264)
		),
		ids: ("Apple", "HTC", "Huawei", "LG", "Nokia", "Samsung", "Sony", "Other")
	),
	draw-label: label.default-circular-label-drawer(formatter: (val) => str(calc.round(val, digits:1)) + "%"),
	ribbon-stylizer: ribbon-stylizer.match-greater-direction(),
	layout: layout.circular(radius: 6),
)


#sankey-diagram(
	(
		("Agricultural 'waste'", "Bio-conversion", 124.729),
		("Bio-conversion", "Liquid", 0.597),
		("Bio-conversion", "Losses", 26.862),
		("Bio-conversion", "Solid", 280.322),
		("Bio-conversion", "Gas", 81.144),
		("Biofuel imports", "Liquid", 35),
		("Biomass imports", "Solid", 35),
		("Coal imports", "Coal", 11.606),
		("Coal reserves", "Coal", 63.965),
		("Coal", "Solid", 75.571),
		("District heating", "Industry", 10.639),
		("District heating", "Heating and cooling - commercial", 22.505),
		("District heating", "Heating and cooling - homes", 46.184),
		("Electricity grid", "Over generation / exports", 104.453),
		("Electricity grid", "Heating and cooling - homes", 113.726),
		("Electricity grid", "H2 conversion", 27.14),
		("Electricity grid", "Industry", 342.165),
		("Electricity grid", "Road transport", 37.797),
		("Electricity grid", "Agriculture", 4.412),
		("Electricity grid", "Heating and cooling - commercial", 40.858),
		("Electricity grid", "Losses", 56.691),
		("Electricity grid", "Rail transport", 7.863),
		("Electricity grid", "Lighting & appliances - commercial", 90.008),
		("Electricity grid", "Lighting & appliances - homes", 93.494),
		("Gas imports", "Ngas", 40.719),
		("Gas reserves", "Ngas", 82.233),
		("Gas", "Heating and cooling - commercial", 0.129),
		("Gas", "Losses", 1.401),
		("Gas", "Thermal generation", 151.891),
		("Gas", "Agriculture", 2.096),
		("Gas", "Industry", 48.58),
		("Geothermal", "Electricity grid", 7.013),
		("H2 conversion", "H2", 20.897),
		("H2 conversion", "Losses", 6.242),
		("H2", "Road transport", 20.897),
		("Hydro", "Electricity grid", 6.995),
		("Liquid", "Industry", 121.066),
		("Liquid", "International shipping", 128.69),
		("Liquid", "Road transport", 135.835),
		("Liquid", "Domestic aviation", 14.458),
		("Liquid", "International aviation", 206.267),
		("Liquid", "Agriculture", 3.64),
		("Liquid", "National navigation", 33.218),
		("Liquid", "Rail transport", 4.413),
		("Marine algae", "Bio-conversion", 4.375),
		("Ngas", "Gas", 122.952),
		("Nuclear", "Thermal generation", 839.978),
		("Oil imports", "Oil", 504.287),
		("Oil reserves", "Oil", 107.703),
		("Oil", "Liquid", 611.99),
		("Other waste", "Solid", 56.587),
		("Other waste", "Bio-conversion", 77.81),
		("Pumped heat", "Heating and cooling - homes", 193.026),
		("Pumped heat", "Heating and cooling - commercial", 70.672),
		("Solar PV", "Electricity grid", 59.901),
		("Solar Thermal", "Heating and cooling - homes", 19.263),
		("Solar", "Solar Thermal", 19.263),
		("Solar", "Solar PV", 59.901),
		("Solid", "Agriculture", 0.882),
		("Solid", "Thermal generation", 400.12),
		("Solid", "Industry", 46.477),
		("Thermal generation", "Electricity grid", 525.531),
		("Thermal generation", "Losses", 787.129),
		("Thermal generation", "District heating", 79.329),
		("Tidal", "Electricity grid", 9.452),
		("UK land based bioenergy", "Bio-conversion", 182.01),
		("Wave", "Electricity grid", 19.013),
		("Wind", "Electricity grid", 289.366)
	),
	layout: layout.auto-linear(
		node-gap: 0.5,
		layer-gap: 1.8,
		min-node-height: 0,
		radius: 0,
		layers: (
			"0": ("Nuclear", "Gas imports", "Gas reserves", "Agricultural 'waste'", "UK land based bioenergy", "Marine algae", "Geothermal", "Other waste", "Solar", "Hydro", "Tidal", "Biomass imports", "Wave", "Coal imports", "Wind", "Coal reserves", "Pumped heat", "Oil imports", "Oil reserves", "Biofuel imports"),
			"1": ("Ngas", "Bio-conversion", "Solar PV", "Solar Thermal", "Coal", "Oil"),
			"2": ("Gas", "Liquid", "Solid"),
			"3": "Thermal generation",
			"4": ("District heating", "Electricity grid"),
			"5": "H2 conversion",
			"6": "H2",
			"7": ("Losses", "Over generation / exports", "Heating and cooling - homes", "Heating and cooling - commercial", "Lighting & appliances - homes", "Lighting & appliances - commercial", "Industry", "Road transport", "Rail transport", "International aviation", "Domestic aviation", "International shipping", "National navigation", "Agriculture")
		)
	),
	tinter: tinter.layer-tinter(palette: tinter.palette.catppuccin),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to(),
	draw-label: label.default-linear-label-drawer(
		width-limit: false,
		draw-content: (properties, ..) => [
			#text(properties.name, size: 0.3cm) \
		]
	),
)