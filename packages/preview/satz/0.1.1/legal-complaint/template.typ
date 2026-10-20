// Klageschrift template — ZPO-compliant civil complaint (Amtsgericht).
//
// Uses a wider right margin (35mm) for judicial binding margins.
// Includes Rubrum, Streitwert, Anträge section, and attachment list.

#import "components.typ": rubrum_block, streitwert_block, anlagen_liste, court_absender_block, court_empfaenger_block

/// A Klageschrift for German civil court (Amtsgericht).
///
/// Gives you Rubrum, Streitwert, your claims, and the Anlagen list.
/// Attach a PDF if you need to include exhibits.
/// ZPO-style layout with a wider right margin for the court file.
///
/// ```example
/// #show: klageschrift.with(
///   gericht: "Amtsgericht Musterstadt",
///   gericht_ort: "Gerichtsstraße 1, 12345 Musterstadt",
///   klagername: "Max Mustermann",
///   klagerin_str: "Musterstraße 1",
///   klagerin_plz: "12345 Musterstadt",
///   beklagter: "Erika Beispiel",
///   beklagter_str: "Beispielweg 2",
///   beklagter_plz: "54321 Beispielstadt",
///   streitwert: "1.000,00 EUR",
///   anlagen: ("Anlage K 1: Vertrag",),
/// )
/// = Anträge
/// ...
/// ```
///
/// - gericht (str): court name
/// - gericht_ort (str): court address
/// - klagername (str): who sues
/// - klagerin_str (str): their street
/// - klagerin_plz (str): their zip and city
/// - beklagter (str): who gets sued
/// - beklagter_str (str): their street
/// - beklagter_plz (str): their zip and city
/// - streitwert (str): how much — e.g. "600,00 EUR"
/// - anlagen (array): list your exhibits
/// - anlagen_pdf_path (none, str): PDF to attach. None = skip
/// - anlagen_max_pages (int): how many pages to pull from that PDF
/// - font (str): body font — "Inter" by default
/// - body (content): your claims and reasoning
#let klageschrift(
  gericht: "Amtsgericht",
  gericht_ort: "",
  klagername: "",
  klagerin_str: "",
  klagerin_plz: "",
  beklagter: "",
  beklagter_str: "",
  beklagter_plz: "",
  streitwert: "",
  anlagen: (),
  anlagen_pdf_path: none,
  anlagen_max_pages: 30,
  font: "Inter",
  body,
) = {
  let zeilenabstand = 0.75em

  // --- Global styles ---
  set text(font: font, size: 11pt, lang: "de", hyphenate: false)
  set page(
    "a4",
    // Right margin 35mm — judicial binding margin (Heftrand)
    margin: (left: 25mm, right: 35mm, top: 25mm, bottom: 25mm),
    footer: context [
      #set text(size: 8.5pt)
      #align(center)[Seite #counter(page).get().first() von #counter(page).final().last()]
    ],
  )
  set par(justify: true, leading: zeilenabstand)
  set list(spacing: zeilenabstand)

  // --- Sender block (top-right, smaller than letter version) ---
  court_absender_block(klagername, klagerin_str + " " + klagerin_plz, zeilenabstand)
  v(1.5em)

  // --- Recipient (window envelope field) ---
  court_empfaenger_block(
    klagername,
    klagerin_str + ", " + klagerin_plz,
    gericht,
    gericht_ort,
  )
  v(4em)

  // --- Title ---
  align(center, text(weight: "bold", size: 12pt)[Klage])
  v(1em)

  // --- Rubrum (party identification) ---
  rubrum_block(
    klagername,
    [#klagerin_str, #klagerin_plz],
    beklagter,
    [#beklagter_str, #beklagter_plz],
  )

  v(0.5em)

  // --- Streitwert ---
  streitwert_block(streitwert)
  v(1.5em)

  // --- Anträge ---
  text(weight: "bold", size: 11pt)[Anträge:]
  v(0.5em)

  body

  // --- Datum ---
  v(2em)
  align(right)[#datetime.today().display("[day].[month].[year]")]

  // --- Unterschrift ---
  v(4em)
  line(length: 40%, stroke: 0.5pt)
  v(0.3em)
  [#klagername \
  Klägerin]

  // --- Anlagenverzeichnis ---
  anlagen_liste(anlagen, zeilenabstand)

  // --- Anlagen PDF (optional) ---
  if anlagen_pdf_path != none {
    pagebreak()
    for p in range(1, anlagen_max_pages + 1) {
      set page(margin: 0cm, header: none, footer: none)
      image(anlagen_pdf_path, page: p, width: 100%, height: 100%)
    }
  }
}
