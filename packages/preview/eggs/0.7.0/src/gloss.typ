#import "@preview/elembic:1.1.1" as e

#import "utils.typ": auto-length, prefix, gen-get-function


#let split-line(line, separator: [ ]) = {
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

#let build-gloss-grid(lines, styles, word-spacing, line-spacing) = {
  let len = lines.at(0).len()

  for word-index in range(0, len) {
    let words = lines.map(line => line.at(word-index))
    let args = words.zip(styles).map(((word, style)) => style(word))
    box(grid(row-gutter: line-spacing, ..args))
    h(word-spacing)
  }
}

#let build-gloss(
  elem
) = {

  let lines = elem.body.map(split-line)
  assert(lines.len() > 0, message: "at least one gloss line must be present")

  // guard against invalid line lengths
  for line in lines {
    assert(line.len() == lines.at(0).len(), message: "gloss lines have different lengths")
  }

  // fill missing styles with defaults
  let styles = elem.styles
  if styles.len() < lines.len() {
    styles += (x => x,) * (lines.len() - styles.len())
  }
  block(
    above: (elem.get-before-spacing)(),
    below: (elem.get-after-spacing)(),
    build-gloss-grid(
      lines,
      styles,
      elem.word-spacing,
      (elem.get-line-spacing)(),
    )
  )
}

/// Interlinear gloss grid.
///
/// - body (content): Any number of rows of equal length. Rows can be either contents where elements are separated by more than one space or lists.
///
///   *Required*
///
/// - word-spacing (length): Horizontal spacing between words in glosses.
///
///   *Default*: 1em
///
/// - line-spacing (length): Vertical spacing between lines in glosses.
///
///   *Default*: current `par.leading`.
///
/// - before-spacing (length): Vertical spacing above glosses (i.e. after the preamble).
///
///   *Default*: current `par.leading`.
///
/// - after-spacing (length): Vertical spacing below glosses (i.e. before the translation).
///
///   *Default*: current `par.leading`.
///
/// - styles (array): List of functions to be applied to each line of glosses.
///   Can be of any length. `gloss-styles[0]` is applied to the first line,
///   `gloss-styles[1]` --- to the second, etc.
///   E.g. ```typst (emph, it => it + [.])``` makes the first line italicized
///   and adds a period to the second line.
///
///   *Default*: ()
///
///
/// -> content
#let gloss = e.element.declare(
  "gloss",
  prefix: prefix,
  doc: "Interlinear gloss grid",
  labelable: false,

  fields: (
    e.field("body", array, required: true, doc: "Any number of rows of equal length. Rows can be either contents where elements are separated by more than one space or lists."),
    e.field("word-spacing", length, default: 1em, doc: "Horizontal spacing between words in glosses."),
    e.field("line-spacing", auto-length, doc: "Vertical spacing between lines in glosses. Defaults to `par.leading`."),
    e.field("before-spacing", auto-length, doc: "Vertical spacing above glosses (i.e. after the preamble). Defaults to `par.leading`."),
    e.field("after-spacing", auto-length, doc: "Vertical spacing below glosses (i.e. before the translation). Defaults to `par.leading`."),
    e.field("styles", array, doc: "List of functions to be applied to each line of glosses. Can be of any length. `gloss-styles[0]` is applied to the first line, `gloss-styles[1]` --- to the second, etc. E.g. ```typst (emph, it => it + [.])``` makes the first line italicized and adds a period to the second line."),

    e.field("get-line-spacing", function, synthesized: true, default: () => par.leading),
    e.field("get-before-spacing", function, synthesized: true, default: () => par.leading),
    e.field("get-after-spacing", function, synthesized: true, default: () => par.leading),
  ),

  parse-args: (default-parser, fields: none, typecheck: none) => (args, include-required: false) => {
    let args = if include-required {
      arguments(args.pos(), ..args.named())
    } else if args.pos() == () {
      args
    } else {
      return (false, "element 'sunk': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },

  synthesize: it => gen-get-function(
    it,
    ("line-spacing", par.leading),
    ("before-spacing", par.leading),
    ("after-spacing", par.leading)
  ),

  display: build-gloss
)
