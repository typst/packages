#let src-block(title: none, content) = {
  let stroke = black + 0.5pt
  let radius = 5pt
  show raw: set text(
    font: "TeX Gyre Cursor",
    ligatures: false,
    size: 1em,
    spacing: 100%,
  )
  block(stroke: stroke, radius: radius, clip: true, fill: rgb("#f2f2f2"))[
    #if title != none {
      block(
        stroke: stroke,
        inset: 0.5em,
        below: 0em,
        radius: (top-left: radius, bottom-right: radius),
        clip: true,
        fill: rgb("#d8d8d8"),
        title,
      )
    }
    #block(
      width: 100%,
      inset: (rest: 0.5em),
      clip: true,
      content,
    )
  ]
}

/// This uses a hack, path handling may be improved in the future
/// https://forum.typst.app/t/why-are-paths-always-relative-to-the-current-file/306/5
#let src-file(..path, lang: auto) = {
  let filename = path.at(0)
  let inferred = if lang != auto {
    lang
  } else {
    let parts = filename.split(".")
    if parts.len() > 1 {
      parts.last()
    } else {
      "txt"
    }
  }
  src-block(
    title: filename,
    raw(read(..path), lang: inferred),
  )
}
