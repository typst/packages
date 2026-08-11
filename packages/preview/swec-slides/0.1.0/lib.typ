#import "@preview/polylux:0.4.0" as pl: *

#let swec-blue = rgb("#02216f")
#let swec-light-blue = rgb("#3036ac")
#let swec-dark-blue = rgb("154389")
#let swec-orange = rgb("#fdb445")
#let swec-logo-light = image("./SWEC-S_blue.svg")
#let swec-logo-dark = image("./SWEC-S_white.svg")

#let swec-template-title = state("title", none)
#let swec-template-subtitle = state("subtitle", none)
#let swec-template-authors = state("authors", none)
#let swec-template-mode = state("mode", none)


// See https://github.com/typst/typst/discussions/4260
#let _shrink_title_to_fit(body, max) = layout(size => {
  let font_size = 54pt
  let (height,) = measure(
    block(width: size.width * 0.6, text(size: font_size)[#body]),
  )
  let max_height = 54pt

  while height.cm() > max_height.cm() {
    font_size -= 0.2pt
    height = measure(
      block(
        width: size.width * 0.6,
        text(
          size: font_size,
          weight: "bold",
        )[#body],
      ),
    ).height
  }

  block(
    height: height,
    text(size: font_size, weight: "bold", fill: swec-blue)[#body],
  )
})

#let swec-template(
  aspect-ratio: "16-9",
  dark-mode: false,

  title: none,
  subtitle: none,
  authors: none,
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    fill: if dark-mode { swec-blue } else { white },
    margin: (top: 10pt, bottom: 0pt, right: 0pt, left: 0pt),
    header: none,
    footer: none,
    header-ascent: 0pt,
    footer-descent: 0pt,
  )

  set text(
    fill: if dark-mode { white } else { swec-blue },
    size: 20pt,
    font: "Noto Sans",
  )

  set raw(
    theme: if dark-mode { "./colorschema/UltimateDark.tmTheme" } else { auto },
  )

  swec-template-title.update(title)
  swec-template-subtitle.update(subtitle)
  swec-template-authors.update(authors)
  swec-template-mode.update(dark-mode)

  body
}

#let title-slide(
  body: none,
) = context (
  {
    let content = align(top + center, context (
      {
        let title = swec-template-title.at(here())
        title = if title == none { " " } else { title }
        let title-color = swec-blue
        let subtitle = swec-template-subtitle.at(here())
        let authors = swec-template-authors.at(here())
        let logo = swec-logo-light

        set page(
          fill: swec-orange,
          margin: 10pt,
        )

        place(
          bottom + right,
          dx: -0.5cm,
          dy: -0.3cm,
          scale(page.height / measure(logo).height * 22%, reflow: true, logo),
        )

        set align(left + horizon)

        let title-text = _shrink_title_to_fit(title, page.width)
        let title-size = measure(width: page.width, title-text)

        place(
          horizon,
          dy: -3.1em,
          curve(
            fill: white,
            curve.move((-10pt, -8pt)),
            curve.line((0pt, title-size.height + 8pt), relative: true),
            curve.line((title-size.width + 30pt, 0pt), relative: true),
            curve.cubic(
              (title-size.height / 2, 0pt),
              (title-size.height / 2, -title-size.height / 2),
              (title-size.height, -title-size.height / 2 - 2pt),
              relative: true,
            ),
            curve.line((100%, 0pt), relative: true),
            curve.line((0pt, -4pt), relative: true),
            curve.line((-100%, 0pt), relative: true),
            curve.cubic(
              (-title-size.height / 2, 0pt),
              (-title-size.height / 2, -title-size.height / 2),
              (-title-size.height, -title-size.height / 2 - 2pt),
              relative: true,
            ),
            curve.line((-title-size.width + 30pt, 0pt), relative: true),
            curve.close(),
          ),
        )
        place(
          horizon,
          dy: -3.2em,
          title-text,
        )

        place(
          horizon,
          dy: -1em,
          text(
            size: 18pt,
            fill: swec-blue,
            weight: "bold",
            if subtitle != none { subtitle } else { " " },
          ),
        )
        if authors != none {
          place(
            bottom,
            dy: -1em,
            grid(
              align: left,
              gutter: 1em,
              columns: (0.2fr, 1fr),
              rows: auto,
              ..for i in range(authors.len()) {
                let (name, e-mail) = authors.at(i)
                (
                  align(left, text(size: 12pt, fill: swec-blue, name)),
                  align(left, text(size: 12pt, fill: swec-blue, e-mail)),
                )
              }
            ),
          )
        }

        body
      }
    ))

    pl.slide({ content })

    counter("logical-slide").update(n => n - 1)
  }
)

#let slide(
  title: none,
  page-number: true,
  body,
) = context (
  {
    let deck-title = swec-template-title.at(here())
    let mode = swec-template-mode.at(here())

    let header = align(top, context (
      {
        let logo = if mode { swec-logo-dark } else { swec-logo-light }
        place(
          top + left,
          grid(
            columns: (auto, auto),
            gutter: 0pt,
            pad(logo, x: 0.3cm, top: 0.0cm),
            align(horizon + left, {
              text(
                size: 32pt,
                weight: "bold",
                title,
              )
            }),
          ),
        )
      }
    ))

    let footer = align(top + center, context (
      {
        place(top + center, line(
          length: 100% - 2cm,
          stroke: (
            paint: if mode { white } else { swec-orange },
            thickness: 2pt,
          ),
        ))

        set text(bottom-edge: "descender")

        block(
          height: 100%,
          width: 100%,
          inset: (x: 0.8cm),
          align(horizon, text(
            fill: if mode { white } else { swec-orange },
            size: 16pt,
            grid(
              gutter: 0.8cm,
              columns: (0.7fr, 0.7fr),
              align(left, deck-title),
              align(
                right,
                if page-number [#toolbox.slide-number/#toolbox.last-slide-number],
              ),
            ),
          )),
        )
      }
    ))

    set page(
      margin: (top: 2.5cm, bottom: 1cm),
      header: header,
      header-ascent: -20pt,
      footer: footer,
    )

    pl.slide({
      set align(horizon)
      set text(size: 16pt, top-edge: 20pt, bottom-edge: 0pt)
      show: block.with(inset: (x: 1.2cm, y: .2cm), width: 100%)
      body
    })

    if not page-number { counter("logical-slide").update(n => n - 1) }
  }
)
