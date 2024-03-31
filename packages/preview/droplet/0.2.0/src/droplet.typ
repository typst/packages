#import "extract.typ": extract
#import "split.typ": split

// Sets the font size so the resulting text height matches the given height.
//
// If not specified otherwise in "text-args", the top and bottom edge of the
// resulting text element will be set to "bounds".
//
// Parameters:
// - height: The target height of the resulting text.
// - threshold: The maximum difference between target and actual height.
// - text-args: Arguments to be passed to the underlying text element.
// - body: The content of the text element.
//
// Returns: The text with the set font size.
#let sized(height, ..text-args, threshold: 0.1pt, body) = style(styles => {
  let text = text.with(
    top-edge: "bounds",
    bottom-edge: "bounds",
    ..text-args.named(),
    body
  )

  let size = height
  let font-height = measure(text(size: size), styles).height

  // This should only take one iteration, but just in case...
  while calc.abs(font-height - height) > threshold {
    size *= 1 + (height - font-height) / font-height
    font-height = measure(text(size: size), styles).height
  }

  return text(size: size)
})

// Shows the first letter of the given content in a larger font.
//
// If the first letter is not given as a positional argument, it is extracted
// from the content. The rest of the content is split into two pieces, where
// one is positioned next to the dropped capital, and the other below it.
//
// Parameters:
// - height: The height of the first letter. Can be given as the number of
//           lines (integer) or as a length.
// - justify: Whether to justify the text next to the first letter.
// - gap: The space between the first letter and the text.
// - hanging-indent: The indent of lines after the first line.
// - overhang: The amount by which the first letter should overhang into the
//             margin. Ratios are relative to the width of the first letter.
// - transform: A function to be applied to the first letter.
// - text-args: Named arguments to be passed to the underlying text element.
// - body: The content to be shown.
//
// Returns: The content with the first letter shown in a larger font.
#let dropcap(
  height: 2,
  justify: false,
  gap: 0pt,
  hanging-indent: 0pt,
  overhang: 0pt,
  transform: none,
  ..text-args,
  body
) = layout(bounds => style(styles => {  
  let (letter, rest) = if text-args.pos() == () {
    extract(body)
  } else {
    // First letter already given.
    (text-args.pos().first(), body)
  }

  if transform != none {
    letter = transform(letter)
  }

  let letter-height = if type(height) == int {
    // Create dummy content to convert line count to height.
    let sample-lines = range(height).map(_ => [x]).join(linebreak())
    measure(sample-lines, styles).height
  } else {
    measure(v(height), styles).height
  }

  // Create dropcap with the height of sample content.
  let letter = sized(letter-height, letter, ..text-args.named())
  let letter-width = measure(letter, styles).width

  // Resolve overhang if given as percentage.
  let overhang = if type(overhang) == ratio {
    letter-width * overhang
  } else if type(overhang) == relative {
    letter-width * overhang.ratio + overhang.length
  } else {
    overhang
  }

  // Try to justify as many words as possible next to dropcap.
  let bounded = box.with(width: bounds.width - letter-width - gap + overhang)

  let index = 1
  let (first, second) = while true {
    let (first, second) = split(rest, index)
    let first = {
      set par(hanging-indent: hanging-indent, justify: justify)
      first
    }

    if second == none {
      // All content fits next to dropcap.
      (first, none)
      break
    }

    // Allow a bit more space to accommodate for larger elements.
    let max-height = letter-height + measure([x], styles).height / 2
    let height = measure(bounded(first), styles).height    
    if height > max-height {
      split(rest, index - 1)
      break
    }

    index += 1
  }

  // Layout dropcap and aside text as grid.
  set par(justify: justify)

  box(grid(
    column-gutter: gap,
    columns: (letter-width - overhang, 1fr),
    move(dx: -overhang, letter),
    {
      set par(hanging-indent: hanging-indent)
      first
      if second != none { linebreak(justify: justify) }
    }
  ))

  linebreak()
  second
}))
