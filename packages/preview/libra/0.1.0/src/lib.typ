/// Balances text, useful for headings, captions, centered text, or others.

/// Balances lines of text while keeping the minimum amount of lines possible.
/// Works by shrinking the width of the text until it can't be shrunk anymore.
///
/// Unbalanced text:
/// #example(```
///   #rect(width: 25em, lorem(10))
/// ```)
///
/// Balanced text:
/// #example(```
///   #rect(width: 25em, balance(lorem(10)))
/// ```)
///
/// -> content
#let balance(
  /// The text to balance. -> content
  body,
  /// Maximum number of iterations to perform. -> int
  max-iterations: 20,
  /// The precision to which to balance. -> length
  precision: 0.1em,
) = context layout(size => {
  set text(hyphenate: par.justify) if text.hyphenate == auto
  let lead = par.leading.to-absolute()
  let line-height = measure(body).height + lead
  let initial-size = measure(width: size.width, body)
  let initial-lines = (initial-size.height + lead) / line-height

  let high = initial-size.width
  let low = high * (1 - (1 / initial-lines)) / 2

  let extra-lines = initial-lines
  for i in range(0, max-iterations) {
    let candidate = high - (high - low) / (extra-lines + 1)
    set par(justify: false)
    let (height, width) = measure(width: candidate, body)
    if height > initial-size.height {
      low = candidate
      extra-lines = (height - initial-size.height) / line-height
    } else {
      high = width
      if measure(width: width - precision, body).height > initial-size.height {
        break
      }
      high -= precision.to-absolute()
    }
    if high - low < precision.to-absolute() {
      break
    }
  }

  box(width: high, body + if par.justify { linebreak(justify: true) })
})
