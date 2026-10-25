// Shared title/icon placement for the reusable components added in this series.
#let session-title-layout(
  title,
  icon,
  position,
  icon-size,
  icon-colour,
  rtl,
  text-dir,
  alignment,
  width,
  gap,
) = {
  if not ("top", "start", "end", "left", "right").contains(position) {
    panic("icon-position must be top, start, end, left, or right")
  }
  if icon == none {
    (title: title, above: none, above-h: 0pt, above-gap: 0pt)
  } else {
    let icon-content = text(font: "DejaVu Sans", dir: text-dir,
      size: icon-size, fill: icon-colour, icon)
    if position == "top" {
      (title: title,
       above: box(width: width, height: icon-size,
         align(center + horizon, icon-content)),
       above-h: icon-size, above-gap: gap)
    } else {
      let icon-box = box(baseline: 25%, width: icon-size, height: icon-size,
        align(center + horizon, icon-content))
      let icon-first = if position == "left" { true }
        else if position == "right" { false }
        else if position == "start" { not rtl }
        else { rtl }
      let row = if icon-first {
        [#icon-box#h(gap)#title]
      } else {
        [#title#h(gap)#icon-box]
      }
      (title: box(width: width, align(alignment + horizon, row)),
       above: none, above-h: 0pt, above-gap: 0pt)
    }
  }
}
