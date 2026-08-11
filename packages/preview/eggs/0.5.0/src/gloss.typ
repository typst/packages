#import "config.typ": auto-sub

#let build-gloss(lines, styles, word-spacing, line-spacing,) = {
    let make-word-box(..args) = {
        context{
          box(grid(row-gutter: line-spacing, ..args))
        }
    }

    let len = lines.at(0).len()

    for word-index in range(0, len) {
        let args = ()
        for (line, style) in lines.zip(styles) {
            let word = line.at(word-index)
            args.push(style(word))
        }
        make-word-box(..args)
        h(word-spacing)
    }
}

// content -> array
#let split(line, separator: [ ]) = {

  // one-word lines
  if "children" not in line.fields() {
    return (line,)
  }

  let res = ()
  let accum = ()
  for child in line.children {
    if child == [ ] and accum != () {
      res.push(accum)
      accum = ()
    }
    else {
      accum.push(child)
    }
  }
  if accum != () {
    res.push(accum)
  }
  return res.map([].func())
}

// (content | array) -> array
#let split-if(line, separator: [ ]) = {
  if type(line) == content {
    return split(line)
  } else {
    assert(type(line) == array, message: "lines must be either arrays or contents, but " + repr(line) + " is " + str(type(line)))
    return line
  }
}

/// Typesets a block of interlinear glosses.
#let gloss(
  /// The number used to refer to the example in error messages. -> string
  example-number: none,
  /// Any number of rows of equal length.
  /// Rows can be either contents where elements are separated
  /// by more than one space or lists. -> content | array
  ..args,
) = context {
  let config = state("eggs-config").get()
  assert(config != none, message: "`show: eggs` must be used before `gloss`")

  let lines = args.pos()
  assert(lines.len() > 0, message: "at least one gloss line must be present")

  // guard against invalid line lengths
  let lines-split = lines.map(split-if)
  let first-line = lines-split.at(0)
  for line in lines-split {
    // don't generate the error message until the error is confirmed
    // (assert's `message` is not lazy)
    if line.len() != first-line.len() {
      assert(line.len() == first-line.len(), message: {
        if example-number != none {
          "at example " + str(example-number) + ": "
        } + "gloss lines have different lengths: " + repr(line.join()) + " and " + repr(first-line.join())
      })
    }
  }

  // fill missing styles with defaults
  let styles = config.gloss.styles
  if styles.len() < lines.len() {
    styles += (x => x,) * (lines.len() - styles.len())
  }
  block(
    above: auto-sub(config.gloss.before-spacing, par.leading),
    below: auto-sub(config.gloss.after-spacing, par.leading),
    build-gloss(
      lines-split,
      styles,
      config.gloss.word-spacing,
      auto-sub(config.gloss.line-spacing, par.leading),
    )
  )
}
