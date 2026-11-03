#import "@preview/datify:1.0.1": *
#import "../colors/colors.typ": *
#import "../assets/fonts.typ": *
#import "../i18n/i18n.typ": language-state

#let cover-image = image.with(
    width: 100%,
    height: 60%,
    fit: "cover"
  )

#let cover(title, subtitle, date, palette, cover-image) = {
  page(margin: 0pt, header: none)[
    // Optional Background Image
    #if cover-image != none {
      place(top, cover-image)
    }
    
    #place(center + horizon)[
      #block(
         width: 75%, 
         stroke: (
           top: 4pt + palette.dark, 
           bottom: if cover-image == none { 4pt + palette.dark } else { none }
         ), 
         inset: (y: 3em),
         fill: if cover-image != none { palette.light } else { none },
         outset: if cover-image != none { 1cm } else { 0cm }
      )[
        #par(leading: 0.35em)[
          #text(font: fonts.header, weight: "black", size: 4.5em, title)
        ]
        #v(1.5em)
        #text(font: fonts.body, style: "italic", size: 1.5em, fill: palette.dark, subtitle)
      ]
    ]
    #context {
      place(bottom + center)[
         #pad(bottom: 3cm, text(font: fonts.header, size: 0.8em, tracking: 3pt, fill: palette.dark, upper(custom-date-format(date, pattern: "MMMM yyyy", lang: language-state.get()))))
      ]
    }
  ]
}  