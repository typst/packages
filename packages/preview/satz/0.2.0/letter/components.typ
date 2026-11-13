/// Show the sender at the top.
///
/// Logo on the left, address on the right.
/// No logo? We just push the address to the right.
///
/// - absender (dictionary): your name, address, phone, email, logo
/// - zeilenabstand (length): how tight the lines sit
/// - strings (dictionary): translated "Tel." / "E-Mail"
#let absender_block(absender, zeilenabstand, strings) = {
  let logo = absender.at("logo", default: none)
  let telefon = absender.at("telefon", default: "")
  let email = absender.at("email", default: "")
  let zusatz = absender.at("zusatz", default: none)

  block(width: 100%, height: 2.8cm, clip: true)[
    #if logo != none {
      // Logo left, sender info right
      grid(
        columns: (auto, 1fr),
        gutter: 2em,
        align(top + left)[#logo],
        align(right, text(size: 9pt)[
          #absender.name \
          #if zusatz != none and zusatz != "" [
            #zusatz \
          ]
          #absender.strasse \
          #absender.plz_ort \
          #if telefon != "" [
            #strings.tel: #telefon \
          ]
          #if email != "" [
            #strings.email: #link("mailto:" + email)[#email]
          ]
        ]),
      )
    } else {
      // No logo — sender info right-aligned (classic)
      align(right, text(size: 9pt)[
        #absender.name \
        #if zusatz != none and zusatz != "" [
          #zusatz \
        ]
        #absender.strasse \
        #absender.plz_ort \
        #if telefon != "" [
          #strings.tel: #telefon \
        ]
        #if email != "" [
          #strings.email: #link("mailto:" + email)[#email]
        ]
      ])
    }
  ]
}

/// Render a compact sender header for a digital letter.
///
/// Unlike the postal sender block, this version does not reserve a window
/// envelope address area. It aligns the sender information to the right and
/// omits empty name, email, or website fields. Email and website values become
/// clickable links.
///
/// - absender (dictionary): sender record with optional `name`, `email`, and
///   `website` strings
/// - hoehe (length): reserved block height; defaults to `19mm`
/// -> content: right-aligned sender details
#let digitaler_absender_block(absender, hoehe: 19mm) = {
  let name = absender.at("name", default: "")
  let email = absender.at("email", default: "")
  let website = absender.at("website", default: "")

  block(width: 100%, height: hoehe)[
    #align(right)[
      #if name != "" [#text(size: 12pt, weight: "bold")[#name] #linebreak()]
      #if email != "" [#text(size: 9pt)[#link("mailto:" + email)[#email]] #linebreak()]
      #if website != "" [#text(size: 9pt)[#link("https://" + website)[#website]]]
    ]
  ]
}

/// The address window for envelopes.
///
/// 85 mm wide, sits where the window sits. Shows your
/// name on top in small type, then the recipient's address.
/// Add a postal note like "Einschreiben" if you need it.
///
/// - absender (dictionary): your details (for the tiny line on top)
/// - empfaenger (dictionary): who it goes to
/// - postvermerk (str): postal note (optional)
/// - strings (dictionary): translations
#let empfaenger_block(absender, empfaenger, postvermerk, strings) = {
  // DIN 5008: address field for window envelope
  // Window position: 45mm from top, 20mm from left, 85mm × 45mm
  // The page top margin (25mm) + preceding content positions this correctly.
  // Verify with actual window envelope before production use.
  block(width: 85mm)[
    // Small sender reference line above the address
    #if absender.name != "" [
      #text(size: 7pt, fill: black)[
        #absender.name · #if absender.zusatz != none and absender.zusatz != "" { absender.zusatz + " · " } #absender.strasse · #absender.plz_ort
      ]
      #v(-2.5mm)
      #line(length: 100%, stroke: 0.25pt + black)
      #v(1.5mm)
    ]
    // Postal remark (Versendungsvermerk) — right-aligned above recipient
    #if postvermerk != "" [
      #text(weight: "bold", size: 10pt)[#postvermerk]
      #v(0.3em)
    ]
    // Recipient address
    #text(size: 11pt)[
      #if empfaenger.name != "" [
        #empfaenger.name
        \
      ]
      #if empfaenger.zusatz != none and empfaenger.zusatz != "" [
        #empfaenger.zusatz
        \
      ]
      #if empfaenger.strasse != "" [
        #empfaenger.strasse
        \
      ]
      #if empfaenger.plz_ort != "" [
        #empfaenger.plz_ort
      ]
      #if empfaenger.land != "" [
        \
        #empfaenger.land
      ]
    ]
  ]
}

