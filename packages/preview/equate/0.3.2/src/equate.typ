// Element function for alignment points.
#let align-point = $&$.body.func()

// Element function for sequences.
#let sequence = $a b$.body.func()

// Element function for a counter update.
#let counter-update = counter(math.equation).update(1).func()

// State for tracking whether equate is enabled.
#let equate-state = state("equate/enabled", 0)

// State for tracking the sub-numbering property.
#let sub-numbering-state = state("equate/sub-numbering", false)

// State for tracking the shared alignment block we're in.
#let share-align-state = state("equate/share-align", (stack: (), max: 0))

// State for tracking whether we're in a nested equation.
#let nested-state = state("equate/nested-depth", 0)

// Show rule necessary for referencing equation lines, as the number is not
// stored in a counter, but as metadata in a figure.
#let equate-ref(it) = {
  if it.element == none { return it }
  if it.element.func() != figure { return it }
  if it.element.kind != math.equation { return it }
  if it.element.body == none { return it }
  if it.element.body.func() != metadata { return it }

  // Display correct number, depending on whether sub-numbering was enabled.
  let nums = if sub-numbering-state.at(it.element.location()) {
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
      let counting-symbols = ("1", "a", "A", "i", "I", "一", "壹", "あ", "い", "ア", "イ", "א", "가", "ㄱ", "*", "①", "⓵")
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
  } else if type(it.supplement) == function {
    (it.supplement)(it.element)
  } else {
    it.supplement
  }

  link(it.element.location(), if supplement not in ([], none) [#supplement~#num] else [#num])
}

// Replace all lr elements with their (stretched) body.
// Necessary to correctly extract lines from equations.
#let replace-lr(eq) = {
  let equation(body) = [
    #math.equation(
      block: true,
      numbering: none,
      body
    ) <equate:revoke>
  ]

  let height(body) = measure(equation(body)).height

  let children = if eq.body.func() == sequence {
    eq.body.children
  } else {
    (eq.body,)
  }

  math.equation(children.map(child => {
    if type(child) != content or child.func() != math.lr {
      child
    } else {
      // Unwrap nested lr elements (e.g. `lr(size: #2em, (a + b))`)
      let lr-size = child.fields().at("size", default: 100%)
      if child.body.func() == math.lr {
        child = child.body
        if child.has("size") { lr-size = child.size }
      }

      let lines = if child.body.func() == sequence {
        child.body.children.split(linebreak())
      } else {
        ((child.body,),)
      }

      let (first, ..mid, last) = if child.body.func() == sequence {
        child.body.children
      } else {
        ([], child.body, [])
      }

      // Don't take unstretchable boundaries into account.
      if height(first) == height(math.stretch(size: 200%, first)) {
        mid = (first, ..mid)
        first = none
      }
      if height(last) == height(math.stretch(size: 200%, last)) {
        mid = (..mid, last)
        last = none
      }

      let size = calc.max(..lines.map(line => {
        height(math.lr(size: lr-size, first + line.join() + last))
      }))

      // Manually stretch first/last and mid elements.
      let stretched(first, mid, last, size) = {
        if first != none { math.stretch(size: size, first) }
        mid.map(child => if child.func() == math.mid {
          math.class("large", math.stretch(size: size, child))
        } else {
          child
        }).join()
        if last != none { math.stretch(size: size, last) }
      }

      // Take possible short-fall into account. We may need multiple iterations
      // to ensure that the stretched height matches the original height, and
      // that the middle elements are stretched to the same size.
      let shortfall = 0pt
      for i in range(5) {
        let delta = calc.max(..lines.map(line => {
          height(stretched(first, line, last, size - shortfall))
        })) - size

        if delta == 0pt { break }
        shortfall += delta
      }

      stretched(first, mid, last, size - shortfall)
    }
  }).join())
}

