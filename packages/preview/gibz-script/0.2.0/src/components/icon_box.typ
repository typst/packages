#import "./base_box.typ": base-box

// A reusable "icon + content" box built on base_box
#let icon-box(icon, content, style: (:)) = {
  base-box(
    [
      #grid(
        columns: (50pt, 1fr),
        align: (center + horizon, left + horizon),
        [
          #set text(size: 20pt)
          #pad(right: 15pt, bottom: 5pt, icon)
        ],
        [#content],
      )
    ],
    style: (
      fill: gray.lighten(85%),
      radius: 10pt,
      inset: 15pt,
    )
      + style,
  )
}
