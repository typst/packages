// Element function for alignment points.
#let align-point = $&$.body.func()

// Element function for sequences.
#let sequence = $a b$.body.func()

// Element function for a counter update.
#let counter-update = counter(math.equation).update(1).func()

// Sub-numbering state.
#let state = state("equate/sub-numbering", false)

// Show rule necessary for referencing equation lines, as the number is not
// stored in a counter, but as metadata in a figure.
#let equate-ref(it) = {
  if it.element == none { return it }
  if it.element.func() != figure { return it }
  if it.element.kind != math.equation { return it }
  if it.element.body == none { return it }
  if it.element.body.func() != metadata { return it }

  // Display correct number, depending on whether sub-numbering was enabled.
  let nums = if state.at(it.element.location()) {
    it.element.body.value
  } else {
    // (3, 1): 3 + 1 - 1 = 3
    // (3, 2): 3 + 2 - 1 = 4
    (it.element.body.value.first() + it.element.body.value.slice(1).sum(default: 1) - 1,)
  }

  assert(
    it.element.numbering != none,
    message: "cannot reference equation without numbering."
  )

  let num = numbering(
    if type(it.element.numbering) == str {
      // Trim numbering pattern of prefix and suffix characters.
      let counting-symbols = ("1", "a", "A", "i", "I", "一", "壹", "あ", "い", "ア", "イ", "א", "가", "ㄱ", "*")
      let prefix-end = it.element.numbering.codepoints().position(c => c in counting-symbols)
      let suffix-start = it.element.numbering.codepoints().rev().position(c => c in counting-symbols)
      it.element.numbering.slice(prefix-end, if suffix-start == 0 { none } else { -suffix-start })
    } else {
      it.element.numbering
    },
    ..nums
  )

  let supplement = if it.supplement == auto {
    it.element.supplement
  } else {
    it.supplement
  }

  link(it.element.location(), if supplement not in ([], none) [#supplement~#num] else [#num])
}

// Extract lines and trim spaces.
#let to-lines(equation) = {
  let lines = if equation.body.func() == sequence {
    equation.body.children.split(linebreak())
  } else {
    ((equation.body,),)
  }

  // Trim spaces at begin and end of line.
  let lines = lines.filter(line => line != ()).map(line => {
    if line.first() == [ ] and line.last() == [ ] {
      line.slice(1, -1)
    } else if line.first() == [ ] {
      line.slice(1)
    } else if line.last() == [ ] {
      line.slice(0, -1)
    } else {
      line
    }
  })

  lines
}

// Layout a single equation line with the given number.
#let layout-line(
  number: none,
  number-align: none,
  number-width: auto,
  text-dir: auto,
  line
) = context {
  let equation(body) = [
    #math.equation(
      block: true,
      numbering: _ => none,
      body
    ) <equate:revoke>
  ]

  // Short circuit if no number has to be added.
  if number == none {
    return equation(line.join())
  }

  // Short circuit if number is a counter update.
  if type(number) == content and number.func() == counter-update {
    return {
      number
      equation(line.join())
    }
  }

  // Start of equation block.
  let x-start = here().position().x

  // Resolve number width.
  let number-width = if number-width == auto {
    measure(number).width
  } else {
    number-width
  }

  // Resolve equation alignment in x-direction.
  let equation-align = if align.alignment.x in (left, center, right) {
    align.alignment.x
  } else if text-dir == ltr {
    if align.alignment.x == start { left } else { right }
  } else if text-dir == rtl {
    if align.alignment.x == start { right } else { left }
  }

  // Add numbers to the equation body, so that they are aligned at their
  // respective baselines. If the equation is centered, the number is put
  // on both sides of the equation to keep the center alignment.

  let num = box(width: number-width, align(number-align, number))
  let line-width = measure(equation(line.join())).width
  let gap = 0.5em

  layout(bounds => {
    let space = if equation-align == center {
      bounds.width - line-width - 2 * number-width
    } else {
      bounds.width - line-width - number-width
    }

    let body = if number-align.x == left {
      if equation-align == center {
        h(-gap) + num + h(space / 2 + gap) + line.join() + h(space / 2) + hide(num)
      } else if equation-align == right {
        num + h(space + 2 * gap) + line.join()
      } else {
        h(-gap) + num + h(gap) + line.join() + h(space + gap)
      }
    } else {
      if equation-align == center {
        hide(num) + h(space / 2) + line.join() + h(space / 2 + gap) + num + h(-gap)
      } else if equation-align == right {
        h(space + gap) + line.join() + h(gap) + num + h(-gap)
      } else {
        line.join() + h(space + 2 * gap) + num
      }
    }

    equation(body)
  })
}

