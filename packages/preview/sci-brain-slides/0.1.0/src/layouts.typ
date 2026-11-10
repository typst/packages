// sci-brain-slides . layouts
// ============================
// Slide-body composers: where content goes on one slide. Each takes ready-made
// content (often gadgets from G) and arranges it within a touying slide body.
// A `== Heading` is still what creates the slide; these lay out its body.
//
//   #import "@preview/sci-brain-slides:0.1.0": layouts
//   #let (spread,) = layouts(palette)
//   == Some slide
//   #spread([figure], [commentary])

#import "scale.typ": sizes as default-sizes

#let make(pal, sizes: default-sizes) = {
  let card = (body) => block(
    width: 100%, inset: 12pt, radius: 3pt,
    fill: pal.paper_bg, stroke: 0.5pt + pal.hairline,
  )[#body]

  return (
    // Figure (wide) + commentary (narrow). The default talk slide.
    "spread": (fig, text, ratio: (2fr, 1fr)) => grid(
      columns: ratio, column-gutter: 24pt, align: top,
      fig, text,
    ),

    // Equal two-column split for side-by-side compare/contrast.
    "twocol": (left, right, gutter: 20pt) => grid(
      columns: (1fr, 1fr), column-gutter: gutter, align: top, left, right,
    ),

    // Three equal columns (three parallel concepts, three case studies).
    "threecol": (a, b, c, gutter: 16pt) => grid(
      columns: (1fr, 1fr, 1fr), column-gutter: gutter, align: top, a, b, c,
    ),

    // Centred single punch line / equation / figure. For the slide that carries one idea.
    "hero": (body) => align(center + horizon)[
      #block(width: 80%, inset: (x: 8pt))[#align(center)[#body]]
    ],

    // Horizontal band of equal items (badges, portraits, mini-cards).
    "band": (..items, gutter: 14pt) => grid(
      columns: (1fr,) * items.pos().len(), column-gutter: gutter, align: top,
      ..items.pos(),
    ),

    // Grid of N cards (cell content becomes a bordered card each).
    "cards": (..items, cols: 2, gutter: 8pt) => grid(
      columns: (1fr,) * cols, column-gutter: gutter, row-gutter: gutter, align: top,
      ..items.pos().map(card),
    ),

    // A bordered card around any content.
    "card": card,

    // One headline statement for the slide that carries a single quantity.
    // The quantity is emphasised by weight and colour only, at the same scale
    // as the sentence . no detached display numeral. Keep the unit inside the
    // emphasis (`unit: [weeks]` reads "13 weeks"; a bare "13" says nothing).
    // `label` is provenance (e.g. [survey, n=128]) under the statement.
    "punch": (number, desc, label: none, unit: none) => align(center)[
      #block(width: 100%, text(sizes.xlarge, fill: pal.text)[
        #text(weight: "bold", fill: pal.accent_deep)[#number#if unit != none [~#unit]] #desc
      ])
      #if label != none [#v(8pt) #text(sizes.caption, fill: pal.text_soft)[#label]]
    ],

    // Captioned figure centred on its own (no commentary rail).
    "centered_figure": (body, caption: none) => align(center + horizon)[
      #body
      #if caption != none [#v(6pt) #text(sizes.caption, fill: pal.text_soft)[#caption]]
    ],
  )
}
