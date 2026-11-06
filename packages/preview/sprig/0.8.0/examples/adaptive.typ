// Sprig 0.8.0 — content-fitting leaves, dimensional bounds, and extra shapes.
#import "@preview/sprig:0.8.0": *

#set page(width: 32cm, height: auto, margin: 1cm)
#set text(font: ("New Computer Modern",), size: 9pt)
#set par(leading: 0.58em)

= Content-led radial leaves

#mindmap([*Every leaf fits its words*],
  min-width: 1.8, max-width: 5.2,
  min-height: 1.0, max-height: 4.0,
  leaf-width: 5.2,
  branch(title: [Short], shape: "leaf")[A brief note.],
  branch(title: [A longer thought], shape: "note",
    min-width: 2.7, max-width: 4.5,
    min-height: 1.5, max-height: 3.7)[This one wraps naturally, and its card grows only as much as its content requires.],
  branch(title: [A bounded idea], shape: "ticket",
    min-width: 2.5, max-width: 4.2,
    min-height: 1.4, max-height: 3.2)[The height limit is checked after the text column has widened as far as its maximum.],
  branch(title: [Single word], shape: "bookmark")[Done.],
)

#v(1cm)
= Extra outlines on a fixed grid

#mindgrid([A shared column pitch], cols: 3, cell: 6.0,
  min-width: 2.2, max-width: 5.6,
  min-height: 1.0, max-height: 4.0,
  node(title: [Diamond], shape: "diamond")[The grid aligns the cells; each leaf still fits its own text.],
  node(title: [Parallelogram], shape: "parallelogram")[Longer text occupies more height without colliding with the next row.],
  node(title: [Document], shape: "document")[Short note.],
  node(title: [Leaf], shape: "leaf")[A new silhouette.],
  node(title: [Bookmark], shape: "bookmark")[Another new silhouette.],
  node(title: [Ticket], shape: "ticket")[One more.],
)

#v(1cm)
= Notes that size to their contents

#sticky([The board is a sheet too], cols: 3, cell: 5.6, cell-h: 2.6,
  min-width: 2.0, max-width: 5.4,
  note(title: [Short note], shape: "ticket",
    min-width: 2.0, max-width: 4.8, max-height: 3.2)[A small reminder.],
  note(title: [Room to explain], shape: "document",
    min-width: 2.5, max-width: 5.0,
    min-height: 1.8, max-height: 4.2)[Several lines of content can expand this sheet while the neighboring cards remain aligned to their own rows.],
  note(title: [Quick thought], shape: "leaf")[Brief.],
  note(title: [A folded note], shape: "note", min-width: 2.3,
    max-width: 4.8, min-height: 2.0, max-height: 4.0)[The default cell height is a floor unless a smaller per-note height is explicitly permitted by its maximum.],
)

#v(1cm)
= Petals and concept nodes

#blossom([*A flower of ideas*], petal: "petal", numbering: true,
  min-width: 1.4, max-width: 4.2,
  min-height: 0.7, max-height: 3.2,
  branch(title: [Observe], shape: "diamond")[Notice what is given.],
  branch(title: [Describe], shape: "leaf")[Say it in your own words.],
  branch(title: [Connect], shape: "bookmark")[Relate it to another idea.],
  branch(title: [Check], shape: "ticket")[Test the result.],
)

#v(1cm)
#tikzmap(concept([*Concept map*], children: (
  concept(title: [Content-sized node], shape: "ellipse", width: 4.2,
    min-width: 2.2, max-width: 4.6,
    min-height: 1.1, max-height: 3.2)[The node wraps within its own width limit.],
  concept(title: [Short node], shape: "circle"),
  concept(title: [Another leaf], shape: "rounded",
    min-width: 1.8, max-width: 4.0,
    min-height: 1.0, max-height: 2.8),
)), size: "small", grow: "cyclic",
  min-width: 1.5, max-width: 5.4,
  min-height: 0.9, max-height: 3.6)

#v(1cm)
= Calligraphic branch strokes

#buzan([*Thoughts in motion*], stroke-engine: "nibart",
  min-width: 1.8, max-width: 4.6,
  min-height: 1.0, max-height: 3.2,
  branch(title: [First thought], min-width: 2.4, max-width: 4.3,
    min-height: 1.3, max-height: 3.0)[A short annotation below the keyword.],
  branch(title: [Another branch], min-width: 2.2, max-width: 4.2,
    min-height: 1.2, max-height: 3.0)[A second note.],
  branch([A final idea]),
)
