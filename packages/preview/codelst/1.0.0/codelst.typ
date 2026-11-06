
#let codelst-counter = counter("@codelst-line-numbers")

#let codelst-count-blanks( line, char:"\t" ) = {
  let m = line.match(regex("^" + char + "+"))
  if m != none {
    return m.end
  } else {
    return 0
  }
}

#let codelst-add-blanks( line, spaces:4, gobble:0 ) = {
  if gobble in (none, false) { gobble = 0 }

  if line.len() > 0 {
    line =  line.slice(gobble)
  }

  return line.replace(regex("^\t+"), (m) => " " * (m.end * spaces))
}

#let codelst-numbering = numbering

#let code-frame(
  fill:      luma(250),
  stroke:    .6pt + luma(200),
  inset:	   (x: .45em, y: .65em),
  radius:    3pt,
  code
) = block(
  fill: fill,
  stroke: stroke,
  inset: inset,
  radius: radius,
  breakable: true,
  width: 100%,
  code
)

#let codelst-lno( lno ) = {
  v(0.08em)
  if type(lno) != "string" {
    lno.counter.display((lno, ..x) => align(right, text(.8em, luma(160), raw(str(lno)))))
  } else {
    align(right, text(.8em, luma(160), raw(lno)))
  }
}

#let sourcecode(
  lang: auto,

  numbering: "1",
  numbers-start: auto,
  numbers-side: left,
  numbers-width: auto,
  numbers-style: codelst-lno,
  numbers-first: 1,
  numbers-step: 1,
  continue-numbering: false,

  gutter: 10pt,

  tab-indent: 2,
  gobble: auto,

  highlighted: (),
  highlight-color: rgb(234, 234,189),
  label-regex: regex("// <([a-z-]{3,})>$"),
  highlight-labels: false,

  showrange: none,
  showlines: false,

  frame: code-frame,

  code
) = {
  // Find first raw element in body
  if code.func() != raw {
    code = code.children.find((c) => c.func() == raw)
  }
  assert.ne(code, none, message: "Missing raw content.")

  let line-numbers = numbering != none
  let numbers-format = numbering

  let code-lang = lang
  if lang == auto {
    if code.has("lang") {
      code-lang = code.lang
    } else {
      code-lang = "plain"
    }
  }
  let code-lines = code.text.split("\n")
  let line-count = code-lines.len()

  // Reduce lines to range
  if showrange != none {
    assert.eq(showrange.len(), 2)
    showrange = (
      calc.clamp(calc.min(..showrange), 1, line-count) - 1,
      calc.clamp(calc.max(..showrange), 1, line-count)
    )
    code-lines = code-lines.slice(..showrange)
    line-count = code-lines.len()
    if numbers-start == auto {
      numbers-start = showrange.first() + 1
    }
  }
  // TODO: Should this happen before showrange?
  if not showlines {
    let trim-start = code-lines.position((line) => line.trim() != "")
    let trim-end   = code-lines.rev().position((line) => line.trim() != "")
    code-lines = code-lines.slice(trim-start, line-count - trim-end)
    line-count = code-lines.len()
  }

  // Starting line number
  if numbers-start == auto {
    numbers-start = 1
  }

  // Get the amount of whitespace to gobble
  if gobble == auto {
    gobble = 9223372036854775807
    let _c = none
    for line in code-lines {
      if line.len() == 0 { continue }
      if not line.at(0) in (" ", "\t") {
        gobble = 0
      } else {
        if _c == none { _c = line.at(0) }
        gobble = calc.min(gobble, codelst-count-blanks(line, char:_c))
      }
      if gobble == 0 { break }
    }
  }

  // Convert tabs to spaces and remove unecessary whitespace
  code-lines = code-lines.map((line) => codelst-add-blanks(line, spaces:tab-indent, gobble:gobble))

  // Parse labels
  let labels = (:)
  if label-regex != none {
    for (i, line) in code-lines.enumerate() {
      let m = line.match(label-regex)
      if m != none {
        labels.insert(str(i), m.captures.at(0))
        code-lines.at(i) = line.replace(label-regex, "")
        if highlight-labels {
          highlighted.push(i + numbers-start)
        }
      }
    }
  }

  // Add a blank raw element, to allow use in figure
  raw("", lang:code-lang)
  // Does this make sense to pass full code to show rules?
  // #block(height:0pt, clip:true, code)

  if frame == none {
    frame = (b) => b
  }

  frame(layout(size => style(styles => {

  let m1 = measure(raw("0"), styles)
  let m2 = measure(raw("0\n0"), styles)

  let letter-height = m1.height
  let descender = 1em - letter-height
  let line-gap = m2.height - 2*letter-height - descender

  // Measure the maximum width of the line numbers
  // We need to measure every line, since the numbers
  // are styled and could have unexpected formatting
  // (e.g. line 10 is extra big)
  let numbers-width = numbers-width
  if numbering != none and numbers-width == auto {
    numbers-width = calc.max(
      ..range(numbers-first - 1, line-count, step:numbers-step).map((lno) => measure(
        numbers-style(codelst-numbering(numbering, lno + numbers-start)),
        styles
      ).width)
    ) + .1em
  } else if numbering == none {
    numbers-width = 0pt
  }

  let code-width = size.width - numbers-width - gutter

  // Create line numbers and
  // highlight / labels columns
  let highlight-column = ()
  let numbers-column = ()

  for i in range(line-count) {
    // Measure actual code line height
    // (including with potential line breaks)
    let m = measure(
      block(
        width: code-width,
        spacing:0pt,
        raw(code-lines.at(i))
      ),
      styles
    )
    let line-height = calc.max(letter-height, m.height)

    numbers-column.push(block(
      width: 100%,
      // clip: true,
      // breakable: true,
      height: line-height,
      // spacing: 0pt,
      below: if i == line-count - 1 {
        0pt
      } else {
        descender + line-gap
      },
      {
        codelst-counter.step()
        if i + numbers-start >= numbers-first and calc.rem(i + numbers-start - numbers-first, numbers-step) == 0 [
          #numbers-style(codelst-counter.display((lno, ..x) => [
            #codelst-numbering(numbering, lno)<line-number>
          ]))
          #if str(i) in labels { label(labels.at(str(i))) }
        ]
      }
    ))

    highlight-column.push({
      // move(dy:-.5 * (line-gap + descender),
      block(
        breakable: true,
        width: size.width,
        fill: if i + numbers-start in highlighted {
          highlight-color
        } else {
          none
        },
        spacing: 0pt,
        height: line-height + line-gap + descender
        // height: line-height
      )
      // )
      // Prevent some empty space at the bottom due
      // to line highlights
      if i == line-count -1 and i + numbers-start not in highlighted {
        v(-1 * (line-gap + descender))
      }
    })
  }

  numbers-column = {
    if not continue-numbering {
      codelst-counter.update(numbers-start - 1)
    }
    //stack(dir: ttb, ..numbers-column)
    v(.5 * (line-gap + descender))
    numbers-column.join()
  }
  highlight-column = {
    set align(left)
    stack(dir:ttb,
      // spacing: -.5 * (line-gap + descender),
      ..highlight-column
    )
    // highlight-column.join()
  }

  // Create final code block
  // (might have changed due to range option and trimming)
  let code-column = {
    set align(left)
    set par(justify:false)
    v(.5 * (line-gap + descender))
    raw(lang:code-lang, code-lines.join("\n"))
  }

  grid(
    columns: if numbering == none {
      (-gutter, 1fr)
    } else if numbers-side != right {
      (-gutter, numbers-width, 1fr)
    } else {
      (-gutter, 1fr, numbers-width)
    },
    column-gutter: gutter,

    ..if numbering == none {
      (highlight-column, code-column)
    } else if numbers-side != right {
      (highlight-column, numbers-column, code-column)
    } else {
      (highlight-column, code-column, numbers-column)
    }
  )

  })) // end style + layout
  ) // end frame
}

