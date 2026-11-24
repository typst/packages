// Klageschrift template — ZPO-compliant civil complaint (Amtsgericht).
//
// Uses a wider right margin (35mm) for judicial binding margins.
// Includes Rubrum, Streitwert, Anträge section, and attachment list.

#import "components.typ": rubrum_block, streitwert_block, anlagen_liste, court_absender_block, court_empfaenger_block
#import "../input.typ": select-alias

/// A German civil complaint (*Klageschrift*) for the Amtsgericht.
///
/// English names are the canonical interface; German argument names remain as
/// compatibility aliases. The rendered complaint stays German. It provides the
/// Rubrum, Streitwert, a place for your claims and reasoning, the signature
/// block, and the exhibit list. The layout uses a wider right margin for the
/// court file.
///
/// ```example
/// #show: complaint.with(
///   court: "Amtsgericht Musterstadt",
///   court-address: "Gerichtsstraße 1, 12345 Musterstadt",
///   plaintiff: "Alex Example",
///   plaintiff-street: "Example Street 1",
///   plaintiff-postal-code-city: "12345 Example City",
///   defendant: "Robin Sample",
///   defendant-street: "Sample Road 2",
///   defendant-postal-code-city: "54321 Sample City",
///   amount-in-dispute: "1.000,00 EUR",
///   exhibits: ("Exhibit K 1: Contract",),
/// )
/// = Anträge
/// ...
/// ```
///
/// - court (str): court name; defaults to `"Amtsgericht"`
/// - court-address (str): court street and postal code; defaults to empty
/// - plaintiff (str): party bringing the claim; defaults to empty
/// - plaintiff-street (str): plaintiff street and number; defaults to empty
/// - plaintiff-postal-code-city (str): plaintiff postal code and city; defaults to empty
/// - defendant (str): party being sued; defaults to empty
/// - defendant-street (str): defendant street and number; defaults to empty
/// - defendant-postal-code-city (str): defendant postal code and city; defaults to empty
/// - amount-in-dispute (str): Streitwert as display text, e.g. `"600,00 EUR"`; defaults to empty
/// - exhibits (array of str): exhibit labels for the Anlagenverzeichnis; defaults to empty
/// - exhibits-pdf (str, none): PDF to append after the complaint; `none` skips it
/// - exhibit-page-limit (int): maximum PDF pages to append; defaults to 30. This
///   is not a truncation limit, so it must not exceed the PDF's actual page count
/// - date (str, none): filing date. Omitting it uses the compilation date as
///   `DD.MM.YYYY`; set it explicitly for a reproducible filing
/// - plaintiff-designation (str): signature-block role; defaults to `"Kläger/in"`
/// - font (str): body font family; defaults to `"Inter"`
/// - body (content): claims and reasoning after the Anträge heading
///
/// German aliases: `gericht`, `gericht_ort`, `klagername`, `klagerin_str`,
/// `klagerin_plz`, `beklagter`, `beklagter_str`, `beklagter_plz`, `streitwert`,
/// `anlagen`, `anlagen_pdf_path`, `anlagen_max_pages`, and `datum`. Supplying
/// both spellings of the same value produces a field-specific conflict error.
#let klageschrift(
  gericht: none,
  gericht_ort: none,
  klagername: none,
  klagerin_str: none,
  klagerin_plz: none,
  beklagter: none,
  beklagter_str: none,
  beklagter_plz: none,
  streitwert: none,
  anlagen: none,
  anlagen_pdf_path: none,
  anlagen_max_pages: none,
  datum: none,
  court: none,
  court-address: none,
  plaintiff: none,
  plaintiff-street: none,
  plaintiff-postal-code-city: none,
  defendant: none,
  defendant-street: none,
  defendant-postal-code-city: none,
  amount-in-dispute: none,
  exhibits: none,
  exhibits-pdf: none,
  exhibit-page-limit: none,
  date: none,
  plaintiff-designation: none,
  font: "Inter",
  body,
) = {
  let gericht = select-alias(gericht, court, "gericht", "court", "Amtsgericht")
  let gericht_ort = select-alias(gericht_ort, court-address, "gericht_ort", "court-address", "")
  let klagername = select-alias(klagername, plaintiff, "klagername", "plaintiff", "")
  let klagerin_str = select-alias(klagerin_str, plaintiff-street, "klagerin_str", "plaintiff-street", "")
  let klagerin_plz = select-alias(klagerin_plz, plaintiff-postal-code-city, "klagerin_plz", "plaintiff-postal-code-city", "")
  let beklagter = select-alias(beklagter, defendant, "beklagter", "defendant", "")
  let beklagter_str = select-alias(beklagter_str, defendant-street, "beklagter_str", "defendant-street", "")
  let beklagter_plz = select-alias(beklagter_plz, defendant-postal-code-city, "beklagter_plz", "defendant-postal-code-city", "")
  let streitwert = select-alias(streitwert, amount-in-dispute, "streitwert", "amount-in-dispute", "")
  let anlagen = select-alias(anlagen, exhibits, "anlagen", "exhibits", ())
  let anlagen_pdf_path = select-alias(anlagen_pdf_path, exhibits-pdf, "anlagen_pdf_path", "exhibits-pdf", none)
  let anlagen_max_pages = select-alias(anlagen_max_pages, exhibit-page-limit, "anlagen_max_pages", "exhibit-page-limit", 30)
  let datum = select-alias(datum, date, "datum", "date", datetime.today().display("[day].[month].[year]"))
  let plaintiff-designation = if plaintiff-designation == none { "Kläger/in" } else { plaintiff-designation }
  for (field, value) in (
    ("court", gericht), ("court-address", gericht_ort), ("plaintiff", klagername),
    ("plaintiff-street", klagerin_str), ("plaintiff-postal-code-city", klagerin_plz),
    ("defendant", beklagter), ("defendant-street", beklagter_str),
    ("defendant-postal-code-city", beklagter_plz), ("amount-in-dispute", streitwert),
    ("date", datum), ("plaintiff-designation", plaintiff-designation), ("font", font),
  ) {
    assert(type(value) == str, message: "Complaint field `" + field + "` must be a string.")
  }
  assert(type(anlagen) == array and anlagen.all(a => type(a) == str),
    message: "Complaint `exhibits` must be an array of strings.")
  assert(anlagen_pdf_path == none or type(anlagen_pdf_path) == str,
    message: "Complaint `exhibits-pdf` must be a string or none.")
  assert(type(anlagen_max_pages) == int and anlagen_max_pages > 0,
    message: "Complaint `exhibit-page-limit` must be a positive integer.")
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
  align(right)[#datum]

  // --- Unterschrift ---
  v(4em)
  line(length: 40%, stroke: 0.5pt)
  v(0.3em)
  [#klagername \
  #plaintiff-designation]

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
