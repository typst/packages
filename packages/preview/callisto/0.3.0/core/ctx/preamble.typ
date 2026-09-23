#import "@preview/cmarker:0.1.10"

#import "/core/latex.typ"
#import "/core/reading/notebook.typ"

// Wrap the math item arguments in a labelled metadata
#let _math-metadata(..args) = [#metadata(args)<__callisto-math-item>]

// Return true if the content item is an extracted math item
#let _is-math-item(it) = it.at("label", default: none) == <__callisto-math-item>

// Extract an array of math items from the given Markdown string.
// Each item is returned as an 'arguments' value holding the arguments that
// cmarker passes to the 'math' callback for rendering the math item.
// This includes at least
// - a positional argument for the string holding the LaTeX math
// - a 'block' argument set to true for block equations
#let _extract-math(markdown) = {
  let rendered = cmarker.render(
    markdown,
    math: _math-metadata,
    scope: (image: (..args) => none),
    heading-labels: "jupyter",
  )
  // For sequence, gather all math items among the children
  if rendered.func() == [].func() {
    return rendered.children.filter(_is-math-item).map(x => x.value)
  }
  // Otherwise we have at most one item
  if _is-math-item(rendered) {
    return (rendered.value,)
  }
  return ()
}

// Get the LaTeX definitions found in the math items in the given cell.
// Each item is returned as a regex match in which the 'text' field
// holds the command definition.
#let _cell-latex-defs(c) = {
  _extract-math(c.source)
    .map(args => latex.definitions(args.at(0)))
    .join()
}

// Gather all LaTeX \newcommand definitions from the given notebook cells
// and return the corresponding LaTeX preamble as string.
// Returns none if there is no notebook or no LaTeX definition in there.
// This is done to support commands defined in one Markdown LaTeX equation and
// used in a later one (as supported by MathJax and often used in Jupyter
// notebook although it's not valid in real LaTeX). There are two caveats:
// 1. Only '\newcommand' gets this special treatment. MathJax also supports
//    definitions through '\def', '\newenvironment', '\renewcommand', etc. but
//    these don't get any special treatment here.
// 2. MathJax allows using '\newcommand' instead of '\renewcommand' to
//    redefine an existing command, while LaTeX and MiTeX do not. There's no
//    good way for us to support this
//    in the general case (e.g. when a single equation defines a command
//    several times with different values) so we only allow duplicate
//    definitions when they are redundant (redefining a command to the same
//    value) and raise an error otherwise. This covers the most common case
//    of duplicate definitions, where an equation or cell is duplicated by
//    copy-paste.
#let latex-preamble(cells) = {
  // Get all Markdown cells and normalize source
  let md-cells = cells
    .filter(c => c.cell_type == "markdown")
    .map(notebook.normalize-cell-source)

  // Get array of matches for command definitions
  let defs = md-cells.map(_cell-latex-defs).join()
  if defs == none {
    return none
  }

  // Convert array to preamble string
  return latex.make-preamble(defs)
}
