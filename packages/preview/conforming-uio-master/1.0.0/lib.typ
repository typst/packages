#let uio-thesis(
  title: [],
  subtitle: [],
  author: [],
  supervisor: [],
  study-programme: [],
  department: [],
  faculty: [],
  abstract: [],
  preface: [],
  semester: [Spring],
  print: false,
  ects: 60,
  front-page-font: "Nimbus Sans",
  font: "libertinus serif",
  language: "en",
  body
) = {

  import "@preview/hydra:0.6.2": hydra
  let inset = 25pt
  let top_space = 9em

  set heading(outlined: false)
  set document(title: title, author: author)
  set par(justify: true)
  set text(lang: language, font: font, size: 10pt)

  page(fill: rgb(230, 236, 255), margin: 0pt)[
    #set text(font: front-page-font)

    #box(fill: rgb(134, 164, 247), width: 100%, height: 31%, inset: inset, outset: 0pt)[
      #if language == "en" {
        image("resources/uio-fp-navn-eng.pdf", height: 40pt, alt: "University of Oslo")
      } else {
        image("resources/uio-fp-navn-bm.png", height: 40pt, alt: "Universitetet i Oslo")
      }
      #align(bottom, rect(fill: black, inset: 12pt, text(fill: white, weight: "bold", size: 15pt, if language == "en" [Master's thesis] else [Masteroppgave])))
    ]

    #box(
      inset: (x: inset, y: inset - 5pt),
      {
        text(size: 2em, weight: 500, title)
        v(0.8em)
        text(size: 1.2em, subtitle)

        v(3em)
        set text(size: 1.3em)
        text(weight: "bold", author)

        v(1em)
        [
          #study-programme\
          #ects
          #if language == "en" [ECTS study points] else [studiepoeng]
        ]

        v(1em)
        [
          #department\
          #faculty
        ]
      }
    )

    #{
      set align(bottom)
      set text(size: 1.3em)
      grid(
        columns: (1fr, 1fr),
        align: (start, end),
        inset: inset,
        {
          semester
          " "
          datetime.today().display("[year]")
        },
        {
          image("resources/uio-fp-segl.pdf", width: 70pt, alt: "UiO Logo")
        }
      )
    }
  ]

  counter(image).update(0)

  if print {
    page(none)
  }

  {
    set align(center)
    set text(size: 16pt)
    v(7cm)
    text(weight: "bold", author)
    v(1.5em)
    text(size: 1.5em, title)
    v(1.5em)
    text(subtitle)
    set align(bottom)
    [
      #if language == "en" [
        Supervisor:\
      ] else [
        Veileder:\
      ]
      #supervisor
    ]
    v(7cm)
  }

  if print {page(none)}

  set page(margin: auto)

  let numbering_footer(s) = context {
    let alignment = center
    if print {
      if calc.rem(counter(page).get().at(0), 2) == 1 {
        alignment = end
      } else {
        alignment = start
      }
    }
    set align(alignment)
    counter(page).display(s)
  }

  set page(footer: numbering_footer("i"))

  counter(page).update(1)

  {
    v(top_space)
    show heading: it => {
      v(2em)
      align(center, text(size: 1.1em, weight: "bold", it))
      v(1em)
    }
    show heading: it => align(center, text(weight: "bold", size: 12pt, it))
    abstract
  }


  set page(margin: (x: 3cm, y: auto))
  {
    show heading.where(level: 1): it => {
      text(size: 1.6em, it)
      v(3em)
    }

    if print {
      page(none)
    }
    pagebreak(weak: true)
    v(top_space)

    outline(depth: 2)

    context {
      if counter(figure.where(kind: image)).final().at(0) > 0 {
        if print {
          page(none)
        }
        pagebreak(weak: true)
        v(top_space)
        outline(
          title: if language == "nb" or language == "nn" [Figurliste] else [List of Figures],
          target: figure.where(kind: image)
        )
      }

      if counter(figure.where(kind: table)).final().at(0) > 0 {
        if print {
          page(none)
        }
        pagebreak(weak: true)
        v(top_space)
        outline(
          title: if language == "nb" or language == "nn" [Tabelliste] else [List of Tables],
          target: figure.where(kind: table)
        )
      }
    }
  }

  set page(margin: (inside: 3cm, outside: auto, y: auto))

  if print {
    page(none)
  }
  v(top_space)
  heading(if language == "en" [Preface] else [Forord])
  preface

  pagebreak(to: if print {"even"} else {none})

  counter(page).update(1)
  set page(footer: numbering_footer("1"))

  set heading(numbering: "I.1", outlined: true)

  show heading.where(level: 1): it => {
    if print {pagebreak(to: "odd")}
    pagebreak(weak: true)
    set align(center + horizon)
    text(size: 1.8em)[
      #if language == "en" [Part] else [Del] #counter(heading).display()

      #it.body
    ]

    if print {
      page(footer: none, none)
    }
    pagebreak(weak: true)
  }

  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    v(5em)
    text(weight: "bold", size: 1.3em)[#if language == "en" [Chapter] else [Kapittel] #counter(heading).display()]
    v(0pt)
    text(weight: "bold", size: 1.4em, it.body)
    v(10pt)
  }

  set page(header: context {hydra(2, skip-starting: true, book: print)})

  body
}
