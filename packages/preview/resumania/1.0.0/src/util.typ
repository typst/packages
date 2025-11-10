// These are assorted utilities that don't have any particular category or
// location to them. They're not really meant for external use, but if you find
// them useful that's cool too.
// -----------------------------------------------------------------------------

// Join elements in an array with a separator except at line breaks.
//
// Inspiration is taken from an answer in the Typst forum:
//   https://forum.typst.app/t/how-to-avoid-item-separators-at-linebreaks-when-printing-lists/1809/2
#let join-with-linebreaks(items, separator: [, ]) = {
  layout(size => {
    let container-width = size.width
    let separator-width = measure(separator).width

    items
      // Accumulate lines by sequentially adding the items in order (with the
      // separator between), filling up the available width. The accumulator is
      // an array of the filled-up lines. The last entry in the accumulator is
      // the current line being filled.
      .fold((), (lines, item) => {
        let item-width = measure(item).width

        // The last line is the "current" line (the one being added onto). Since
        // the acuumulator starts empty, a default is needed, and `none` works
        // here to indicate a new line is needed.
        let last-line = lines.last(default: none)
        let last-line-width = measure(last-line).width

        let line = if (
          last-line-width + separator-width + item-width > container-width
        ) {
          // Since the last line is already at its maximum, a new line is needed.
          none
        } else {
          // Otherwise, keep working on the last line.
          last-line
        }

        if line == none {
          // A new line is needed, which happens either at the beginning of the
          // `fold` or when the previous line is full.
          line = [#item]
          lines.push(line)
        } else {
          // The line isn't done yet, so add the separator and item, then update
          // the accumulator's last line.
          line += [#separator#item]
          lines.at(-1) = line
        }

        lines
      })
      .intersperse(linebreak())
      .sum()
  })
}
