// Legal complaint components — shared rendering for ZPO Klageschrift templates.

/// The Rubrum — who sues whom.
///
/// Plaintiff, "— Klägerin —", "gegen", defendant, "— Beklagter —".
///
/// - klagername (str): who sues
/// - klagerin_adresse (content): their address
/// - beklagter (str): who gets sued
/// - beklagter_adresse (content): their address
#let rubrum_block(
  klagername,
  klagerin_adresse,
  beklagter,
  beklagter_adresse
) = {
  text(size: 10pt)[
    #text(weight: "bold")[#klagername] \
    #klagerin_adresse \
    \
    — Klägerin — \
    \
    #text(weight: "bold")[gegen] \
    \
    #text(weight: "bold")[#beklagter] \
    #beklagter_adresse \
    \
    — Beklagter —
  ]
}

/// How much the case is about — between two lines.
///
/// - streitwert (str): e.g. "600,00 EUR"
#let streitwert_block(streitwert) = {
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
  text(size: 10pt)[*vorläufiger Streitwert:* #streitwert]
  line(length: 100%, stroke: 0.5pt)
}

/// List your attachments.
///
/// Skips if you have none.
///
/// - anlagen (array): your Anlagen as strings
/// - zeilenabstand (length): space before the list
#let anlagen_liste(anlagen, zeilenabstand) = {
  if anlagen.len() > 0 {
    v(3em)
    text(weight: "bold", size: 10pt)[Anlagen:]
    v(0.3em)
    list(..anlagen.map(a => text(size: 9.5pt)[#a]))
  }
}

/// Your address at the top right — smaller than in a normal letter.
///
/// - name (str): your name
/// - adresse (content): street + city
/// - zeilenabstand (length): line spacing
#let court_absender_block(name, adresse, zeilenabstand) = {
  align(right, text(size: 8.5pt)[
    #name \
    #adresse
  ])
}

/// The court address for the window envelope.
///
/// Tiny return line on top, court address below.
///
/// - return_name (str): name in the tiny return line
/// - return_adresse (content): address in the tiny return line
/// - empfaenger_name (str): court name
/// - empfaenger_adresse (content): court address
#let court_empfaenger_block(return_name, return_adresse, empfaenger_name, empfaenger_adresse) = {
  block(width: 85mm)[
    #text(size: 7.5pt, fill: black)[#return_name · #return_adresse]
    #v(-2.5mm)
    #line(length: 100%, stroke: 0.25pt + black)
    #v(1.5mm)
    #text(size: 11pt)[
      #empfaenger_name \
      #empfaenger_adresse
    ]
  ]
}
