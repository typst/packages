#import "./data-processing.typ"
#import "./layout.typ"
#import "./ribbon-stylizer.typ"
#import "./tinter.typ"
#import "./label.typ"

#let ribbony-diagram = (
	data,
	aliases: (:),
	categories: (:),
	layout: layout.auto-linear(),
	tinter: tinter.default-tinter(),
	ribbon-stylizer: ribbon-stylizer.match-from(),
	draw-label: none,
	debug: false,
) => {
	let nodes = data-processing.preprocess-data(data, aliases, categories)

	if (debug == 1) { repr(nodes) }
     
	let (layouter, drawer) = layout
	nodes = layouter(nodes)

	if (debug == 2) {	repr(nodes) }

	nodes = tinter(nodes)

	if (debug == 3) { repr(nodes) }

	drawer(nodes, ribbon-stylizer, draw-label)
}

#let sankey-diagram = (
    data,
    aliases: (:),
    categories: (:),
    layout: layout.auto-linear(),
    tinter: tinter.default-tinter(),
    ribbon-stylizer: ribbon-stylizer.match-from(),
    draw-label: label.default-linear-label-drawer(),
    ..args
) => ribbony-diagram(
    data,
    aliases: aliases,
    categories: categories,
    layout: layout,
    tinter: tinter,
    ribbon-stylizer: ribbon-stylizer,
    draw-label: draw-label,
    ..args
)

#let chord-diagram = (
	data,
	aliases: (:),
	categories: (:),
	layout: layout.circular(),
	tinter: tinter.default-tinter(),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to(),
	draw-label: label.default-circular-label-drawer(),
    ..args
) => ribbony-diagram(
    data,
    aliases: aliases,
    categories: categories,
    layout: layout,
    tinter: tinter,
    ribbon-stylizer: ribbon-stylizer,
    draw-label: draw-label,
    ..args
)

#sankey-diagram(
	(
		("A", "B", 2),
		("A", "B", 3),
		("A", "C", 3),
		("B", "D", 2),
		("B", "E", 4),
		("C", "D", 3),
		("C", "E", 4),
		("E", "F", 2),
	),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to(
		stroke-width: 0.2pt,
	)
)


#sankey-diagram(
	(
		"A": ("B": 5, "C": 3),
		"B": ("D": 2, "E": 4),
		"C": ("D": 3, "E": 4),
		"D": (:),
		"E": ("F": 2),
	)
)
#sankey-diagram(
	(
		"iPhone": (
			"Products": 44582
		),
		"Wearables, Home, Accessories": (
			"Products": 7404
		),
		"Mac": (
			"Products": 8046
		),
		"iPad": (
			"Products": 6581
		),
		"Products": (
			"Apple Net Sales Quarter": 66613
		),
		"Services": (
			"Apple Net Sales Quarter": 27423
		),
		"Apple Net Sales Quarter": (
			"Gross Margin": 43718,
			"Cost of Sales": 50318,
		),
		"Gross Margin": (
			"Operating Income": 28202,
			"Research & Development": 8866,
			"Selling, General, Administrative": 6650,
		),
		"Operating Income": (
			"Income before Taxes": 28031,
			"Other Expense": 171,
		),
		"Income before Taxes": (
			"Taxes": 4597,
			"Net Income": 23434
		)
	),
)
#sankey-diagram(
	(
		"iPhone": (
			"Products": 44582
		),
		"Wearables, Home, Accessories": (
			"Products": 7404
		),
		"Mac": (
			"Products": 8046
		),
		"iPad": (
			"Products": 6581
		),
		"Products": (
			"Apple Net Sales Quarter": 66613
		),
		"Services": (
			"Apple Net Sales Quarter": 27423
		),
		"Apple Net Sales Quarter": (
			"Gross Margin": 43718,
			"Cost of Sales": 50318,
		),
		"Gross Margin": (
			"Operating Income": 28202,
			"Research & Development": 8866,
			"Selling, General, Administrative": 6650,
		),
		"Operating Income": (
			"Income before Taxes": 28031,
			"Other Expense": 171,
		),
		"Income before Taxes": (
			"Taxes": 4597,
			"Net Income": 23434
		)
	),
	layout: layout.auto-linear(
		radius: 0,
		vertical: true
	)
)


