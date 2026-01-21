#let _grid = grid

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: free-form
/// Write an answer.
/// #free-form.plain(placeholder: [...], stroke: 0.5pt, stretch: 200%)[
///   an answer
/// ]
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - placeholder (auto, content): the placeholder to display instead of hiding the answer. For the
///   layout of exam and solution to match, this needs to have the same height as the answer.
/// - height (auto, relative): the height of the region where an answer can be written
/// - stretch (ratio): the amount by which the height of the answer region should be stretched
///   relative to the required height of the provided solution. Can only be set to a value other
///   than 100% if `height == auto`.
/// - stroke (none, stroke): the stroke of the box to draw around the answer area
/// -> content
#let plain(
  answer,
  placeholder: auto,
  height: auto,
  stretch: 100%,
  stroke: none,
) = layout(((width,)) => {
  import "../solution.typ"
  let (answer, height) = (answer, height)

  assert(
    height == auto or stretch == 100%,
    message: "a `stretch` value other than 100% is only allowed if `height == auto`.",
  )

  answer = solution.answer(answer, placeholder: placeholder)

  let answer-block = block.with(
    width: 100%,
    outset: (x: 0.3em, y: 0.4em),
    inset: (y: 0.3em),
    stroke: stroke,
    align(horizon, answer),
  )

  if stretch != 100% {
    height = measure(answer-block(width: width)).height * stretch
  }
  answer-block(height: height)
})

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// This answer type is meant for text questions and shows a lines to write on. By default, the
/// lines are spaced to match a regular paragraph (assuming the text styles are not changed within
/// the answer) and the number of lines depends on what is needed for the sample solution. If a
/// `line-height` is explicitly set, the `par.leading` is adjusted to make the sample solution
/// fit the lines. Paragraph spacing is currently not adjusted, so for the answer to look nice, it
/// should only be a single paragraph.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: free-form
/// Write an answer.
/// #free-form.lines(placeholder: [...\ ...], count: 150%, stretch: 200%)[
///   this answer takes \ more than one line
/// ]
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - placeholder (auto, content): the placeholder to display instead of hiding the answer. For the
///   layout of exam and solution to match, this needs to have the same height as the answer.
/// - count (auto, int, ratio): the number of lines to show; defaults to however many are needed for
///   the answer. If given as a ratio, the `auto` line number is multiplied by that and rounded up.
/// - line-height (auto, relative): the line height; defaults to what printed lines naturally take
/// - stretch (ratio): the amount by which the line height should be stretched relative to the
///   regular line height. Can only be set to a value other than 100% if `line-height == auto`.
/// - stroke (none, stroke): the stroke of the lines to draw
/// -> content
#let lines(
  answer,
  placeholder: auto,
  count: auto,
  line-height: auto,
  stretch: 100%,
  stroke: 0.5pt,
) = layout(((width,)) => {
  import "../solution.typ"
  let (answer, count, line-height) = (answer, count, line-height)

  assert(
    line-height == auto or stretch == 100%,
    message: "a `stretch` value other than 100% is only allowed if `line-height == auto`.",
  )

  answer = solution.answer(answer, placeholder: placeholder)

  // transform lines to be of the right height, and adjust the line height variable if necessary
  show: {
    // the height advance of one line
    let line-advance = measure[a\ a].height - measure[a].height

    if line-height != auto {
      // explicit line height; don't adjust the value but adjust the leading
      body => {
        set par(leading: par.leading + line-height - line-advance)
        body
      }
    } else if stretch == 100% {
      // implicit line height; adjust the value but not the leading
      line-height = line-advance

      body => body
    } else {
      // stretched line height; adjust the value and the leading
      line-height = line-advance * stretch

      body => {
        set par(leading: par.leading + line-height - line-advance)
        body
      }
    }
  }

  // start a new context block so we can measure using the new leading
  context {
    let count = count
    if type(count) != int {
      let multiplier = if count == auto { 1 } else  { count / 100% }
      // measure the height, then divide by the line height; round up
      count = calc.ceil(measure(block(width: width, answer)).height / line-height)
      count = calc.ceil(count * multiplier)
    }

    block({
      v(-0.3em)
      _grid(
        columns: (1fr,),
        rows: (line-height,) * count,
        stroke: (bottom: stroke),
      )
      place(top, answer, dy: par.leading / 2)
    })
  }
})

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// This answer type is meant for math and graphing tasks and shows a grid of lines. By default, the
/// grid has a 5mm raster, and occupies enough vertical space to contain the answer. The grid fits
/// the available width; use padding or similar to make it more narrow.
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: free-form
/// Draw a circle with the given center.
/// #free-form.grid(stretch: 125%, {
///   place(dx: 19.7mm, dy: 9.7mm, circle(radius: 0.3mm))
///   pad(left: 15mm, y: 5mm, circle(radius: 5mm))
/// }, placeholder: {
///   place(dx: 19.7mm, dy: 9.7mm, circle(radius: 0.3mm))
/// })
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - placeholder (auto, content): the placeholder to display instead of hiding the answer. For the
///   layout of exam and solution to match, this needs to have the same height as the answer.
/// - height (auto, relative): the height of the grid region
/// - stretch (ratio): the amount by which the height of the answer region should be stretched
///   relative to the required height of the provided solution. Can only be set to a value other
///   than 100% if `height == auto`.
/// - size (relative, dictionary): grid size, or a dictionary containing `width` and `height`
/// - stroke (none, stroke): the stroke of the grid to draw
/// -> content
#let grid(
  answer,
  placeholder: auto,
  height: auto,
  stretch: 100%,
  size: 5mm,
  stroke: 0.5pt+gray,
) = layout(((width,)) => {
  import "../solution.typ"
  let (answer, height, size) = (answer, height, size)

  assert(
    height == auto or stretch == 100%,
    message: "a `stretch` value other than 100% is only allowed if `height == auto`.",
  )

  answer = solution.answer(answer, placeholder: placeholder)

  if type(size) != dictionary {
    size = (width: size, height: size)
  }

  if height == auto {
    height = measure(block(width: width, answer)).height * stretch
  }

  let columns = calc.floor(width / size.width)
  let rows = calc.ceil(height / size.height)

  block({
    _grid(
      columns: (size.width,) * columns,
      rows: (size.height,) * rows,
      stroke: stroke,
    )
    place(top, answer)
  })
})