/// Render a digital recipient address without postal-envelope decoration.
///
/// The block uses the full available width and prints each populated address
/// field on its own line. It does not add the sender return line, postal mark,
/// or fixed-size envelope window used by `empfaenger_block`.
///
/// - empfaenger (dictionary): recipient fields `name`, `zusatz`, `strasse`,
///   `plz_ort`, and `land`; absent or empty fields are omitted
/// -> content: recipient address block
#let digitaler_empfaenger_block(empfaenger) = {
  let name = empfaenger.at("name", default: "")
  let zusatz = empfaenger.at("zusatz", default: none)
  let strasse = empfaenger.at("strasse", default: "")
  let plz_ort = empfaenger.at("plz_ort", default: "")
  let land = empfaenger.at("land", default: "")

  block(width: 100%)[
    #text(size: 11pt)[
      #if name != "" [#name #linebreak()]
      #if zusatz != none and zusatz != "" [#zusatz #linebreak()]
      #if strasse != "" [#strasse #linebreak()]
      #if plz_ort != "" [#plz_ort #linebreak()]
      #if land != "" [#land]
    ]
  ]
}

/// The reference line above the subject.
///
/// Each column is a (label, value) pair. When supplied, the date is appended
/// as the final, right-aligned column.
///
/// - geschaeftszeile (array): your columns as (("Label", "Value"), ...)
/// - datum (str, none): date for the final column; `none` omits that column
/// - zeilenabstand (length): line spacing
/// - strings (dictionary): translated "Datum"
#let geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings, show-date-label: true) = {
  block(width: 100%)[
    #let alle_posten = if datum == none {
      geschaeftszeile
    } else {
      geschaeftszeile + ((strings.datum, datum),)
    }
    #let spalten_anzahl = alle_posten.len()

    #let bloecke = alle_posten.enumerate().map(((i, pair)) => {
      let text_ausrichtung = if i == spalten_anzahl - 1 { right } else { left }
      block(align(text_ausrichtung)[
        #if datum == none or i != spalten_anzahl - 1 or show-date-label [#text(size: 7.5pt)[#pair.at(0)] \
        ]
        #text(size: 9pt)[#pair.at(1)]
      ])
    })

    #stack(dir: ltr, spacing: 1fr, ..bloecke)
  ]
}

/// Render the date at the right edge of a digital letter.
///
/// The optional translated date label can be hidden while retaining the date
/// value. This block intentionally does not render the business reference-line
/// fields handled by `geschaeftszeile_block`.
///
/// - datum (str): formatted date text
/// - strings (dictionary): translated `datum` label
/// - show-label (bool): whether to show the date label; defaults to `true`
/// -> content: right-aligned label and date
#let digitales_datum_block(datum, strings, show-label: true) = align(right)[
  #if show-label [#text(size: 7.5pt)[#strings.datum] \
  ]
  #text(size: 9pt)[#datum]
]

/// A line to sign, then your name under it.
///
/// Add `zusatz` if you want a title or department below.
///
/// - name (str): your name
/// - zusatz (str): extra line (e.g. your title)
/// - zeilenabstand (length): line spacing
#let signatur_block(name, zusatz, zeilenabstand, davor) = {
  v(davor)
  line(length: 40%, stroke: 0.5pt + black)
  v(1 * zeilenabstand)
  name
  if zusatz != "" {
    v(0.3em)
    text(size: 9pt)[#zusatz]
  }
}
