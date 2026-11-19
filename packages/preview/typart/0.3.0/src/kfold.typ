// K-fold cross-validation: one row per fold with its validation part highlighted.
// Import with:  #import "kfold.typ": kfold
//
//   #kfold(k: 5, test: 20%)
#import "common.typ": _fluid, _lens, _or, _theme, _txt

#let kfold(
  k: 5,
  labels: ([Train], [Validation], [Test]),
  prefix: [Fold],
  test: none,
  item-height: 1.6em,
  gap: 0.4em,
  fills: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("kfold", theme, style)
  if not (type(k) == int and k >= 2) { assert(false, message: "kfold: `k` must be an integer of at least 2, got " + repr(k)) }
  if not (type(labels) == array and labels.len() == 3) { assert(false, message: "kfold: `labels` must be (train, validation, test), got "
    + repr(labels)) }
  assert(test == none or type(test) == ratio and test > 0% and test < 100%,
    message: "kfold: `test` must be none or a ratio between 0% and 100%, got " + repr(test))
  let (h, gap, size, em) = _lens("kfold", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let total = _fluid("kfold", width, area)
  let fills = _or(fills, (t.palette.at(0), t.palette.at(3), t.palette.at(2)))
  if not (type(fills) == array and fills.len() == 3) { assert(false, message: "kfold: `fills` is auto or the colours of the training, "
    + "validation and test parts, got " + repr(fills)) }
  let caption(body) = _txt(body, t.ink, size * t.small, weight: auto)
  let name-w = measure(caption[#prefix #k]).width + 0.7 * em
  let bar-w = total - name-w
  let seg-gap = 0.15 * em
  let test-w = if test == none { 0pt } else { bar-w * test }
  let seg-w = (bar-w - test-w - seg-gap * (if test == none { k - 1 } else { k })) / k
  let part(w, fill) = box(width: w, height: h, radius: calc.min(t.corner-radius, h / 4), fill: fill)
  box(width: total, stack(dir: ttb, spacing: gap,
    ..range(k).map(i => stack(dir: ltr,
      box(width: name-w, height: h, align(left + horizon, caption[#prefix #(i + 1)])),
      stack(dir: ltr, spacing: seg-gap, ..range(k).map(j => part(seg-w, fills.at(if j == i { 1 } else { 0 }))),
        ..if test != none { (part(test-w, fills.at(2)),) }))),
    pad(left: name-w, top: 0.3 * em, stack(dir: ltr, spacing: 1.2 * em,
      ..fills.zip(labels).slice(0, if test == none { 2 } else { 3 }).map(((fill, label)) => grid(columns: 2,
        column-gutter: 0.4 * em, align: horizon, box(width: 0.9 * em, height: 0.9 * em, radius: 0.2 * em, fill: fill),
        caption(label)))))))
})
