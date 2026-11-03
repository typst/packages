// Gastspielvertrag template — guest performance contract with fill-in fields.
//
// Supports three document types: Vertrag (contract), Angebot (offer), Rechnung (invoice).

#import "components.typ": contract_header, paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5, paragraph_6, paragraph_7, paragraph_8, signature_lines

/// Guest performance contract — blanks for the venue to fill in.
///
/// Pick what you send:
/// - `"vertrag"`: full contract with all §§ and signature lines
/// - `"angebot"`: offer — no sigs, says "Kostenvoranschlag"
/// - `"rechnung"`: invoice mode
///
/// Blanks show as underlines — fill them by hand or in a PDF editor.
/// Artist defaults are placeholders — set your own.
///
/// ```example
/// #show: gastspielvertrag.with(
///   dokument: "vertrag",
///   veranstaltung: "Konzert",
///   location: "Club XYZ",
///   datum: "15.03.2026",
///   festgage: 800,
///   transport_km: 120,
/// )
/// ```
///
/// - dokument (str): "vertrag", "angebot", or "rechnung"
/// - veranstaltung (str): what's the show?
/// - location (str): where?
/// - datum (str): when?
/// - auftrittszeit (str): stage time
/// - auftrittsdauer (str): how long you play
/// - einlass (str): doors open
/// - curfew (str): when you stop
/// - musiker (int): how many musicians
/// - techniker (bool): bring a tech?
/// - fotograf (bool): bring a photographer?
/// - gage_typ (str): "fest" or "prozent"
/// - festgage (int): flat fee in EUR
/// - prozentsatz (int): % of ticket sales
/// - mindestgage (int): minimum you get
/// - kleinunternehmer (bool): show the § 19 VAT-free note?
/// - transport_km (int): one-way distance (0 = no transport)
/// - transport_satz (float): EUR per km — 0.30 by default
/// - techniker_honorar (int): tech fee (0 = none)
/// - uebernachtung (int): hotel costs (0 = none)
/// - sonstiges_text (str): what else costs?
/// - sonstiges_betrag (int): how much else?
/// - buyout_pro_person (int): buy-out per person in EUR
/// - kuenstler (str): your artist name
/// - kuenstler_vertreter (str): who signs for you
/// - kuenstler_anschrift (str): your address
/// - font (str): body font — "Inter" by default
/// - body (content): extra text after §8 if you need it
#let gastspielvertrag(
  // Document type
  dokument: "vertrag",

  // Artist info
  kuenstler: "Max Mustermann",
  kuenstler_vertreter: "Max Mustermann",
  kuenstler_anschrift: "Musterstraße 1, 12345 Musterstadt",

  // Event
  veranstaltung: "",
  location: "",
  datum: "",
  auftrittszeit: "",
  auftrittsdauer: "",
  einlass: "",
  curfew: "",

  // Personnel
  musiker: 4,
  techniker: true,
  fotograf: false,

  // Fee
  gage_typ: "fest",
  festgage: 0,
  prozentsatz: 80,
  mindestgage: 0,
  kleinunternehmer: true,

  // Transport
  transport_km: 0,
  transport_satz: 0.30,

  // Optional costs
  techniker_honorar: 0,
  uebernachtung: 0,
  sonstiges_text: "",
  sonstiges_betrag: 0,

  // Hospitality
  buyout_pro_person: 15,

  // Styling
  font: "Inter",

  // Extra content
  body,
) = {
  let zeilenabstand = 0.75em

  // Build default gig dict for components (filled from params)
  let g = (
    veranstaltung: veranstaltung,
    location: location,
    datum: datum,
    auftrittszeit: auftrittszeit,
    auftrittsdauer: auftrittsdauer,
    einlass: einlass,
    curfew: curfew,
    musiker: musiker,
    techniker: techniker,
    fotograf: fotograf,
    gage_typ: gage_typ,
    festgage: festgage,
    prozentsatz: prozentsatz,
    mindestgage: mindestgage,
    kleinunternehmer: kleinunternehmer,
    transport_km: transport_km,
    transport_satz: transport_satz,
    techniker_honorar: techniker_honorar,
    uebernachtung: uebernachtung,
    sonstiges_text: sonstiges_text,
    sonstiges_betrag: sonstiges_betrag,
    buyout_pro_person: buyout_pro_person,
    kuenstler: kuenstler,
    kuenstler_vertreter: kuenstler_vertreter,
    kuenstler_anschrift: kuenstler_anschrift,
  )

  // --- Global styles ---
  set text(font: font, size: 11pt, lang: "de", hyphenate: false)
  set page(
    "a4",
    margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
    footer: context [
      #set text(size: 8.5pt)
      #align(center)[Seite #counter(page).get().first() von #counter(page).final().last()]
    ],
  )
  set par(justify: true, leading: zeilenabstand)
  set list(spacing: zeilenabstand)

  // --- Title ---
  let title = if dokument == "angebot" {
    [KOSTENVORANSCHLAG]
  } else if dokument == "rechnung" {
    [RECHNUNG]
  } else {
    [GASTSPIELVERTRAG]
  }
  align(center, text(weight: "bold", size: 14pt)[#title])
  v(2em)

  // --- Contract header ---
  contract_header(g, zeilenabstand)
  v(2em)

  // --- Contract body (full contract mode only) ---
  if dokument != "rechnung" {
    paragraph_1(g)
    v(1.5em)

    paragraph_2(g, zeilenabstand)
    v(1.5em)

    paragraph_3()
    v(1.5em)

    paragraph_4()
    v(1.5em)

    paragraph_5(g)
    v(1.5em)

    paragraph_6(g)
    v(1.5em)

    paragraph_7()
    v(1.5em)

    paragraph_8()
    v(2em)

    // Custom body content (e.g., additional clauses)
    body

    // Signatures (contract mode only)
    if dokument == "vertrag" {
      v(1em)
      text(size: 9pt)[
        #align(center)[
          Ort, Datum: #datetime.today().display("[day].[month].[year]")
        ]
      ]
      signature_lines(g.kuenstler_vertreter)
    }

    // Angebot footer
    if dokument == "angebot" {
      v(2em)
      text(size: 9pt, style: "italic")[
        Dieses Angebot ist unverbindlich und gilt bis zum
        #datetime.today().display("[day].[month].[year]").
      ]
    }
  }
}
