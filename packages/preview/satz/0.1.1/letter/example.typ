#import "@preview/satz:0.1.1": brief

#show: brief.with(
  absender: (
    name: "Max Mustermann",
    strasse: "Musterstraße 1",
    plz_ort: "12345 Musterstadt",
    telefon: "+49 123 4567890",
    email: "max.mustermann@gmail.com"),
  empfaenger: (
    name: "Musterfirma GmbH",
    zusatz: "z.Hd. Frau Erika Beispiel",
    strasse: "Beispielallee 42",
    plz_ort: "60311 Frankfurt am Main",
    land: "",
  ),
  betreff: "Subject Line",
  geschaeftszeile: (
    ("Mietsache", "112345"),
    ("Kundennummer", "123456"),
    ("Rechnungsnummer", "2023-001"),
    // man kann beliebige zeichen hinzufügen in dem man ("Zeichen", "Wert") hinzufügt, z.B. ("Kundennummer", "123456")
  ),
  lang: "de",
  postvermerk: "Einschreiben Einwurf",
)

Sehr geehrte Damen und Herren,

#lorem(200)

#v(2*0.65em)

Mit freundlichen Grüßen
// Linie für Unterschrift kommt automatisch
