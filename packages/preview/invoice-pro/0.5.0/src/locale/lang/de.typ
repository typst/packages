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
    // The German VAT law reserves "Gutschrift" for self-billed invoices
    // (§ 14 Abs. 2 Satz 2 UStG), so a credit note is a "Rechnungskorrektur".
    credit-note: "Rechnungskorrektur",
    corrected: "Korrigierte Rechnung",
    prepayment: "Anzahlungsrechnung",
    // Required on a self-billed invoice (§ 14 Abs. 4 Satz 1 Nr. 10 UStG).
    self-billed: "Gutschrift",
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
    preceding-invoice-date: "Datum der vorherigen Rechnung",
    due-date: "Fälligkeitsdatum",
    payment-reference: "Verwendungszweck",
    contact-person: "Ansprechpartner:in",
    contact-phone: "Telefon",
    contact-email: "E-Mail",
    payee: "Zahlungsempfänger",
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
    conjunction: "und",
    origin: "Ursprungsland",
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

  tax-exemption: (
    reverse-charge: "Steuerschuldnerschaft des Leistungsempfängers",
    intra-community: "Steuerfreie innergemeinschaftliche Lieferung",
    export: "Steuerfreie Ausfuhrlieferung",
    outside-scope: "Nicht steuerbarer Umsatz",
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

  payment-means: (
    method: "Zahlungsart",
    transfer: "Überweisung",
    direct-debit: "Lastschrift",
    sepa-direct-debit: "SEPA-Lastschrift",
    card: "Kartenzahlung",
    credit-card: "Kreditkarte",
    debit-card: "Debitkarte",
    cash: "Barzahlung",
    cheque: "Scheck",
    online: "Online-Zahlung",
    mandate: "Mandatsreferenz",
    creditor-id: "Gläubiger-ID",
    debtor-iban: "Ihre IBAN",
    card-number: "Kartennummer",
    card-holder: "Karteninhaber:in",
    paid: (
      sum,
      date,
    ) => [Der Gesamtbetrag in Höhe von *#sum* wurde#if date != none [ am #date] bezahlt.],
    paid-due: (
      sum,
      date,
    ) => [Der fällige Betrag in Höhe von *#sum* wurde#if date != none [ am #date] bezahlt.],
    paid-credit: (
      sum,
      date,
    ) => [Den Betrag in Höhe von *#sum* haben wir Ihnen#if date != none [ am #date] ausgezahlt.],
  ),

  payment: (
    text: (
      sum,
      deadline,
    ) => [Bitte überweisen Sie den Gesamtbetrag in Höhe von *#sum* #deadline auf das unten angegebene Konto.],
    text-due: (
      sum,
      deadline,
    ) => [Bitte überweisen Sie den fälligen Betrag in Höhe von *#sum* #deadline auf das unten angegebene Konto.],
    text-direct-debit: (
      sum,
      deadline,
    ) => [Der Gesamtbetrag in Höhe von *#sum* wird #deadline per Lastschrift von Ihrem Konto eingezogen.],
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [Der fällige Betrag in Höhe von *#sum* wird #deadline per Lastschrift von Ihrem Konto eingezogen.],
    text-card: (
      sum,
      deadline,
    ) => [Der Gesamtbetrag in Höhe von *#sum* wird Ihrer Karte #deadline belastet.],
    text-card-due: (
      sum,
      deadline,
    ) => [Der fällige Betrag in Höhe von *#sum* wird Ihrer Karte #deadline belastet.],
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [Bei Zahlung #deadline gewähren wir #percent Skonto#if basis != none [ auf #basis].],
    deadline-date: date => ("bis zum", date).join(" "),
    deadline-days: days => (
      "innerhalb von",
      str(days),
      "Tagen",
    ).join(" "),
    deadline-soon: "sofort nach Erhalt",
    text-credit: (
      sum,
      deadline,
    ) => [Den Betrag in Höhe von *#sum* überweisen wir #deadline auf das unten angegebene Konto.],
    deadline-soon-credit: "umgehend",
  ),

  signature: (
    closing: "Mit freundlichen Grüßen,",
  ),

  legal: (
    vat-exemption: "Aufgrund der Kleinunternehmerregelung wird keine Umsatzsteuer berechnet.",
  ),

  errors: (
    name-missing: "Name fehlt!",
    address-missing: "Adresse fehlt!",
    city-missing: "Stadt fehlt!",
    ambiguous-tax: "Mehrdeutiger Steuersatz von 0 % erkannt.",
    invalid-tax: "Ungültiger Steuersatz erkannt: ",
  ),
)
