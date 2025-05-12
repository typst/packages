#let affidavit(
  background,
  lastName,
  firstName,
  title,
  place,
  date,
  titleSize
) = {
  set page(margin: (top: 10cm), background: background)

  heading(outlined: false, numbering: none)[Eidesstattliche Versicherung]

  v(0.3cm)
  stack(
    spacing: 2mm,
    [#lastName, #firstName],
    line(length: 100%, stroke: 0.5pt),
    [#text(8pt)[Name, Vorname /\/ Name, First Name]]
  )
  v(0.3cm)

  set text(11pt)

  [Ich versichere hiermit an Eides statt, dass ich die vorliegende Abschlussarbeit mit dem Titel]

  v(-10pt)
  text(titleSize, hyphenate: true)[*#title*]
  v(-10pt)

  [selbstständig und ohne unzulässige fremde Hilfe erbracht habe. Ich habe keine anderen als die angegebenen Quellen und Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate kenntlich gemacht. Die Arbeit hat in gleicher oder ähnlicher Form noch keine Prüfungsbehörde vorgelegen.]

  v(0.7cm)
  stack(
    spacing: 2mm,
    [#place, am #date.display("[day].[month].[year]"),],
    line(length: 100%, stroke: 0.5pt),
    [#text(8pt)[Ort, Datum, Unterschrift /\/ Place, Date, Signature]],
  )
}
