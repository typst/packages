#import "fonts.typ": TJFONT_CAPTION

// Multi-image figure — places children in a configured column layout
// and applies the shared caption.
#let imagex(
  ..children,
  caption: none,
  columns: auto,
  placement: none,
  label: none,
) = {
  figure(
    table(
      ..children,
      columns: columns,
      stroke: none,
      inset: 8pt,
    ),
    kind: "image",
    supplement: [图],
    caption: caption,
    placement: placement,
  )
}

// Sub-figure within an imagex group — carries its own (a)/(b) label
// and optional sub-caption. Use inside imagex arguments.
#let subfig(
  body,
  caption: none,
  lbl-name: none,
) = {
  let lbl = if lbl-name != none { label(lbl-name) } else { none }
  figure(
    [
      #body
      #if lbl != none { lbl }
    ],
    kind: "subfigure",
    caption: caption,
    numbering: "(a)",
    supplement: [],
    outlined: false,
  )
}
