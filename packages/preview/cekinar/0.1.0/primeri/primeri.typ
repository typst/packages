#set document(
	title: "Primeri UPN QR",
	author: "hpcfzl",
	description: "Primeri UPN QR iz paketa Cekinar",
	keywords: ("UPN QR", "primeri"),
	date: datetime.today(),
)

#set page(
	numbering: sym.dot + " 1 " + sym.dot,
	foreground: context {
		text(
			10em,
			fill: white.transparentize(100%),
			stroke: 2pt + gradient.radial(black.transparentize(65%), black.transparentize(95%)),
			if calc.rem(counter(page).get().first(), 3) == 0 {
				[IZVORNO]
			} else if calc.rem(counter(page).get().first() - 1, 3) == 0 and counter(page).get() != (1,) {
				[CEKINAR]
			},
		)
	},
)

#set text(lang: "sl")

#set raw(lang: "typ")

#set outline.entry(fill: repeat(gap: 0.45em)[.])

#set heading(numbering: (..n) => context {
	"0" * (str(counter(heading).final().last()).len() - str(n.pos().first() - 1).len()) + str(n.pos().first() - 1) + sym.space + sym.dot
})

#show heading: smallcaps

#show link: underline

#show link: set text(blue)

#show raw.where(block: true): block.with(
	width: 100%,
	height: 1fr,
	radius: 1pt,
	inset: 1em,
	fill: luma(250),
)

#let primer(naslov, izvirnik, kopija) = {
	heading(level: 1, naslov)
	divider()
	raw(block: true, kopija.replace("../cekinar/cekinar.typ", "@preview/cekinar:0.1.0"))
	page(margin: 0cm, izvirnik)
	eval(kopija, mode: "markup")
	pagebreak(weak: true)
}

#page(
	margin: 5cm,
	{
		set align(center)
		show heading: set align(left)
		title()
		[
			Vir datoteke PDF je dostopen v repozitoriju Typst paketa #link("https://typst.app/universe/package/cekinar")[Cekinar],
			vendar pa njena koda `primeri.typ` ni namenjena uporabniku.

			Vir vseh, razen primerov 12 in 13, je standard UPN QR.
		]
		outline()
		scale(60%, reflow: true, image("naslovnica-klicev.svg", alt: "Hierarhija klicev po datotekah paketa"))
	}
)

