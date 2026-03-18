
#let codelst-counter = counter("@codelst-line-numbers")

// Counts the number of blanks (of a specific type)
// the line starts with.
#let codelst-count-blanks( line, char:"\t" ) = {
  let m = line.match(regex("^" + char + "+"))
  if m != none {
    return m.end
  } else {
    return 0
  }
}

// Counts the maximum number of whitespace (of similar type)
// all lines have in common.
#let codelst-gobble-count( code-lines ) = {
  let gobble = 9223372036854775807
  let _c = none
  for line in code-lines {
    if line.trim().len() == 0 { continue }
    if not line.at(0) in (" ", "\t") {
      return 0
    } else {
      if _c == none { _c = line.at(0) }
      gobble = calc.min(gobble, codelst-count-blanks(line, char:_c))
    }
  }
  return gobble
}

// Removes whitespace from the start of each line.
#let codelst-gobble-blanks( code-lines, gobble ) = {
  if gobble == auto {
    gobble = codelst-gobble-count(code-lines)
  }

  // Convert tabs to spaces and remove unnecessary whitespace
  return code-lines.map((line) => {
    if line.len() > 0 {
      line = line.slice(gobble)
    }
    line
  })
}

// Alias for the numbering function
#let codelst-numbering = numbering

// Creates a copy of the given raw element with
// some optional overwrites for some options.
// If a text is provided, the text from the original raw element
// is ignored.
#let codelst-raw-copy( code, text:none, ..overrides ) = {
  let args = (:)
  for k in ("syntaxes", "theme", "align", "lang", "block") {
    if code.has(k) {
      args.insert(k, code.at(k))
    }
  }
  for (k, v) in overrides.named() {
    args.insert(k, v)
  }
  if text == none {
    raw(..args, code.text)
  } else {
    raw(..args, text)
  }
}

// Default format for code frames
#let code-frame(
  fill:      luma(250),
  stroke:    .6pt + luma(200),
  inset:	   (x: .45em, y: .65em),
  radius:    3pt,
  clip:      false,
  code
) = block(
  fill: fill,
  stroke: stroke,
  inset: inset,
  radius: radius,
  breakable: true,
  width: 100%,
  clip: clip,
  code
)

// Default format for line numbers
#let codelst-lno( lno ) = text(.8em, luma(160), raw(lno))