// Replace "fake labels" with a hidden figure that is labelled
// accordingly. 
#let replace-labels(
  lines,
  number-mode,
  numbering,
  supplement,
  has-label
) = {
  // Main equation number.
  let main-number = counter(math.equation).get()

  // Indices of lines that contain a label.
  let labelled = lines
    .enumerate()
    .filter(((i, line)) => {
      if line.len() == 0 { return false }
      if line.last().func() != raw { return false }
      if line.last().lang != "typc" { return false }
      if line.last().text.match(regex("^<.+>$")) == none { return false }
      return true
    })
    .map(((i, _)) => i)

  // Indices of numbered lines in this equation.
  let numbered = if number-mode == "line" {
    range(lines.len())
  } else if labelled.len() == 0 and has-label {
    // Only outer label, so number all lines.
    range(lines.len())
  } else {
    labelled
  }

  (
    numbered,
    lines.enumerate()
      .map(((i, line)) => {
        if i not in labelled { return line }

        // Remove trailing spacing (before label).
        if line.at(-2, default: none) == [ ] { line.remove(-2) }

        // Append sub-numbering only if there are multiple numbered lines.
        let nums = main-number + if numbered.len() > 1 {
          (numbered.position(n => n == i) + 1,)
        }

        // We use a figure with kind "equation" to make the sub-equation
        // referenceable with the correct supplement. The numbering is stored
        // in the figure body as metadata, as a counter would only show a
        // single number.
        line.at(-1) = [#figure(
          metadata(nums),
          kind: math.equation,
          numbering: numbering,
          supplement: supplement
        )#label(line.last().text.slice(1, -1))]

        return line
      })
  )
}

// Splitting an equation into multiple lines breaks the inbuilt alignment
// with alignment points, so it is emulated here by adding spacers manually.
#let realign(lines) = {
  // Utility shorthand for unnumbered block equation.
  let equation(body) = [
    #math.equation(
      block: true,
      numbering: none,
      body
    ) <equate:revoke>
  ]

  // Short-circuit if no alignment points.
  if lines.all(line => align-point() not in line) {
    return lines
  }

  // Store widths of each part between alignment points.
  let part-widths = lines.map(line => {
    line.split(align-point())
      .map(part => measure(equation(part.join())).width)
  })

  // Get maximum width of each part.
  let part-widths = for i in range(calc.max(..part-widths.map(points => points.len()))) {
    (calc.max(..part-widths.map(line => line.at(i, default: 0pt))), )
  }

  // Get maximum width of each slice of parts.
  let max-slice-widths = array.zip(..lines.map(line => range(part-widths.len()).map(i => {
    let parts = line.split(align-point()).map(array.join)
    if i >= parts.len() {
      0pt
    } else {
      let slice = parts.slice(0, i + 1).join()
      measure(equation(slice)).width
    }
  }))).map(widths => calc.max(..widths))

  // Add spacers for each part, so that the part widths are the same for all lines.
  let lines = lines.map(line => {
    line.split(align-point())
      .enumerate()
      .map(((i, part)) => {
        // Add spacer to make part the correct width.
        let width-diff = part-widths.at(i) - measure(equation(part.join())).width
        let spacing = if width-diff > 0pt { h(0pt) + box(fill: yellow, width: width-diff) + h(0pt) }

        if calc.even(i) {
          spacing + part.join() // Right align.
        } else {
          part.join() + spacing // Left align.
        }
      })
      .intersperse(align-point())
  })

  // Update maximum slice widths to include spacers.
  let max-slice-widths = array.zip(..lines.map(line => range(part-widths.len()).map(i => {
    let parts = line.split(align-point()).map(array.join)
    if i >= parts.len() {
      0pt
    } else {
      let slice = parts.slice(0, i + 1).join()
      calc.max(max-slice-widths.at(i), measure(equation(slice)).width)
    }
  }))).map(widths => calc.max(..widths))

  // Add spacers between parts to ensure correct spacing with combined parts.
  lines = for line in lines {
    let parts = line.split(align-point()).map(array.join)
    for i in range(max-slice-widths.len()) {
      if i >= parts.len() {
        break
      }
      let slice = parts.slice(0, i).join() + h(0pt) + parts.at(i)
      let slice-width = measure(equation(slice)).width
      if slice-width < max-slice-widths.at(i) {
        parts.at(i) = h(0pt) + box(fill: green, width: max-slice-widths.at(i) - slice-width) + h(0pt) + parts.at(i)
      }
    }
    (parts,)
  }

  // Append remaining spacers at the end for lines that have less align points.
  let line-widths = lines.map(line => measure(equation(line.join())).width)
  let max-line-width = calc.max(..line-widths)
  lines = lines.zip(line-widths).map(((line, line-width)) => {
    if line-width < max-line-width {
      line.push(h(0pt) + box(fill: red, width: max-line-width - line-width))
    }
    line
  })

  lines
}

