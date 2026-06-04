#import "hex.typ": crossregex-hex
#import "square.typ": crossregex-square

/// Make a wonderful cross-regex puzzle. This is a dispatcher function.
/// All of the arguments apply to `crossregex-hex` or `crossregex-square`.
///
/// - size (int): The size of the grids, namely the number of cells on the edge.
/// - alphabet (regex): The set of acceptable characters, used for highlight.
/// - constraints (array): All constraint regular expressions, given in clockwise order.
/// - answer (none, array, content): Your answers, either a multi-line raw block or an array of strings. The character in one cell is represented as a char in the string.
/// - show-whole (bool): Whether to show all constraints in one page.
/// - show-views (bool): Whether to show three views separately.
/// - cell (content): The shape of grid cells.
/// - cell-config (dict): Controls the appearance of cells. Defaults: (size: 1em, text-style: (:), valid-color: blue, invalid-color: purple). The text-style applies to the cell texts.
/// - deco-config (dict): Controls the appearance of decorations (hint marker + regex). Defaults: (hint-offset: 0.5em, hint-marker: auto, regex-offset: 1.0em, regex-style: auto).
/// - progress-creator (function, none): The creator function of progress: (total, filled) => content. If set to none, the progress is not shown.
/// - page-margin (length, dict): The margin of each page.
#let crossregex(size, shape: "hex", ..args) = {
  if shape == "hex" {
    crossregex-hex(size, ..args)
  } else if shape == "square" {
    crossregex-square(size, ..args)
  } else {
    panic("unsupported shape: " + repr(shape))
  }
}
