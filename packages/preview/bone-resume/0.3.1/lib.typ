#import "@preview/oxifmt:0.2.1": strfmt

#let show-common-state = state("show-common", false)
#let resume-init(
  author: "六个骨头",
  header: none,
  footer: none,
  show-common: true,
  size: 11pt,
  body,
) = {
  set document(author: author)
  context {
    if target() != "html" {
      set page(margin: (x: 3.2em, y: 3.2em), header: header, footer: footer)
    }
  }
  set list(marker: [‣])
  set text(size: size, font: "Source Han Sans", lang: "zh")
  show emph: set text(
    font: ("Times New Roman", "LXGW WenKai GB"),
    style: "italic",
  )
  show raw: set text(font: "Hack Nerd Font")
  show link: set text(fill: blue, weight: "bold")
  show heading.where(level: 1): it => {
    set text(rgb("#448"), font: "LXGW WenKai GB")
    v(1em, weak: true)
    stack(
      dir: ttb,
      spacing: 0.55em,
      {
        it.body
      },
      line(stroke: 1.5pt, length: 100%),
    )
    v(0.5em, weak: true)
  }
  set par(spacing: 0.65em, justify: true)
  show-common-state.update(show-common)
  body
}

#let info(author) = {
  stack(
    dir: ltr,
    spacing: 1fr,
    text(24pt)[*#author*],
    stack(spacing: 0.75em),
    stack(spacing: 0.75em),
    image("photo.png", height: 74pt, width: 60pt),
  )
  v(-2.5em)
}

#let primary-achievement(name, decs, contrib) = {
  context {
    if show-common-state.get() {
      box(
        fill: color.hsv(240deg, 10%, 100%),
        stroke: 1pt,
        inset: 5pt,
        radius: 3pt,
      )[
        #name #h(1fr) #decs
        #v(1em, weak: true)
        #contrib
      ]
    } else {
      box(
        stroke: 1pt,
        inset: 5pt,
        radius: 3pt,
      )[
        #name #h(1fr) #decs
        #v(1em, weak: true)
        #contrib
      ]
    }
  }
}
#let common-achievement(name, decs, contrib) = {
  context {
    if show-common-state.get() {
      box(stroke: 1pt, inset: 5pt, radius: 3pt)[
        #name #h(1fr) #decs
        #v(1em, weak: true)
        #contrib
      ]
    }
  }
}
#let achievement(primary: false, name, decs, contrib) = {
  if primary {
    primary-achievement(name, decs, contrib)
  } else {
    common-achievement(name, decs, contrib)
  }
}
#let resume-section(primary: true, name, decs, contrib) = {
  achievement(primary: primary, name, decs, contrib)
}

#let link-fn(base) = {
  let _link(dest, body) = {
    link(strfmt("{}/{}", base, dest))[#body]
  }
  _link
}
#let grid-fn(
  columns: auto,
  align: auto,
  column-gutter: auto,
  row-gutter: 6pt,
  processor: it => it,
) = {
  let _grid(..content) = {
    let processed-content = content.pos().map(processor)
    grid(
      columns: columns,
      rows: auto,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      align: align,
      ..processed-content.flatten(),
    )
  }
  _grid
}

#let github(repo, body: none) = {
  if body == none {
    body = repo
  }
  link-fn("https://github.com")(repo, body)
}
