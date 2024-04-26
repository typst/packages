// Element function for alignment points.
#let align-point = $&$.body.func()

// Sub-numbering state.
#let state = state("equate/sub-numbering", false)
  
// Extract lines and trim spaces.
#let to-lines(equation) = {
  let lines = if equation.body.has("children") {
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
  line
) = {
  // Short circuit if no number has to be added.
  if number == none {
    return math.equation(block: true, numbering: _ => none, line.join())
  }
  
  // Start of equation block.
  let x-start = here().position().x

  // Resolve number width.
  let number-width = if number-width == auto {
    measure(number).width
  } else {
    number-width
  }

  let equation-align = align.alignment.x

  layout(bounds => {
    // Add numbers to the equation body, so that they are aligned
    // at their respective baselines. They are wrapped in a zero-width box
    // to not mess with the center alignment.
    let body = line.join() + box(width: 0pt, context move(
      dx: x-start - here().position().x + if number-align.x == right { bounds.width },
      align(number-align, box(width: number-width, number))
    ))

    // Make numbering take up space.
    let pad-key = if equation-align == center { "x" }
                  else if number-align == left { "left" }
                  else { "right" }

    let pad-arg = ((pad-key): number-width)
    pad(..pad-arg, math.equation(numbering: _ => none, block: true, body))
  })
}

// Replace "fake labels" with a hidden figure that is labelled
// accordingly. 
#let replace-labels(lines, sub-numbering, numbering, supplement) = {
  // Main equation number.
  let main-number = counter(math.equation).get()
  
  lines.enumerate()
    .map(((i, line)) => {
      if line.len() == 0 { return line }

      let last = line.last()
      if last.func() != raw { return line }
      if last.lang != "typc" { return line }
      if last.text.match(regex("^<.+>$")) == none { return line }

      // Remove trailing spacing (before label).
      if line.at(-2, default: none) == [ ] { line.remove(-2) }
      
      // We use a figure with kind "equation" to make the sub-equation
      // referenceable with the correct supplement. The numbering is stored
      // in the figure body as metadata, as a counter would only show a
      // single number.
      line.at(-1) = [#figure(
        metadata(main-number + if lines.len() > 1 { (i + 1,) }),
        kind: math.equation,
        numbering: numbering,
        supplement: supplement
      )#label(last.text.slice(1, -1))]

      return line
    })
}

// Splitting an equation into multiple lines breaks the inbuilt alignment
// with alignment points, so it is emulated here by adding spacers manually.
#let realign(lines) = {
  // Utility shorthand for unnumbered block equation.
  let equation = math.equation.with(block: true, numbering: none)

  // Short-circuit if not alignment points.
  if lines.all(line => align-point() not in line) {
    return lines
  }
    
  // Store widths of each part between alignment points.
  let part-widths = lines.map(line => line
      .split(align-point())
      .map(part => measure(equation(part.join())).width))
  
  // Get maximum width of each part.
  let part-widths = for i in range(calc.max(..part-widths.map(points => points.len()))) {
    (calc.max(..part-widths.map(line => line.at(i, default: 0pt))), )
  }

  // Add spacers for each part, so that the part widths are the same for all lines.
  let lines = lines.map(line => {
    let parts = line.split(align-point())
  
    let spaced(i, spacing) = {
      let spacing = if spacing > 0pt { box(width: spacing) }
      if calc.even(i) {
        // Right align.
        spacing + parts.at(i).join()
      } else {
        // Left align.
        parts.at(i).join() + spacing
      }
    }
    
    parts.enumerate()
      .map(((i, part)) => {
        // Add spacer to make part the correct width.
        let width = part-widths.at(i) - measure(equation(part.join())).width
        let elem = equation(spaced(i, width))

        // Adjust for math class spacing between the spacer and the actual equation.
        equation(spaced(i, width + part-widths.at(i) - measure(elem).width))
      })
      .intersperse(align-point())
  })

  // Ensure correct spacing with all previous parts combined.
  let max-slice-widths = array.zip(..lines.map(line => range(part-widths.len()).map(i => {
    let parts = line.split(align-point()).map(array.join)
    if i >= parts.len() {
      0pt
    } else {
      let slice = parts.slice(0, i + 1).join()
      measure(equation(slice)).width
    }
  }))).map(widths => calc.max(..widths))

  lines = lines.map(line => {
    let parts = line.split(align-point()).map(array.join)
    for i in range(max-slice-widths.len()) {
      if i >= parts.len() {
        break
      }
      let slice = parts.slice(0, i + 1).join()
      let slice-width = measure(equation(slice)).width
      if slice-width < max-slice-widths.at(i) {
        parts.at(i) = box(width: max-slice-widths.at(i) - slice-width) + parts.at(i)
      }
    }
    parts
  })

  // Append remaining spacers at the end for lines that have less align points.
  let line-widths = lines.map(line => measure(equation(line.join())).width)
  let max-line-width = calc.max(..line-widths)
  lines = lines.zip(line-widths).map(((line, line-width)) => {
    if line-width < max-line-width {
      line.push(box(width: max-line-width - line-width))
    }
    line
  })
  
  lines
}

#let equate(sub-numbering: false, debug: false, body) = {
  show math.equation.where(block: true): it => {
    // Allow a way to make default equations.
    if it.has("label") and it.label == <equate:revoke> {
      return it
    }

    // Make spacers visible in debug mode.
    show box.where(body: none): set box(
      height: 0.5em,
      stroke: 0.4pt,
      fill: yellow
    ) if debug
    
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
    
    let lines = replace-labels(to-lines(it), sub-numbering, it.numbering, it.supplement)
    let equation = math.equation.with(block: it.block, numbering: none)

    // Short-circuit for single-line equations.
    if lines.len() == 1 {
      if it.numbering == none { return it }
      if numbering(it.numbering, 1) == none { return it }

      return {
        // Update state to allow correct referencing.
        state.update(_ => sub-numbering)
        
        layout-line(
          lines.first(),
          number: numbering(it.numbering, main-number),
          number-align: number-align
        )

        // Step back counter as we introducted an additional equation
        // that increased the counter by one.
        counter(math.equation).update(n => n - 1)
      }
    }

    // Calculate maximum width of all numberings in this equation.
    let max-number-width = if it.numbering == none { 0pt } else {
      calc.max(..range(lines.len()).map(i => {
        let nums = if sub-numbering {(main-number, i + 1)} else {(main-number + i,)}
        measure(numbering(it.numbering, ..nums)).width
      }))
    }

    // Update state to allow correct referencing.
    state.update(_ => sub-numbering)

    // Layout equation as grid to allow page breaks.
    grid(
      columns: 1,
      row-gutter: par.leading,
      ..realign(lines).enumerate().map(((i, line)) => {
        let number = if it.numbering == none {
          none
        } else if sub-numbering {
          numbering(it.numbering, main-number, i + 1)
        } else {
          numbering(it.numbering, main-number + i)
        }

        layout-line(
          line,
          number: number,
          number-align: number-align,
          number-width: max-number-width
        )
      })
    )

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
        n - if sub-numbering { lines.len() } else { 1 }
      })
    }
  }

  // Add support for sub-numbering in references.
  show ref: it => {
    if it.element == none { return it }
    if it.element.func() != figure { return it }
    if it.element.kind != math.equation { return it }
    if it.element.body == none { return it }
    if it.element.body.func() != metadata { return it }

    // Display correct number, depending on whether sub-numbering was enabled.
    let nums = if state.at(it.element.location()) {
      it.element.body.value
    } else {
      (it.element.body.value.sum() - 1,)
    }

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
  
  body
}
