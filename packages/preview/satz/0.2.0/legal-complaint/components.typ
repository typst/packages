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

/// Render the provisional amount in dispute between two horizontal rules.
///
/// The value is printed after the fixed German label `vorläufiger Streitwert:`;
/// this helper does not parse, localize, or format the amount.
///
/// - streitwert (str): preformatted amount, for example `"600,00 EUR"`
/// -> content: ruled amount-in-dispute block
#let streitwert_block(streitwert) = {
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
  text(size: 10pt)[*vorläufiger Streitwert:* #streitwert]
  line(length: 100%, stroke: 0.5pt)
}

/// Render a German `Anlagen` list when attachments are present.
///
/// Empty arrays produce no heading or list. For a non-empty array, the helper
/// prints the fixed heading and each supplied item as one list entry. Callers
/// should number or describe each attachment in the provided string.
///
/// - anlagen (array of str): attachment labels or descriptions
/// - zeilenabstand (length): accepted for template compatibility; current
///   heading and list spacing use fixed values
/// -> content: attachment heading and list, or empty content
#let anlagen_liste(anlagen, zeilenabstand) = {
  if anlagen.len() > 0 {
    v(3em)
    text(weight: "bold", size: 10pt)[Anlagen:]
    v(0.3em)
    list(..anlagen.map(a => text(size: 9.5pt)[#a]))
  }
}

/// Render the claimant's sender details at the top right of a court filing.
///
/// The name and address use compact 8.5pt text and are right-aligned. This is a
/// court-document block rather than the DIN window-address layout used for the
/// recipient.
///
/// - name (str): claimant or sender name
/// - adresse (content): address lines, usually street and city
/// - zeilenabstand (length): accepted for template compatibility; current text
///   line spacing follows Typst's surrounding paragraph settings
/// -> content: compact, right-aligned sender block
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
