#import "@preview/cekinar:0.1.0": *

#show: cekinar.with(
	znesek: none,
	datum: none,
	rok: none,
	nujno: false,
	polog: false,
	dvig: false,
	namen: (
		koda: "",
		opis: "",
	),
	plačnik: (
		ime: "",
		ulica: "",
		kraj: "",
		iban: "",
		referenca: "",
		podpis: none,
	),
	prejemnik: (
		ime: "",
		ulica: "",
		kraj: "",
		iban: "",
		referenca: "",
	),
	logotip: (
		logo: none,
		naziv: "",
	),
	možnosti: (
		qr: false,
		ročno: false,
		jezik: "sl",
		nalog: "",
		kamuflaža: "",
		vodni-žig: "",
		postavitev: "A4/1",
		prozorno: false,
	),
)

#block(
	inset: 1em,
	lorem(100),
)