#let sourcecode(
  lang: auto,

  numbering: "1",
  numbers-start: auto,
  numbers-side: left,
  numbers-width: auto,
  numbers-style: codelst-lno,
  numbers-align: right+horizon,
  numbers-first: 1,
  numbers-step: 1,
  // continue-numbering: false,

  gutter: 10pt,

  tab-size: 2,
  gobble: auto,

  highlighted: (),
  highlight-color: rgb(234, 234,189),
  label-regex: regex("// <([a-z-]{3,})>$"),
  highlight-labels: false,

  showrange: none,
  showlines: false,

  frame: code-frame,
  syntaxes: (),
  theme: none,

  code
) = {
  if code.func() != raw {
    code = code.children.find((c) => c.func() == raw)
  }
  assert.ne(code, none, message: "Missing raw content.")

  let line-numbers = numbering != none
  let numbers-format = numbering
  let continue-numbering = false // TODO: How to implement?

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
    if numbers-start == auto {
      numbers-start = showrange.first() + 1
    }
  } else {
    showrange = (0, line-count)
  }

  // Starting line number
  if numbers-start == auto {
    numbers-start = 1
    if not continue-numbering {
      codelst-counter.update(0)
    }
  } else {
    codelst-counter.update(numbers-start - 1)
  }

  if not showlines {
    let trim-start = code-lines.position((line) => line.trim() != "")
    let trim-end = code-lines.rev().position((line) => line.trim() != "")
    showrange = (showrange.first() + trim-start, showrange.last() - trim-end)
    code-lines = code-lines.slice(trim-start, code-lines.len() - trim-end)
    numbers-start = numbers-start + trim-start
  }

  // Parse labels
  let labels = (:)
  if label-regex != none {
    for (i, line) in code-lines.enumerate() {
      let m = line.match(label-regex)
      if m != none {
        labels.insert(str(i + numbers-start), m.captures.at(0))
        if highlight-labels {
          highlighted.push(i + numbers-start)
        }
      }
    }
  }

  if frame == none {
    frame = (b) => b
  }

  show raw.where(block: true): it => {
    let code-lines = it.lines.slice(
      showrange.first(),
      calc.min(
        showrange.last(),
        it.lines.len()
      )
    )
    // TODO: Somehow one blank line gets removed from the raw text (seems like a bug). This adds them back, if necessary.
    if showrange.last() > it.lines.len() {
      code-lines += ("",) * (showrange.last() - it.lines.len())
    }
    let line-count = code-lines.len()

    // Numbering function
    let next-lno() = {
      codelst-counter.step()
      context codelst-counter.display((lno) => [
        #if lno >= numbers-first and calc.rem(lno - numbers-first, numbers-step) == 0 [
          #numbers-style(codelst-numbering(numbering, lno))
        ]
        #if str(lno) in labels { label(labels.at(str(lno))) }
      ])
    }

    let code-table = context {
      // Measure the maximum width of the line numbers
      // We need to measure every line, since the numbers
      // are styled and could have unexpected formatting
      // (e.g. line 10 is extra big)
      let numbers-width = numbers-width
      if numbering != none and numbers-width == auto {
        numbers-width = calc.max(
          ..{(0pt,) + range(numbers-first - 1, line-count, step:numbers-step).map((lno) => measure(
            numbers-style(codelst-numbering(numbering, lno + numbers-start))
          ).width)}
        ) + .1em
      }

      table(
        columns: if numbering == none {
          (1fr,)
        } else if numbers-side != right {
          (numbers-width, gutter, 1fr)
        } else {
          (1fr, gutter, numbers-width)
        },
        column-gutter: 0pt,
        row-gutter: 0pt,

        stroke:none,
        inset: (x: 0pt, y: .25em),

        fill: (c, r) => {
          if r + numbers-start in highlighted {
            highlight-color
          } else {
            none
          }
        },
        align: (c, r) => {
          if numbering != none {
            if numbers-side != right and c == 0 or (numbers-side == right and c == 2) {
              return numbers-align
            }
          }
          return start
        },

        ..if numbering == none {
          code-lines
        } else if numbers-side != right {
          code-lines.map((l) => (next-lno(), none, l)).flatten()
        } else {
          code-lines.map((l) => (l, none, next-lno())).flatten()
        }
      )
    }

    frame[
      #set align(start)
      #code-table
    ]
  }


  // Create actual raw element
  //// Prepare code text
  code-lines = code.text.split("\n")

  ///// Gobble whitespace from the start of lines
  code-lines = codelst-gobble-blanks(code-lines, gobble)
  ///// Remove labels
  code-lines = code-lines.map((line) => line.replace(label-regex, ""))

  let code-opts = (
    block: true,
    lang: code-lang,
    syntaxes: syntaxes,
    tab-size: tab-size
  )
  if theme != none {
    code-opts.insert("theme", theme)
  }
  raw(
    ..code-opts,
    code-lines.join("\n")
  )
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

#let lineref( label, supplement:"line" ) = context {
  let lines = query(selector(label))
  assert.ne(lines, (), message: "Label <" + str(label) + "> does not exists.")
  [#supplement #{context numbering("1", ..codelst-counter.at(lines.first().location()))}]
}

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
        sourcecode(..args,
          codelst-raw-copy(code, text:code-lines.join("\n"))
        )
      }
      body
    }
  } else {
    return (body) => {
      show raw: (code) => {
        if code.text.starts-with(":" + tag) {
          sourcecode(..args, codelst-raw-copy(code, text:code.text.slice(tag.len() + 1)))
        } else {
          code
        }
      }
      body
    }
  }
}
