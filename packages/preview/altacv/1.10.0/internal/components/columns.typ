// The page body: the column sections side by side.

#import "../context.typ": _theme

// `left` and `right` are the rendered sections of each column, `ratio`
// the left column's share of the width. A ratio of 1, or no right-hand
// sections, stacks them all in one column.
#let _columns(left, right, ratio) = if ratio == 1 or right.len() == 0 {
  (left + right).join()
} else {
  // The fr columns split what the gutter leaves, so both sides give up
  // a proportional share of it.
  context grid(
    columns: (ratio * 1fr, (1 - ratio) * 1fr),
    column-gutter: _theme().column-gutter,
    left.join(), right.join(),
  )
}
