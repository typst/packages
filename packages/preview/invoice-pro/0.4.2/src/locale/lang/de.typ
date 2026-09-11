/// German language overrides.
#let resolve-plural(v, n) = {
  if type(v) != dictionary { return v }
  if v.len() == 0 { return none }
  let num = if type(n) == decimal or type(n) == int or type(n) == float {
    float(n)
  } else if type(n) == str {
    float(n)
  } else {
    1.0
  }
  let fallback = v.pairs().first(default: (none, none)).last()
  if num == 1 {
    v.at("singular", default: fallback)
  } else {
    v.at("plural", default: fallback)
  }
}

#let de = (
  meta: (
    lang: "de",
    resolve-plural: resolve-plural,
  ),

  document: (
    invoice: "Rechnung",
  ),

  address: (
    recipient: "Rechnungsempfänger:in",
    sender: "Rechnungssteller:in",
  ),

  reference: (
    tax-number: "Steuernummer",
    invoice-number: "Rechnungsnummer",
    vat-id: "USt-IdNr.",
    invoice-date: "Rechnungsdatum",
    service-time: "Leistungszeitraum",
    customer-number: "Kundennummer",
    buyer-reference: "Leitweg-ID / Referenz",
    recipient-vat-id: "Empfänger:in USt-IdNr.",
    recipient-tax-number: "Empfänger:in Steuernummer",
    order-number: "Bestellnummer",
    order-date: "Bestelldatum",
    project: "Projekt",
    contract-number: "Vertragsnummer",
    quote-number: "Angebotsnummer",
    delivery-note-number: "Lieferscheinnummer",
    delivery-address: "Lieferadresse",
    preceding-invoice-number: "Vorherige Rechnungsnummer",
    due-date: "Fälligkeitsdatum",
    payment-reference: "Verwendungszweck",
    contact-person: "Ansprechpartner:in",
    contact-phone: "Telefon",
    contact-email: "E-Mail",
  ),

  line-items: (
    position: "Pos.",
    description: "Bezeichnung",
    quantity: "Menge",
    unit-price: "Einzelpreis",
    price: "Preis",
    total: "Gesamtpreis",
    vat: "USt.",
    net: "netto",
    gross: "brutto",
    discount: "Rabatt",
    surcharge: "Zuschlag",
    subtotal: "Zwischensumme",
    prepayment: "Anzahlung",
  ),

  summary: (
    sum: "Summe",
    vat-tax: "Umsatzsteuer",
    total: "Gesamtbetrag",
    including: "inkl.",
    excluding: "zzgl.",
    prepayment: "Anzahlung",
    amount-due: "Fälliger Betrag",
  ),

  global-info: (
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Alle Artikel sind #tax-text #rate #vat-tax.],
    unit: "Einheit für alle Artikel:",
    quantity: "Menge für alle Artikel:",
    date: "Leistungsdatum für alle Artikel:",
  ),

  units: (
    piece: "Stück",
    "set": (singular: "Satz", plural: "Sätze"),
    pair: (singular: "Paar", plural: "Paare"),
    "lump-sum": (singular: "Pauschale", plural: "Pauschalen"),
    hour: (singular: "Stunde", plural: "Stunden"),
    day: (singular: "Tag", plural: "Tage"),
    month: (singular: "Monat", plural: "Monate"),
    year: (singular: "Jahr", plural: "Jahre"),
    kilogram: "Kilogramm",
    gram: "Gramm",
    tonne: (singular: "Tonne", plural: "Tonnen"),
    metre: "Meter",
    "square-metre": "Quadratmeter",
    millimetre: "Millimeter",
    centimetre: "Zentimeter",
    kilometre: "Kilometer",
    litre: "Liter",
    "cubic-metre": "Kubikmeter",
  ),

  bank-details: (
    account-holder: "Kontoinhaber:in",
    bank: "Kreditinstitut",
    iban: "IBAN",
    bic: "BIC",
    reference: "Verwendungszweck",
  ),

  payment: (
    text: (
      sum,
      deadline,
    ) => [Bitte überweisen Sie den Gesamtbetrag in Höhe von *#sum* #deadline auf das unten angegebene Konto.],
    deadline-date: date => ("bis zum", date).join(" "),
    deadline-days: days => (
      "innerhalb von",
      str(days),
      "Tagen",
    ).join(" "),
    deadline-soon: "sofort nach Erhalt",
  ),

  signature: (
    closing: "Mit freundlichen Grüßen,",
  ),

  legal: (
    vat-exemption: "Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.",
  ),

  errors: (
    name-missing: "Name fehlt!",
    address-missing: "Adresse fehlt!",
    city-missing: "Stadt fehlt!",
    ambiguous-tax: "Mehrdeutiger Steuersatz von 0 % erkannt.",
    invalid-tax: "Ungültiger Steuersatz erkannt: ",
  ),
)
