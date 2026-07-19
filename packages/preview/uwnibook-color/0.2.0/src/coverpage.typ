#let coverpage(title: (ja: "和文タイトル", en: "English Title"), author: "Name", date: datetime.today()) = {
  set page(background: image("assets/cover.svg", height: 100%))
  set text(fill: cmyk(100%, 82%, 8%, 16%))
  place(dx: 270pt, dy: 180pt, image("assets/logo.svg", width: 50%))
  show: place.with(dy: 400pt)
  text(2em, weight: "bold")[
    #title.en\
    #title.ja
  ]
  v(1em)
  set text(1.5em)
  [by]
  v(1em)
  author
  linebreak()
  date.display("[month repr:long] [year]")
}

#coverpage()
#pagebreak()
df
