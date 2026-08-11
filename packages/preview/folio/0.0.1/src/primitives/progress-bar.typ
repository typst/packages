/// Raw progress-bar primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let progress-bar(
  percentage,
  fill-color: rgb("#2563eb"),
  bg-color: rgb("#e2e8f0"),
  h: 0.6em,
  rad: 3pt,
) = {
  let p = calc.max(0, calc.min(100, float(str(percentage).replace("%", ""))))
  block(
    width: 100%,
    height: h,
    {
      rect(width: 100%, height: h, fill: bg-color, radius: rad, stroke: none)
      place(
        top + left,
        rect(
          width: p * 1%,
          height: h,
          fill: fill-color,
          radius: rad,
          stroke: none,
        ),
      )
    },
  )
}
