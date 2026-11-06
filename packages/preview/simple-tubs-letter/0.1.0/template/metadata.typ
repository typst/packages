/*
 - SPDX-FileCopyrightText: 2025-2025 Malte Kumlehn
 - SPDX-License-Identifier: MIT
*/

#let lang = "de"
#let tubs-logo = image("assets/figure/tubs/tubs_logo.svg", width: 38%)
#let institute-logo = image("assets/figure/tubs/institute_logo.jpg", width: 40%) // make sure that the size of this logo fits!
#let institute-name = [
  Beispiel Institute
  #v(1em)
  #text(weight: "bold")[
    Abteilung für Beispiele
  ]
]
#let institute-name-en = [
  Example Institute\
  for exmplary research
  #v(1em)
  #text(weight: "bold")[
    Dept. of Examples
  ]
]
#let institute-prof = [Prof. Dr.-Ing. habil. Anna Müller]
#let author = "Max Mustermann"
#let phone-nr = [+49 (0) 531 391-0000]
#let fax-nr = [+49 (0) 531 391-0001]
#let email = [max.mustermann\@tu-braunschweig.de]
#let website = [www.tu-braunschweig.de/institute]
#let institute-address-header = [Technische Universität Braunschweig | Example Institut\
  Postfach 1234 | 38023 Braunschweig]
#let to-address = [Empfänger\
  Something-Street 1\
  12345 Some-city\
  Germany]
#let date = [#datetime.today().display("[day].[month].[year]")]
#let subject = [This is a very important examplary letter]