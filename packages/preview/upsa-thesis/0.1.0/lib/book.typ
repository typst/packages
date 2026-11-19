#import "info.typ"
#import "title.typ": title-page

/// El lomo del libro (art. 135 del Reglamento de Graduación)
#let spine-cover() = context {
  let typeface = info.font.get()
  let university = info.university-short.get()
  let modality = info.thesis-modality-short.get()
  let title = info.work-title.get()
  let year = info.work-date.get()
  let volumes = info.volumes.get()

  set document(
    title: title,
  )

  if volumes == none {
    volumes = 1
  }

  for n in range(1, volumes + 1) {
    set align(center)
    set page(
      height: 11in,
      width: 2in,
      margin: 1cm,
    )

    set text(
      weight: "bold",
      hyphenate: false,
      ..typeface.display,
    )

    set par(justify: false)
    show grid: set block(breakable: false)

    grid(
      rows: (auto, 1fr, auto),
      align: horizon,
      {
        set text(tracking: 2pt)
        text(university, size: 28pt)
        parbreak()
        text(modality, size: 20pt)
      },
      rotate(
        -90deg,
        reflow: true,
        box(
          text(title, size: 22pt, weight: "bold", ..typeface.display),
          width: 90%,
        ),
      ),
      {
        import "@preview/datify:1.3.0": custom-date-format

        if volumes > 1 {
          text(size: 24pt, weight: "bold", ..typeface.display)[
            #numbering("I", n)
          ]
          parbreak()
        }

        text(
          size: 20pt,
          number-type: "lining",
          number-width: "tabular",
          custom-date-format(
            year,
            pattern: "yyyy",
            lang: text.lang,
          ),
        )
      },
    )

    if n < volumes {
      pagebreak()
    }
  }
}

// Art. 134: Cubierta o tapa externa
// En la cubierta o tapa de la TL, PG, TD o documento de GE se debe colocar con letras de color negro, partiendo de la parte superior: logo de la universidad en color negro, facultad y carrera, modalidad de graduación, título del trabajo, nombre del autor, ciudad, pais y año.
#let front-cover() = title-page(is-front-cover: true)
