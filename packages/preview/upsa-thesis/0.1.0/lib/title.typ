#let uni-logo(width: 50%) = image(
  "../assets/images/upsa-logo-green.svg",
  width: width,
  alt: "Logo de la Universidad Privada de Santa Cruz de la Sierra",
)

// Art. 136: Carátula o tapa interna.
//
// En la carátula o tapa interna se debe colocar lo mismo que en la tapa (portada externa) con la sola adición de: "{modalidad de grado} para optar al grado de {grado} en {carrera}".
#let title-page(is-front-cover: false) = context {
  import "info.typ"
  import "@preview/datify:1.3.0": custom-date-format

  let typeface = info.font.get()
  let font-family = info.font-family.get()
  let author = info.author-name.get()
  let faculty = info.faculty.get()
  let faculty-short = info.faculty-short.get()
  let major = info.degree-program.get()
  let is-proposal = info.proposal.get()
  let degree-level = info.degree-level.get()
  let modality = info.thesis-modality.get()
  let year = info.work-date.get()
  let work-title = info.work-title.get()
  let author-id = info.author-uni-id.get()
  let supervisor = info.supervisor.get()
  let city = info.city.get()
  let paper-size = info.paper-size.get()

  set document(title: work-title)

  let cover-margins = if paper-size == "a4" {
    (x: 30mm, y: 35mm)
  } else {
    (x: 1.2in, y: 1.4in)
  }

  let meta-scale = if is-front-cover { 1.12 } else { 1.0 }
  let title-scale = if is-front-cover { 1.14 } else { 1.0 }
  let info-size = typeface.text.size * meta-scale

  set text(
    ..typeface.display,
  )

  show title: set text(
    font: if font-family != "Reforma" { typeface.text.font } else { "Reforma 1969" },
    features: (case: 1),
    size: typeface.text.size * 1.6 * title-scale,
    hyphenate: false,
    number-type: "lining",
  )

  show title: set par(leading: 0.55em, justify: false)

  set page(
    paper: paper-size,
    margin: cover-margins,
    numbering: none,
    header: none,
    footer: none,
  ) if is-front-cover

  set align(center)

  uni-logo(width: if is-front-cover { 55% } else { 45% })

  v(3.5em)

  block(spacing: 0pt, {
    text(weight: "bold", size: info-size * 1.15, tracking: 0.04em)[#upper(faculty-short) --- #smallcaps(faculty)]
  })

  v(1.2fr)

  block({
    if is-proposal {
      text(size: info-size * 0.9, weight: "medium", tracking: 0.08)[Plan de trabajo de graduación]
      v(1.2em)
    }

    block(width: 90%, title())

    if modality != none {
      v(1.5em)
      set text(..typeface.text)

      set par(leading: 1em)

      block(width: 80%, {
        [#text(modality, weight: "medium") para optar por el grado de]
        linebreak()
        text(weight: "medium", style: "normal")[«#degree-level en #major»]
      })
    }
  })

  v(1.5fr)

  block(spacing: 0pt, {
    text(author, size: info-size * 1.25, weight: "bold")
  })

  if author-id != none and not is-front-cover [
    #v(1.25em)
    #text(size: info-size * 0.95, number-type: "lining", number-width: "tabular")[Código de estudiante: #author-id]
  ]

  if supervisor != none {
    v(1.5em)
    text(size: info-size * 0.85, tracking: 0.05em)[Director de #modality]
    v(0.5em)
    text(supervisor, size: info-size * 1.05, weight: "medium")
  }

  v(1fr)

  block(spacing: 0pt, {
    text(city, size: info-size * 1.1, tracking: 0.04em)
    v(0.3em)
    text(size: info-size, weight: "bold", number-type: "lining")[#custom-date-format(
      year,
      pattern: "yyyy",
      lang: text.lang,
    )]
  })

  if not is-front-cover {
    pagebreak(to: "odd", weak: true)
  }
}