// Applies show rules to the given body, so that block equations can span over
// page boundaries while retaining alignment. The equation number is stepped
// and displayed at every line, optionally with sub-numbering.
//
// Parameters:
// - breakable: Whether to allow page breaks within the equation.
// - sub-numbering: Whether to add sub-numbering to the equation.
// - number-mode: Whether to number all lines or only lines containing a label.
//                Must be either "line" or "label".
// - debug: Whether to show alignment spacers for debugging.
//
// Returns: The body with the applied show rules.
#let equate(
  breakable: auto,
  sub-numbering: false,
  number-mode: "line",
  debug: false,
  body
) = {
  // Validate parameters.
  assert(
    breakable == auto or type(breakable) == bool,
    message: "expected boolean or auto for breakable, found " + repr(breakable)
  )
  assert(
    type(sub-numbering) == bool,
    message: "expected boolean for sub-numbering, found " + repr(sub-numbering)
  )
  assert(
    number-mode in ("line", "label"),
    message: "expected \"line\" or \"label\" for number-mode, found " + repr(number-mode)
  )
  assert(
    type(debug) == bool,
    message: "expected boolean for debug, found " + repr(debug)
  )

  // This function was applied to a reference or label, so apply the reference
  // rule instead of the equation rule.
  if type(body) == label {
    return {
      show ref: equate-ref
      ref(body)
    }
  } else if body.func() == ref {
    return {
      show ref: equate-ref
      body
    }
  }

  show math.equation.where(block: true): set block(breakable: breakable) if type(breakable) == bool
  show math.equation.where(block: true): it => {
    // Allow a way to make default equations.
    if it.has("label") and it.label == <equate:revoke> {
      return it
    }

    // Make spacers visible in debug mode.
    show box.where(body: none): it => {
      if debug { it } else { hide(it) }
    }
    show box.where(body: none): set box(
      height: 0.4em,
      stroke: 0.4pt,
    ) if debug

    // Prevent show rules on figures from messing with replaced labels.
    show figure.where(kind: math.equation): it => {
      if it.body == none { return it }
      if it.body.func() != metadata { return it }
      none
    }

    // Main equation number.
    let main-number = counter(math.equation).get().first()

    // Resolve text direction.
    let text-dir = if text.dir == auto {
      if text.lang in (
        "ar", "dv", "fa", "he", "ks", "pa",
        "ps", "sd", "ug", "ur", "yi",
      ) { rtl } else { ltr }
    } else {
      text.dir
    }

    // Resolve number position in x-direction.
    let number-align = if it.number-align.x in (left, right) {
      it.number-align.x
    } else if text-dir == ltr {
      if it.number-align.x == start { left } else { right }
    } else if text-dir == rtl {
      if it.number-align.x == start { right } else { left }
    }

    let (numbered, lines) = replace-labels(
      to-lines(it),
      number-mode,
      it.numbering,
      it.supplement,
      it.has("label")
    )

    // Short-circuit for single-line equations.
    if lines.len() == 1 {
      if it.numbering == none { return it }
      if numbering(it.numbering, 1) == none { return it }

      let number = if numbered.len() > 0 {
        numbering(it.numbering, main-number)
      } else {
        // Step back counter as this equation should not be counted.
        counter(math.equation).update(n => n - 1)
      }

      return {
        // Update state to allow correct referencing.
        state.update(_ => sub-numbering)

        layout-line(
          lines.first(),
          number: number,
          number-align: number-align,
          text-dir: text-dir
        )

        // Step back counter as we introducted an additional equation
        // that increased the counter by one.
        counter(math.equation).update(n => n - 1)
      }
    }

    // Calculate maximum width of all numberings in this equation.
    let max-number-width = if it.numbering == none { 0pt } else {
      calc.max(0pt, ..range(numbered.len()).map(i => {
        let nums = if sub-numbering and numbered.len() > 1 {
          (main-number, i + 1)}
        else {
          (main-number + i,)
        }
        measure(numbering(it.numbering, ..nums)).width
      }))
    }

    // Update state to allow correct referencing.
    state.update(_ => sub-numbering)

    // Layout equation as grid to allow page breaks.
    block(grid(
      columns: 1,
      row-gutter: par.leading,
      ..realign(lines).enumerate().map(((i, line)) => {
        let sub-number = numbered.position(n => n == i)
        let number = if it.numbering == none {
          none
        } else if sub-number == none {
          // Step back counter as this equation should not be counted.
          counter(math.equation).update(n => n - 1)
        } else if sub-numbering and numbered.len() > 1 {
          numbering(it.numbering, main-number, sub-number + 1)
        } else {
          numbering(it.numbering, main-number + sub-number)
        }

        layout-line(
          line,
          number: number,
          number-align: number-align,
          number-width: max-number-width,
          text-dir: text-dir
        )
      })
    ))

    // Revert equation counter step(s).
    if it.numbering == none {
      // We converted a non-numbered equation into multiple empty-
      // numbered ones and thus increased the counter at every line.
      counter(math.equation).update(n => n - lines.len())
    } else {
      // Each line stepped the equation counter, but it should only
      // have been stepped once (when using sub-numbering). We also
      // always introduced an additional numbered equation that
      // stepped the counter.
      counter(math.equation).update(n => {
        n - if sub-numbering and numbered.len() > 1 { numbered.len() } else { 1 }
      })
    }
  }

  // Add show rule for referencing equation lines.
  show ref: equate-ref

  body
}
