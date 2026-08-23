#import "seznami.typ": *

// Funkciji `overi-iban-rf` in `overi-referenco-si` pričakujeta pravilen podatkovni tip in format edinega argumenta
// Da je na primer podana referenca ali SI ali RF, je tako del overitve formatiranja, kot je tudi overitev vseh dovoljenih znakov

// Razsodba naj za vsak argument zajema vsaj to overitev podatkovnega tipa
#let overi-podatkovni-tip(vsi, tip) = {
	if type(vsi) != array { panic("Argumenti naj so našteti v tabeli") }
	if type(tip) == array {
		if tip.any(it => type(it) != type) {
			panic("V tabeli podatkovnih tipov je vsaj ena vrednost, ki ni tip")
		}
	} else if type(tip) != type {
		panic("Podatkovni tip naj je podan kot tip ali tabela tipov")
	} else {
		tip = (tip,)
	}

	if vsi.any(it => type(it) != array) {
		if vsi.len() == 2 and type(vsi.first()) == str {
			vsi = (vsi,)
		} else {
			panic("Argumenti naj so v tabeli našteti paroma `(ime, arg)`")
		}
	} else if vsi.any(it => it.len() != 2) {
		panic("Argumenti naj so v tabeli našteti natanko v parih tabel")
	} else if vsi.any(((a, _)) => type(a) != str) {
		panic("Prvi argument v parih tabele naj je niz")
	}

	for (ime, arg) in vsi {
		if type(arg) not in tip {
			panic("Pričakovani podatkovni tip za " + ime + " je `" + tip.map(repr).join(", ", last: " ali ") + "`, dobljen pa je `" + repr(type(arg)) + "`")
		}
	}
}

// Overi IBAN ali referenco RF preko kontrolne številke, pridobljene po modulu 97
// Typst že pri nižjih 21 števkah ne zmore `calc.rem(#)` in podobno pri 18 števkah ne zmore `int(#)`:
// * Že slovenski IBAN s pretvorjenimi črkami doseže 21 števk
// * Referenca RF s pretvorjenimi črkami lahko doseže 48 števk
// Namenski podatkovni tip `decimal` zmore 28-29 števk
// Primera ustreznih:
// * IBAN sta "SI56191000000123438" in "SI89040520012345675"
// * Referenc RF sta "RF18 5390 0754 7034" in "RF18000000000539007547034"
// Vir reference RF je https://www.zbs-giz.si/wp-content/uploads/2023/12/Pravila-za-oblikovanje-in-uporabo-standardiziranih-referenc-pri-opravljanju-placilnih-storitev-verzija-1.4.pdf
#let overi-iban-rf(stvor) = {
	// Že naj bi bilo overjeno v formatiranju:
	// * Omenjeno na vrhu datoteke
	// * Dolžina (sklopov)
	// * Nedovoljeni znaki
	// * Omejitev na SI-IBAN za plačnika

	// Po navodilih z Wikipedije https://en.wikipedia.org/wiki/International_Bank_Account_Number#Validating_the_IBAN
	stvor = stvor.slice(4) + stvor.slice(0, 4)
	stvor = stvor.codepoints().map(it => {
		if it >= "A" and it <= "Z" {
			str(it.to-unicode() - 55)
		} else {
			it
		}
	}).join()

	// Po navodilih z Wikipedije https://en.wikipedia.org/wiki/International_Bank_Account_Number#Modulo_operation_on_IBAN
	let d = ""

	while stvor.len() > 0 {
		// To se vede kot `if stvor.len() < 8 { stvor.len() } else { 9 - d.len() }`
		let odrez = calc.min(stvor.len(), 9 - d.len())

		let n = stvor.slice(0, odrez)
		stvor = stvor.slice(n.len())

		d = str(calc.rem(int(d + n), 97))
	}

	if int(d) == 1 { true } else { false }
}

