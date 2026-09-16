#import "/src/utils.typ": line-height
#import "/src/elements/colors.typ": colors

#let fonts(doc, black-headlines: false) = {
  // RUNNING TEXT
  // https://intranet.tu-dresden.de/spaces/TUDMarke/pages/403965504/Schrift
  set text(
    font: "Noto Sans",
    weight: "regular",
    size: 10pt // 9pt is default size, but 10pt is more readable
  )

  // https://forum.typst.app/t/how-to-change-font-weight-associated-with-strong/2638/3
  set strong(delta: 0)
  show strong: set text(weight: "semibold")

  set par(
    leading: line-height(1.5em),
    spacing: line-height(1.5em) * 2,
    justify: true
  )
  
  // HEADLINES
  
  // weights
  // https://intranet.tu-dresden.de/spaces/TUDMarke/pages/403965504/Schrift
  show heading: set text(weight: "medium", font: "Noto Sans")
  show heading.where(level: 1): set text(weight: "semibold")

  // sizes
  show heading.where(level: 1): set text(size: 18pt) // 22pt
  show heading.where(level: 2): set text(size: 14pt) // 15pt
  show heading.where(level: 3): set text(size: 12pt) // 12pt

  
  show heading.where(level: 1): body => {
    if black-headlines == false {
      set text(fill: state("color-primary").get())
      body
    } else {
      body
    }
  }

  show heading.where(level: 2): body => {
    if black-headlines == false {
      set text(fill: state("color-primary").get())
      body
    } else {
      body
    }
  }

  show link: body => context {
    set text(fill: state("color-primary").get())
    body
  }

  // RAW
  show raw: set text(font: "Noto Sans Mono")

  // EQUATION
  show math.equation: set text(font: "Noto Sans Math")

  // QUOTES

  // style + weight
  // https://intranet.tu-dresden.de/spaces/TUDMarke/pages/403965504/Schrift
  set quote(block: true)
  show quote: it => {
    {
      set text(
        size: 15pt,
        font: "Noto Serif",
        weight: "light",
        style: "italic",
        fill: state("color-primary").get()
      )
      it.body
    }

    set text(weight: "semibold", fill: colors.gray-100)    
    if it.attribution != none [#v(-1em) #it.attribution #v(1em)]
  }

  // FIGURE CAPTIONS
  show figure.caption: set text(
    fill: colors.gray-100,
    size: 9pt,
    font: "Noto Serif"
  )
  show figure.caption: set align(left)

  // Footnote
  show footnote.entry: set text(size: 9pt) //

  doc
}