#let sourcefile( code, file:none, lang:auto, ..args ) = {
  if file != none and lang == auto {
    let m = file.match(regex("\.([a-z0-9]+)$"))
    if m != none {
      lang = m.captures.first()
    }
  } else if lang == auto {
    lang = "plain"
  }
  sourcecode( ..args, raw(code, lang:lang, block:true))
}

#let lineref( label, supplement:"line" ) = locate(loc => {
  let lines = query(selector(label), loc)
  assert.ne(lines, (), message: "Label <" + str(label) + "> does not exists.")
  [#supplement #numbering("1", ..codelst-counter.at(lines.first().location()))]
})

#let codelst-styles( body ) = {
  show figure.where(kind: raw): set block(breakable: true)

  body
}

#let codelst(
  tag: "codelst",
  reversed: false,
  ..args
) = {
  if not reversed {
    return (body) => {
      show raw.where(lang: tag): (code) => {
        let code-lines = code.text.split("\n")
        let lang = code-lines.remove(0).trim().slice(1)
        sourcecode(..args, raw(lang:lang, code-lines.join("\n")))
      }
      body
    }
  } else {
    return (body) => {
      show raw: (code) => {
        if code.text.starts-with(":" + tag) {
          sourcecode(..args, raw(lang: code.lang, code.text.slice(tag.len() + 1)))
        } else {
          code
        }
      }
      body
    }
  }
}
