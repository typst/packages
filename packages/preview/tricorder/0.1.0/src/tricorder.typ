/// U+3000 CJK Symbols and Punctuation IDEOGRAPHIC SPACE
#let SPACE = "\u{3000}"

/// Insert a space for 2-character names.
/// Do nothing for other names
///
/// - name (str):
/// -> str
#let fill-name(name) = {
  // Name without the annotation
  let bare = name.match(regex("^[^（]+")).text

  if bare.clusters().len() == 2 {
    let (a, ..b) = name.clusters()
    (a, SPACE, ..b).join()
  } else {
    name
  }
}

/// Measure the number of cells that will be occupied by the `name`
///
/// - name (str):
/// - column-gutter (length):
/// -> span (int):
/// -> overflow (bool):
#let measure-span(name, column-gutter) = {
  let len = name
    .clusters()
    // TODO: Hard-coded
    .map(c => if "·，（）".contains(c) {
      0.5em
    } else { 1em })
    .sum()

  let span = 1 + calc.floor(len / (3em + column-gutter))
  (
    span: span,
    overflow: span != calc.ceil((len + column-gutter) / (3em + column-gutter)),
  )
}

/// Put blocks before a wall
/// - blocks (array): A list of ((span, overflow), content)
/// - wall (int): Number of available cells in each row
/// -> array
#let put-before-wall(blocks, wall) = {
  let result = ()
  // Rest space to the wall
  let rest = wall

  for ((span, overflow), value) in blocks {
    assert(
      span + int(overflow) <= wall,
      message: "impossible to place such a long block: (span: "
        + repr(span)
        + ", overflow: "
        + repr(overflow)
        + ", "
        + repr(value)
        + ")",
    )

    if span + int(overflow) > rest {
      if rest > 0 {
        // Fill the rest space with empty blocks
        result.push(((span: rest, overflow: false), none))
      }
      // Start a new row
      rest = wall
    }

    // Put a block
    result.push(((span: span, overflow: overflow), value))
    rest -= span
  }

  result
}

#let tricorder(columns: auto, column-gutter: 1em, row-gutter: 1em, ..names) = {
  assert(names.named().len() == 0)
  let names = names.pos()
  assert(columns == auto or (type(columns) == int and columns > 0))

  // Convert `names` to a list of `((span, overflow), name)`

  let default-span = (span: 1, overflow: false)
  let spans-and-names = names
    .map(n => if type(n) == str {
      // Fill name for regular names
      fill-name(n)
    } else {
      // Skip others
      n
    })
    .map(n => if type(n) == str {
      // Measure span for regular names
      (measure-span(n, column-gutter), n)
    } else if type(n) != array {
      // Set default span for content-ish items
      (default-span, n)
    } else {
      // Parse others
      assert(
        n.len() == 2
          and type(n.first()) == dictionary
          and (not n.first().keys().contains("span") or (type(n.first().span) == int and n.first().span > 0))
          and (not n.first().keys().contains("overflow") or type(n.first().overflow) == bool),
        message: "fail to parse as ((span, overflow), name): " + repr(n),
      )
      let (span, name) = n
      (default-span + span, name)
    })

  // TODO: Hard-coded
  show "（": it => h(-0.5em) + it
  show regex("[，）]"): it => it + h(-0.5em)

  // Write out contents

  if columns == auto {
    // Auto columns
    block({
      set par(leading: row-gutter)

      // The whole block can be arbitrarily aligned,
      // but its last line is always aligned left.
      set align(start)

      spans-and-names
        .map((((span, overflow), name)) => (
          // If not overflow, write `name` and a weak gutter.
          // Otherwise, write `name` and the gutter into a single box.
          box(
            width: (3em + column-gutter) * span - if not overflow { column-gutter } else { 0em },
            name,
          ),
          if not overflow { h(column-gutter, weak: true) } else { none },
        ))
        .flatten()
        .join()
    })
  } else {
    // Fixed columns
    grid(
      columns: (3em,) * columns,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      align: start,
      ..put-before-wall(spans-and-names, columns).map((((span, overflow), name)) => grid.cell(
        colspan: span,
        inset: if overflow { (right: -column-gutter) } else { (:) },
        name,
      ))
    )
  }
}