// Extract lines and trim spaces.
#let to-lines(equation) = {
  equation = replace-lr(equation)

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
  let equation(body, measure: false) = [
    // We may need to measure the width of the equation, so it has to be auto.
    #show math.equation: set block(width: auto) if measure
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
  let line-width = measure(equation(line.join(), measure: true)).width
  let gap = 0.5em

  layout(bounds => {
    let space = if bounds.width.pt().is-infinite() {
      // If we're in an unbounded container, the number is placed right next to
      // the equation body, with only the `gap` as spacing.
      0pt
    } else if equation-align == center {
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

  // Indices of lines that are marked not to be numbered.
  let revoked = lines
    .enumerate()
    .filter(((i, line)) => {
      if i not in labelled { return false }
      return line.last().text == "<equate:revoke>"
    })
    .map(((i, _)) => i)

  // The "revoke" label shall not count as a labelled line.
  labelled = labelled.filter(i => i not in revoked)

  // Indices of numbered lines in this equation.
  let numbered = if number-mode == "line" {
    range(lines.len()).filter(i => i not in revoked)
  } else if labelled.len() == 0 and has-label {
    // Only outer label, so number all lines.
    range(lines.len()).filter(i => i not in revoked)
  } else {
    labelled
  }

  (
    numbered,
    lines.enumerate()
      .map(((i, line)) => {
        if i in revoked {
          // Remove "revoke" label and space and return line.
          let _ = line.remove(-1)
          let _ = if line.at(-2, default: none) == [ ] { line.remove(-2) }
          return line
        }

        if i not in labelled { return line }

        // Remove trailing spacing (before label).
        let _ = if line.at(-2, default: none) == [ ] { line.remove(-2) }

        // Append sub-numbering.
        let nums = main-number + if numbered.len() > 0 {
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

        line
      })
  )
}

// Remove labels from lines, so that they don't interfere when measuring.
#let remove-labels(lines) = {
  lines.map(line => {
    if line.len() == 0 { return line }
    if line.last().func() != raw { return line }
    if line.last().lang != "typc" { return line }
    if line.last().text.match(regex("^<.+>$")) == none { return line }

    let _ = line.remove(-1)
    let _ = if line.at(-1, default: none) == [ ] { line.remove(-1) }
    line
  })
}

// Splitting an equation into multiple lines breaks the inbuilt alignment
// with alignment points, so it is emulated here by adding spacers manually.
#let realign(lines) = {
  // Utility shorthand for unnumbered block equation.
  let equation(body) = [
    // We need this for measuring the width, so it has to be auto.
    #show math.equation: set block(width: auto)
    #math.equation(
      block: true,
      numbering: none,
      body
    ) <equate:revoke>
  ]

  // Consider lines of other equations in shared alignment block.
  let extra-lines = if share-align-state.get().stack != () {
    let num = share-align-state.get().stack.last()
    let align-state = state("equate/align/" + str(num), ())
    remove-labels(align-state.final())
  } else {
    ()
  }

  let lines = extra-lines + lines

  // Short-circuit if no alignment points.
  if lines.all(line => align-point() not in line) {
    return lines.slice(extra-lines.len())
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

  lines.slice(extra-lines.len())
}

// Any block equation inside this block will share alignment points, thus
// allowing equations to be interrupted by text and still be aligned.
// 
// Sub-numbering is not (yet) continued across equations in this block, so
// each new equation will get a new main number. Equations with a revoke label
// will not share alignment with other equations in this block.
// 
// Requires the equate show rule to be enabled.
#let share-align(body) = {
  context assert(
    equate-state.get() > 0,
    message: "shared alignment block requires equate to be enabled."
  )

  share-align-state.update(((stack, max)) => (
    stack: stack + (max + 1,),
    max: max + 1
  ))

  show math.equation.where(block: true): it => {
    // Allow a way to exclude equations from shared alignment.
    if it.has("label") and it.label == <equate:revoke> {
      return it
    }

    let num = share-align-state.get().stack.last()
    let align-state = state("equate/align/" + str(num), ())
    let lines = to-lines(it)
    align-state.update(total-lines => total-lines + lines)
    it
  }

  body

  share-align-state.update(((stack, max)) => (
    stack: stack.slice(0, -1),
    max: max
  ))
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
    // Don't apply show rule in a nested equations.
    if nested-state.get() > 0 {
      return it
    }

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
    if lines.len() == 1 and share-align-state.get().stack == () {
      if it.numbering == none { return it }
      if numbering(it.numbering, 1) == none { return it }

      let number = if numbered.len() > 0 {
        let include-sub-number = sub-numbering and (
          lines.first().last().func() == figure
          and lines.first().last().kind == math.equation
          and lines.first().last().body.func() == metadata
        )
        numbering(it.numbering, main-number, ..if include-sub-number { (1,) })
      } else {
        // Step back counter as this equation should not be counted.
        counter(math.equation).update(n => n - 1)
      }

      return {
        // Update state to allow correct referencing.
        sub-numbering-state.update(_ => sub-numbering)

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
    sub-numbering-state.update(_ => sub-numbering)

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
        } else if sub-numbering {
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

  // Apply this show rule first to update nested state.
  // This works because the context provided by the other show rule does not
  // yet include the updated state, so it can be retrieved correctly.
  show math.equation.where(block: true): it => {
    // Turn off numbering for nested equations, as it's usually unwanted.
    // Workaround for https://github.com/typst/typst/issues/5263.
    set math.equation(numbering: none)

    nested-state.update(n => n + 1)
    it
    nested-state.update(n => n - 1)
  }

  // Add show rule for referencing equation lines.
  show ref: equate-ref

  equate-state.update(n => n + 1)
  body
  equate-state.update(n => n - 1)
}