#primer(
	"Privzeto",
	align(bottom, image(/*width: 210mm, */"primer-00.svg", alt: "Prazen obrazec UPN QR")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar
	```.text
)

#primer(
	"Z naslovnice standarda",
	align(bottom, image(width: 210mm, "primer-01.svg", alt: "Obrazec UPN QR z naslovnice standarda")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 14.71,
		rok: datetime(day: 25, month: 6, year: 2016),
		namen: (
			koda: "SCVE",
			opis: "Ravn. z odpadki 04/2016 0040098579",
		),
		plačnik: (
			ime: "Janez Novak",
			ulica: "Lepa cesta 10",
			kraj: "2000 Maribor",
		),
		prejemnik: (
			ime: "Snaga d.o.o.",
			ulica: "Povšetova ulica 6",
			kraj: "1000 Ljubljana",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI12 1033842574531",
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obveznosti, gotovinsko",
	align(bottom, image(width: 210mm, "primer-02.png", alt: "Obrazec UPN QR za gotovinsko plačilo obveznosti")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 81.05,
		namen: (
			koda: "COST",
			opis: "Plačilo obveznosti 10/2016",
		),
		plačnik: (
			ime: "Janez Novak",
			ulica: "Dunajska 1",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI05 98765432108", // SI05 98765432100 ni veljavna
		),
		možnosti: (
			qr: true,
			nalog: "plačilo-obveznosti",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obveznosti, negotovinsko",
	align(bottom, image(width: 210mm, "primer-03.png", alt: "Obrazec UPN QR za negotovinsko plačilo obveznosti")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 1280.67,
		namen: (
			koda: "ADVA",
			opis: "Plačilo avansa-ponudba 2016/12",
		),
		plačnik: (
			ime: "Združenje bank Slovenije",
			ulica: "Šubičeva 2",
			kraj: "1000 Ljubljana",
			iban: "SI56 0201 7001 4356 205",
			referenca: "SI00 3528-990",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI00 123456-67890-12345",
		),
		možnosti: (
			qr: true,
			nalog: "plačilo-obveznosti",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obveznosti registriranega izdajatelja",
	align(bottom, image(width: 210mm, "primer-04.png", alt: "Obrazec UPN QR za plačilo obveznosti registriranega izdajatelja")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 81.05,
		rok: datetime(day: 15, month: 11, year: 2016),
		namen: (
			koda: "RENT",
			opis: "Plačilo najemnine 10/2016",
		),
		plačnik: (
			ime: "Janez Novak",
			ulica: "Dunajska 1",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI12 9990000359896",
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obv. reg. izd. za humanitarne namene",
	align(bottom, image(width: 210mm, "primer-05.png", alt: "Obrazec UPN QR za humanitarne namene")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		namen: (
			koda: "CHAR",
			opis: "Donacija v dobrodelne namene",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI12 1234567890120",
		),
		možnosti: (
			qr: true,
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za polog gotovine",
	align(bottom, image(width: 210mm, "primer-06.png", alt: "Obrazec UPN QR za polog gotovine")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 280,
		polog: true,
		datum: datetime(day: 30, month: 11, year: 2016),
		namen: (
			koda: "CASH",
			opis: "Polog iztržka za november",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
		),
		možnosti: (
			qr: true,
			nalog: "polog-gotovine",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za dvig gotovine",
	align(bottom, image(width: 210mm, "primer-07.png", alt: "Obrazec UPN QR za dvig gotovine")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 350,
		datum: datetime(day: 30, month: 11, year: 2016),
		dvig: true,
		namen: (
			koda: "CSDB",
			opis: "Dnevnica november 2016",
		),
		plačnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
		),
		možnosti: (
			qr: true,
			nalog: "dvig-gotovine",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obveznosti, negotovinsko, čezmejno, RF",
	align(bottom, image(width: 210mm, "primer-08.png", alt: "Obrazec UPN QR za čezmejno plačilo obveznosti")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 131.67,
		namen: (
			koda: "SUBS",
			opis: "Letna naročnina na ZZYS",
		),
		plačnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "RF81 352A DD05 899",
		),
		prejemnik: (
			ime: "Gesselshaft GmbH",
			ulica: "Rosenthal 15",
			kraj: "DE-86807 Buchloe",
			iban: "DE12 5001 0517 0648 4898 90",
			referenca: "RF45 SBO2 010",
		),
		možnosti: (
			qr: true,
			nalog: "plačilo-obveznosti",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obveznosti registriranega izdajatelja, RF",
	align(bottom, image(width: 210mm, "primer-09.png", alt: "Obrazec UPN QR z referenco RF")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 81.05,
		rok: datetime(day: 15, month: 11, year: 2016),
		namen: (
			koda: "RENT",
			opis: "Plačilo najemnine 10/2016",
		),
		plačnik: (
			ime: "Janez Novak",
			ulica: "Dunajska 1",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "RF45 SBO2 010",
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

// Napaka v standardu, ker vrednost _Namen in rok plačila_ ni v eni vrstici, datum 12/2026 pa postane 2026/12
#primer(
	"Nalog za plačilo obveznosti, negotovinsko, ročno",
	align(bottom, image(width: 210mm, "primer-10.png", alt: "Ročno izpolnjen obrazec UPN QR")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 1280.67,
		datum: datetime(day: 15, month: 12, year: 2016),
		namen: (
			koda: "ADVA",
			opis: "Plačilo avansa 12/2016",
		),
		plačnik: (
			ime: "Združenje bank Slovenije",
			ulica: "Šubičeva 2",
			kraj: "1000 Ljubljana",
			iban: "SI56 0201 7001 4356 205",
			referenca: "SI00 3528-990",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI00 123456-67890-12345",
		),
		možnosti: (
			ročno: true,
			nalog: "plačilo-obveznosti",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

#primer(
	"Nalog za plačilo obv. reg. izd. za hum. nam., ročno, strojno",
	align(bottom, image(width: 210mm, "primer-11.png", alt: "Ročno in strojno izpolnjen obrazec UPN QR")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 150,
		namen: (
			koda: "CHAR",
			opis: "Donacija v dobrodelne namene",
		),
		plačnik: (
			ime: "Janez Novak",
			ulica: "Dunajska 1",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Novo podjetje d.o.o.",
			ulica: "Lepa cesta 15",
			kraj: "3698 Loški Potok",
			iban: "SI56 0510 0801 0486 080",
			referenca: "SI12 1234567890120",
		),
		možnosti: (
			qr: true,
			ročno: (
				znesek: true,
				plačnik: (
					ime: true,
					ulica: true,
					kraj: true,
				),
			),
			nalog: "registriran-izdajatelj",
			vodni-žig: "VZOREC",
		),
	)
	```.text,
)

