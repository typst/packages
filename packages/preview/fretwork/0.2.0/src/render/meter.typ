// The time signature: two numerals stacked on the staff.
//
// Where its room comes from is `layout/spacing.typ`'s business — `meter-cap`
// and `meter-allowance` there decide the size and the width, and the placed
// system carries the x it was given. This module only draws.

#import "../layout/spacing.typ": meter-cap

/// One time signature, as a box the height of the staff.
///
/// The two numerals stack tight against the staff's middle, all but touching —
/// which is what the published sheets do, and what makes the pair read as one
/// mark rather than as two numbers that happen to be above each other. Tabular
/// figures, so `12/8` and `4/4` sit on the same axis.
///
/// Must be called from a context: the numerals are measured.
#let draw(theme, strings, time, width) = {
  let h = (strings - 1) * theme.staff-space
  let cap = meter-cap(theme, strings)
  // The hair of daylight left between the two on the reference sheet.
  let split = 0.04 * theme.staff-space
  let (beats, unit) = time

  let numeral(n) = text(
    font: theme.font,
    // `size` sets the em, and a digit's cap is roughly 0.72 of it in the faces
    // this package targets — the same conversion the TAB mark uses.
    size: cap / 0.72,
    weight: 700,
    fill: theme.color,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    number-type: "lining",
    number-width: "tabular",
    str(n),
  )

  box(width: width, height: h, {
    for (i, n) in (beats, unit).enumerate() {
      let body = numeral(n)
      place(
        top + left,
        dx: (width - measure(body).width) / 2,
        // Sitting just above the middle, then hanging just below it.
        dy: if i == 0 { h / 2 - split - cap } else { h / 2 + split },
        body,
      )
    }
  })
}
