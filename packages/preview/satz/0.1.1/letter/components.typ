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

/// The ref line above the subject.
///
/// Each column is a (label, value) pair. We tack the
/// date on as the last column, right-aligned.
///
/// - geschaeftszeile (array): your columns as (("Label", "Value"), ...)
/// - datum (str): date — lands in the last column
/// - zeilenabstand (length): line spacing
/// - strings (dictionary): translated "Datum"
#let geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings) = {
  block(width: 100%)[
    #let alle_posten = geschaeftszeile + ((strings.datum, datum),)
    #let spalten_anzahl = alle_posten.len()
    
    #let bloecke = alle_posten.enumerate().map(((i, pair)) => {
      let text_ausrichtung = if i == spalten_anzahl - 1 { right } else { left }
      block(align(text_ausrichtung)[
        #text(size: 7.5pt)[#pair.at(0)] \
        #text(size: 9pt)[#pair.at(1)]
      ])
    })
    
    #stack(dir: ltr, spacing: 1fr, ..bloecke)
  ]
}

/// A line to sign, then your name under it.
///
/// Add `zusatz` if you want a title or department below.
///
/// - name (str): your name
/// - zusatz (str): extra line (e.g. your title)
/// - zeilenabstand (length): line spacing
#let signatur_block(name, zusatz, zeilenabstand) = {
  v(5 * zeilenabstand)
  line(length: 40%, stroke: 0.5pt + black)
  v(1 * zeilenabstand)
  name
  if zusatz != "" {
    v(0.3em)
    text(size: 9pt)[#zusatz]
  }
}
