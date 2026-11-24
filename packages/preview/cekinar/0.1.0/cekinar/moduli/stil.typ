#let barve = (
	brez: color.spot(
		none,
		white.transparentize(100%), // Drugače ne gre
	).tint(100%),
	bela: color.spot(
		"Pantone White", // [TODO] Napaka v standardu, ker ni enoumno
		cmyk(0%, 0%, 0%, 0%), // Ugibano
	).tint(100%),
	črna: color.spot(
		"Pantone Black", // [TODO] Napaka v standardu, ker ni enoumno
		cmyk(0%, 0%, 0%, 100%), // Ugibano
	).tint(100%),
	roza: color.spot(
		"Pantone 172 U",
		cmyk(0%, 60%, 70%, 0%), // S `tint(20%)` postane `cmyk(0%, 12%, 14%, 0%)`
	).tint(20%),
	rumena: color.spot(
		"Pantone 116 U",
		cmyk(0%, 29%, 93%, 0%), // S `tint(20%)` postane `cmyk(0%, 5.8%, 18.6%, 0%)`
	).tint(20%),
	oranžna: color.spot(
		"Pantone 172 U",
		cmyk(0%, 60%, 70%, 0%),
	).tint(100%),
	izpis: cmyk(0%, 0%, 0%, 100%), // [TODO] Napaka v standardu, ker ni omembe. Je enako kot `črna`, ampak brez Pantone, da ni potrate
	/* [TODO] Ni vključeno, ker 2/3 barv ni prepoznanih
	dno: (
		levo: cmyk(0%, 24%, 37%, 3%), // [TODO] Napaka v standardu, ker ni omembe
		desno: (
			primarna: cmyk(0%, 26%, 46%, 3%), // [TODO] Napaka v standardu, ker ni omembe
			sekundarna: color.spot(
				"Pantone 116 U",
				cmyk(0%, 29%, 93%, 0%), // S `tint(10%)` postane `cmyk(0%, 2.9%, 9.3%, 0%)`
			).tint(10%),
		),
	),
	*/
)

#let črta = (
	tanka: 0.25pt,
	debela: 0.5pt,
)

#let črtkano = (
	polje: (0.5pt, 0.2pt),
	mikroperforacija: (0.5pt, 0.5pt),
)