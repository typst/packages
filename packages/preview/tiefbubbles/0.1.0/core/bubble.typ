#import "core.typ": merge-settings

#let bubble-box(box-style, body) = {
  box(
    ..box-style,
    body,
  )
}

#let bubble(
  name: none,
  name-style: (:),
  box-style: (:),
  body,
) = {
  let default-box-style = (
    stroke: (thickness: 2pt, paint: luma(15%)),
    inset: 5pt,
    radius: 5pt,
  )
  let computed-box-style = merge-settings(box-style, default-box-style)

  let default-name-style = (
    size: .8em,
  )
  let computed-name-style = merge-settings(name-style, default-name-style)

  if name != none {
    box(
      stack(
        dir: ttb,
        spacing: 4pt,
        text(..computed-name-style, name),
        bubble-box(computed-box-style, body),
      ),
    )
  } else {
    bubble-box(computed-box-style, body)
  }
}
