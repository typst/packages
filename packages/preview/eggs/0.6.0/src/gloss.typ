#import "config.typ": auto-sub

#let build-gloss(lines, styles, word-spacing, line-spacing) = {
  let len = lines.at(0).len()

  for word-index in range(0, len) {
    let words = lines.map(line => line.at(word-index))
    let args = words.zip(styles).map(((word, style)) => style(word))
    box(grid(row-gutter: line-spacing, ..args))
    h(word-spacing)
  }
}

/// Typesets a block of interlinear glosses.
#let gloss(
  /// Any number of rows of equal length.
  /// Rows can be either contents where elements are separated
  /// by more than one space or lists. -> content | array
  ..args,
) = {
  let split-line(line, separator: [ ]) = {
    if type(line) == array {
      return line
    }
    assert(type(line) == content)
    // one-word line
    if "children" not in line.fields() {
      return (line,)
    }
    line.children.split(separator).filter(it => it != ()).map([].func())
  }

  let lines = args.pos().map(split-line)
  assert(lines.len() > 0, message: "at least one gloss line must be present")

  // guard against invalid line lengths
  for line in lines {
    assert(line.len() == lines.at(0).len(), message: "gloss lines have different lengths")
  }

  context {
    let config = state("eggs-config").get()
    assert(config != none, message: "`show: eggs` must be used before `gloss`")

    // fill missing styles with defaults
    let styles = config.gloss.styles
    if styles.len() < lines.len() {
      styles += (x => x,) * (lines.len() - styles.len())
    }
    block(
      above: auto-sub(config.gloss.before-spacing, par.leading),
      below: auto-sub(config.gloss.after-spacing, par.leading),
      build-gloss(
        lines,
        styles,
        config.gloss.word-spacing,
        auto-sub(config.gloss.line-spacing, par.leading),
      )
    )
  }
}
