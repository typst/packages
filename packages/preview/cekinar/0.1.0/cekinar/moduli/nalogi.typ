// Domneva se, da je `način` predhodno overjen
#let nalogi(način: "") = {
	// Pomeni vrednosti so sledeči:
	// * `true`  ... obvezno
	// * `false` ... ni dovoljeno
	// * `auto`  ... neobvezno
	// Za izjeme (1), (2), (3) in (4) iz standarda je v `README.md` priporočena uporaba `nalog: ""`
	(
		znesek: if način == "plačilo-obveznosti" {
				true
			} else if način == "registriran-izdajatelj" {
				true
			} else if način == "polog-gotovine" {
				true
			} else if način == "dvig-gotovine" {
				true
			} else {
				auto
			},
		datum: if način == "plačilo-obveznosti" {
				auto
			} else if način == "registriran-izdajatelj" {
				false
			} else if način == "polog-gotovine" {
				true
			} else if način == "dvig-gotovine" {
				true
			} else {
				auto
			},
		rok: if način == "plačilo-obveznosti" {
				auto
			} else if način == "registriran-izdajatelj" {
				auto
			} else if način == "polog-gotovine" {
				false
			} else if način == "dvig-gotovine" {
				false
			} else {
				auto
			},
		nujno: if način == "plačilo-obveznosti" {
				auto
			} else if način == "registriran-izdajatelj" {
				false
			} else if način == "polog-gotovine" {
				false
			} else if način == "dvig-gotovine" {
				false
			} else {
				auto
			},
		polog: if način == "plačilo-obveznosti" {
				false
			} else if način == "registriran-izdajatelj" {
				false
			} else if način == "polog-gotovine" {
				true
			} else if način == "dvig-gotovine" {
				false
			} else {
				auto
			},
		dvig: if način == "plačilo-obveznosti" {
				false
			} else if način == "registriran-izdajatelj" {
				false
			} else if način == "polog-gotovine" {
				false
			} else if način == "dvig-gotovine" {
				true
			} else {
				auto
			},
		namen: (
			koda: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					true
				} else {
					auto
				},
			opis: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					true
				} else {
					auto
				},
		),
		plačnik: (
			ime: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					auto
				} else if način == "dvig-gotovine" {
					true
				} else {
					auto
				},
			ulica: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					auto
				} else if način == "dvig-gotovine" {
					true
				} else {
				 auto
				},
			kraj: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					auto
				} else if način == "dvig-gotovine" {
					true
				} else {
					auto
				},
			iban: if način == "plačilo-obveznosti" {
					auto
				} else if način == "registriran-izdajatelj" {
					false
				} else if način == "polog-gotovine" {
					false
				} else if način == "dvig-gotovine" {
					true
				} else {
					auto
				},
			referenca: if način == "plačilo-obveznosti" {
					auto
				} else if način == "registriran-izdajatelj" {
					false
				} else if način == "polog-gotovine" {
					false
				} else if način == "dvig-gotovine" {
					auto
				} else {
					auto
				},
			podpis: if način == "plačilo-obveznosti" {
					auto
				} else if način == "registriran-izdajatelj" {
					auto
				} else if način == "polog-gotovine" {
					auto
				} else if način == "dvig-gotovine" {
					auto
				} else {
					auto
				},
		),
		prejemnik: (
			ime: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					auto
				} else {
					auto
				},
			ulica: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					auto
				} else {
					auto
				},
			kraj: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					auto
				} else {
					auto
				},
			iban: if način == "plačilo-obveznosti" {
					true
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					true
				} else if način == "dvig-gotovine" {
					false
				} else {
					auto
				},
			referenca: if način == "plačilo-obveznosti" {
					auto
				} else if način == "registriran-izdajatelj" {
					true
				} else if način == "polog-gotovine" {
					auto
				} else if način == "dvig-gotovine" {
					false
				} else {
					auto
				},
		),
	)
}