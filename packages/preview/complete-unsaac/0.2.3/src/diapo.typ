#import "@preview/touying:0.7.4": *
#import "./utils/fecha.typ": fecha_str

/// TODO: dont just use metropolis
#import themes.metropolis: *
/// - [x] dewdrop: how to have its block style
/// - [x] metropolis: its main vibe
/// - [ ] aqua: to learn to have background

#let doc-diapo(
  titulo: none,
  subtitulo: none,
  curso: none,
  docente: none,
  autores: (),
  fecha: none,
  /// school specific
  facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  escuela: [Ingeniería Informática y de Sistemas],
  escuela-logo: image("imgs/escuela_logo.png"),
  ///
  doc,
) = {
  set text(lang: "es", region: "pe")
  set heading(numbering: "1.")

  show: metropolis-theme.with(
    aspect-ratio: "16-9", // NOTE: doesn't get overwritten by config-store()
    align: horizon,
    footer: self => self.info.titulo,
    config-info(
      titulo: titulo,
      subtitulo: subtitulo,
      curso: curso,
      docente: docente,
      autores: autores,
      date: [Perú, #if (fecha != none) { fecha } else { fecha_str(datetime.today()) }],
      faculty: facultad,
      school: escuela,
      school-logo: escuela-logo,
      // logo: emoji.city,
    ),
    config-common(
      handout: false,
      slide-level: 1,
      new-section-slide-fn: none, // new-section-slide
      // show-notes-on-second-screen: right,
      // datetime-format: "[day]-[month]-[year]", // NOTE: do use this when language support for 'es'
    ),
    config-colors(
      primary: rgb("#eb811b"),
      primary-light: rgb("#d6c6b7"),
      secondary: rgb("#23373b"),
      neutral-lightest: rgb("#fafafa"),
      neutral-dark: rgb("#23373b"),
      neutral-darkest: rgb("#23373b"),
    ),
    config-methods(
      cover: utils.color-changing-cover.with(transparentize-table: true),
    ),
    config-page(
      // margin: (x: 4em, y: 2em),
      // header-ascent: 0em,
      // footer-descent: 0em,
    ),
  )

  doc
}

#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.neutral-lightest,
      margin: (
        top: 1em,
        bottom: 1em,
        left: 2em,
        right: 2em,
      ),
    ),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    // context page.margin
    block(
      breakable: false,
      width: 100%,
      inset: 0.25em,
      {
        {
          set std.align(center + horizon)
          set text(size: 0.7em)
          set par(spacing: 1em)
          block(height: 4.45cm)[
            #grid(
              columns: (2fr, 9fr, 2fr),
              image("imgs/unsaac_logo.png"),
              [
                #upper[Universidad Nacional de San Antonio Abad Del Cusco]

                #if info.faculty != none { upper[Facultad de #info.faculty] }

                #if info.school != none { upper[Escuela Profesional de #info.school] }
              ],
              info.school-logo,
            )
          ]
        }

        // components.left-and-right(
        {
          set std.align(center + horizon)
          block(
            fill: self.colors.primary-light,
            inset: 1em,
            width: 100%,
            radius: 0.2em,
            text(size: 1.3em, fill: self.colors.secondary, text(
              weight: "medium",
              info.titulo,
            ))
              + (
                if info.subtitulo != none {
                  linebreak()
                  text(size: 0.9em, fill: self.colors.secondary, info.subtitulo)
                }
              ),
          )
        }
        //   ,text(2em, utils.call-or-display(self, info.logo)),
        // )

        line(length: 100%, stroke: .05em + self.colors.primary)

        set text(size: 0.8em)

        let sep = ":"
        let rows = ()
        if info.curso != none { rows += (smallcaps[Curso], [#sep], [#info.curso]) }
        if info.docente != none { rows += (smallcaps[Docente], [#sep], [#info.docente]) }
        if info.autores != none {
          if info.autores.len() > 1 {
            rows += (smallcaps[Integrantes], [#sep], [])
          } else if info.autores.len() == 1 {
            let (nombre, codigo) = info.autores.at(0)
            rows += (smallcaps[Alumno], [#sep], [#nombre (#codigo)])
          }
        }
        grid(
          columns: (auto, auto, auto),
          gutter: 0.80em,
          ..rows,
        )

        if info.autores != none {
          block(spacing: 1em)[

            #if info.autores.len() > 1 [
              #set par(spacing: 0.75em)
              #let cols = calc.ceil(info.autores.len() / 4)
              #pad(left: 1em)[
                #grid(
                  align: (left, left) * cols,
                  columns: cols * 2,
                  gutter: 3pt,
                  column-gutter: (0.8em, 2em) * cols,
                  inset: (
                    y: 2pt,
                  ),
                  ..info
                    .autores
                    .map(autor => (
                      [- #autor.nombre],
                      [(#autor.codigo)],
                    ))
                    .flatten()
                )
              ]
            ]
          ]
        }

        v(1fr)

        if info.date != none {
          set std.align(right + horizon)
          block(spacing: 1em, utils.display-info-date(self))
        }

        if extra != none {
          set text(size: 0.8em)
          block(spacing: 1em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})
