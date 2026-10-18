/// Raw metric primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let metric(
  label,
  value,
  val-color: rgb("#2563eb"),
  pad: 0.5em,
  label-size: 0.85em,
  label-color: rgb("#64748b"),
  val-size: 1.5em,
) = {
  block(
    stack(
      dir: ttb,
      spacing: pad,
      text(size: label-size, fill: label-color)[#label],
      text(size: val-size, weight: "bold", fill: val-color)[#value],
    ),
  )
}
