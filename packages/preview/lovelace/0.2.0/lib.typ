#let ind = metadata("lovelace indent")
#let ded = metadata("lovelace dedent")
#let no-number = metadata("lovelace no number")
#let line-label(it) = {
  if type(it) == str {
    it = label(it)
  } else if type(it) == label {
    // nothing
  } else {
    panic("line-label requires either a string or a label.")
  }

  metadata((
    identifier: "lovelace line label",
    label: it
  ))
}

#let comment(body) = {
  h(1fr)
  text(size: .7em, fill: gray, sym.triangle.stroked.r + sym.space + body)
}

#let pseudocode(
  line-numbering: true,
  line-number-transform: it => it,
  indentation-guide-stroke: none,
  ..children
) = {
  let lines = ()
  let indentation = 0
  let line-no = 1
  let curr-label = none
  let numbered-line = true
  let indentation-box = box.with(
    inset: (left: 1em, rest: 0pt),
    stroke: (left: indentation-guide-stroke, rest: none)
  )
  let rep-app(fn, init, num) = {
    let x = init
    for i in range(num) {
      x = fn(x)
    }
    x
  }

  for child in children.pos() {
    if child == ind {
      indentation += 1
    } else if child == ded {
      indentation -= 1
    } else if child == no-number {
      numbered-line = false
    } else if type(child) == label {
      curr-label = child
    } else {
      lines.push((
        no: if numbered-line and line-numbering {
          align(right + horizon)[
            #figure(
              kind: "lovelace-line-no",
              supplement: "Line",
              [#line-number-transform(line-no)]
            )
            #curr-label
          ]
        },
        line: rep-app(
          indentation-box,
          pad(left: -2pt, rest: 4pt, child),
          indentation
        )
      ))
      if numbered-line {
        line-no += 1
      }
      curr-label = none
      numbered-line = true
    }
  }

  set par(hanging-indent: .5em)
  let columns = if line-numbering { 2 } else { 1 }
  let cells = if line-numbering {
    lines.map(line => ( line.no, line.line ) ).flatten()
  } else {
    lines.map(line => line.line)
  }
  
  grid(
    columns: columns,
    column-gutter: 1em,
    row-gutter: .0em,
    ..cells
  )
}

#let pseudocode-list(..config, body) = {
  let is-not-empty(it) = {
    return type(it) != content or not (
      it.fields() == (:) or
      (it.has("children") and it.children == ()) or
      (it.has("children") and it.children.all(c => not is-not-empty(c))) or
      (it.has("text") and it.text.match(regex("^\\s*$")) != none)
    )
  }

  let transform-list(it) = {
    if not it.has("children") {
      return it
    }

    let transformed = ()
    let current-normal-child = []
    for child in it.children {
      if child.func() in (enum.item, list.item) {
        if is-not-empty(current-normal-child) {
          transformed.push(current-normal-child)
          current-normal-child = []
        }
        transformed.push(ind)
        if child.func() == list.item {
          transformed.push(no-number)
        }
        transformed.push(transform-list(child.body))
        transformed.push(ded)
      } else if (
        child.func() == metadata and
        child.value.at("identifier", default: "") == "lovelace line label" and
        "label" in child.value
      ) {
        transformed.push(child.value.label)
      } else {
        current-normal-child += child
      }
    }
    if is-not-empty(current-normal-child) {
      transformed.push(current-normal-child)
    }

    transformed
  }

  let transformed = transform-list(body)
  let cleaned = transformed.flatten().filter(is-not-empty)
  let dedented = cleaned
  while dedented.first() == ind and dedented.last() == ded {
    dedented = dedented.slice(1, -1)
  }

  pseudocode(..config.named(), ..dedented)
}

#let pseudocode-raw(typst-code, ..config, scope: (:)) = {
  assert.eq(type(typst-code), content)
  assert.eq(typst-code.func(), raw)

  let indent = 0
  let last-indent = 0
  let res = ()
  for line in typst-code.text.split("\n") {
    let whitespaces = line.find(regex("^\\s+"))
    let current-indent = if whitespaces != none { whitespaces.len() } else { 0 }
    if indent == 0 and current-indent != 0 {
      indent = current-indent
    }
    if current-indent > last-indent {
      res += (ind,) * int((current-indent - last-indent) / indent)
    } else if current-indent < last-indent {
      res += (ded,) * int((last-indent - current-indent) / indent)
    }
    last-indent = current-indent
    let line-code = line.slice(current-indent)
    let match = line-code.match(regex("^<(.*)>\\s*$"))
    if (match != none) {
      res.push(label(match.captures.at(0)))
    } else {
      res.push(eval(line-code, mode: "markup", scope: (no-number: no-number, comment: comment) + scope))
    }
  }
  pseudocode(..config.named(), ..res)
}


#let algorithm = figure.with(kind: "lovelace", supplement: "Algorithm")

#let setup-lovelace(
  line-number-style: text.with(size: .7em),
  line-number-supplement: "Line",
  body-inset: (bottom: 5pt),
  body
) = {
  show ref: it => if (
    it.element != none and
    it.element.func() == figure and
    it.element.kind == "lovelace-line-no"
  ) {
    link(
      it.element.location(),
      { line-number-supplement; sym.space; it.element.body }
    )
  } else {
    it
  }
  show figure.where(kind: "lovelace-line-no"): it => line-number-style(it.body)
  show figure.where(kind: "lovelace"): it => {
    let booktabbed = block(
      stroke: (y: 1.3pt),
      inset: 0pt,
      breakable: true,
      width: 100%,
      {
        set align(left)
        block(
          inset: (y: 5pt),
          width: 100%,
          stroke: (bottom: .8pt),
          {
            strong({
              it.supplement
              sym.space.nobreak
              counter(figure.where(kind: "lovelace")).display(it.numbering)
              if it.caption != none {
                [: ]
              } else {
                [.]
              }
            })
            if it.caption != none {it.caption.body}
          }

        )
        block(
          inset: body-inset,
          breakable: true,
          it.body
        )
      }
    )
    let centered = pad(x: 5%, booktabbed)
    if it.placement in (auto, top, bottom) {
      place(it.placement, float: true, centered)
    } else {
      centered
    }
  }

  body
}
