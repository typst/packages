// Gastspielvertrag template — guest performance contract with fill-in fields.
//
// Supports three document types: Vertrag (contract), Angebot (offer), Rechnung (invoice).

#import "components.typ": contract_header, paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5, paragraph_6, paragraph_7, paragraph_8, signature_lines
#import "../input.typ": select-alias

/// A German guest-performance contract with fill-in fields.
///
/// English names are the canonical interface; German argument names remain as
/// compatibility aliases. The rendered contract stays German.
///
/// `document-type` chooses the form:
/// - `"vertrag"`: full contract with all §§ and signature lines
/// - `"angebot"`: offer without signatures, titled "Kostenvoranschlag"
/// - `"rechnung"`: invoice title only; no §§, fee table, signature lines, or
///   `body`. Use `invoice()` from Satz for a real invoice.
///
/// Empty fields render as underlines for handwriting or a PDF editor. The
/// default artist details are placeholders and should always be replaced.
///
/// ```example
/// #show: gastspielvertrag.with(
///   document-type: "vertrag",
///   artist: "Alex Example",
///   artist-representative: "Alex Example",
///   artist-address: "Example Street 1, 12345 Example City",
///   event: "Example concert",
///   venue: "Example Hall",
///   date: "15.03.2026",
///   fixed-fee: 800,
///   travel-km: 120,
/// )
/// ```
///
/// - document-type (str): `"vertrag"`, `"angebot"`, or `"rechnung"`; defaults to `"vertrag"`
/// - artist (str): artist or band name
/// - artist-representative (str): person signing for the artist
/// - artist-address (str): artist postal address
/// - event (str): event description; defaults to empty
/// - venue (str): venue name and city; defaults to empty
/// - date (str): performance date as display text; defaults to empty
/// - performance-time (str): stage time; defaults to empty
/// - performance-duration (str): set length; defaults to empty
/// - doors (str): door-opening time; defaults to empty
/// - curfew (str): latest permitted end time; defaults to empty
/// - musicians (int): number of musicians; defaults to 4
/// - technician (bool): whether a technician is included; defaults to true
/// - photographer (bool): whether a photographer is included; defaults to false
/// - fee-type (str): `"fest"` for a fixed fee or `"prozent"` for a percentage;
///   defaults to `"fest"`
/// - fixed-fee (int): fixed fee in EUR, used only when `fee-type` is `"fest"`;
///   defaults to 0
/// - percentage (int): artist share of ticket sales, 0–100; defaults to 80
/// - minimum-fee (int): guaranteed minimum fee in EUR; defaults to 0
/// - small-business (bool): show the § 19 small-business VAT note. Defaults to
///   true; set false when you charge VAT.
/// - travel-km (int): one-way travel distance in km; 0 disables travel costs.
///   The calculated fee uses the round trip (`km × rate × 2`).
/// - travel-rate (int, float): EUR per km; defaults to 0.30
/// - technician-fee (int): technician fee in EUR; 0 disables it
/// - accommodation (int): accommodation cost in EUR; 0 disables it
/// - other-description (str): label for an additional cost
/// - other-amount (int): amount for that additional cost in EUR
/// - buyout-per-person (int): hospitality buy-out in EUR per person; defaults to 15
/// - font (str): body font family; defaults to `"Inter"`
/// - body (content): extra clauses after § 8; ignored in `"rechnung"` mode
///
/// German aliases: `dokument`, `kuenstler`, `kuenstler_vertreter`,
/// `kuenstler_anschrift`, `veranstaltung`, `datum`, `auftrittszeit`,
/// `auftrittsdauer`, `einlass`, `musiker`, `techniker`, `fotograf`,
/// `gage_typ`, `festgage`, `prozentsatz`, `mindestgage`, `kleinunternehmer`,
/// `transport_km`, `transport_satz`, `techniker_honorar`, `uebernachtung`,
/// `sonstiges_text`, `sonstiges_betrag`, and `buyout_pro_person`.
/// `venue` is the English name for `location`. Supplying both spellings of the
/// same value produces a field-specific conflict error.
#let gastspielvertrag(
  // Document type
  dokument: none,
  document-type: none,

  // Artist info
  kuenstler: none,
  kuenstler_vertreter: none,
  kuenstler_anschrift: none,
  artist: none,
  artist-representative: none,
  artist-address: none,

  // Event
  veranstaltung: none,
  location: none,
  datum: none,
  auftrittszeit: none,
  auftrittsdauer: none,
  einlass: none,
  curfew: "",
  event: none,
  venue: none,
  date: none,
  performance-time: none,
  performance-duration: none,
  doors: none,

  // Personnel
  musiker: none,
  techniker: none,
  fotograf: none,
  musicians: none,
  technician: none,
  photographer: none,

  // Fee
  gage_typ: none,
  festgage: none,
  prozentsatz: none,
  mindestgage: none,
  kleinunternehmer: none,
  fee-type: none,
  fixed-fee: none,
  percentage: none,
  minimum-fee: none,
  small-business: none,

  // Transport
  transport_km: none,
  transport_satz: none,
  travel-km: none,
  travel-rate: none,

  // Optional costs
  techniker_honorar: none,
  uebernachtung: none,
  sonstiges_text: none,
  sonstiges_betrag: none,
  technician-fee: none,
  accommodation: none,
  other-description: none,
  other-amount: none,

  // Hospitality
  buyout_pro_person: none,
  buyout-per-person: none,

  // Styling
  font: "Inter",

  // Extra content
  body,
) = {
  let dokument = select-alias(dokument, document-type, "dokument", "document-type", "vertrag")
  let kuenstler = select-alias(kuenstler, artist, "kuenstler", "artist", "Max Mustermann")
  let kuenstler_vertreter = select-alias(kuenstler_vertreter, artist-representative, "kuenstler_vertreter", "artist-representative", "Max Mustermann")
  let kuenstler_anschrift = select-alias(kuenstler_anschrift, artist-address, "kuenstler_anschrift", "artist-address", "Musterstraße 1, 12345 Musterstadt")
  let veranstaltung = select-alias(veranstaltung, event, "veranstaltung", "event", "")
  let location = select-alias(location, venue, "location", "venue", "")
  let datum = select-alias(datum, date, "datum", "date", "")
  let auftrittszeit = select-alias(auftrittszeit, performance-time, "auftrittszeit", "performance-time", "")
  let auftrittsdauer = select-alias(auftrittsdauer, performance-duration, "auftrittsdauer", "performance-duration", "")
  let einlass = select-alias(einlass, doors, "einlass", "doors", "")
  let musiker = select-alias(musiker, musicians, "musiker", "musicians", 4)
  let techniker = select-alias(techniker, technician, "techniker", "technician", true)
  let fotograf = select-alias(fotograf, photographer, "fotograf", "photographer", false)
  let gage_typ = select-alias(gage_typ, fee-type, "gage_typ", "fee-type", "fest")
  let festgage = select-alias(festgage, fixed-fee, "festgage", "fixed-fee", 0)
  let prozentsatz = select-alias(prozentsatz, percentage, "prozentsatz", "percentage", 80)
  let mindestgage = select-alias(mindestgage, minimum-fee, "mindestgage", "minimum-fee", 0)
  let kleinunternehmer = select-alias(kleinunternehmer, small-business, "kleinunternehmer", "small-business", true)
  let transport_km = select-alias(transport_km, travel-km, "transport_km", "travel-km", 0)
  let transport_satz = select-alias(transport_satz, travel-rate, "transport_satz", "travel-rate", 0.30)
  let techniker_honorar = select-alias(techniker_honorar, technician-fee, "techniker_honorar", "technician-fee", 0)
  let uebernachtung = select-alias(uebernachtung, accommodation, "uebernachtung", "accommodation", 0)
  let sonstiges_text = select-alias(sonstiges_text, other-description, "sonstiges_text", "other-description", "")
  let sonstiges_betrag = select-alias(sonstiges_betrag, other-amount, "sonstiges_betrag", "other-amount", 0)
  let buyout_pro_person = select-alias(buyout_pro_person, buyout-per-person, "buyout_pro_person", "buyout-per-person", 15)

  assert(dokument in ("vertrag", "angebot", "rechnung"),
    message: "Guest contract `document-type` must be vertrag, angebot or rechnung.")
  assert(gage_typ in ("fest", "prozent"), message: "Guest contract `fee-type` must be fest or prozent.")
  for (field, value) in (
    ("artist", kuenstler), ("artist-representative", kuenstler_vertreter),
    ("artist-address", kuenstler_anschrift), ("event", veranstaltung),
    ("venue", location), ("date", datum), ("performance-time", auftrittszeit),
    ("performance-duration", auftrittsdauer), ("doors", einlass), ("curfew", curfew),
    ("other-description", sonstiges_text), ("font", font),
  ) {
    assert(type(value) == str, message: "Guest contract field `" + field + "` must be a string.")
  }
  for (field, value) in (
    ("musicians", musiker), ("fixed-fee", festgage), ("percentage", prozentsatz),
    ("minimum-fee", mindestgage), ("travel-km", transport_km),
    ("technician-fee", techniker_honorar), ("accommodation", uebernachtung),
    ("other-amount", sonstiges_betrag), ("buyout-per-person", buyout_pro_person),
  ) {
    assert(type(value) == int and value >= 0,
      message: "Guest contract field `" + field + "` must be a nonnegative integer.")
  }
  assert(type(transport_satz) == int or type(transport_satz) == float,
    message: "Guest contract `travel-rate` must be a nonnegative number.")
  assert(transport_satz >= 0, message: "Guest contract `travel-rate` must be a nonnegative number.")
  assert(prozentsatz <= 100, message: "Guest contract `percentage` must not exceed 100.")
  assert(type(techniker) == bool and type(fotograf) == bool and type(kleinunternehmer) == bool,
    message: "Guest contract `technician`, `photographer` and `small-business` must be booleans.")
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