#sankey-diagram(
	(
		"A": ("B": 4, "C": 9, "D": 4),
		"B": ("E": 2, "F": 2),
		"E": ("G": 1, "H": 1)
	),
	aliases: (
		"A": "meow"
	)
)
#sankey-diagram(
	(
		"Nuclear": (
			"Thermal generation": 839
		),
		"Agricultural 'waste'": (
			"Bio-conversion": 124
		),
		"UK land based bioenergy": (
			"Bio-conversion": 182
		),
		"Marine algae": (
			"Bio-conversion": 4
		),
		"Other waste": (
			"Bio-conversion": 77,
			"Solid": 56
		),
		"Tidal": (
			"Electricity grid": 9
		),
		"Wave": (
			"Electricity grid": 19
		),
		"Solar": (
			"Solar PV": 59,
			"Solar Thermal": 19
		),
		"Solar PV": (
			"Electricity grid": 59
		),
		"Geothermal": (
			"Electricity grid": 7
		),
		"Hydro": (
			"Electricity grid": 6
		),
		"Wind": (
			"Electricity grid": 289
		),
		"District heating": (
			"Industry": 10,
			"Heating and cooling - commercial": 22,
			"Heating and cooling - homes": 46
		),
		"Solar Thermal": (
			"Heating and cooling - homes": 19
		),
		"Pumped heat": (
			"Heating and cooling - homes": 193,
			"Heating and cooling - commercial": 70
		),
		"Bio-conversion": (
			"Losses": 26,
			"Solid": 280,
			"Gas": 81,
			"Liquid": 0
		),
		"Biomass imports": (
			"Solid": 35
		),
		"Coal imports": (
			"Coal": 11
		),
		"Coal reserves": (
			"Coal": 63
		),
		"Coal": (
			"Solid": 75
		),
		"Gas": (
			"Losses": 1,
			"Thermal generation": 151,
			"Heating and cooling - commercial": 0,
			"Industry": 48,
			"Agriculture": 2
		),
		"Gas imports": (
			"Ngas": 40
		),
		"Gas reserves": (
			"Ngas": 82
		),
		"Ngas": (
			"Gas": 122
		),
		"H2 conversion": (
			"H2": 20,
			"Losses": 6
		),
		"Solid": (
			"Agriculture": 0,
			"Thermal generation": 400,
			"Industry": 46
		),
		"Electricity grid": (
			"Losses": 56,
			"Industry": 342,
			"Over generation / exports": 104,
			"Lighting & appliances - commercial": 90,
			"Lighting & appliances - homes": 93,
			"Heating and cooling - homes": 113,
			"H2 conversion": 27,
			"Rail transport": 7,
			"Road transport": 37,
			"Agriculture": 4,
			"Heating and cooling - commercial": 40
		),
		"H2": (
			"Road transport": 20
		),
		"Liquid": (
			"Industry": 121,
			"Road transport": 135,
			"International aviation": 206,
			"International shipping": 128,
			"Agriculture": 3,
			"National navigation": 33,
			"Rail transport": 4,
			"Domestic aviation": 14
		),
		"Oil imports": (
			"Oil": 504
		),
		"Oil reserves": (
			"Oil": 107
		),
		"Oil": (
			"Liquid": 611
		),
		"Biofuel imports": (
			"Liquid": 35
		),
		"Thermal generation": (
			"Electricity grid": 525,
			"Losses": 787,
			"District heating": 79
		)
	),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to()
)

#chord-diagram(
	(
		"a": ("a": 1000, "b": 1000),
		"b": ("a": 1000, "b": 1000),
	),
	// tinter: node-tinter()
)

#chord-diagram(
	(
		"a": ("a": 1000, "b": (300, 500)),
		"b": ("a": 500, "b": 1000),
	),
    layout: layout.circular(directed: true)
	// tinter: node-tinter()
	// ribbon-stylizer: ribbon-stylizer.gradient-from-to()
)


#chord-diagram(
	(
		"black": ("black": 11975, "blond": 5871, "brown": 8916, "red": 2868),
		"blond": ("black": 1951, "blond": 10048, "brown": 2060, "red": 6171),
		"brown": ("black": 8010, "blond": 16145, "brown": 8090, "red": 8045),
		"red": ("black": 1013, "blond": 990, "brown": 940, "red": 6907)
	),
	layout: layout.circular(),
	tinter: tinter.dict-tinter((
		"black": rgb("#000000"),
		"blond": rgb("#ffdd89"),
		"brown": rgb("#957244"),
		"red": rgb("#f26223"),
	))
)
#chord-diagram(
	(
		matrix: (
			(11975, 5871, 8916, 2868),
			(1951, 10048, 2060, 6171),
			(8010, 16145, 8090, 8045),
			(1013, 990, 940, 6907)
		),
		ids: ("black", "blond", "brown", "red")
	),
	layout: layout.circular(),
	tinter: tinter.dict-tinter((
		"black": rgb("#000000"),
		"blond": rgb("#ffdd89"),
		"brown": rgb("#957244"),
		"red": rgb("#f26223"),
	))
)

#sankey-diagram(
	(
		"A": ("B": 10),
		"B": ("C": 10),
		"C": ("D": 10, "Y": 10),
		"D": ("E": 10),
		"X": ("C": 10),
	)
)
