#import "content.typ" as ct

/// Return the widths of the gutter columns: the numbers and the markers.
///
/// - number (dictionary): The number parameters, with its cells (which contain the line markers placed over the numbers).
/// - marker (dictionary): The marker column parameters, with all the markers of the number column (`number-markers`) and of the marker column (`markers`).
/// - widest (none, str, content): Some content the number column must be wide enough for (the widest number of the following blocks).
/// - monotonic (bool): Whether the widest numbers are the first and the last shown ones (as for the numbers themselves), so that only them are measured.
/// -> array
#let numbers-markers-width(number, marker, widest: none, monotonic: false) = {
  let max-width(contents) = calc.max(0pt, ..contents.map(c => measure(c).width))

  let numbers-width = if number.visible {
    // (the lines without number having empty cells)
    let cells = number.cells.filter(c => c != [])
    if monotonic and cells.len() > 2 { cells = (cells.first(), cells.last()) }
    (
      number.inset.left
        + calc.max(
          max-width(cells),
          max-width(marker.number-markers),
          max-width(if widest != none { (widest,) } else { () }),
        )
        + number.inset.right
    )
  } else { 0mm }

  let markers-width = if marker.visible {
    marker.inset.left + max-width(marker.markers) + marker.inset.right
  } else { 0mm }

  return (numbers-width, markers-width)
}

/// Return the maximum width of the code.
///
/// - layout-size (dictionary): The layout dimensions.
/// - frame (dictionary): The frame parameters.
/// - code (dictionary): The code parameters.
/// - numbers-width (length):
/// -> length
#let available-code-width(layout-size, frame, code, numbers-width) = {
  let frame-width = if frame.width == auto {
    layout-size.width
  } else if type(frame.width) == ratio {
    layout-size.width * frame.width
  } else {
    frame.width
  }

  return (
    frame-width - numbers-width - (code.inset.left + code.inset.right)
  ).to-absolute()
}

/// Return the actual width filled by the code.
///
/// - frame (dictionary): The frame parameters.
/// - code-width (length):
/// - lang-tag (dictionary): The parameters of the lang tag.
/// - it-lines (array): The formatted lines of the document.
/// - char-width (length):
/// -> length
#let tight-code-width(frame, code-width, lang-tag, it-lines, char-width) = {
  if frame.width == auto {
    let lines-width = it-lines.map(l => l.slines.map(sl => (
      sl.offset * char-width + measure(sl.body).width
    )))

    if lang-tag.placement == "inline" and lines-width.len() > 0 {
      lines-width.at(0).at(0) += lang-tag.width
    } else if lang-tag.placement == "code" {
      lines-width = lines-width.map(sl => sl.map(w => w + lang-tag.width))
    }

    lines-width = lines-width.map(lens => calc.max(..lens))

    return calc.min(code-width, calc.max(..lines-width))
  } else {
    return code-width
  }
}

/// The code width when the header and footer are taken into account.
///
/// - header-width (length):
/// - numbers-width (length):
/// - code (dictionary): The code parameters.
/// - code-width (length):
/// - footer-width (length):
/// -> length
#let hf-code-width(
  header-width,
  numbers-width,
  code,
  code-width,
  footer-width,
) = {
  calc.max(
    code-width,
    (
      header-width - numbers-width - code.inset.left - code.inset.right
    ).to-absolute(),
    (
      footer-width - numbers-width - code.inset.left - code.inset.right
    ).to-absolute(),
  )
}

/// The code width when the comments are taken into account.
///
/// - frame (dictionary): The frame parameters.
/// - comments (array): The formatted comments, with the position of the code in their cell (`code-offset`).
/// - code (dictionary): The code parameters.
/// - code-width (length):
/// - max-code-width (length): The maximum width available for the code.
/// -> length
#let comments-code-width(
  frame,
  comments,
  code,
  code-width,
  max-code-width,
) = if frame.width == auto {
  calc.max(
    code-width,
    ..comments.map(c => calc.min(
      max-code-width,
      (
        c.inset.left
          + measure(c.body).width
          + c.inset.right
          - c.code-offset
          - code.inset.left
          - code.inset.right
      ).to-absolute(),
    )),
  )
} else {
  code-width
}

/// Return the actual width filled by the lines of pseudo code.
///
/// - frame (dictionary): The frame parameters.
/// - code-width (length): The available code width.
/// - bodies (array): The contents of the lines (see `pseudo-line-body`).
/// -> length
#let pseudo-code-width(frame, code-width, bodies) = if frame.width == auto {
  calc.min(code-width, calc.max(0pt, ..bodies.map(b => measure(b).width)))
} else { code-width }

/// Return the height of each line of pseudo code.
///
/// - bodies (array): The contents of the lines (see `pseudo-line-body`).
/// - code (dictionary): The code parameters.
/// - code-width (length):
/// - char-height (length): The height of a line of text.
/// -> array
#let pseudo-lines-height(bodies, code, code-width, char-height) = bodies.map(
  b => (
    calc.max(char-height, measure(block(width: code-width, b)).height)
      + code.line-spacing.to-absolute()
  ),
)

// The widths of the codes of a diff, from the `columns` setting and the natural widths of the codes: the automatic ones take their natural width, the fractions share the rest (too large automatic separated codes sharing the available width), and the automatic ones share the rest of a fixed width
#let diff-code-widths(columns, natural, available, fill) = {
  if (
    columns.len() == 2
      and columns.all(c => c == auto)
      and natural.sum() > available
  ) {
    columns = (1fr, 1fr)
  }

  let widths = columns.map(c => if c == auto or type(c) == fraction {
    none
  } else if type(c) == ratio { available * c } else if type(c) == relative {
    available * c.ratio + c.length.to-absolute()
  } else { c.to-absolute() })
  let fixed = widths.filter(w => w != none).sum(default: 0pt)

  let autos = range(columns.len()).filter(k => columns.at(k) == auto)
  for k in autos {
    widths.at(k) = calc.min(natural.at(k), calc.max(0pt, available - fixed))
    fixed += widths.at(k)
  }

  let total-fr = columns
    .filter(c => type(c) == fraction)
    .map(c => c / 1fr)
    .sum(default: 0)
  let rest = calc.max(0pt, available - fixed)
  for (k, c) in columns.enumerate() {
    if type(c) == fraction { widths.at(k) = rest * (c / 1fr) / total-fr }
  }

  if fill and total-fr == 0 and autos.len() > 0 {
    let rest = calc.max(0pt, available - widths.sum())
    for k in autos { widths.at(k) += rest / autos.len() }
  }

  widths
}
