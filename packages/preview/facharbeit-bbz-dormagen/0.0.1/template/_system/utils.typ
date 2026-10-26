// =======================================================================
// DATEI: utils.typ
// ZWECK: Unsichtbare Hilfsfunktionen und Parser-Logik
// =======================================================================

// Hilfsfunktion zum Parsen von Breitenangaben (z.B. "80%" -> 80%)
#let parse-breite(b) = {
  if type(b) == ratio or type(b) == length or b == auto { return b }
  if type(b) == int or type(b) == float { return b * 1% }
  if type(b) == str {
    let s = b.replace(",", ".").replace(" ", "").replace("%", "")
    return float(s) * 1%
  }
  return auto
}

// Makro für DIN-A3 Seiten (Querformat) im Anhang.
// Sorgt dafür, dass die Seite als A3-Seite eingefügt wird und
// positioniert die Seitenzahl so, dass sie beim Falten auf A4-Größe
// exakt an der gleichen Stelle erscheint wie bei regulären A4-Seiten (in der linken Hälfte).
#let a3-seite(body) = {
  set page(paper: "a3", flipped: true, footer: context {
    grid(
      columns: (210mm, 1fr),
      align(center)[
        #set text(size: 10pt)
        #counter(page).display()
      ],
      []
    )
  })
  body
}
