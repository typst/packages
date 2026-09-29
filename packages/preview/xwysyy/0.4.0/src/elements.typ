// Shared show-chain (xwysyy-elements) and reusable components (info, textbox).

#import "@preview/touying:0.7.4": components
#import "themes.typ": *

#let xwysyy-elements(
  doc,
  code-font: ("Maple Mono", "Noto Sans Mono CJK SC"),
  t-sea: sea,
  t-sky: sky,
  t-skyll: skyll,
  t-paper: paper,
) = [
  // Bold enhancement — 1.1em + true bold weight, no stroke (stroking fills the
  // CJK glyph counters and looks muddy). 0.03em tracking opens the run
  // internally; 0.05em hair spacing on both sides keeps it off the neighbors
  // (non-weak: weak spacing would swallow adjacent Latin word spaces); the
  // 0.035em baseline drop re-centers the enlarged CJK glyphs optically.
  #show strong: it => {
    h(0.05em)
    text(size: 1.1em, weight: 700, tracking: 0.03em, baseline: 0.035em, it.body)
    h(0.05em)
  }

  // List style
  #set list(marker: (text(fill: t-sea, [❖]), text(fill: t-sky, [⬦]), text(fill: t-sky, [–])), spacing: 1.2em, indent: 0.5em, body-indent: 0.8em)
  #set enum(spacing: 1.2em, indent: 0.5em)

  // Italic — per-character synthetic skew for CJK
  #show emph: it => {
    if type(it.body) == content and it.body.has("text") {
      for c in it.body.text {
        box(skew(ax: -8deg, c))
      }
    } else {
      box(skew(ax: -8deg, it.body))
    }
  }

  // Image shadow disabled (layout+measure incompatible with touying slides)
  // #show image: it => {
  //   layout(size => {
  //     let w = measure(it).width
  //     let h = measure(it).height
  //     block(width: w, height: h, {
  //       place(dx: 1.5pt, dy: 1.5pt, block(width: w, height: h, fill: luma(210), radius: 1pt))
  //       place(dx: 0pt, dy: 0pt, it)
  //     })
  //   })
  // }

  // Figure captions — smaller
  #show figure.caption: it => {
    set text(size: 0.78em, fill: luma(100))
    v(0.3em)
    it
  }

  // Table captions on top
  #show figure.where(kind: table): set figure.caption(position: top)

  // Codeblocks
  #show raw.where(block: true): it => {
    set text(font: code-font, size: 0.9em)
    block(
      width: 100%,
      height: auto,
      fill: t-skyll,
      inset: 0.6em,
      radius: 0.5em,
      it
    )
  }
  // Inline code — the chip fill is painted with `outset` so it does not join
  // baseline/line-height layout (the old inset+baseline recipe sank the code
  // text ~0.1em below the surrounding baseline).
  #show raw.where(block: false): it => {
    set text(font: code-font)
    box(
      fill: t-skyll,
      inset: (x: 0.3em),
      outset: (y: 0.2em),
      radius: 0.3em,
      it
    )
  }

  // Links
  #show link: underline
  #show link: it => {
    set text(fill: t-sea)
    it
  }

  // Detail Decoration — longer patterns first to avoid partial matches.
  // Each rule is guarded so it never rewrites code content: string show rules
  // also match text inside raw, which used to turn `<=` in code into ⇐.
  // NB: `text.font` reports lowercased family names — compare case-insensitively.
  #let code-head = lower(if type(code-font) == array { code-font.first() } else { code-font })
  #let non-code(arrow) = it => context {
    let f = text.font
    let head = if type(f) == array and f.len() > 0 { f.first() } else { f }
    if lower(head) == code-head { it } else { arrow }
  }
  #show "<==>": non-code([$arrow.l.r.double.long$])
  #show "<=>": non-code([$<=>$])
  #show "-->": non-code([$-->$])
  #show "<--": non-code([$<--$])
  #show "==>": non-code([$==>$])
  #show "<==": non-code([$arrow.l.double.long$])
  #show "->": non-code([$->$])
  #show "<-": non-code([$<-$])
  #show "=>": non-code([$=>$])
  #show "<=": non-code([$arrow.l.double$])
  #show "|->": non-code([$|->$])

  // Tables — seamless filled header + zebra body (no gutter: cell gaps used to
  // slice the fills into fragments), theme-toned thin hlines
  #set table(
    stroke: none,
    inset: (x: 0.6em, y: 0.42em),
    align: center,
    fill: (x, y) => if y == 0 { t-sea } else if calc.even(y) { t-skyll } else { none },
  )
  #set table.hline(stroke: 0.5pt + t-sea.lighten(30%))
  #show table.cell: it => {
    if it.y == 0 {
    set text(t-paper, weight: "bold")
    it
  } else {it}
  }

  #doc
]

// information item
#let info(something, description) = [
  *#something* #h(1fr) *#description*\
]

#let textbox(inset: 0.8em, radius: 0.4em, width: 100%, gutter: 0.6em, ..bodies) = context {
  let t = _theme-state.get()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    block(width: width, fill: t.skyll, inset: inset, radius: radius, bodies.first())
  } else {
    components.lazy-layout(grid(
      columns: (1fr,) * bodies.len(),
      gutter: gutter,
      ..bodies.map(b => block(width: 100%, fill: t.skyll, inset: inset, radius: radius, {
        b
        components.lazy-v(1fr)
      })),
    ))
  }
}
