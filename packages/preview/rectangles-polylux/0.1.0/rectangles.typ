#import "@preview/polylux:0.4.0": slide as polylux-slide, toolbox

#let m-metadata = state("m-metadata", (:))
#let m-style = state("m-style", (:))

#let rectangles-theme(
  aspect-ratio: "16-9",
  title: [Title],
  subtitle: none,
  authors: none,
  date: datetime.today().display(),
  short-title: none,
  short-authors: none,
  accent-fill-color: rgb("#008ccc"),
  accent-text-color: none,
  text-size: 20pt,
  body
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0em,
    header: none,
    footer: none,
  )
  set text(font: ("New Computer Modern Sans"), fallback: true, text-size)
  show math.equation: set text(font: "New Computer Modern Sans Math")
  show raw: set text(font: "DejaVu Sans Mono")
  show footnote.entry: set text(size: .6em)
  show heading.where(level: 1): it => pad(bottom: 0.25em, it)
  set list(marker: text(accent-fill-color, sym.square.filled))
  if short-title == none and title != none {
    if subtitle != none {
      short-title = [#title – #subtitle]
    } else {
      short-title = title
    }
  }
  if authors != none and type(authors) != array {
    authors = (authors, )
  }
  if short-authors == none and authors != none {
      short-authors = authors.join(", ")
  }
  if accent-text-color == none {
    let contrast-color(c) = {
      let (lightness, _, _, _) = oklab(c).components()
      if lightness > 70% { black } else { white }
    }
    accent-text-color = contrast-color(accent-fill-color)
  }
  m-metadata.update(
    (
      "title": title,
      "subtitle": subtitle,
      "authors": authors,
      "date": date,
      "short-title": short-title,
      "short-authors": short-authors,
    )
  )
  m-style.update(
    (
      "accent-fill-color": accent-fill-color,
      "accent-text-color": accent-text-color,
    )
  )
  body
}

#let title-slide() = {
  let content = context {
    set align(center + horizon)
    let metadata = m-metadata.get()
    let style = m-style.get()
    set stack(spacing: 1em)
    stack(
      block(fill: style.accent-fill-color, width: 60%, inset: 1em)[
        #set text(style.accent-text-color)
        #stack(
          text(1.5em, weight: "bold", metadata.title),
          {
            if metadata.subtitle != none {
              metadata.subtitle
            }
          }
        )
      ],
      {
        set text(size: .8em)
        stack(
          ..metadata.authors,
          none,
          metadata.date
        )
      }
    )
  }
  polylux-slide(content)
}

#let slide(
  title: none,
  new-section: none,
  body,
) = {
  if new-section != none {
    toolbox.register-section(new-section)
  }
  let decoration(body) = context {
    let style = m-style.get()
    block(
      fill: style.accent-fill-color,
      width: 100%,
      inset: 0.75em,
      height: 100%,
      {
        set align(horizon)
        set text(style.accent-text-color, 0.6em)
        body
      }
    )
  }
  let header = {
    set align(top)
    decoration(
      {
        set align(center)
        toolbox.current-section
      }
    )
  }
  let footer = context {
    let metadata = m-metadata.get()
    set align(bottom)
    decoration(
      grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        metadata.short-authors,
        metadata.short-title,
        [#toolbox.slide-number  / #toolbox.last-slide-number]
      )
    )
  }
  let content = {
    set page(
      header: header,
      footer: footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 25pt, bottom: 25pt),
      fill: white,
    )
    show: pad.with(2em)
    grid(
      columns: 1fr,
      rows: (auto, 1fr),
      {
        if title != none {
          heading(level: 1, title)
        }
      },
      block(
        height: 100%,
        width: 100%,
        {
          set align(horizon)
          body
        }
      )
    )
  }
  polylux-slide(content)
}

#let outline-slide(
  title: "Outline",
  highlight-section: none,
  new-section: none
) = slide(
  title: title,
  new-section: new-section,
  {
    set list(marker: none, spacing: 1.5em)
    set align(horizon)
    toolbox.all-sections((s, c) => list(
      ..s.map(x => {
        if highlight-section == none or highlight-section == x.body.text {
          x
        } else {
          text(gray, x)
        }
      })
    ))
  }
)

