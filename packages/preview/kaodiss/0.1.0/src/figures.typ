// Figures, tables, listings and their captions (kaobook floatrow setup).
#import "metrics.typ" as m
#import "state.typ": *
#import "notes.typ": margin-note, margin-par-style, margin-text-style
#import "@preview/marginalia:0.3.1" as marginalia

// "Figure 2.3: Text", label in bold, footnotesize, justified.
#let caption-text(cap) = {
  set text(..margin-text-style)
  set par(..margin-par-style)
  if cap.numbering == none {
    cap.body
  } else {
    let label = context [#cap.supplement #cap.counter.display(cap.numbering):]
    [#strong(label) #cap.body]
  }
}

// Caption next to the float, in the outer margin. Figures align the caption
// with their bottom, tables and listings with their top.
#let margin-caption(cap, position) = {
  let note = marginalia.note(
    counter: none,
    alignment: position,
    dy: if position == "bottom" { 0.25 * m.size.footnotesize } else { 0pt },
    shift: "avoid",
    keep-order: true,
    text-style: margin-text-style,
    par-style: margin-par-style,
    caption-text(cap),
  )
  place(if position == "top" { top + left } else { bottom + left }, box(width: 0pt, height: 0pt, note))
}

#let caption-position(it) = if it.kind == image { bottom } else { top }

// Float with its caption in the margin (main matter).
#let margin-figure-layout(it) = {
  let position = caption-position(it)
  block(width: 100%, breakable: false, above: 1.2 * m.par-spacing, below: 1.2 * m.par-spacing, {
    if position == top { margin-caption(it.caption, "top") }
    align(center, it.body)
    if position == bottom { margin-caption(it.caption, "bottom") }
  })
}

// Float with the caption above or below it (wide floats, front and back
// matter, figures in the margin).
#let stacked-figure-layout(it) = {
  let position = caption-position(it)
  let caption = block(width: 100%, caption-text(it.caption))
  block(width: 100%, breakable: false, above: 1.2 * m.par-spacing, below: 1.2 * m.par-spacing, {
    if position == top { caption; v(m.caption-skip, weak: true) }
    align(center, it.body)
    if position == bottom { v(m.caption-skip, weak: true); caption }
  })
}

// `margin-captions`: true in the main matter.
// `appendix`: chapter numbers are letters (Figure A.1).
#let figure-rules(strings: (:), margin-captions: true, appendix: false, body) = {
  let chapter-pattern = if appendix { "A.1" } else { "1.1" }
  // Numbering per chapter: Figure 2.3, Table 4.1, Listing 5.2 ...
  set figure(numbering: (..nums) => numbering(chapter-pattern, counter(heading).get().first(), ..nums))
  set math.equation(numbering: (..nums) => numbering(
    "(" + chapter-pattern + ")",
    counter(heading).get().first(),
    ..nums,
  ))
  show figure.where(kind: image): set figure(supplement: strings.figure)
  show figure.where(kind: table): set figure(supplement: strings.table)
  show figure.where(kind: raw): set figure(supplement: strings.listing)
  show figure.where(kind: "algorithm"): set figure(supplement: strings.algorithm)
  set math.equation(supplement: strings.equation)
  set figure(gap: m.caption-skip)

  show figure: it => {
    if it.kind not in float-kinds or it.caption == none { return it }
    if margin-captions { margin-figure-layout(it) } else { stacked-figure-layout(it) }
  }
  body
}

// A block that extends into the margin; floats inside get their caption below
// or above them (kaobook figure*, table*, widepar).
#let wide(body) = marginalia.wideblock({
  show figure: it => {
    if it.kind not in float-kinds or it.caption == none { return it }
    stacked-figure-layout(it)
  }
  body
})

// A figure (or table) in the margin with its caption below it:
// `#marginfigure(image("x.png"), caption: [Text], label: <fig:x>)`.
// (A label after the call would attach to the margin note, hence the parameter.)
#let marginfigure(body, caption: none, label: none, dy: 0pt, ..args) = margin-note(dy: dy, {
  show figure: it => {
    if it.kind not in float-kinds or it.caption == none { return it }
    block(width: 100%, {
      it.body
      v(m.caption-skip)
      caption-text(it.caption)
    })
  }
  let fig = figure(body, caption: caption, placement: none, ..args)
  if label != none [#fig#label] else { fig }
})

// --- Tables ----------------------------------------------------------------------

// booktabs rules for tables: `table.hline` with the classic widths.
#let toprule = table.hline(stroke: 0.08em)
#let midrule = table.hline(stroke: 0.05em)
#let bottomrule = table.hline(stroke: 0.08em)

#let table-rules(body) = {
  set table(stroke: none, inset: (x: 6pt, y: 3pt))
  show table: set par(justify: false)
  body
}

// --- Algorithms -----------------------------------------------------------------

// Figure kind for algorithms (e.g. typeset with the lovelace package).
#let algorithm(body, caption: none, ..args) = figure(
  body,
  kind: "algorithm",
  caption: caption,
  ..args,
)

// --- Code listings (minted/kaolst style) ---------------------------------------------

#let code-font = ("DejaVu Sans Mono",)

#let code-rules(rule-color: black, body) = {
  set raw(theme: "../themes/kaolst.tmTheme")
  show raw: set text(font: code-font)
  show raw.where(block: false): set text(size: 10pt * 0.85)
  show raw.where(block: true): it => {
    set text(size: 8pt * 0.85, top-edge: m.top-edge, bottom-edge: m.bottom-edge)
    set par(leading: 9.45pt - 6.8pt, justify: false)
    // line numbers in tiny grey figures to the left of the code
    show raw.line: line => {
      box(width: 0pt, {
        h(-20pt)
        box(width: 8pt, align(right, text(size: 4.85pt, fill: m.colors.code-number, str(line.number))))
      })
      line.body
    }
    block(
      width: 100%,
      stroke: (top: 0.4pt + rule-color, bottom: 0.4pt + rule-color),
      inset: (top: 5pt, bottom: 5pt),
      above: 1.2 * m.par-spacing,
      below: 1.2 * m.par-spacing,
      it,
    )
  }
  body
}
