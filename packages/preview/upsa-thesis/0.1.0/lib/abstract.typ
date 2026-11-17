#import "info.typ"

/// Resumen analítico especializado requerido por facultad.
#let faculty(
  problem: none,
  objective: none,
  content-index: none,
) = context {
  let major = info.degree-program.get()
  let supervisors = info.supervisor-entries(info.supervisor.get())
  let keywords = info.keywords.get()
  let email = info.author-email.get()
  let author = info.author-name.get()
  let work-title = info.work-title.get()
  let year = info.work-date.get()

  set heading(numbering: none, outlined: true, bookmarked: true)
  show outline: set heading(numbering: none, outlined: false, level: 2)

  heading(level: 1)[Abstracto]

  show table.cell: c => {
    if c.x == 0 {
      strong(c)
    } else {
      c
    }
  }

  table(
    align: (left + horizon, left),
    columns: 2,
    stroke: 1pt,
    [Título], work-title,
    [Autor], author,
  )

  set heading(level: 2)

  if problem != none {
    heading[Problemática]
    problem
  }

  if objective != none {
    heading[Objetivo]
    objective
  }

  show outline.entry: set block(spacing: 0.75em)
  show outline.entry: set text(weight: "medium")
  content-index

  v(1em)
  import "@preview/datify:1.3.0": custom-date-format

  table(
    columns: (auto, 1fr),
    stroke: 1pt,
    align: (left + horizon, left),
    ..if major != none {
      ([Carrera], major)
    },
    ..supervisors,
    ..if keywords != none {
      ([Palabras clave], keywords.join(", "))
    },
    ..if email != none {
      (
        [Correo electrónico],
        {
          show link: set text(
            number-type: "lining",
            number-width: "tabular",
          )

          link("mailto:" + email)
        },
      )
    },
    ..if year != none {
      (
        [Año],
        text(
          custom-date-format(
            year,
            pattern: "yyyy",
            lang: text.lang,
          ),
          number-type: "lining",
          number-width: "tabular",
        ),
      )
    },
  )
}

/// Resumen del trabajo requerido para la entrega de trabajos de grado de Universidades Privadas, a pedido de la Biblioteca del Ministerio de Educación. Tiene que ser impreso.
///
/// Ref.:
/// - https://www.minedu.gob.bo/index.php?option=com_content&view=article&id=1666:resolucion-bime&catid=235&Itemid=971.
/// - https://utp.minedu.gob.bo/pdfs/Biblioteca.pdf
#let bime(body: none) = context {
  import "@preview/datify:1.3.0": custom-date-format

  let author = info.author-name.get()
  let work-title = info.work-title.get()
  let year = info.work-date.get()
  let city = info.city.get()
  let modality = info.thesis-modality.get()
  let supervisor = info.supervisor-names(info.supervisor.get()).join(", ")
  let abstract = if body == none { info.work-abstract.get() } else { body }
  let university = info.university.get()
  let degree = info.degree-program.get()
  let typeface = info.font.get()
  let paper-size = info.paper-size.get()

  set document(
    title: work-title,
    author: author,
    description: abstract,
  )

  show std.title: set align(center)
  show std.title: set block(spacing: 2em)
  show std.title: set text(size: 16pt, ..typeface.display)

  set text(
    size: 10pt,
    lang: "es",
    region: "bo",
    hyphenate: false,
    ..typeface.text,
  )

  set page(
    paper: paper-size,
    margin: if paper-size == "a4" { 3.5cm } else { 1.5in },
  )

  set par(justify: true)
  set terms(separator: [: ])
  line(length: 100%)

  [
    / #upper[Universidad]: #university
    / #upper[Carrera]: #degree
    / #upper[Título]: #work-title
    / #upper[Modalidad de titulación]: #modality
    / #upper[Nombres y apellidos del autor]: #author
    / #upper[Nombres y apellidos del tutor o prof. guía]: #supervisor
    / #upper[Ciudad]: #city
    / #upper[Año del trabajo]: #text(number-type: "lining", number-width: "tabular")[#custom-date-format(
        year,
        pattern: "yyyy",
        lang: text.lang,
      )]
  ]

  line(length: 100%)

  std.title()

  import "@preview/wordometer:0.1.6": total-words, word-count
  show: word-count
  set text(hyphenate: true, size: 11pt)
  let hard-limit = 250

  word-count(
    total => {
      abstract

      assert(
        total.words <= hard-limit,
        message: "El abstracto no debe exceder las "
          + str(hard-limit)
          + " palabras. Actualmente tiene "
          + str(total.words)
          + " palabras.",
      )
    },
  )
}
