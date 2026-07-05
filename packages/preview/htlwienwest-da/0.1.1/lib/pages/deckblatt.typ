#import "../assertions.typ": *
#import "../settings.typ" as settings

#let deckblatt(title, abteilung, schuljahr, teilnehmer) = {  
  set page(margin: (left: 3cm, bottom: 3cm, top: 1cm))
  
  let gutter = 3mm
  let img_height = 3.81cm
  let headline = grid(
    columns: (1fr, auto, auto),
    align: (right),
    column-gutter: gutter,
    {
      set text(16pt, hyphenate: false)
      set par(leading: 12pt, justify: false)
      v(1mm)
      grid(
        row-gutter: 6mm,
        [
          HÖHERE TECHNISCHE\
          BUNDESLEHRANSTALT WIEN 16
        ],
        block(width: 100% + 0.5cm,
          text(font: settings.FONT_ACCENT)[
            Abteilung für #abteilung
          ]
        )
      )
      
    },
    line(length: img_height, angle: 90deg, stroke: 0.8pt),
    image("../images/HTLWienWest.png", height: img_height)
  )

  
  headline


  set align(center)

  v(3cm)
  text(36pt)[DIPLOMARBEIT]
  v(2cm)
  block(
    width: 12cm,
    par(leading: 20pt, justify: false, 
      text(36pt, title)
    )
  )
  v(0.5cm)
  text(18pt)[Ausgeführt im Schuljahr #schuljahr]

  set text(11pt)
  
  place(bottom,
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      row-gutter: 0.5cm,
      ..teilnehmer
        .map((e) => {
          let betreuer_suffix = if e.betreuer.geschlecht == "female" {
            "In"
          } else {
            ""
          }
          ([#e.vorname #e.nachname (#e.klasse)], [Betreuer#betreuer_suffix: #e.betreuer.name])
        })
        .flatten(),
    )

  )

}
