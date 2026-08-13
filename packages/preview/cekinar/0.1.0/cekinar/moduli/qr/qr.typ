#import "../stil.typ": barve

// Kombinacija obeh privzetih vrednosti namenoma javi napako
#let qr(simbol: bytes(""), a: 77) = if calc.sqrt(simbol.len()) != a {
	panic("Pričakovana je bila koda QR stranice `" + str(a) + "`, dobljena pa je " + str(calc.sqrt(simbol.len())))
} else {
	align(
		center + horizon, // Ugibano
		// Neupoštevanje standarda, ker celokupno 32,59641-mm tukajšnja koda QR odstopa za 0,000NN mm od 32,59676 in 32,59667 mm?
		grid(
			columns: (0.42333mm,) * a,
			rows: (0.42333mm,) * a,
			..array(simbol).map(modul => grid.cell(
					fill: if modul == 0 {
						// Naj bo brez polnila
						// barve.bela
					} else if modul == 1 {
						barve.izpis
					} else {
						panic("V kodi QR je modul nedvojiške vrednosti " + modul)
					},
				)[]
			),
		),
	)
}