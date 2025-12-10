#import "locale.typ": *

#let titlepage(
  language,
  matricola,
  titolo,
  relatore,
  tutor,
  azienda,
  anno_accademico,
  dipartimento,
  corso,
  codice_corso,
  autore,

) = {
  // ---------- Page Setup ---------------------------------------

  let page-grid = 10pt
  
  // The whole page in `title-font`, all elements centered
  // set text( size: page-grid)
  set align(center)

  place(
    top + center,
    box(image("uninsubria-logo.png"), width: 100pt)
  )

  // ---------- Title ---------------------------------------

  v(21 * page-grid)


  set text(size: 20pt, weight: "semibold")
  place(
    center,
    dy: -7 * page-grid,
    "UNIVERSITÀ DEGLI STUDI DELL'INSUBRIA",
  )

  set text(size: 16pt, weight: "regular")
  place(
    center,
    dy: -4 * page-grid,
    dipartimento
  )

  set text(size: 16pt)
  place(
    center,
    dy: -2.5 * page-grid,
    corso + " - " + codice_corso,
  )

  v(15 * page-grid)

  set text(size: 28pt, weight: "bold")
  place(
    center,
    dy: -1 * page-grid,
    text(titolo),
  )


  v(21 * page-grid)

  set text(size: 12pt, weight: "light")
  place(
    left,
    // dy: 2 * page-grid,
    text("Relatore:", weight: "bold") +
    text("\nProf. " + relatore),
  )

  place(
    right,
    dy: 2 * page-grid,
    text("Tesi di Laurea di:", weight: "bold") +
    text("\n" + autore + " - " + matricola),
  )

  place(
    left,
    dy: 5 * page-grid,
    text("Tutor Aziendale:", weight: "bold") +
    text("\n" + tutor),
  )

  place(
    right,
    dy: 5 * page-grid,
    text("Azienda ospitante:", weight: "bold") +
    text("\n" + azienda),
  )

  place(
    center,
    dy: 8 * page-grid,
    text("Anno Accademico:", weight: "bold") +
    text("\n" + anno_accademico),
  )
}
