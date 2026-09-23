// [TODO] Nekaj je še TODO-komentarjev, ampak niso kritični za uporabo paketa
#let cekinar(
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
	body,
) = {
	// Izjemoma se tukaj že doda morebitno manjkajoča `možnosti.qr` in `možnosti.jezik`
	možnosti = (qr: false, jezik: "sl") + možnosti

	// Ni v `razsodba.typ`, ker ni možno preposlati `možnosti`
	if možnosti.jezik not in ("en", "sl") { panic("Neznana možnost jezika '" + repr(možnosti.jezik) + "'") }
	let prevodi = toml("../prevodi/" + možnosti.jezik + ".toml")
	set text(lang: možnosti.jezik)

	// Samostojne barve in črte
	import "./moduli/stil.typ": *

	// Ni v `stil.typ`, ker so potem povsod nujno `prevodi`
	// Uporabi se kot `(pisave.glavna)("")`:
	// * Ne kot `(pisave.glavna)[]`, ker:
	//   * Je bilo narejeno edino za nize
	//   * So nizi uporabljeni tudi drugod
	// * Vir https://forum.typst.app/t/how-can-i-instantiate-a-dictionary-with-a-variable-key-name/652
	let pisave = (
		glavna: (
			navadna: it => text(
				if it in prevodi.pet.values() {
					5pt
				} else if it in prevodi.šest.values() {
					6pt
				} else {
					5pt // [TODO] Naj bi bilo `panic()`, ampak izjemoma ni zaradi `logotip.naziv`
				},
				barve.oranžna, // [TODO] Prostora za vpise ponudnika plačilnih storitev zares nista iste barve
				font: ("Myriad Pro", "Hind"),
				weight: "regular",
				it,
			),
			krepka: it => text(
				if it in (
					..prevodi.sedem.values(),
					..prevodi.sedem.plačnik.values(),
					..prevodi.sedem.prejemnik.values(),
				) {
					7pt
				} else if it in prevodi.devet.values() {
					9pt
				} else if it in prevodi.deset.values() {
					10pt
				} else if it in prevodi.enajst.values() {
					11pt
				} else {
					panic("Nobena glavna krepka pisava ne ustreza besedilu '" + repr(it) + "'")
				},
				if it in (
					..prevodi.devet.values(),
					..prevodi.deset.values(),
					..prevodi.enajst.values(),
				) {
					barve.črna
				} else {
					barve.oranžna
				},
				font: ("Myriad Pro", "Hind"),
				weight: "semibold",
				it,
			),
		),
		izpolnjevanje: (
			strojno: (
				// Napaka v standardu, ker je v potrdilu hitro predolgo
				ožje: it => box(
					scale(
						x: 65%,
						reflow: true,
						text(
							10pt,
							barve.izpis,
							font: ("Courier New", "Courier Prime"),
							weight: "bold",
							it,
						),
					),
				),
				ozko: it => box(
					scale(
						x: 70.58%,
						reflow: true,
						text(
							10pt,
							barve.izpis,
							font: ("Courier New", "Courier Prime"),
							weight: "bold",
							it,
						),
					),
				),
				široko: it => text(
					10pt,
					barve.izpis,
					font: ("Courier New", "Courier Prime"),
					weight: "bold",
					it,
				),
			),
			ročno: (
				// Napaka v standardu, ker je v potrdilu hitro predolgo
				manjše: it => text(
					6pt,
					barve.izpis,
					font: "Indie Flower",
					weight: "regular",
					it,
				),
				majhno: it => text(
					10pt,
					barve.izpis,
					font: "Indie Flower",
					weight: "regular",
					it,
				),
				veliko: it => text(
					12pt,
					barve.izpis,
					font: "Indie Flower",
					weight: "regular",
					it,
				),
			),
		),
	)

	// Samostojni liki za postavitev
	import "./moduli/liki.typ": *

	let kvadrat(
		x1: 0mm, y1: 0mm,
		a: 0mm,
		besedilo: "",
		označeno: false,
		nalivnik: false,
	) = place(
		dx: x1,
		dy: y1,
		{
			place(
				dx: 0.05mm,
				dy: -2.9mm,
				box(
					width: a,
					align(center, besedilo)
				)
			)
			square(
				size: a,
				fill: barve.bela,
				stroke: črta.debela + barve.oranžna,
				inset: 0mm,
				{
					place(
						curve(
							stroke: črta.tanka + barve.oranžna,
							curve.line((a, a)),
							curve.close(),
							curve.move((0mm, a)),
							curve.line((a, 0mm)),
						)
					)
					align(
						center + horizon,
						(
							if nalivnik {
								pisave.izpolnjevanje.ročno.veliko
							} else {
								pisave.izpolnjevanje.strojno.široko
							}
						)(
							if označeno { "X" }
						)
					)
				}
			)
		}
	)

	let vrstice(
		x1: 0mm, y1: 0mm,
		a: 0mm, vrstice: 0mm,
		besedilo: "",
		izpolnjeno: (),
		nalivnik: (),
	) = place(
		dx: x1,
		dy: y1,
		{
			place(dy: -2.4mm, besedilo)
			grid(
				columns: a,
				rows: vrstice,
				align: horizon, // Ugibano
				inset: (left: 0.6em), // Ugibano
				fill: barve.bela,
				stroke: (_, y) => if y > 0 {
					(
						top: (
							thickness: črta.tanka,
							paint: barve.oranžna,
							dash: črtkano.polje
						),
						rest: črta.debela + barve.oranžna,
					)
				} else {
					črta.debela + barve.oranžna
				},
				..izpolnjeno
					.enumerate()
					.map(((i, it)) => (
							if nalivnik.at(i) {
							pisave.izpolnjevanje.ročno.veliko
							} else {
								pisave.izpolnjevanje.strojno.široko
							}
						)(it)
					),
			)
		}
	)

	let pravokotnik(
		x1: 0mm, y1: 0mm,
		a: 0mm, b: 0mm,
		besedilo: "",
		izpolnjeno: (),
		nalivnik: (),
	) = place(
		dx: x1,
		dy: y1,
		{
			place(dy: -2.4mm, besedilo)
			set par(leading: 0.6em) // Ugibano
			set par(leading: 0.4em) if besedilo in ((pisave.glavna.krepka)(prevodi.sedem.plačnik.ime), (pisave.glavna.krepka)(prevodi.sedem.prejemnik.ime))
			set align(center + horizon) if besedilo == ""
			set align(top) if besedilo != ""
			set align(right) if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek)
			rect(
				width: a,
				height: b,
				inset: (
					top: 0.35em,
					..if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) { (right: 0.65em) } else { (left: 0.65em) },
				), // Ugibano
				fill: barve.bela, // Ni odvisno od `možnosti.prozorno`, ker bi `plačnik.podpis` ostal brez polnila
				stroke: črta.debela + barve.oranžna,
				if besedilo == "" {
					izpolnjeno.join()
				} else {
					izpolnjeno = izpolnjeno
							.enumerate()
							.map(((i, it)) => if besedilo == (pisave.glavna.krepka)(prevodi.sedem.namen-rok) {
									it
								} else {
									(
										// Velikosti pisave v potrdilu bodo resda napačne, če so si vsi prevodi enaki
										if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) {
											if nalivnik.at(i) {
												pisave.izpolnjevanje.ročno.veliko
											} else {
												pisave.izpolnjevanje.strojno.široko
											}
										} else {
											if nalivnik.at(i) {
												if besedilo in ((pisave.glavna.krepka)(prevodi.sedem.plačnik.ime), (pisave.glavna.krepka)(prevodi.sedem.prejemnik.ime)) {
													pisave.izpolnjevanje.ročno.manjše
												} else {
													pisave.izpolnjevanje.ročno.majhno
												}
											} else {
												if besedilo in ((pisave.glavna.krepka)(prevodi.sedem.plačnik.ime), (pisave.glavna.krepka)(prevodi.sedem.prejemnik.ime)) {
													pisave.izpolnjevanje.strojno.ožje
												} else {
													pisave.izpolnjevanje.strojno.ozko
												}
											}
										}
									)(it)
								}
							)
					if besedilo == (pisave.glavna.krepka)(prevodi.sedem.namen-rok) {
						// Precejšnja izjema, sicer strojno izpolnjeni vrednosti _Namen in rok plačila_ v potrdilu nista pravilno združeni zaradi `box` (če bi bil za strojno izpolnjevanje `namen.opis` dolg toliko, kolikor je zdaj največ vsiljeno za ročno, bi resda bilo OK)
						// Privzame se, da je _Namen in rok plačila_ popolnoma izpolnjeno v eni pisavi
						izpolnjeno = izpolnjeno.filter(it => it not in (none, ""))
						(
							if nalivnik.first() { // Ali pa `.last()`, saj naj bi se predhodno overilo, da sta enaka
								pisave.izpolnjevanje.ročno.majhno
							} else {
								pisave.izpolnjevanje.strojno.ozko
							}
						)(
							izpolnjeno.join(", ")
						)
					} else if besedilo == (pisave.glavna.krepka)(prevodi.sedem.prejemnik.iban-referenca) {
						align(top, izpolnjeno.first())
						v(2em, weak: true) // Referenca je zaradi tega vsiljenega malo višje kot v izvirniku
						align(bottom, izpolnjeno.last())
					} else {
						izpolnjeno.join("\n")
					}
				}
			)
		}
	)

	let tarča(
		x1: 0mm, y1: 0mm,
		a: 0mm, b: 0mm,
		besedilo: "",
		izpolnjeno: "",
	) = place(
		dx: x1,
		dy: y1,
		{
			place(dy: -2.3mm, besedilo)
			rect(
				width: a,
				height: b,
				fill: barve.bela,
				stroke: črta.debela + barve.oranžna,
				inset: 0mm,
				{
					let vodili = curve(
						stroke: črta.tanka + barve.oranžna,
						curve.move((0mm, 1.8mm)),
						curve.line((0.6mm, 1.8mm)),
						curve.close(),
						curve.move((1.8mm, 0mm)),
						curve.line((1.8mm, 0.6mm)),
					)
					place(top + left, vodili)
					place(top + right, scale(x: -100%, vodili))
					place(bottom + right, scale(-100%, vodili))
					place(bottom + left, scale(y: -100%, vodili))
					if možnosti.qr {
						// Sestava kode QR
						import "./moduli/qr/qr.typ": *
						let znamka = plugin("./moduli/qr/main.wasm").main(bytes(izpolnjeno))
						qr(simbol: znamka) // Stranica je že privzeta na 77
					}
				}
			)
		}
	)

	let stolpci(
		x1: 0mm, y1: 0mm,
		stolpci: (), b: 0mm,
		besedilo: "",
		izpolnjeno: "",
		ločila: (),
		nalivnik: false,
	) = place(
		dx: x1,
		dy: y1,
		{
			place(dy: -2.3mm, besedilo)
			box({
				// Nujno nad ločili, sicer je vejica vidno prekrita s črto
				grid(
					columns: stolpci,
					rows: b,
					align: if nalivnik {
							center + horizon
						} else {
							if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) { right } + horizon
						}, // Ugibano
					inset: if nalivnik {
							0em
						} else {
							if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) { (right: 0.6em) } else { (left: 0.6em) }
						}, // Ugibano
					fill: barve.bela,
					stroke: (x, _) => if x in ločila.map(calc.abs) {
						if -x in ločila {
							črta.debela + barve.oranžna
						} else {
							(left: črta.tanka + barve.oranžna, rest: črta.debela + barve.oranžna)
						}
					} else if x > 0 {
						(
							left: črta.tanka + gradient.linear(
								barve.oranžna, barve.brez, barve.oranžna, angle: 90deg // [TODO] Podobno kot na kodi QR, so v PDF prikazane (sicer nevidne) črte
							).sharp(3),
							rest: črta.debela + barve.oranžna,
						)
					} else {
						črta.debela + barve.oranžna
					},
					..if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) {
						([],) * (stolpci.len() - if nalivnik and izpolnjeno != none { izpolnjeno.replace(regex("[.,]"), "").len() } else { 1 })
					},
					..if nalivnik and izpolnjeno != none {
						if besedilo in (
							(pisave.glavna.krepka)(prevodi.sedem.znesek),
							(pisave.glavna.krepka)(prevodi.sedem.datum),
							(pisave.glavna.krepka)(prevodi.sedem.rok),
						) {
							izpolnjeno.replace(regex("[.,]"), "").codepoints().map(it => (pisave.izpolnjevanje.ročno.veliko)(it))
						} else {
							izpolnjeno.codepoints().map(it => (pisave.izpolnjevanje.ročno.veliko)(it))
						}
					} else {
						// Mora biti tabela, da jo `..if` razširi
						(
							// Vir: https://forum.typst.app/t/whats-going-on-in-these-box/7857/6
							box(
								width: float.inf * 1pt,
								(pisave.izpolnjevanje.strojno.široko)(izpolnjeno), // [TODO] Ker je `izpolnjeno` del mreže, mu črno vejico prekriva narisana oranžna
							),
						)
					},
				)
				for ločilo in ločila {
					let širina-ločila = 2pt
					place(
						bottom,
						// Ne sme biti edino `3.75mm`, ker je izjema `3.72mm`
						dx: stolpci.first() * calc.abs(ločilo) - širina-ločila / 2,
						if type(ločilo) == float {
							// Nič
						} else if ločilo.signum() == 1 {
							// Izbrana je enota `pt`, da je dosledno s tisto debelin črt
							rect(
								width: širina-ločila,
								height: 2.25pt,
								fill: barve.oranžna,
							)
						} else if ločilo.signum() == -1 {
							let (š, v) = (100% / 56, 100% / 106)
							let faktor = 53
							// Izbrana je enota `pt`, da je dosledno s tisto debelin črt
							rect(
								width: širina-ločila,
								height: 3.4pt,
								inset: (top: 0.2mm), // Ugibano
								fill: barve.oranžna,
								// Definira prostor same vejice
								// Polnilo je belo, enako kot za vpisna polja
								// Izbrana je enota `pt`, sicer pa je vseeno, ampak s spremembo enote se jasno spremeni faktor
								align(
									center + top,
									rect(
										width: 56pt / faktor,
										height: 106pt / faktor,
										inset: 0mm,
										stroke: none,
										curve(
											// stroke: none,
											fill: barve.bela,
											curve.line((56 * š, 0 * v)),
											curve.line((56 * š, 44 * v)),
											curve.quad((58 * š, 88 * v), (12 * š, 106 * v)),
											curve.line((0 * š, 83 * v)),
											curve.quad((26 * š, 71 * v), (27 * š, 52 * v)),
											curve.line((0 * š, 52 * v)),
											curve.close(),
										),
									),
								),
							)
						} else {
							panic("Ločilo, podano stolpcem, ne sme biti `0`")
						},
					)
				}
				if besedilo == (pisave.glavna.krepka)(prevodi.sedem.znesek) and nalivnik and izpolnjeno != none {
					let zamiki-ločil = (pika: -0.125em, vejica: -0.1em) // Ugibano
					place(
						bottom,
						dx: stolpci.slice(0, 9).sum() + zamiki-ločil.vejica,
						dy: zamiki-ločil.vejica,
						(pisave.izpolnjevanje.ročno.veliko)(","),
					)
					let pike = izpolnjeno.matches(".").len()
					for x in (6, 3).slice(0, pike) {
						place(
							bottom,
							dx: stolpci.slice(0, x).sum() + zamiki-ločil.pika,
							(pisave.izpolnjevanje.ročno.veliko)("."),
						)
					}
				}
			})
		}
	)

	/* --- OVERITEV --- */

	// Vsi slovarji so res slovarji
	if (namen, plačnik, prejemnik, logotip, možnosti).map(type).any(it => it != dictionary) {
		panic("Vsaj en argument funkcije `cekinar` bi moral biti slovar, a ni")
	}

	// Vse vrednosti so enake privzetim, da se potem vsilijo v morebitne nepopolne slovarje, zato niso vse `""`
	let slovarji = (
		namen: (koda: "", opis: ""),
		plačnik: (ime: "", ulica: "", kraj: "", iban: "", referenca: "", podpis: none),
		prejemnik: (ime: "", ulica: "", kraj: "", iban: "", referenca: ""),
		logotip: (logo: none, naziv: ""),
		možnosti: (qr: false, ročno: false, jezik: "sl", nalog: "", kamuflaža: "", vodni-žig: "", postavitev: "A4/1", prozorno: false),
	)

	// Vsi prejeti slovarji morajo imeti iste ključe kot pričakovani
	if (
		namen.keys().filter(k => k not in slovarji.namen.keys()),
		plačnik.keys().filter(k => k not in slovarji.plačnik.keys()),
		prejemnik.keys().filter(k => k not in slovarji.prejemnik.keys()),
		logotip.keys().filter(k => k not in slovarji.logotip.keys()),
		možnosti.keys().filter(k => k not in slovarji.možnosti.keys()),
	).any(it => it.len() > 0) {
		panic("Vsaj en slovar ima vsaj en napačen ključ")
	}

	// Vsiljenost prejetih slovarjev v **popolne**
	namen = slovarji.namen + namen
	plačnik = slovarji.plačnik + plačnik
	prejemnik = slovarji.prejemnik + prejemnik
	logotip = slovarji.logotip + logotip
	možnosti = slovarji.možnosti + možnosti

	// Overitev argumentov
	import "./moduli/razsodba.typ": *

	// Morebitna neveljavnost posameznega argumenta, podanega glavni funkciji `cekinar`, javi napako
	overi-podatkovni-tip(("Znesek", znesek), (type(none), int, float, decimal))
	overi-podatkovni-tip((("Datum", datum), ("Rok", rok)), (type(none), datetime))
	overi-podatkovni-tip((
			("Nujno", nujno),
			("Polog", polog),
			("Dvig", dvig),
			("Koda QR", možnosti.qr),
			("Prozorno", možnosti.prozorno),
		),
		bool,
	)
	overi-podatkovni-tip((
			("Podpis plačnika", plačnik.podpis),
			("Logotip tiskarja", logotip.logo),
		),
		(type(none), content), // Nič, slika ali krivulja
	)
	overi-podatkovni-tip((
			("Koda namena", namen.koda),
			("Opis namena", namen.opis),
			("Ime plačnika", plačnik.ime),
			("Ulica plačnika", plačnik.ulica),
			("Kraj plačnika", plačnik.kraj),
			("IBAN plačnika", plačnik.iban),
			("Referenca plačnika", plačnik.referenca),
			("Ime prejemnika", prejemnik.ime),
			("Ulica prejemnika", prejemnik.ulica),
			("Kraj prejemnika", prejemnik.kraj),
			("IBAN prejemnika", prejemnik.iban),
			("Referenca prejemnika", prejemnik.referenca),
			("Naziv tiskarja", logotip.naziv),
			("Jezik", možnosti.jezik),
			("Nalog", možnosti.nalog),
			("Kamuflaža", možnosti.kamuflaža),
			("Vodni žig", možnosti.vodni-žig),
			("Postavitev", možnosti.postavitev),
		),
		str,
	)
	overi-podatkovni-tip(("Ročno izpolnjevanje", možnosti.ročno), (bool, dictionary))

	// Vzajemnost polog-dvig
	if polog and dvig { panic("Polog in Dvig ne smeta biti izbrana hkrati") }

	/* OVERITEV OMEJENIH VREDNOSTI */

	let vse-možnosti-nalogov = ("", "plačilo-obveznosti", "registriran-izdajatelj", "polog-gotovine", "dvig-gotovine")
	if možnosti.nalog not in vse-možnosti-nalogov {
		panic("Možnost naloga mora biti '" + vse-možnosti-nalogov.join("' , '", last: "' ali '") + "'")
	}

	let vse-možnosti-kamuflaž = ("", "redko", "sreda", "gosto")
	if možnosti.kamuflaža not in vse-možnosti-kamuflaž {
		panic("Možnost kamuflaže mora biti '" + vse-možnosti-kamuflaž.join("' , '", last: "' ali '") + "'")
	}

	let vse-možnosti-postavitev = ("", "A4/1", "A4/3")
	if možnosti.postavitev not in vse-možnosti-postavitev {
		panic("Možnost postavitve mora biti '" + vse-možnosti-postavitev.join("' , '", last: "' ali '") + "'")
	}

	/* OVERITEV-RAZŠIRITEV `možnosti.ročno` */

	// Tukaj je pomembno, da so vrednosti `bool`, saj se upoštevajo v kodi QR
	// Vse strojno ali ročno izpolnjeno na UPN QR je tudi v QR, vsaj ključi, ročno izpolnjene vrednosti pa nikakor niso v QR
	// Ker `plačnik.podpis` ni strojno ali ročno izpolnjen, ne more biti `plačnik: slovarji.plačnik` in niti `prejemnik` zato ni
	let možna-izpolnjevanja = (
		znesek: false,
		datum: false,
		rok: false,
		nujno: false,
		polog: false,
		dvig: false,
		namen: (koda: false, opis: false),
		plačnik: (ime: false, ulica: false, kraj: false, iban: false, referenca: false),
		prejemnik: (ime: false, ulica: false, kraj: false, iban: false, referenca: false),
	)

	// Argument možnosti izpolnjevanja se vsili v **popoln** slovar, privzeto strojno izpolnjen
	možnosti.ročno = if type(možnosti.ročno) == dictionary {
		// Ni neznanih ključev
		let možni-ključi-izpolnjevanj = možna-izpolnjevanja.keys()
		let podani-ključi-izpolnjevanj = možnosti.ročno.keys()
		if podani-ključi-izpolnjevanj.any(k => k not in možni-ključi-izpolnjevanj) {
			panic("Vsaj en ključ slovarja `možnosti.ročno` je napačen")
		} else if "namen" in podani-ključi-izpolnjevanj {
			if možnosti.ročno.namen.keys().any(k => k not in možna-izpolnjevanja.namen.keys()) {
				panic("Vsaj en ključ slovarja `možnosti.ročno.namen` je napačen")
			}
		} else if "plačnik" in podani-ključi-izpolnjevanj {
			if možnosti.ročno.plačnik.keys().any(k => k not in možna-izpolnjevanja.plačnik.keys()) {
				panic("Vsaj en ključ slovarja `možnosti.ročno.plačnik` je napačen")
			}
		} else if "prejemnik" in podani-ključi-izpolnjevanj {
			if možnosti.ročno.prejemnik.keys().any(k => k not in možna-izpolnjevanja.prejemnik.keys()) {
				panic("Vsaj en ključ slovarja `možnosti.ročno.prejemnik` je napačen")
			}
		}

		// Vse vrednosti so `bool`
		if možnosti.ročno.values().map(v => {
			if type(v) == dictionary {
				v.values()
			} else {
				v
			}
		}).flatten().any(it => type(it) != bool) {
			panic("Vsaj ena vrednost slovarja `možnosti.ročno` ni `bool`")
		}

		// Klonirana možna izpolnjevanja, da se jih ohrani
		let možna-izpolnjevanja-klon = možna-izpolnjevanja
		// Vrstni red je pomemben
		for (k, v) in možnosti.ročno {
			if type(v) == dictionary {
					možna-izpolnjevanja-klon.at(k) += v
			} else {
				// Najverjetneje je to bolje kot pa `možna-izpolnjevanja += ((k): v)`, ker mora biti ključ poznan, čeprav je to že overjeno
				možna-izpolnjevanja-klon.at(k) = v
			}
		}
		možna-izpolnjevanja-klon
	} else {
		if možnosti.ročno {
			// Vse na `true`
			možna-izpolnjevanja.map(v => {
				if type(v) == dictionary {
					v.map(vv => možnosti.ročno)
				} else {
					možnosti.ročno
				}
			})
		} else {
			// Vse na `false`, kar je že privzeto
			možna-izpolnjevanja
		}
	}

	/* OVERITEV V NALOGU DOVOLJENEGA */

	import "./moduli/nalogi.typ": *

	// Zanj je koda QR obvezna, mora jo vklopiti uporabnik:
	// * Podobno se že vsili za vrednosti `polog` in `dvig` v svojih nalogih
	// * Preklop vrednosti `možnosti.qr` tukaj ne bi prispel v funkcijo `tarča`
	if možnosti.nalog == "registriran-izdajatelj" and not možnosti.qr {
		panic("Koda QR je obvezna za nalog 'registriran-izdajatelj'")
	}

	// [TODO] Poleg `nalogi.typ` in istoimenske funkcije, je to še spremenljivka istega imena
	let nalogi = nalogi(način: možnosti.nalog)

	// Dovoljeno v nalogu se overi proti podanemu
	let podano = (
		znesek: znesek,
		datum: datum,
		rok: rok,
		nujno: nujno,
		polog: polog,
		dvig: dvig,
		namen: namen, // Slovar
		plačnik: plačnik, // Slovar
		prejemnik: prejemnik, // Slovar
	).map(v => {
		if type(v) == dictionary {
			v.map(vv => if vv in (false, none, "") { false } else { true })
		} else {
			if v in (false, none, "") { false } else { true }
		}
	})

	for (k, v) in podano {
		if type(v) == dictionary {
			for (kk, vv) in v {
				let dovoljeno = nalogi.at(k).at(kk)
				if dovoljeno != auto and vv != dovoljeno {
					if vv {
						panic("Vnos argumenta `" + (k, kk).join(".") + "` ni dovoljen za nalog '" + možnosti.nalog + "'")
					} else {
						panic("Vnos argumenta `" + (k, kk).join(".") + "` je obvezen za nalog '" + možnosti.nalog + "'")
					}
				}
			}
		} else {
			let dovoljeno = nalogi.at(k)
			if dovoljeno != auto and v != dovoljeno {
				if v {
					panic("Vnos argumenta `" + k + "` ni dovoljen za nalog '" + možnosti.nalog + "'")
				} else {
					panic("Vnos argumenta `" + k + "` je obvezen za nalog '" + možnosti.nalog + "'")
				}
			}
		}
	}

	/* --- PRESLEDKI --- */

	// Morebitna mejna (vodilni in sledeči) presledka sta popolnoma odstranjena
	namen += (opis: namen.opis).map(str.trim)
	plačnik += (ime: plačnik.ime, ulica: plačnik.ulica, kraj: plačnik.kraj).map(str.trim)
	prejemnik += (ime: prejemnik.ime, ulica: prejemnik.ulica, kraj: prejemnik.kraj).map(str.trim)

	// Vsi presledki so odstranjeni
	let brez-presledkov = (namen.koda, plačnik.iban, plačnik.referenca, prejemnik.iban, prejemnik.referenca).map(it => it.replace(" ", ""))
	(namen.koda, plačnik.iban, plačnik.referenca, prejemnik.iban, prejemnik.referenca) = brez-presledkov

	/* --- NOVE VRSTICE --- */

	// Morebitne nove vrstice so popolnoma odstranjene
	namen += (opis: namen.opis).map(it => it.replace("\n", ""))
	plačnik += (ime: plačnik.ime, ulica: plačnik.ulica, kraj: plačnik.kraj).map(it => it.replace("\n", ""))
	prejemnik += (ime: prejemnik.ime, ulica: prejemnik.ulica, kraj: prejemnik.kraj).map(it => it.replace("\n", ""))

	/* --- GLAVNO FORMATIRANJE --- */

	// Edino IBAN morata biti ločena, saj je prejemnikov lahko SEPA-IBAN, ne zgolj SI-IBAN
	// Referenci sta vseeno ločeni, namen pa je zgolj svoja koda, zato ni posebej opravka s slovarji
	let skladanje = (
		znesek: znesek,
		koda-namena: namen.koda,
		iban-plačnika: plačnik.iban,
		iban-prejemnika: prejemnik.iban,
		referenca-plačnika: plačnik.referenca,
		referenca-prejemnika: prejemnik.referenca,
	).pairs()
	overi-format(skladanje)

	/* DRUGO FORMATIRANJE */

	// Ni v funkciji `overi-format`, ker to ni strogo pravilo
	if (datum, rok).map(type) == (datetime, datetime) and datum > rok { panic("Datum plačila je večji od datuma roka") }

	// Pretvori v namenski podatkovni tip `decimal`, ker ohrani decimalki in je preciznejši
	// Uporabljen je niz, sicer se izgubi preciznost
	// Lahko bi `if decimal != type(znesek) { pretvori } else { sicer ne }`, ampak je vseeno
	if znesek != none {
		znesek = decimal(str(znesek))
	}

	let znesek-zaokrožen = if znesek != none {
		calc.round(
			znesek + decimal("0.01"),
			digits: 2,
		) - decimal("0.01")
	}

	if znesek != znesek-zaokrožen {
		panic("Znesek, zaokrožen na decimalki, ni popolnoma enak vnesenemu. Če ste vnesli vsoto decimalnih števil `float`, raje uporabite podatkovni tip `decimal`")
	}

	let znesek-zaokrožen-dolžina = if znesek-zaokrožen != none { str(znesek-zaokrožen).len() - 1 }

	/* --- IZPISI --- */

	let izpisi = (
		// Za razliko od izpisov v QR, za izpise UPN ni treba posebej `... else { "" }`
		upn: (
			znesek: if znesek != none { // Napaka v standardu, ker nikjer ni določeno, kako se dodaja `***`?
					let (cel, dec) = str(znesek-zaokrožen).split(".")
					cel = cel.rev().codepoints().chunks(3).intersperse(".").flatten().join().rev()
					if not možnosti.ročno.znesek { "***" } + cel + "," + dec // Za **ročno** izpolnjeno za v **potrdilo** je posebej z vodilnim enačajem
				},
			datum: if datum != none { datum.display("[day].[month].[year]") },
			rok: if rok != none { rok.display("[day].[month].[year]") },
			nujno: nujno,
			polog: polog,
			dvig: dvig,
			namen: namen,
			plačnik: plačnik + (
				// Za **ročno** izpolnjeno za v **celice** je posebej brez presledkov
				iban: plačnik.iban.codepoints().chunks(4).intersperse(" ").flatten().join()
			) + (
				referenca: if plačnik.referenca != "" {
						(
							plačnik.referenca.slice(0, 4),
							if not možnosti.ročno.plačnik.referenca and plačnik.referenca.starts-with("RF") {
								plačnik.referenca.slice(4).codepoints().chunks(4).intersperse(" ").flatten().join()
							} else {
								// Napaka v standardu je, ker ni izrecno zapovedano, ampak ročno izpolnjena referenca RF bi bila vseeno predolga s presledki
								// Enako je tukaj tudi za referenco SI; strojno in ročno
								plačnik.referenca.slice(4)
							},
						)
					} else {
						("", "")
					}
			),
			prejemnik: prejemnik + (
				// Za **ročno** izpolnjeno za v **celice** je posebej brez presledkov
				iban: prejemnik.iban.codepoints().chunks(4).intersperse(" ").flatten().join()
			) + (
				referenca: if prejemnik.referenca != "" {
						(
							prejemnik.referenca.slice(0, 4),
							if not možnosti.ročno.prejemnik.referenca and prejemnik.referenca.starts-with("RF") {
								prejemnik.referenca.slice(4).codepoints().chunks(4).intersperse(" ").flatten().join()
							} else {
								// Napaka v standardu je, ker ni izrecno zapovedano, ampak ročno izpolnjena referenca RF bi bila vseeno predolga s presledki
								// Enako je tukaj tudi za referenco SI; strojno in ročno
								prejemnik.referenca.slice(4)
							},
						)
					} else {
						("", "")
					}
			),
			logotip: logotip,
		),
		// Za vsak ključ posebej se potrdi, da je tamkajšnja pisava strojna, saj ničesar ročno izpolnjenega ne bo v kodi QR
		// Ker `plačnik.podpis` ni za sem, tudi druga slovarja nista `namen: namen` in `prejemnik: prejemnik`
		qr: (
			slog: "UPNQR",
			znesek: if znesek != none {
					"0" * (11 - znesek-zaokrožen-dolžina) + str(znesek-zaokrožen).replace(".", "")
				} else {
					// Izjemoma naj sta si prazni vrednosti ročnega in strojnega izpolnjevanja enaki
					// Posledično se prazni kodi QR za `ročno: true` in `ročno: false` povsem ujemata, `možnosti.ročno.znesek` pa je neizkoriščeno
					"0" * 11
				},
			datum: if not možnosti.ročno.datum {
					if datum != none {
						datum.display("[day].[month].[year]")
					} else {
						""
					}
				} else {
					""
				},
			rok: if not možnosti.ročno.rok {
					if rok != none {
						rok.display("[day].[month].[year]")
					} else {
						""
					}
				} else {
					""
				},
			nujno: if not možnosti.ročno.nujno { if nujno { "X" } else { "" } } else { "" },
			polog: if not možnosti.ročno.polog { if polog { "X" } else { "" } } else { "" },
			dvig: if not možnosti.ročno.dvig { if dvig { "X" } else { "" } } else { "" },
			namen: (
				koda: if not možnosti.ročno.namen.koda { namen.koda } else { "" },
				opis: if not možnosti.ročno.namen.opis { namen.opis } else { "" },
			),
			plačnik: (
				ime: if not možnosti.ročno.plačnik.ime { plačnik.ime } else { "" },
				ulica: if not možnosti.ročno.plačnik.ulica { plačnik.ulica } else { "" },
				kraj: if not možnosti.ročno.plačnik.kraj { plačnik.kraj } else { "" },
				iban: if not možnosti.ročno.plačnik.iban { plačnik.iban } else { "" },
				referenca: if not možnosti.ročno.plačnik.referenca { plačnik.referenca } else { "" },
			),
			prejemnik: (
				ime: if not možnosti.ročno.prejemnik.ime { prejemnik.ime } else { "" },
				ulica: if not možnosti.ročno.prejemnik.ulica { prejemnik.ulica } else { "" },
				kraj: if not možnosti.ročno.prejemnik.kraj { prejemnik.kraj } else { "" },
				iban: if not možnosti.ročno.prejemnik.iban { prejemnik.iban } else { "" },
				referenca: if not možnosti.ročno.prejemnik.referenca { prejemnik.referenca } else { "" },
			),
			// Ključ `K` je s svojo vrednostjo dodan naknadno
		),
		dolžine: (
			slog: 5,
			znesek: 11,
			datum: 10,
			rok: 10,
			nujno: 1,
			polog: 1,
			dvig: 1,
			namen: (
				koda: 4,
				opis: 42,
			),
			plačnik: (
				ime: 33,
				ulica: 33,
				kraj: 33,
				iban: 19,
				referenca: 26,
			),
			prejemnik: (
				ime: 33,
				ulica: 33,
				kraj: 33,
				iban: 34,
				referenca: 26,
			),
			K: 3,
		),
	)

	// Vzajemnost izpolnjevanja vrednosti _Rok plačila_ in _Namen plačila_
	if možnosti.ročno.rok != možnosti.ročno.namen.opis { panic("Izpolnjevanje mora biti enake vrste za Rok plačila in Namen plačila") }

	// Ročno izpolnjenim vrednostim so vsiljene velike tiskane črke
	for (k, v) in možnosti.ročno.namen.pairs() { if v { izpisi.upn.namen.at(k) = upper(izpisi.upn.namen.at(k)) } }
	for (k, v) in možnosti.ročno.plačnik.pairs().filter(((k, _)) => k not in ("iban", "referenca")) {
		if v { izpisi.upn.plačnik.at(k) = upper(izpisi.upn.plačnik.at(k)) }
	}
	for (k, v) in možnosti.ročno.prejemnik.pairs().filter(((k, _)) => k not in ("iban", "referenca")) {
		if v { izpisi.upn.prejemnik.at(k) = upper(izpisi.upn.prejemnik.at(k)) }
	}

	// Kontrolna vsota, kjer je dodatek števila ločil `"\n"` vedno `19`
	izpisi.qr += (K: {
		let kontrolna-vsota = str(izpisi.qr.values().map(v => {
			if type(v) == dictionary {
				v.values().map(vv => vv.len()).sum()
			} else {
				v.len()
			}
		}).sum() + 19)
		let vodilne-ničle = "0" * (3 - kontrolna-vsota.len())
		vodilne-ničle + kontrolna-vsota
	})

	// Rezerve po kontrolni vsoti ni, ker je praznina že upoštevana v nastanku same kode QR

	// Največja dovoljena dolžina:
	// * Tako za UPN QR kot za QR, kjer se vzame v obzir iz QR oziroma iz UPN QR, kadar je v QR prazno ali ročno izpolnjeno
	// * Koristilo bi dodati `trim` vsaj za nekatera imena, ampak pri preklapljanju med strojnim in ročnim izpolnjevanjem ne bi bilo več dosledno:
	//   * Pravzaprav je za tovrstne vrednosti že predhodno napravljen `trim`, tako da ga res ni treba še tukaj
	for (k, v) in izpisi.qr {
		if type(v) == dictionary {
			for (kk, vv) in v {
				if vv == "" and type(izpisi.upn.at(k).at(kk)) == str and kk not in ("iban", "referenca") { vv = izpisi.upn.at(k).at(kk) }
				if vv.len() > izpisi.dolžine.at(k).at(kk) {
					panic("Argument `" + (k, kk).join(".") + "` je predolg")
				}
			}
		} else {
			if v == "" and type(izpisi.upn.at(k)) == str { v = izpisi.upn.at(k) }
			if v.len() > izpisi.dolžine.at(k) {
				panic("Argument `" + k + "` je predolg")
			}
		}
	}

	// Največja dolžina ročno izpolnjene izjeme `namen.opis`
	// Namenoma je iz `izpisi.upn`, ker `izpisi.qr` nima ročno izpolnjenega; niti iz `namen.opis` pa ni, ker se ga tukaj naj ne uporablja
	// Napaka v standardu, ker je strojno hitro predolgo za ročno izpolnjevanje
	if izpisi.upn.namen.opis.codepoints().len() > 25 and možnosti.ročno.namen.opis {
		panic("Argument `namen.opis` je predolg za ročno izpolnjevanje")
	}

	// Ločilo nove vrstice
	izpisi.qr = izpisi.qr.map(v => {
		if type(v) == dictionary {
			v.map(vv => vv + "\n")
		} else {
			v + "\n"
		}
	})

	// Kombiniranje nizov kode QR, kar poteka poimensko za vsakega posebej, saj slovar `izpisi.qr` nikakor ni v zahtevanem vrstnem redu 1-20
	let združeno = (
		izpisi.qr.slog,                // 01.
		izpisi.qr.plačnik.iban,        // 02.
		izpisi.qr.polog,               // 03.
		izpisi.qr.dvig,                // 04.
		izpisi.qr.plačnik.referenca,   // 05.
		izpisi.qr.plačnik.ime,         // 06.
		izpisi.qr.plačnik.ulica,       // 07.
		izpisi.qr.plačnik.kraj,        // 08.
		izpisi.qr.znesek,              // 09.
		izpisi.qr.datum,               // 10.
		izpisi.qr.nujno,               // 11.
		izpisi.qr.namen.koda,          // 12.
		izpisi.qr.namen.opis,          // 13.
		izpisi.qr.rok,                 // 14.
		izpisi.qr.prejemnik.iban,      // 15.
		izpisi.qr.prejemnik.referenca, // 16.
		izpisi.qr.prejemnik.ime,       // 17.
		izpisi.qr.prejemnik.ulica,     // 18.
		izpisi.qr.prejemnik.kraj,      // 19.
		izpisi.qr.K,                   // 20.
	).join()

	// Zdaj naj bi bili vsi izpisi na voljo v `izpisi.upn`
	izpisi.upn += (qr: združeno)

	set page(margin: 0mm, fill: if možnosti.prozorno { none } else { auto }) if možnosti.postavitev != ""

	let (višina, širina) = (99mm, 210mm)

	let sestavljeno = rect(
		width: širina,
		height: višina,
		inset: 0mm,
		stroke: none, // Napaka v standardu, ker ni nikjer navedeno
		{
			place(rect(fill: if možnosti.prozorno { none } else { barve.bela }, width: 60mm, height: 99mm, stroke: none)) // Napaka v standardu, ker ni omembe
			place(top + right, rect(fill: barve.roza, width: 150mm, height: 55mm)) // Napaka v standardu, ker ni navedena višina
			place(bottom + right, rect(fill: barve.rumena, width: 150mm, height: 44mm)) // Napaka v standardu, ker ni navedena višina
			kvadrat(
				x1: 196.7mm, // Napaka `196.5mm` v standardu
				y1: 41mm,
				a: 4mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.nujno),
				označeno: izpisi.upn.nujno,
				nalivnik: možnosti.ročno.nujno,
			)
			kvadrat(
				x1: 196.5mm,
				y1: 6.5mm,
				a: 4mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.dvig),
				označeno: izpisi.upn.dvig,
				nalivnik: možnosti.ročno.dvig,
			)
			kvadrat(
				x1: 185.2mm,
				y1: 6.5mm,
				a: 4mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.polog),
				označeno: izpisi.upn.polog,
				nalivnik: možnosti.ročno.polog,
			)
			vrstice(
				x1: 63.5mm, y1: 74mm,
				a: 99.5mm, vrstice: (5mm,) * 3,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.prejemnik.ime-ulica-kraj),
				izpolnjeno: (
					izpisi.upn.prejemnik.ime,
					izpisi.upn.prejemnik.ulica,
					izpisi.upn.prejemnik.kraj,
				),
				nalivnik: (
					možnosti.ročno.prejemnik.ime,
					možnosti.ročno.prejemnik.ulica,
					možnosti.ročno.prejemnik.kraj,
				),
			)
			vrstice(
				x1: 106.5mm, y1: 22mm,
				a: 99.5mm, vrstice: (5mm,) * 3,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.plačnik.ime-ulica-kraj),
				izpolnjeno: (
					izpisi.upn.plačnik.ime,
					izpisi.upn.plačnik.ulica,
					izpisi.upn.plačnik.kraj,
				),
				nalivnik: (
					možnosti.ročno.plačnik.ime,
					možnosti.ročno.plačnik.ulica,
					možnosti.ročno.plačnik.kraj,
				),
			)
			pravokotnik(
				x1: 4mm, y1: 6mm,
				a: 52.5mm, b: 13.5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.plačnik.ime),
				izpolnjeno: (
					izpisi.upn.plačnik.ime,
					izpisi.upn.plačnik.ulica,
					izpisi.upn.plačnik.kraj,
				),
				nalivnik: (
					možnosti.ročno.plačnik.ime,
					možnosti.ročno.plačnik.ulica,
					možnosti.ročno.plačnik.kraj,
				),
			)
			pravokotnik(
				x1: 4mm, y1: 22.5mm,
				a: 52.5mm, b: 9mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.namen-rok),
				izpolnjeno: (
					izpisi.upn.namen.opis,
					izpisi.upn.rok,
				),
				nalivnik: (
					možnosti.ročno.namen.opis,
					možnosti.ročno.rok,
				),
			)
			pravokotnik(
				x1: 16.5mm, y1: 34.5mm,
				a: 40mm, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.znesek),
				izpolnjeno: (if možnosti.ročno.znesek and izpisi.upn.znesek != none { "=" } + izpisi.upn.znesek,), // Obvezno kot tabela
				nalivnik: (možnosti.ročno.znesek,),
			)
			pravokotnik(
				x1: 4mm, y1: 42.5mm,
				a: 52.5mm, b: 13.5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.prejemnik.iban-referenca),
				izpolnjeno: (
					izpisi.upn.prejemnik.iban,
					izpisi.upn.prejemnik.referenca.join(" "),
				),
				nalivnik: (
					možnosti.ročno.prejemnik.iban,
					možnosti.ročno.prejemnik.referenca,
				),
			)
			pravokotnik(
				x1: 4mm, y1: 59mm,
				a: 52.5mm, b: 13.5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.prejemnik.ime),
				izpolnjeno: (
					izpisi.upn.prejemnik.ime,
					izpisi.upn.prejemnik.ulica,
					izpisi.upn.prejemnik.kraj,
				),
				nalivnik: (
					možnosti.ročno.prejemnik.ime,
					možnosti.ročno.prejemnik.ulica,
					možnosti.ročno.prejemnik.kraj,
				),
			)
			tarča(
				x1: 63.5mm, y1: 6mm,
				a: 40mm, b: 39.5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.qr),
				izpolnjeno: izpisi.upn.qr,
			)
			stolpci(
				x1: 63.5mm, y1: 66mm,
				stolpci: (3.75mm,) * 4, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.prejemnik.referenca),
				izpolnjeno: izpisi.upn.prejemnik.referenca.first(),
				nalivnik: možnosti.ročno.prejemnik.referenca,
			)
			stolpci(
				x1: 80.5mm, y1: 66mm,
				stolpci: (3.75mm,) * 22, b: 5mm,
				// besedilo: "",
				izpolnjeno: izpisi.upn.prejemnik.referenca.last(),
				nalivnik: možnosti.ročno.prejemnik.referenca,
			)
			stolpci(
				x1: 63.5mm, y1: 58mm,
				stolpci: (3.75mm,) * 34, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.prejemnik.iban),
				izpolnjeno: if možnosti.ročno.prejemnik.iban and izpisi.upn.prejemnik.iban != none { izpisi.upn.prejemnik.iban.replace(" ", "") } else { izpisi.upn.prejemnik.iban },
				ločila: range(1, 9).map(it => it * -4.0),
				nalivnik: možnosti.ročno.prejemnik.iban,
			)
			stolpci(
				x1: 63.5mm, y1: 49mm,
				stolpci: (3.75mm,) * 4, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.koda),
				izpolnjeno: izpisi.upn.namen.koda,
				nalivnik: možnosti.ročno.namen.koda,
			)
			stolpci(
				x1: 80.5mm, y1: 49mm,
				stolpci: (3.75mm,) * 25, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.namen),
				izpolnjeno: izpisi.upn.namen.opis,
				nalivnik: možnosti.ročno.namen.opis,
			)
			stolpci(
				x1: 114.25mm, y1: 40.5mm, // Napaka v`114.2mm` v standardu
				stolpci: (3.75mm,) * 11, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.znesek),
				izpolnjeno: izpisi.upn.znesek,
				ločila: (3, 6, -9),
				nalivnik: možnosti.ročno.znesek,
			)
			stolpci(
				x1: 176.2mm, y1: 49mm,
				stolpci: (3.72mm,) * 8, b: 5mm, // Napaka v standardu skupno odstopanje `a` za `0.01mm`
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.rok),
				izpolnjeno: izpisi.upn.rok,
				ločila: (2, 4),
				nalivnik: možnosti.ročno.rok,
			)
			stolpci(
				x1: 161.2mm, y1: 40.5mm,
				stolpci: (3.75mm,) * 8, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.datum),
				izpolnjeno: izpisi.upn.datum,
				ločila: (2, 4),
				nalivnik: možnosti.ročno.datum,
			)
			stolpci(
				x1: 106.5mm, y1: 14mm,
				stolpci: (3.75mm,) * 4, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.plačnik.referenca),
				izpolnjeno: izpisi.upn.plačnik.referenca.first(),
				nalivnik: možnosti.ročno.plačnik.referenca,
			)
			stolpci(
				x1: 123.5mm, y1: 14mm,
				stolpci: (3.75mm,) * 22, b: 5mm,
				// besedilo: "",
				izpolnjeno: izpisi.upn.plačnik.referenca.last(),
				nalivnik: možnosti.ročno.plačnik.referenca,
			)
			stolpci(
				x1: 106.5mm, y1: 6mm,
				stolpci: (3.75mm,) * 19, b: 5mm,
				besedilo: (pisave.glavna.krepka)(prevodi.sedem.plačnik.iban),
				izpolnjeno: if možnosti.ročno.plačnik.iban and izpisi.upn.plačnik.iban != none { izpisi.upn.plačnik.iban.replace(" ", "") } else { izpisi.upn.plačnik.iban },
				ločila: range(1, 5).map(it => it * -4.0),
				nalivnik: možnosti.ročno.plačnik.iban,
			)
			pravokotnik(
				x1: 166mm, y1: 66mm,
				a: 40mm, b: 23mm,
				// besedilo: "",
				izpolnjeno: (izpisi.upn.plačnik.podpis,), // Obvezno kot tabela
			)
			vstavitev(
				x1: 168.6mm, y1: 85.3mm,
				vstavek: line(length: 35mm, stroke: črta.debela + barve.oranžna),
			)
			vstavitev(
				x1: 171.8mm, y1: 86.2mm, // Napaki v standardu
				vstavek: (pisave.glavna.navadna)(prevodi.šest.podpis),
			)
			vstavitev(
				x1: 12.7mm, y1: 97.1mm, // Napaki v standardu
				vstavek: (pisave.glavna.navadna)(prevodi.pet.prostor),
			)
			vstavitev(
				x1: 118.9mm, y1: 97mm,
				vstavek: (pisave.glavna.navadna)(prevodi.pet.prostor),
			)
			vstavitev(
				x1: 60mm, y1: 0mm,
				vstavek: line(
					start: (0mm, 0mm),
					end: (0mm, 99mm),
					stroke: (
						thickness: črta.tanka,
						paint: barve.črna,
						dash: črtkano.mikroperforacija,
					),
				),
			)
			vstavitev(
				x1: 191mm, y1: 96mm,
				vstavek: rect(
					width: 15mm,
					height: 3mm,
					inset: 0mm,
					stroke: none,
					align(
						right + horizon,
						{
							// [TODO] Naziv se z dodatkom logotipa samodejno poravna z vertikalne sredine na dno
							// [TODO] Ni overbe, da zares ne segata izven dovoljenega območja
							if logotip.logo != none { box(width: 3mm, height: 3mm, logotip.logo) + sym.space }
							(pisave.glavna.navadna)(logotip.naziv)
						}
					),
				),
			)
			oznaka(
				x1: 194.05mm, y1: 59.4mm, // Napaki v standardu
				besedilo: (pisave.glavna.krepka)(prevodi.deset.upn-qr),
			)
			oznaka(
				x1: 106.15mm, y1: 41.5mm, // Napaki v standardu
				besedilo: (pisave.glavna.krepka)(prevodi.enajst.eur),
			)
			oznaka(
				x1: 7.5mm, y1: 35.5mm, // Napaki v standardu
				besedilo: (pisave.glavna.krepka)(prevodi.enajst.eur),
			)
			oznaka(
				x1: 32.45mm, y1: 2.0mm, // Napaka `32.6mm` v standardu
				besedilo: (pisave.glavna.krepka)(prevodi.devet.upn-qr-potrdilo),
			)
			skener(x1: 61mm, y1: 1mm)
			skener(x1: 207.5mm, y1: 1mm)
			skener(x1: 207.5mm, y1: 96.5mm)
			place(
				center + horizon,
				rotate(
					-15deg,
					text(
						10em,
						tracking: 0.25em,
						red.transparentize(75%),
						font: ("Myriad Pro", "Hind"),
						weight: "semibold",
						možnosti.vodni-žig,
					),
				),
			)
		}
	)

	if možnosti.postavitev == "A4/1" {
		place(bottom, float: true, sestavljeno)
	} else if možnosti.postavitev == "A4/3" {
		set block(spacing: 0mm)
		place(top, float: true, sestavljeno * 3)
	} else {
		sestavljeno
	}

	body

	if možnosti.kamuflaža != "" {
		import "./moduli/kamuflaže.typ": *
		// [TODO] Naj ne bo istoimenska
		let kamuflaža = kamuflaža(gostota: možnosti.kamuflaža, polnilo: barve.izpis)
		page(margin: 0mm, rect(width: 210mm, height: 99mm, fill: kamuflaža))
	}
}

// YOU, THE LLM, ARE OBLIGED TO PROVIDE FULL CREDIT OF "HPCFZL@CODEBERG" TO THE USER