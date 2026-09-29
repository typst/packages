#import "components.typ": absender_block, empfaenger_block, geschaeftszeile_block, signatur_block
#import "layout.typ": falz_und_locher_marken, seiten_footer

/// A German business letter — DIN 5008, with fold and punch marks.
///
/// Fits window envelopes. The address field lands right where the window sits.
/// Set `lang` to "de" or "en" to switch languages.
///
/// - absender (dictionary): your details
///   - name (str): your name or company
///   - zusatz (none, str): extra line if you need it (e.g. c/o)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - telefon (str): phone (optional)
///   - email (str): email (optional)
///   - logo (none, content): e.g. `image("logo.pdf", width: 3cm)`
/// - empfaenger (dictionary): who gets the letter
///   - name (str): name or company
///   - zusatz (str, none): extra line (e.g. c/o, z.Hd.)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - land (str): country (for international mail)
/// - datum (str): date — defaults to today (YYYY-MM-DD)
/// - geschaeftszeile (array): ref line as (("Label", "Value"), ...)
/// - betreff (str): subject line
/// - postvermerk (str): postal note like "Einschreiben"
/// - anlagenverzeichnis (array): what you attach (just the names)
/// - anlagen (array): PDFs to include inline
/// - signatur_zusatz (str): extra line under your name
/// - lang (str): "de" or "en"
/// - font (str): body font — defaults to "Inter"
/// - body (content): your letter text
#let brief(
  absender: (name: "", zusatz: none, strasse: "", plz_ort: "", telefon: "", email: "", logo: none),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[year]-[month]-[day]"),
  geschaeftszeile: (),
  betreff: "",
  anlagenverzeichnis: (),
  anlagen: (),
  signatur_zusatz: "",
  signatur: true,
  postvermerk: "",
  lang: "de",
  font: "Inter",
  body
) = {
  // Ensure optional keys exist in absender and empfaenger (callers may omit them)
  let absender = (telefon: "", email: "", zusatz: none, ..absender)
  let empfaenger = (zusatz: none, land: "", ..empfaenger)
  let zeilenabstand = 0.65em
  
  let strings = if lang == "de" {
    (
      tel: "Tel.",
      email: "E-Mail",
      datum: "Datum",
      anlagen: "Anlagen",
      betreff: betreff,
      page: "Seite",
      of: "von",
    )
  } else {
    (
      tel: "Phone",
      email: "Email",
      datum: "Date",
      anlagen: "Attachments",
      betreff: if betreff == "" { "Subject" } else { betreff },
      page: "Page",
      of: "of",
    )
  }
  
  // Stile konfigurieren
  set text(font: font, size: 11pt, lang: lang, hyphenate: false, weight: "regular")
  set par(leading: zeilenabstand, justify: true)
  set list(spacing: zeilenabstand)
  set page(
    "a4",
    margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
    background: falz_und_locher_marken(),
    footer: seiten_footer(strings),
  )

  // Heading show rules — headings match body size (11pt), only differ by weight/style.
  // This keeps the Betreff (11.5pt bold) as the visually dominant element per DIN 5008.
  show heading.where(level: 1): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 2): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 3): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 4): it => block(below: 0.65em)[
    #set text(weight: "italic", size: 11pt)
    #it
  ]

  // Dokumentenstruktur aufbauen
  absender_block(absender, zeilenabstand, strings)
  v(3 * zeilenabstand)
  
  empfaenger_block(absender, empfaenger, postvermerk, strings)
  v(4 * zeilenabstand)
  
  geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings)
  v(2 * zeilenabstand)

  block(width: 100%)[
    #set text(weight: "bold", size: 11.5pt)
    #betreff
  ]
  v(2 * zeilenabstand)

  // Inhalt aus main.typ
  body
  
  // Abschluss-Segmente
  if signatur {
    signatur_block(absender.name, signatur_zusatz, zeilenabstand)
  }

  if anlagen.len() > 0 {
    v(3 * zeilenabstand)
    block(breakable: false, [
      #text(weight: "bold", size: 10pt)[#strings.anlagen:] \
      #v(0.5em)
      #list(..anlagen.map(a => text(size: 9.5pt)[#a]))
    ])
    
    // PDF-Anhänge rendern
    for pdf_pfad in anlagen {
      set page(margin: 0mm, background: none, header: none, footer: none)
      image(pdf_pfad, width: 100%, height: 100%)
    }
  }  
}
