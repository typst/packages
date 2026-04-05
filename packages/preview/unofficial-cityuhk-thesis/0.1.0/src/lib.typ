#import "@preview/hydra:0.6.1": hydra, selectors.custom

#import "front-page.typ": *

#set document(
  title: [CityU HK PhD Thesis Template],
  author: "Bowen Tan",
  date: none,
)

#let chapter = figure.with(supplement: [Chapter], kind: "chapter")

#let thesis(
  title: (en: none, zh: none),
  author: (firstname: none, surname: none, firstname-zh: none, surname-zh: none),
  dept: (en: none, zh: none),
  degree: (en: none, zh: none, abbr: none),
  date: (en: none, zh: none),
  supervisor: (title: none, name: none, dept: none, university: none),
  panel-members: (),
  examiners: (),
  abstract: none,
  ack: none,
  bib: bibliography,
  extras: none,
  body,
) = {
  set page(
    "a4",
    margin: (top: 38mm, bottom: 38mm, left: 32.7mm, right: 32.7mm),
    numbering: "i",
  )
  set text(
    font: "Times New Roman",
    size: 12pt,
  )

  make-title-page(
    title: title,
    author: author,
    dept: dept,
    degree: degree,
    date: date,
  )

  make-abstract-page(abstract)

  make-panel-page(
    author: (
      surname: author.surname,
      firstname: author.firstname,
    ),
    degree: degree.en,
    dept: dept.en,
    supervisor: supervisor,
    panel-members: panel-members,
    examiners: examiners,
  )

  make-ack-page(ack)

  make-toc()

  make-list-of-figures()

  make-list-of-tables()

  set page(numbering: "1")
  counter(page).update(1)

  set par(leading: 0.7em, justify: true, spacing: 1em, first-line-indent: 1.5em)

  // For figure and tables
  set figure.caption(separator: " ")
  show figure.where(kind: image): set figure(
    supplement: [Fig.],
    numbering: (..nums) => [
      #context counter(figure.where(kind: "chapter")).get().first().#nums.at(0)
    ],
  )
  show figure.where(kind: table): set figure(
    supplement: [Table],
    numbering: (..nums) => [
      #context counter(heading).get().at(0).#nums.at(0)
    ],
  )

  // For chapters
  let chapter-sel = figure.where(kind: "chapter")
  show chapter-sel: it => {
    pagebreak(weak: true)

    counter(heading).step()
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)

    set align(left)
    block[
      #v(7em)
      #set text(size: 25pt)
      #set par(first-line-indent: 0em)
      *Chapter #it.counter.display()*
      #v(0.4em)
      *#it.body*
      #v(1.4em)
    ]
  }

  let display-chapter(ctx, chapter) = {
    [Chapter ]
    if chapter.has("numbering") and chapter.numbering != none {
      numbering(chapter.numbering, ..counter(chapter-sel).at(chapter.location()))
      [. ]
    }
    chapter.body
  }
  set page(
    header: context if calc.even(counter(page).get().first()) {
      let chap = hydra(chapter-sel, display: display-chapter)
      let sec = hydra(custom(heading.where(level: 1), ancestors: chapter-sel))

      set align(left)
      chap
      // if chap != none and sec != none [ --- ]
      // sec
    } else {
      align(right, hydra(custom(heading.where(level: 2), ancestors: chapter-sel), use-last: true))
    },
  )
  set heading(offset: 1, numbering: "1.1")
  show heading: it => block[
    #v(1em)
    #set text(size: calc.max(17pt - 2.5pt * (it.level - 2), 12pt))
    #counter(heading).display() #h(0.8em) #it.body
    #v(0.7em)
  ]

  body

  pagebreak()

  // For reference sections
  set heading(offset: 0, numbering: none)
  show heading.where(level: 1): it => [
    #v(4.5em)
    #set text(size: 25pt)
    #it.body
    #v(0.6em)
  ]
  set page(header: none)
  if bib != none { bib }

  if extras != none {
    pagebreak()
    extras
  }
}

