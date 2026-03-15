#let new(titlepage, title, subtitle, authors, date, volume, edition) = {
  if titlepage == auto {
    set text(
      fill: luma(50),
      hyphenate: false
    )
    set par(justify: false)
    
    if type(authors) == array {authors = authors.join(", ")}
  
    volume = if volume > 0 {
        import "@preview/transl:0.1.0": transl
        transl("volume", args: (n: volume)) + "\n"
      } else {""}
      
    edition = if edition > 0 {
        import "@preview/transl:0.1.0": transl
        transl("edition", args: (n: edition)) + "\n"
      } else {""}
  
    align(center + horizon)[
      #set par(leading: 2em)
      #context text(
        size: page.width * 0.06,
        title
      )
      #linebreak()
      #set par(leading: 0.5em)
      #if subtitle != none {
      v(1cm)
        context text(
          size: page.width * 0.04,
          subtitle
        )
        //v(4cm)
      }
    ]
    align(center + bottom)[
      #block(width: 52%)[
        #context text(
          size: page.width * 0.035,
          volume +
          edition +
          authors + "\n" + 
          date.display("[year]")
        )
      ]
    ]
  }
  else if type(titlepage) == content {
    titlepage
  }
  else {
    panic("Invalid titlepage argument value: \"" + repr(titlepage) + "\"")
  }
}