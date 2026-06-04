#let new(cover, title, subtitle, date, authors, volume, cfg) = {
  if cover == auto {
    
    let authors = if type(authors) == array {authors.join(", ")} else {authors}
    
    let cover-bg = context {
        let m = page.margin
        let frame = image(
            width: 93%,
            "../assets/frame.svg"
          )
          
        if type(m) != dictionary {
          m = (
            top: m,
            bottom: m,
            left: m,
            right: m
          )
        }
        
        v(m.top * 0.25)
        align(center + top, frame)
        
        align(center + bottom, rotate(180deg, frame))
        v(m.bottom * 0.25)
      }
    
    volume = if volume > 0 {
        import "@preview/transl:0.1.0": transl
        transl("volume", args: (n: volume)) + "\n"
      } else {""}
    
    set text(
      fill: cfg.cover-txtcolor,
      hyphenate: false
    )
    set par(justify: false)
    
    page(
      margin: (x: 12%, y: 12%),
      fill: cfg.cover-bgcolor,
      background: cover-bg,
    )[
      #align(center + horizon)[
        #set par(leading: 2em)
        #context text(
          size: page.width * 0.06,
          font: cfg.cover-fonts.at(0),
          title
        )
        #linebreak()
        #set par(leading: cfg.line-space)
        #if subtitle != none {
        v(1cm)
          context text(
            size: page.width * 0.04,
            font: cfg.cover-fonts.at(1),
            subtitle
          )
          //v(4cm)
        }
      ]
      #align(center + bottom)[
        #block(width: 52%)[
          #context text(
            size: page.width * 0.035,
            font: cfg.cover-fonts.at(1),
            volume +
            authors + "\n" +
            date.display("[year]")
          )
        ]
      ]
    ]
  }
  else if type(cover) == function {
      cover((
        title: title,
        subtitle: subtitle,
        date: date,
        authors: authors,
        volume: volume,
        ),
        cfg
      )
  }

  else if type(cover) == content {
    if cover.func() == image {
      set image(
        fit: "stretch",
        width: 100%,
        height: 100%
      )
      set page(background: cover)
    }
    else {
      cover
    }
  }
  else if cover != none {
    panic("Invalid page argument value: \"" + cover + "\"")
  }
}