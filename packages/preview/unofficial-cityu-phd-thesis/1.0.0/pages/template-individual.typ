#import "../utils/fonts.typ": thesis_font_size, thesis_font
#import "../utils/datetime-display.typ": datetime-display
#import "../utils/twoside.typ": twoside-pagebreak

#let template-individual(
  outlined: false,
  titlelevel: 2,
  pagetitle,
  s,
) = {

  context {
    twoside-pagebreak
    set text(font: thesis_font.times)

    align(
      left,
      text(size: thesis_font_size.lllarge, weight: "bold")[
        #show heading: x => x.body
        #heading(pagetitle, numbering: none, level: titlelevel, outlined: outlined)
        #v(1em)
      ],
    )

    block(width: 100%)[
      #set par(justify: true)
      #set text(size: thesis_font_size.small)
      #s
    ]

  }
}
