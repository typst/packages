#import "@preview/wordometer:0.1.5": *

#let report(
  class: [],
  title: [],
  author: [],
  number: [],
  supervisor: [],
  date: [],
  abstract: [],
  body
) = {
  set page(margin: (left: 4cm, right: 2.5cm, top: 5cm, bottom: 2cm), header: block(width: calc.inf * 1pt, place(image("../assets/coverpage.png", height: 4.8cm), dx: -4cm, dy: -2.2cm)))

  set document(title: title)

  set text(font: "Liberation Sans", size: 11pt)

  show: word-count.with(exclude: (box, heading.where(level: 1), table, figure.caption))

  show figure.where(kind: table): it => {
    it.caption
    it.body
  }

  show figure.caption: it => {emph(it)}

  if supervisor == [] or supervisor == "" {
    
    table(columns: (auto,1fr), stroke: none, 
    [Class Code/Title:], 
    class,
    [Title:],
    {title},
    [Name/Student Number:],[#author, #number],
    [Date:],date,
    [Word count:],[#total-words],)
  } else {
    table(columns: (auto,1fr), stroke: none, 
    [Class Code/Title:], class,
    [Title:], title,
    [Name/Student Number:],[#author, #number],
    [Supervisor:], supervisor,
    [Date:],date,
    [Word count:],[#total-words],)
  }

  heading(outlined: false, [Abstract])
  abstract //#lorem(n) makes n words of "lorem ipsum"

  set page(margin: (top: 2cm), header: block(width: calc.inf * 1pt, place(image("../assets/header.png", height: 0.58cm), dx: -0.2cm, dy: -0.4cm)), footer: text(fill: luma(0), [Student No.: #number #h(1fr) #context counter(page).display("1")]))
  outline()
  pagebreak()
  set heading(numbering: "1.1.")

  body

}