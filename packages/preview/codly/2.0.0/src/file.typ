// File/source convenience input and reserved header/footer badge rows.
#let filename(value) = {
  if type(value) != path { return value }
  // Typst 0.15 exposes no path components. Its repr is path(<quoted string>),
  // including for package roots. Decode only that compiler-generated string;
  // always read the original path object, never reconstruct its root from repr.
  let shown = repr(value)
  assert(
    shown.starts-with("path(\"") and shown.ends-with("\")"),
    message: "codly: unsupported path representation; specify both file and lang explicitly",
  )
  let name = eval(shown.slice(5, -1), mode: "code")
  name.split("/").last()
}

#let extension(name) = {
  if type(name) != str { return none }
  let name = name.split("/").last()
  let parts = name.split(".")
  if parts.len() < 2 or parts.last() == "" or (parts.len() == 2 and parts.first() == "") {
    return none
  }
  lower(parts.last())
}

#let prepare(body, file: auto, lang: auto) = {
  let from-file = type(body) == path
  let source = from-file or type(body) == str
  let original-name = if from-file and (file == auto or lang == auto) { filename(body) }
  let file = if file == auto { original-name } else { filename(file) }
  if source {
    let code = if from-file { read(body) } else { body }
    let language = if lang == auto {
      extension(if from-file { original-name } else { file })
    } else { lang }
    body = if lang == auto and language == none { raw(code, block: true) } else {
      raw(code, block: true, lang: language)
    }
  }
  (body: body, file: file, source: source)
}

#let badge(it) = box(fill: it.fill, stroke: it.stroke, inset: it.inset, radius: it.radius, it.body)

// place does not reserve space by itself: wrap every badge in its measured
// box before putting the left/right groups into the header/footer grid.
#let reserved(body) = {
  let size = measure(body)
  box(width: size.width, height: size.height, place(top + left, body))
}

#let band(body, file: none, language: none, file-side: left, side: right) = {
  let lhs = ()
  let rhs = ()
  if file != none {
    if file-side == left { lhs.push(reserved(file)) } else { rhs.push(reserved(file)) }
  }
  if language != none {
    if side == left { lhs.push(reserved(language)) } else { rhs.push(reserved(language)) }
  }
  let group(items) = if items.len() == 0 { [] } else {
    grid(columns: (auto,) * items.len(), column-gutter: 0.5em, align: left + top, ..items)
  }
  let row = grid(
    columns: (auto, 1fr, auto),
    column-gutter: 0.5em,
    align: left + top,
    group(lhs), [], group(rhs),
  )
  if body == none or body == [] { row } else { stack(spacing: 0.5em, row, body) }
}


// Measure once, then reserve each side inside the actual code column. The
// inset participates in intrinsic width measurement and leaves later source
// rows at full width. Translated placements retain the badge's public outset.
#let inline-row(badges, padding) = {
  let measured = ()
  let reserved = (left: 0pt, right: 0pt)
  for badge in badges {
    let width = measure(badge.body).width
    let side = if badge.align.x == left { "left" } else { "right" }
    measured.push(badge + (side: side, offset: reserved.at(side)))
    if width > 0pt { reserved.at(side) += width + padding.left + padding.right }
  }
  let render = body => {
    let placements = measured
      .map(badge => place(
        badge.align,
        dx: badge.dx
          + if badge.side == "left" {
            badge.offset - reserved.left
          } else { reserved.right - badge.offset },
        dy: badge.dy,
        badge.body,
      ))
      .join()
    if reserved.left == 0pt and reserved.right == 0pt { return body + placements }
    layout(size => block(
      width: if size.width == calc.inf * 1pt { auto } else { size.width },
      inset: reserved,
      body + placements,
    ))
  }
  (render: render, left: reserved.left)
}
