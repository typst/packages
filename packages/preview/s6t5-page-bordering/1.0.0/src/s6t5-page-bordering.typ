
#let s6t5-page-bordering(
  margin: (left: 30pt, right: 30pt, top: 60pt, bottom: 60pt),
  expand: 15pt,
  space-top: 15pt,
  space-bottom: 15pt,
  stroke-header: none,
  stroke-footer: none,
  header: "",
  footer: "",
  body,
) = {
  if not (
    type(margin) == dictionary and "left" in margin and "right" in margin and "top" in margin and "bottom" in margin
  ) {
    [`s6t5-page-bordering` failed.

      *Please set s6t5-page-bordering(margin: ) as dictionary of 4 direction.*

      e.g.
      ```
      s6t5-page-bordering(
        margin: (left: 30pt, right: 30pt, top: 60pt, bottom: 60pt),
      ),
      ```
    ]
    return
  }
  set page(margin: margin)

  let (left: ml, right: mr, top: mt, bottom: mb) = margin
  let insetL = ml - expand
  let insetR = mr - expand
  set page(
    background: {
      grid(
        rows: (mt - expand, 100% - mt + expand * 2 - mb, mb - expand),
        rect(
          width: 100%,
          height: 100%,
          inset: (left: insetL, right: insetR, bottom: 0pt, top: space-top),
          stroke: stroke-header,
          outset: (left: -insetL, right: -insetR, top: -space-top),
        )[
          #header
        ],
        rect(width: 100%, height: 100%, outset: (left: -insetL, right: -insetR)),
        rect(
          width: 100%,
          height: 100%,
          inset: (left: insetL, right: insetR, top: 0pt, bottom: space-bottom),
          stroke: stroke-footer,
          outset: (left: -insetL, right: -insetR, bottom: -space-bottom),
        )[
          #footer
        ],
      )
    },
  )
  body
}
