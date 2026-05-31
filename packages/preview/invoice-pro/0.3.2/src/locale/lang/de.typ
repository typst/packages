/// German language overrides.
#let de = (
  meta: (
    lang: "de",
  ),

  document: (
    invoice: "Rechnung",
  ),

  address: (
    recipient: "Empfänger",
    sender: "Absender",
  ),

  reference: (
    tax-number: "Steuernummer",
    invoice-number: "Rechnungsnummer",
  ),

  line-items: (
    position: "Pos",
    description: "Beschreibung",
    quantity: "Menge",
    unit-price: "Einzelpreis",
    price: "Preis",
    total: "Gesamt",
    vat: "MwSt.",
    net: "netto",
    gross: "brutto",
    discount: "Rabatt",
    surcharge: "Zuschlag",
    subtotal: "Zwischensumme",
  ),

  summary: (
    sum: "Summe",
    vat-tax: "Mehrwertsteuer",
    total: "Gesamt",
    including: "inkl.",
    excluding: "zzgl.",
  ),

  /// Global informational sentences (usually displayed below the line items)
  global-info: (
    /// Sentence specifying the universal tax rate applied
    /// -> (content|str, content|str, content|str) => content
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Alle Artikel sind #tax-text #rate #vat-tax],
    unit: "Einheit für alle Artikel:",
    quantity: "Menge für alle Artikel:",
    date: "Leistungsdatum für alle Artikel:",
  ),

  bank-details: (
    account-holder: "Kontoinhaber:in",
    bank: "Kreditinstitut",
    iban: "IBAN",
    bic: "BIC",
    reference: "Verwendungszweck",
  ),

  payment: (
    /// Generates the final payment instruction sentence.
    /// -> (content|str, content|str) => content
    text: (
      sum,
      deadline,
    ) => [Bitte überweisen Sie den Gesamtbetrag von *#sum* #deadline ohne Abzug auf das unten genannte Konto.],

    /// Text for a fixed target date.
    deadline-date: date => ("bis spätestens ", date).join(" "),

    /// Text for a relative target date (in X days).
    deadline-days: days => (
      "innerhalb von",
      str(days),
      "Tagen",
    ).join(" "),

    /// Text for immediate/prompt payment.
    deadline-soon: "zeitnah",
  ),

  signature: (
    closing: "Mit freundlichen Grüßen",
  ),

  legal: (
    vat-exemption: "Keine Umsatzsteuer gemäß Kleinunternehmerregelung.",
  ),

  errors: (
    name-missing: "Name fehlt!",
    address-missing: "Adresse fehlt!",
    city-missing: "Stadt fehlt!",
    ambiguous-tax: "Mehrdeutiger 0% Steuersatz erkannt.",
    invalid-tax: "Ungültiger Steuersatz erkannt: ",
  ),
)
