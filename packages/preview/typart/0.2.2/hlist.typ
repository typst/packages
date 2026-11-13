// Horizontal list: equal blocks side by side.  Import with:  #import "hlist.typ": hlist
//
//   #hlist(([Plan], [Execute], ([Review], rgb("#e64553"))))
#import "common.typ": _col, _label, _tallest

#let hlist(
  items,
  text-fill: white,
  size: 18pt,
  height: 3cm,
  radius: 8pt,
  gutter: 10pt,
  inset: 12pt,
) = layout(area => {
  let n = items.len()
  let w = (area.width - gutter * (n - 1)) / n
  let labels = items.map(it => {
    set par(leading: 0.5em)
    _label(it, text-fill, size)
  })
  // every block takes the tallest label's height (height is the minimum)
  let h = calc.max(height, _tallest(labels, w - 2 * inset) + 2 * inset)
  stack(dir: ltr, spacing: gutter, ..items.enumerate().map(((i, it)) =>
    box(width: w, height: h, fill: _col(it, i), radius: radius, inset: inset,
      align(center + horizon, labels.at(i)))))
})