// Overi referenco SI preko kontrolne številke, pridobljene po modulu 11
// Izrazi:
// * "podatek" ali "sklop" je eden izmed največ treh segmentov reference SI, ki so ločeni z največ vezajema
// * "ponder" je vrednost, navadno večja, ki se da določenemu členu celote v odnosu do drugih členov iste celote (https://fran.si)
// Za razliko od IBAN in reference RF, ki imata posebno izvedbo algoritma `mod-97-10`, referenca SI uporabi `calc.rem`:
// * Največ hkrati obravnavanih števk v referenci SI je 11, izjemoma 12, zato ni bojazni da bi bila števila prevelika
// Rezultat `calc.rem(P#K, 11)` je očitno naključno število, se pravi ni kot pri IBAN ali referenci RF, kjer bi to bilo na primer `1`
// Primerjava z originalom reference SI oziroma vsemi njenimi kontrolnimi številkami, ne pa s preprosto konstanto, je zato nujna
// Iz tabele modelov reference SI je razvidno, koliko "podatkov" je v referenci SI in kje so kontrolne številke za primerjavo/njihov izbris za pripravo posameznih "podatkov" na "moduliranje":
// * Pri ločevanju "podatkov" sta v pomoč vezaja (v primeru odsotnosti vezajev je javljena napaka, ker sicer najverjetneje ni mogoče ločiti "podatkov"), kljub temu pa razporeditev kontrolnih številk izhaja zgolj iz tabele
// Pravilna je na primer "SI0519-1235-84503", v kontrolni številki napačna pa "SI081236-17-345679"
// Vir reference SI je https://www.zbs-giz.si/wp-content/uploads/2023/12/Pravila-za-oblikovanje-in-uporabo-standardiziranih-referenc-pri-opravljanju-placilnih-storitev-verzija-1.4.pdf
#let overi-referenco-si(si) = {
	// Že naj bi bilo overjeno v formatiranju:
	// * Omenjeno na vrhu datoteke
	// * Število vezajev
	// * Dolžina izjeme SI12
	// * Dolžina sklopov
	// * Nedovoljeni znaki

	let o-modelu = modeli-si.at(si.slice(0, 4))

	let sklopi = si.slice(4).split("-")

	// Podloži prazne sklope, da so vedno trije
	for _ in range(0, 3 - sklopi.len()) { sklopi.push("") }
	// Pretvori v sklope, ki imajo vsak po kontrolno številko
	// Je bolj na silo, ampak je v redu
	if o-modelu.K == "SSS" {
		sklopi = (sklopi.join(),) // [TODO] Prej je bilo najverjetneje narobe `sklopi.join()`, ker potem nastane niz, ne tabela, nad katerim je izveden `.len()`
	} else if o-modelu.K.starts-with("SS") {
		sklopi = (sklopi.at(0) + sklopi.at(1), sklopi.at(2))
	} else if o-modelu.K.ends-with("SS") {
		sklopi = (sklopi.at(0), sklopi.at(1) + sklopi.at(2))
	} else if o-modelu.K == "PPP" {
		return
	}
	// Izbriše sklope brez kontrolne številke
	// Najprej preveri, da ni bilo združevanja
	// [TODO] Ampak sklopi P/_ v (P, SS)/(SS, P)/(SS, _) zaenkrat niso izbrisani?
	if sklopi.len() == 3 {
		for (i, sklop) in o-modelu.K.clusters().enumerate() {
			if sklop == "P" or sklop == "_" {
				sklopi.at(i) = none
			} else if sklop == "K" or sklop == "S" {
				// Preskoči
			} else {
				// Naj bi se zgodilo zgolj, ko je tabela potvorjena
				panic("Neznana vrsta sklopa '" + sklop + "' za referenco SI '" + si + "'")
			}
		}
		sklopi = sklopi.filter(it => it != none)
	}

	// V izogib napaki `string index out of bounds (index: -1, len: 0)`
	sklopi = sklopi.filter(it => it != "")
	// Temu primerno javljena napaka
	if sklopi.len() < o-modelu.min { panic("Referenca SI '" + si + "' ima premalo sklopov") }

	for sklop in sklopi {
		let (P, K) = (sklop.slice(0, -1), sklop.slice(-1))
		let ponderji = range(2, 13, inclusive: true).rev().slice(0, P.len())

		P = P.clusters().map(int)
		if P.len() != ponderji.len() {
			// Naj bi bilo nedosegljivo
			panic("V referenci SI '" + si + "' se dolžina primerjanega podatka ne ujema z dolžino ponderjev")
		}
		let zmnožki = P.zip(ponderji).map(it => it.product()).sum()

		let ostanek = calc.rem(zmnožki, 11)
		let razlika = 11 - ostanek

		// Izvzame se 10 in 11, saj mora biti kontrolna številka enomestna
		if str(razlika).len() > 1 { razlika = 0 }

		if str(razlika) == K { (true,) } else { (false,) }
	}
}

