#import "@preview/hydra:0.6.2": hydra

#let playwright(
  title: "A Play by You",
  descriptor: "A Play in Two Acts",
  authors: (),
  contact: none,
  paper-size: "a4",
  font: none,
  body
) = {
  set page(
    paper: paper-size,
    margin: 1in,
    numbering: "1",
    number-align: top + right,
    header: context align(
      right, 
      hydra(
        2, 
        skip-starting: false,
        use-last: true,
        display: (_, it) => {
          numbering(it.numbering, ..counter(heading).at(it.location()))
          str(counter(page).get().first())
        }
      )
    )
  )

  // Font Stack for graceful decay depending on what font is present on the user's system.
  // 
  // We fall back on to DejaVu Sans Mono as it's monospaced and default included with typst CLI/web as well
  let fonts = ("Courier Prime", "Courier", "Courier Screenplay", "Courier New", "Times New Roman", "Arial", "DejaVu Sans Mono")
  
  if font != none and type(font) == str {
    fonts.insert(0, font)
  }

  set text(
    font: fonts,
    size: 12pt
  )

  page(numbering: none, header: none)[
    #align(center)[
      #context {
        v(1in)
        title

        let title-size = measure(title)
        let descriptor-size = measure(descriptor)
        let size = calc.max(title-size.width, descriptor-size.width)
        line(length: size + 50pt)

        descriptor

        block(width: size)[
          By
          #if authors.len() <= 2 {
            authors.join(" and ")
          } else {
            authors.join(", ", last: " and ")
          }
        ]
      }
    ]

    #v(1fr)
    
    #if contact != none {
      align(right, block[
        #set align(left)
        #contact
      ])
    }
  ]

  counter(page).update(1)

  set heading(numbering: "I - 1 - ")

  show heading: set text(font: fonts, size: 12pt, weight: "regular")
  show heading: set align(center)
  
  show heading.where(level: 1): set heading(supplement: [Act])
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    underline(it.body)
  }

  show heading.where(level: 2): set heading(supplement: [Scene])
  show heading.where(level: 2): it => {
    let last-act = query(heading.where(level: 1).before(here())).last().location()
    let h2s = query(heading.where(level: 2).before(here(), inclusive: false).after(last-act))
    if h2s != () {
      pagebreak(weak: true)
    }

    underline(it.body)
  }

  body
}

#let last-speaker = state("last-speaker", none)
#let in-dialogue = state("in-dialogue", false)

#let dialogue-parenthetical(body) = align(center, block(spacing: 0.65em)[(#body)])


#let dialogue(speaker, parenthetical: none, body) = context {
  in-dialogue.update(true)

  align(center)[
    #upper(speaker)
    #if last-speaker.get() == speaker [ (CONT.) ]
    #if parenthetical != none [
      #if parenthetical.contains(regex("\s+")) [\ ]
      (#parenthetical)
    ]
  ]
  block(above: 0.65em, body)

  in-dialogue.update(false)
  last-speaker.update(speaker)
}

#let action(body) = context {
  if in-dialogue.get() {
    align(center, block(spacing: 0.65em)[(#body)])
  } else {
    align(right, block(width: 50%)[
      #set align(left)

      #body
    ])
  }
}