// Velika začetnica v "Članarina"
// [TODO] Preliv `logotip: (naziv: "INO d.o.o., Celje, 2017")`
#primer(
	"Slovensko društvo za celiakijo",
	align(bottom, image(/*width: 210mm, */"primer-12.png", alt: "Naključen obrazec UPN QR društva")),
	```
	#import "../cekinar/cekinar.typ": *
	
	#show: cekinar.with(
		znesek: 30,
		namen: (
			koda: "OTHR",
			opis: "Članarina za leto 2025",
		),
		prejemnik: (
			ime: "Slovensko društvo za celiakijo",
			ulica: "Ljubljanska 5",
			kraj: "2000 Maribor",
			iban: "SI56 0417 3000 0683 753",
			referenca: "SI00 900",
		),
		možnosti: (
			qr: true,
		),
	)
	```.text,
)

#show raw: set text(0.65em)

// [TODO] Preliv `logotip: (naziv: "INO d.o.o., Celje, 2017")`
#primer(
	"Družabno omrežje 𝕏",
	image(width: 210mm, height: 298mm, "primer-13.png", alt: "Naključen obrazec UPN QR iz družbenega omrežja"),
	```
	#import "../cekinar/cekinar.typ": *
	
	#set page(margin: 0mm)
	#set block(spacing: 0mm)
	
	#show: cekinar.with(
		znesek: 4000,
		namen: (
			koda: "GOVT",
			opis: "Sodna taksa Okrajno sodišče v Ljubljani",
		),
		plačnik: (
			ime: "Stranka slovenska demokratska",
			ulica: "Trstenjakova ulica 8",
			kraj: "Ljubljana",
		),
		prejemnik: (
			ime: "Okrajno sodišče v Ljubljani",
			ulica: "Mala ulica 3",
			kraj: "1000 Ljubljana",
			iban: "SI56 0110 0845 0162 114",
			referenca: "SI11 824260000085-1816270-8", // SI11 824260000082-1816276-8 ni veljavna
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
			postavitev: "",
		),
	)
	
	#show: cekinar.with(
		znesek: 40000,
		namen: (
			koda: "GOVT",
			opis: "Globa Okrajno sodišče v Ljubljani",
		),
		plačnik: (
			ime: "Slovenska demokratska stranka",
			ulica: "Trstenjakova ulica 8",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Okrajno sodišče v Ljubljani",
			ulica: "Mala ulica 3",
			kraj: "1000 Ljubljana",
			iban: "SI56 0110 0845 0056 578",
			referenca: "SI11 324230013916-1816270-0", // SI11 324230013911-1816276-0 ni veljavna
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
			postavitev: "",
		),
	)
	
	#show: cekinar.with(
		znesek: 15,
		namen: (
			koda: "GOVT",
			opis: "Drugi stroški postopka Okrajno sodišče", // Predolgo je za še _ v L_
		),
		plačnik: (
			ime: "Slovenska demokratska stranka",
			ulica: "Trstenjakova ulica 8",
			kraj: "1000 Ljubljana",
		),
		prejemnik: (
			ime: "Okrajno sodišče v Ljubljani",
			ulica: "Mala ulica 3",
			kraj: "1000 Ljubljana",
			iban: "SI56 0110 0845 0056 481",
			referenca: "SI11 324230013916-1816270-4", // SI11 324230013911-1816276-4 ni veljavna
		),
		možnosti: (
			qr: true,
			nalog: "registriran-izdajatelj",
			postavitev: "",
		),
	)
	```.text,
)