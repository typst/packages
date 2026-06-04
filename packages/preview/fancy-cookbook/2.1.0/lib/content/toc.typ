#import "../assets/fonts.typ": *
#import "../i18n/i18n.typ": translate
#import "../i18n/translations.typ": i18n-words 


#let toc(palette) = {
  page(header: none)[
    #v(3cm)
    #align(center)[
       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, upper(translate(i18n-words.toc)))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + palette.dark)
    ]
    #v(1.5cm)
    
    #show outline.entry: it => {
      context {
        if it.level == 1 {
            align(center)[
              #box(width:70%)[
              // Section / Chapter Header
              #v(1.5em)
              #text(font: fonts.header, weight: "black", fill: palette.dark, size: 1.3em, upper(it.element.body))
              #h(1fr)
              // No page number for chapters, looks cleaner
              ]
            ]
          } else {
            align(center)[
              // Recipe Entry
              #v(0.5em)
              #box(width: 65%)[
                #link(it.element.location())[
                  #text(font: fonts.body, size: 1.1em, it.element.body)
                  #box(width: 1fr, repeat[ #h(0.3em) #text(fill: palette.dark, size: 0.6em)[.] #h(0.3em) ])
                  #text(font: fonts.header, weight: "bold", fill: palette.dark, [#it.element.location().page()])
                ]
              ]
            ]
          }
      }
    }
    #outline(title: none, indent: 0pt, depth: 2)
  ]
}
