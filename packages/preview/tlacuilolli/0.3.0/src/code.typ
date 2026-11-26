#let code-theme = path("code.tmTheme")

#let listing-layout(listing, title: none, start: 1, numbers: true) = {
  block(width: 100%, above: 1.32em, below: 1.45em, breakable: true, {
    if title != none {
      block(
        sticky: true,
        below: 0.53em,
        text(font: ("New Computer Modern", "Libertinus Serif"), size: 0.94em, weight: "semibold", title),
      )
    }
    block(
      width: 100%,
      fill: rgb("#F8F7F4"),
      radius: 3pt,
      inset: (x: 1.16em, y: 0.94em),
      breakable: true,
      layout(size => {
        set text(font: "DejaVu Sans Mono", size: 0.84em, fill: rgb("#292825"), dir: ltr, hyphenate: false)
        set par(justify: false, first-line-indent: 0pt, leading: 0.64em)
        let gutter = 1.65em
        let last-number = start + listing.lines.len() - 1
        // Keep one- and two-digit listings aligned.
        let number-width = if numbers { measure(str(calc.max(99, last-number))).width } else { 0pt }
        let code-width = if numbers { size.width - number-width - gutter.to-absolute() } else { size.width }
        let continuation-indent = calc.min(1.2em.to-absolute(), calc.max(0pt, code-width / 10))
        let rows = listing.lines.map(line => {
          let source = if line.text == "" { sym.space.nobreak } else { line.body }
          let oversized-token = measure(source).width > code-width and line.text
            .matches(regex("\\S+"))
            .any(token => measure(token.text).width > code-width - continuation-indent)
          if oversized-token {
            // Style the break markers separately to keep them out of neighboring PDF text runs.
            source = {
              show regex("\\S+"): token => token.text.clusters().join(text(font: "New Computer Modern", sym.zws))
              source
            }
          }
          let cell = grid.cell(breakable: false, par(hanging-indent: continuation-indent, source))
          if numbers {
            let number = str(start + line.number - 1)
            (grid.cell(breakable: false, align(right, text(fill: rgb("#746F65"), number))), cell)
          } else { (cell,) }
        }).flatten()
        grid(
          columns: if numbers { (number-width, 1fr) } else { (1fr,) },
          align: left + top,
          column-gutter: gutter,
          row-gutter: 0.66em,
          ..rows,
        )
      }),
    )
  })
}

/// Format a string or raw code block as a highlighted source listing.
#let code-listing(body, lang: auto, title: none, start: 1, numbers: true) = {
  let is-raw = type(body) == content and body.func() == raw
  assert(is-raw or type(body) == str, message: "code-listing expects a string or raw code")
  assert(type(start) == int and start > 0, message: "start must be a positive integer")
  let tag = if lang == auto { if is-raw { body.at("lang", default: none) } } else { lang }
  let language = if tag != none {
    let key = lower(tag)
    (python: "py", javascript: "js", typescript: "ts", "c++": "cpp").at(key, default: key)
  }
  show raw.where(block: true): listing-layout.with(title: title, start: start, numbers: numbers)
  raw(if is-raw { body.text } else { body }, block: true, lang: language, theme: code-theme, tab-size: 4)
}
