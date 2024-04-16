#import "font.typ" as fonts

// headings
#show heading.where(level: 1): it =>{
  set text(
    font: fonts.HeiTi,
    size: fonts.No3,
    weight: "regular",
  )
  align(center)[
    #strong(it)
  ]
  text()[#v(0.5em)]
}

#show heading.where(level: 2): it =>{
  set text(
    font: fonts.HeiTi,
    size: fonts.No4,
    weight: "regular"
    )
  it
  text()[#v(0.5em)]
}

#show heading.where(level: 3): it =>{
  set text(
    font: fonts.HeiTi,
    size: fonts.No4-Small,
    weight: "regular"
    )
  it
  text()[#v(0.5em)] 
}

// paragraph
#set par(
  justify: true,
  first-line-indent: 2em,
  leading: 1.5em)

// bibograph
#show bibliography: bib => {
  show heading: title => {}
  
  align(center)[
    #strong()[
      #text(
      font: fonts.HeiTi,
      size: fonts.No3,
    )[#bib.title]
    ]
  ]
  v(1em)
  set text(
    font: fonts.SongTi,
    size: fonts.No5,
  )
  bib
}

#include "../sections/content.typ"

#pagebreak()

#show heading.where(level: 1): it => {
  set align(center)
  set text(
    font: fonts.HeiTi,
    size: fonts.No3,
  )
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  set align(left)
  set text(
    font: fonts.HeiTi,
    size: fonts.No3-Small,
  )
  it
  v(1em)
}

// 附录
#set heading(numbering: none)
#include "../sections/appendix.typ"