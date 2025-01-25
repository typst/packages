#import "extract.typ": extract
#import "split.typ": split
#import "util.typ": inline

// Sets the font size so the resulting text height matches the given height.
//
// Parameters:
// - height: The target height of the resulting text.
// - text-args: Named arguments to be passed to the underlying text element.
// - body: The content of the text element.
//
// Returns: The text with the adjusted size.
#let sized(height, ..text-args, body) = context {
  let styled-text = text.with(..text-args.named(), body)
  let measured = measure(styled-text(1em)).height 
  let factor = if measured > 0pt { height / measured } else { 1 }
  styled-text(factor * 1em)
}

// Resolves the given height to an absolute length.
//
// Height can be given as an integer, which is interpreted as the number of
// lines, or as a length.
//
// Requires context.
#let resolve-height(height) = {
  if type(height) == int {
    measure([x\ ] * height).height
  } else {
    height.to-absolute()
  }
}

// Shows the first letter of the given content in a larger font.
//
// If the first letter is not given as a positional argument, it is extracted
// from the content. The rest of the content is split into two pieces, where
// one is positioned next to the dropped capital, and the other below it.
//
// Parameters:
// - height: The height of the first letter. Can be given as the number of
//           lines (integer) or as a length. If set to `auto`, no scaling is
//           applied.
// - justify: Whether to justify the text next to the first letter.
// - gap: The space between the first letter and the text.
// - hanging-indent: The indent of lines after the first line.
// - overhang: The amount by which the first letter should overhang into the
//             margin. Ratios are relative to the width of the first letter.
// - depth: The minimum space below the first letter. Can be given as the
//          number of lines (integer) or as a length.
// - transform: A function to be applied to the first letter.
// - text-args: Named arguments to be passed to the underlying text element.
// - body: The content to be shown.
//
// Returns: The content with the first letter shown in a larger font.
#let dropcap(
  height: 2,
  justify: auto,
  gap: 0pt,
  hanging-indent: 0pt,
  overhang: 0pt,
  depth: 0pt,
  transform: none,
  ..text-args,
  body
) = layout(bounds => {
  let text-args = text-args

  if height != auto {
    // Set default top and bottom edge to "bounds" if not specified.
    if "top-edge" not in text-args.named() {
      text-args = arguments(..text-args, top-edge: "bounds")
    }
    if "bottom-edge" not in text-args.named() {
      text-args = arguments(..text-args, bottom-edge: "bounds")
    }
  }

  let (letter, rest) = if text-args.pos() == () {
    extract(body)
  } else {
    // First letter already given.
    (text-args.pos().first(), body)
  }

  if transform != none {
    letter = context transform(letter)
  }

  let letter-height = if height == auto {
    // Don't rescale if height is set to auto.
    measure(text(..text-args.named(), letter)).height
  } else {
    resolve-height(height)
  }

  let depth = resolve-height(depth)

  // Create dropcap with the height of sample content.
  let letter = box(
    height: letter-height + depth,
    sized(letter-height, letter, ..text-args.named())
  )
  let letter-width = measure(letter).width

  // Resolve overhang if given as percentage.
  let overhang = if type(overhang) == ratio {
    letter-width * overhang
  } else if type(overhang) == relative {
    letter-width * overhang.ratio + overhang.length
  } else {
    overhang
  }

  // Resolve justify if given as auto.
  let justify = if justify == auto { par.justify } else { justify }

  // Try to justify as many words as possible next to dropcap.
  let bounded = box.with(width: bounds.width - letter-width - gap + overhang)

  let index = 1
  let top-position = 0pt
  let prev-height = 0pt
  let (first, second, sep) = while true {
    let (first, second, _) = split(rest, index)
    let first = {
      set par(hanging-indent: hanging-indent, justify: justify)
      first
    }

    let height = measure(bounded(first)).height
    let (_, new, sep) = split(first, -1)
    top-position = calc.max(
      top-position,
      height - measure(new).height - par.leading.to-absolute()
    )

    if top-position >= letter-height + depth - 1e-6pt and height > prev-height {
      // Limit reached, new element doesn't fit anymore
      split(rest, index - 1)
      break
    }

    if second == none {
      // All content fits next to dropcap.
      (first, none, none)
      break
    }

    index += 1
    prev-height = height
  }

  // Layout dropcap and aside text as grid.
  set par(justify: justify)

  // Find out whether there is a break between the first and second part.
  let has-break = type(sep) == content and sep.func() in (linebreak, parbreak)
  if not has-break {
    let sep = split(first, -1).at(2)
    has-break = type(sep) == content and sep.func() in (linebreak, parbreak)
  }

  // Find elements at boundary.
  let last-of-first = split(first, -1).at(1)
  let first-of-second = if second == none { none } else  { split(second, 1).at(0) }

  let func(body) = if inline(last-of-first) {
    box(body) + linebreak()
  } else {
    block(body)
  }

  func(grid(
    column-gutter: gap,
    columns: (letter-width - overhang, 1fr),
    move(dx: -overhang, letter),
    {
      set par(hanging-indent: hanging-indent)
      first
      
      if not has-break and inline(last-of-first) and inline(first-of-second) {
        linebreak(justify: justify)
      } 
    }
  ))

  if type(sep) == content and sep.func() in (linebreak, parbreak) { sep }

  second
})
