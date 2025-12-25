#import "../languages.typ": getText

#let affidavit(
  background,
  last-name,
  first-name,
  title,
  place-location,
  date,
  title-size,
  signature,
  language: "de",
) = {
  set page(margin: (top: 10cm), background: background)

  heading(outlined: false, numbering: none)[#getText("affidavit", language)]

  v(0.3cm)
  stack(
    spacing: 2mm,
    [#last-name, #first-name],
    line(length: 100%, stroke: 0.5pt),
    [#text(8pt)[#getText("nameFirstName", language)]],
  )
  v(0.3cm)

  set text(11pt)

  [#getText("affidavitText", language)]

  v(-10pt)
  text(title-size, hyphenate: true)[*#title*]
  v(-10pt)

  [#getText("affidavitDeclaration", language)]

  v(0.7cm)
  stack(
    spacing: 2mm,
    [#place-location, am #date.display("[day].[month].[year]"),],
    line(length: 100%, stroke: 0.5pt),
    if (signature != none) {
      [#place(
          top + left,
          dx: 300pt,
          dy: -50pt,
          signature,
        )]
    },
    [#text(8pt)[#getText("placeDateSignature", language)]],
  )
}
