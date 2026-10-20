// kba-document — Information Document (Beschreibungsbogen) per UN-R 10
// See README.md for full parameter documentation and usage notes.

#let kba-document(
  date: "",
  doc-number: "",
  marke: "",
  typ: "",
  varianten: (),
  handelsbezeichnung: "",
  ident-merkmal: "",
  ident-stelle: "",
  hersteller-name-anschrift: "",
  beauftragter: "",
  genehmigung-stelle-art: "",
  montagebetriebe: (),
  genehmigt-als: ("Bauteil", "component"),
  beschraenkungen: ("keine", "none"),
  nennspannung: "",
  // Charging system fields (items 10–15) — only used when is-charging-system: true
  is-charging-system: false,
  ladegeraet: "",
  ladestrom: "",
  phasen: "",
  frequenz: "",
  max-nennstrom: "",
  nenn-ladespannung: "",
  schnittstellen: "",
  rsce-wert: "",
  // Annex table
  anlagen: (),
  body,
) = {
  set text(font: "Arial", size: 10pt)

  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    footer: context [
      #set text(8pt)
      #line(length: 100%, stroke: 0.5pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        [Datum / _Date_: #date],
        align(center, [#doc-number]),
        align(right, [Seite / _Page_:  #counter(page).display("1/1")]),
      )
    ],
  )

  v(1em)
  align(center)[
    #underline(text(weight: "bold", size: 16pt)[Beschreibungsbogen Nr. / _  Information Document No._:]) \
    #v(0.5em)
    #text(weight: "bold", size: 12pt)[#doc-number]
  ]

  v(1em)

  align(center)[
    hinsichtlich der Typgenehmigung für eine elektrische/elektronische Unterbaugruppe \
    in Bezug auf die elektromagnetische Verträglichkeit (UN-R 10) / \
    _for type approval of an electric/electronic sub-assembly \
    with respect to electromagnetic compatibility (UN-R 10)_
  ]

  v(1em)

  let entry(num, ger, eng, val) = {
    let content = if type(val) == array and val.len() == 2 {
      [#val.at(0) / #text(style: "italic")[#val.at(1)]]
    } else {
      val
    }
    block(breakable: false)[
      #grid(
        columns: (30pt, 1fr, 1.5fr),
        gutter: 1em,
        [#num], [#ger / \ #text(style: "italic", size: 9pt)[#eng]:], [*#content*],
      )
      #v(0.5em)
    ]
  }

  entry("1", "Marke", "Make", marke)
  entry("2", "Typ", "Type", typ)
  entry("", "Varianten des Typs", "Variants of the type", varianten.join(", "))
  entry("", "Handelsbezeichnung(en)", "General commercial description(s)", handelsbezeichnung)
  entry("3", "Merkmal zur Typidentifizierung", "Means of identification of type", ident-merkmal)
  entry("3.1", "Stelle, an der die Kennzeichnung angebracht ist", "Location of that marking", ident-stelle)
  entry("4", "Name und Anschrift des Herstellers", "Name and address of manufacturer", hersteller-name-anschrift)
  entry(
    "",
    "ggf. Name und Anschrift des Beauftragten",
    "Name and address of authorised representative, if any",
    beauftragter,
  )
  entry(
    "5",
    "Stelle und Art der Anbringung des Genehmigungszeichens",
    "Location and method of affixing of the EC approval mark",
    genehmigung-stelle-art,
  )
  entry(
    "6",
    "Name(n) und Anschrift(en) der/s Montagebetriebe(s)",
    "Name(s) and address(es) of assembly plant(s)",
    montagebetriebe.join("\n"),
  )
  entry("7", "Diese EUB wird genehmigt als", "This ESA shall be approved as a", genehmigt-als)
  entry(
    "8",
    "Beschränkungen hinsichtlich der Verwendung",
    "Any restrictions of use and conditions for fitting",
    beschraenkungen,
  )
  entry("9", "Nennspannung des elektrischen Systems", "Electrical system rated voltage", nennspannung)

  if is-charging-system {
    v(1em)
    line(length: 100%, stroke: 0.5pt)
    text(weight: "bold")[Nur anzuwenden für Ladesysteme / Only applicable for charging systems:]
    v(0.5em)

    entry("10", "Ladegerät", "charger", ladegeraet)
    entry("11", "Ladestrom", "charging current", ladestrom)
    entry(
      "11.1",
      "Zusätzliche Informationen bei Wechselstrom",
      "Additional information for alternating current",
      [Phasen: #phasen, Frequenz: #frequenz],
    )
    entry("12", "Maximaler Nennstrom", "Maximal nominal current", max-nennstrom)
    entry("13", "Nenn-Ladespannung", "Nominal charging voltage", nenn-ladespannung)
    entry("14", "Basis EUB Schnittstellenfunktionen", "Basic ESA interface functions", schnittstellen)
    entry("15", "Minimaler Rsce-Wert", "Minimal Rsce value", rsce-wert)
  }

  v(2em)
  [*Verzeichnis der zur Beschreibung der EUB beigefügten Unterlagen / \
  _Table of documents for description of ESA_*]
  v(0.5em)

  table(
    columns: (auto, 2fr, 2fr, 1fr, 1fr, 0.8fr),
    align: center + horizon,
    [*Nr. / \ _No._*],
    [*Inhalt / \ _Content_*],
    [*Dokumenten- / Zeichnungsnr. / \ _Document / Drawing No._*],
    [*Ausgabe- \ datum / \ _Date of Issue_*],
    [*Letztes \ Änderungs- \ datum / \ _Last Change Date_*],
    [*Seiten- \ anzahl / \ _Number of Pages_*],
    ..for anlage in anlagen {
      (anlage.nr, anlage.inhalt, anlage.doc-nr, anlage.datum, anlage.rev, anlage.seiten)
    },
  )
  body
}
