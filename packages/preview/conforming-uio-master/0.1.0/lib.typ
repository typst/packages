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
  short-thesis: false,
  body
) = {

  import "@preview/hydra:0.6.2": hydra
  let inset = 25pt
  let top_space = 9em

  set heading(outlined: false)
  set document(title: title, author: author)
  set par(justify: true)

  page(fill: rgb(230, 236, 255), margin: 0pt)[

    #box(fill: rgb(134, 164, 247), width: 100%, height: 31%, inset: inset, outset: 0pt)[
      #image("resources/uio-fp-navn-eng.pdf", width: 25%)
      #align(bottom, rect(fill: black, inset: 12pt, text(fill: white, weight: "bold", size: 15pt, "Master's thesis")))
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
          #if short-thesis [30 ] else [60 ]
          ECTS study points
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
          image("resources/uio-fp-segl.pdf", width: 70pt)
        }
      )
    }
  ]

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
      Supervisor:\
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

    outline(depth: 2, target: selector.or(heading, figure.where(kind: "part")))

    if print {
      page(none)
    }
    pagebreak(weak: true)
    v(top_space)
    outline(
      title: [List of Figures],
      target: figure.where(kind: image)
    )

    if print {
      page(none)
    }
    pagebreak(weak: true)
    v(top_space)
    outline(
      title: [List of Tables],
      target: figure.where(kind: table)
    )
  }

  set page(margin: (inside: 3cm, outside: auto, y: auto))

  if print {
    page(none)
  }
  v(top_space)
  heading("Preface")
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
      Part #counter(heading).display()

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
    text(weight: "bold", size: 1.3em)[Chapter #counter(heading).display()]
    v(0pt)
    text(weight: "bold", size: 1.4em, it.body)
    v(10pt)
  }

  set page(header: context {hydra(2, skip-starting: true)})

  body
}
