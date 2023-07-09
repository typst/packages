#let resume-init(
  title: none, 
  author: "六个骨头",  
  body
) = {
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page(
    margin:(
      x: 4em, y: 5em
    ),
    footer: [
      Powered By 
      #link("https://github.com/zrr1999/BoneDocument")[BoneDocument]
    ]
  )
  
  set box(
    fill: rgb("#ddf"), inset: 5pt, radius: 3pt
  )

  set text(
    font: (
    "Hack Nerd Font",
    // "Source Han Sans CN",
    "Source Han Serif SC",
    ), 
    lang: "zh"
  )
  show emph: it => {
    text(
      it.body,
      font: (
      "Hack Nerd Font",
      "Source Han Serif SC",
      ),
      style: "italic"
    )
  }
  show link: it => {
    set text(
      blue,
      font: (
      "Hack Nerd Font",
      "Source Han Serif SC",
      ),
      weight: "bold"
    )
    // h(-0.5em) // TODO: typst will add space before link
    it
  }
  show heading.where(
    level: 1
  ): it =>{
    set text(
      rgb("#448"),
      size: 16pt, 
      font: "Source Han Sans CN",
    )
    stack(
      dir: ttb,
      spacing: 12pt,
      {
        it.body
      },
      line(length: 100%),
    )
    v(8pt, weak: true)
  }

  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]
  set par(justify: true)
  body
}

#let section(name, decs, contrib) =  {
  box()[
      #name #h(1fr) #decs \
      #contrib
  ]
}


#let module(entry, category:none) = {
  let (init, display)=entry()
  init(category:category)
  display(category:category)
}