// Zajema overitev dovoljenih znakov, razpona in dodatno (s pomočjo funkcij pomagalk) pravilnosti vnosa
// Za kodo namena, IBAN in referenci se domneva predhodna odstranitev vseh presledkov, sicer je javljena napaka
#let overi-format(..vsi) = {
	let velika-začetnica(dano) = {
		if dano.starts-with("iban") {
			upper(dano.split("-").first()) + " " + dano.split("-").last()
		} else {
			upper(dano.first()) + dano.slice(1).replace("-", " ")
		}
	}

	for (ime, arg) in vsi.pos().join() {
		if type(ime) != str { panic("Prvi argument v parih tabele naj je niz") }

		if arg in (none, "") { continue }

		if ime != "znesek" and arg.len() < 4 {
			panic(velika-začetnica(ime) + " mora biti dolžine " + if ime == "koda-namena" { "natanko" } else { "vsaj" } + " 4 znakov")
		}

		if ime in ("koda-namena", "iban-plačnika", "iban-prejemnika") {
			let nedovoljeni-znaki = arg.replace(regex("[A-Z0-9]"), "")
			if nedovoljeni-znaki != "" {
				panic(velika-začetnica(ime) + " vsebuje nedovoljene znake `" + nedovoljeni-znaki + "`")
			}
		}

		// Domneva se predhodno preverjen podatkovni tip in seveda pravilno usklajeno podane pare argumentov
		if ime == "znesek" {
			// Vrednost 0 evrov nadomešča `none`, saj takrat v vpisnem polju ni ničesar, je pa v QR
			if not (arg > 0 and arg < 1000000000) {
				panic("Znesek mora biti vsaj 0,01 € in največ 999.999.999,99 €")
			}
		} else if ime == "koda-namena" {
			if arg.len() > 4 { panic("Koda namena je predolga, imeti mora natanko 4 velike tiskane črke") }
			if arg not in kode-namena { panic("Koda namena '" + arg + "' ni bila najdena") }
		} else if ime.starts-with("iban") {
			let koda = arg.slice(0, 2)
			if ime.ends-with("plačnika") and koda != "SI" { panic("Koda države IBAN '" + koda + "' ni veljavna za plačnika") }
			let dolžina = kode-iban.at(koda, default: none)
			if dolžina == none { panic("Koda države IBAN '" + koda + "' ni bila najdena") }
			if arg.len() != dolžina { panic("Dolžina IBAN mora biti enaka " + str(dolžina)) }

			// Klic dodatne overitve 1/3
			if not overi-iban-rf(arg) { panic("IBAN '" + arg + "' je neveljaven") }
		} else if ime.starts-with("referenca") {
			let koda = arg.slice(0, 4)
			if koda.starts-with("RF") {
				let dolžina = 25
				if arg.len() > dolžina { panic("Referenca RF je predolga, imeti mora manj kot " + str(dolžina + 1) + " znakov") }

				let nedovoljeni-znaki = arg.replace(regex("[A-Z0-9]"), "")
				if nedovoljeni-znaki != "" {
					panic("Referenca RF vsebuje nedovoljene znake `" + nedovoljeni-znaki + "`")
				}

				// Klic dodatne overitve 2/3
				if not overi-iban-rf(arg) { panic("Referenca RF '" + arg + "' je neveljavna") }
			} else if koda.starts-with("SI") {
				let dolžina = 26
				if arg.len() > dolžina { panic("Referenca SI je predolga, imeti mora manj kot " + str(dolžina + 1) + " znakov") }

				let nedovoljeni-znaki = arg.replace(regex("[A-Z0-9-]"), "")
				if nedovoljeni-znaki != "" {
					panic("Referenca SI '" + koda + "' vsebuje nedovoljene znake `" + nedovoljeni-znaki + "`")
				}

				// Nevarno, ker zares ni nujno, da je `K` na prvem mestu, ampak OK
				let (_, min, max) = modeli-si.at(koda, default: (i: none, j: none, k: none)).values()
				if (min, max) == (none, none) { panic("Model reference SI '" + koda + "' ni bil najden") }

				let število-vezajev-najdenih = arg.matches("-").len()
				let število-vezajev-možnih = range(
					if min == 0 { 0 } else { min - 1 },
					if max == 0 { 0 } else { max - 1 },
					inclusive: true, // Ali pa brez tega in za največjo vrednost brez `-1`
				)
				if število-vezajev-najdenih not in število-vezajev-možnih { panic("V referenci " + koda + " je število pričakovanih vezajev " + število-vezajev-možnih.map(str).join(", ", last: " ali ") + ", najdenih pa je " + str(število-vezajev-najdenih)) }

				// [TODO] Ali so zdaj res izvzeti vsi napačni položaji vezajev?
				if arg.slice(4).starts-with("-") { panic("Nobena referenca SI se po modelu ne sme začeti z vezajem") }
				else if arg.ends-with("-") { panic("Nobena referenca SI se ne sme končati z vezajem") }

				if koda == "SI12" {
					if arg.len() < 17 {
						// Naj se uporabi to, če je zaželen samodejen popravek, ampak potem je treba popravljen argument nekako vrniti
						// arg = koda + "0" * (17 - arg.len()) + arg.slice(4)
						panic("Model reference SI12 izjemoma zapolnite z vodilnimi ničlami, da ima sklop 13 števk")
					} else if arg.len() > 17 {
						panic("Referenca modela SI12 je predolga")
					}
				}

				if arg.slice(4).split("-").any(it => {
					it.len() > if koda == "SI12" { 13 } else { 12 }
				}) {
					panic("Vsaj en sklop reference SI '" + arg + "' je predolg")
				}

				// Ker se v tukajšnji implementaciji overja število vezajev, ne sklopov, se za SI99, ki nikoli nima sklopov, ne loči med 0 in 1 sklopom
				if koda == "SI99" and arg.len() > 4 { panic("Model reference SI99 ne sme imeti sklopov") }

				// Klic dodatne overitve 3/3
				let rezultat = overi-referenco-si(arg)

				// Popravek za SI99, kjer ni sklopov in zato `overi-referenco-si` vrne `none`
				if rezultat == none { rezultat = (true,) }

				let neveljavni-sklopi = rezultat.enumerate(start: 1).filter(((i, b)) => not b).map(((i, b)) => i).map(str)
				if neveljavni-sklopi.len() > 0 {
					panic("Referenca SI '" + arg + "' je neveljavna v sklopih " + neveljavni-sklopi.join(", ", last: " in "))
				}
			} else {
				panic("Referenca mora biti tipa RF ali SI. Popravite morebitne neveljavne znake. Sicer pa pustite prazno ali referenco NRC vpišite v Namen plačila")
			}
		} else {
			panic("Nepričakovan drugi argument v paru, očitno ga posledično ni treba formatirati")
		}
	}
}