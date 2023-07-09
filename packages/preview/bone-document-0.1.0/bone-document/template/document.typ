#let document-init(
  title: none, 
  author: "六个骨头", 
  body
) = {
  set document(author: author, title: title)
  set page(
    margin:(
      x: 6em, y: 6em
    ),
    footer: [
      Powered By 
      #link("https://github.com/zrr1999/BoneDocument")[BoneDocument]
      #h(1fr)
      #counter(page).display(
        "1"
      )
    ]
  )
  set heading(level:2, numbering: "1.1.1")
  set par(
    // first-line-indent: 2em,
    // TODO: add first-line-indent 
    justify: true
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
    it
    // h(-0.5em) 
    // TODO: typst will add space before link
  }
  show heading.where(
    level: 1
  ): it =>{
    set text(
      rgb("#448"),
      size: 16pt, 
      font: "Source Han Sans CN",
    )
    set par(first-line-indent: 0pt)
    counter(heading).display("一、")
    it.body
    v(14pt, weak: true)
  }
  show heading.where(
    level: 2
  ): it =>{
    it
    v(12pt, weak: true)
  }
  show heading.where(
    level: 3
  ): it =>{
    it
    v(10pt, weak: true)
  }

  align(center)[
    #block(text(font: "Source Han Sans CN", weight: 700, 2em, title))
  ]
  body
}
