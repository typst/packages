// Apply ACM styles to body content and place material in the margins.

#import "spacing.typ": comp, tex-skip
#import "../formats/_base.typ": tp
#import "theorems.typ": cfg-state, thm-figure-kind
#import "tables.typ": table-inset, light-rule

// Teasers have their own \@mkteasers spacing, so suppress ordinary float spacing and the indent shim.
#let in-topmatter = state("acm-in-topmatter", false)

#let apply-body(cfg, body, amsart-lists: false) = context {
  show figure.where(kind: image): set figure(supplement: if cfg.journal { [Fig.] } else { [Figure] })
  show figure.where(kind: table): set figure(supplement: cfg.strings.table)
  show figure.where(kind: table): set figure.caption(position: top)
  set figure(placement: auto)
  set figure.caption(separator: if cfg.journal or cfg.name == "sigplan" { [. ] } else { [: ] })

  show figure.caption: it => context {
    let cap-font = if cfg.journal { cfg.fonts.sans } else { cfg.fonts.body }
    let cap-weight = if cfg.journal or cfg.name == "sigplan" { "regular" } else { "bold" }
    let cap-step = if cfg.journal or cfg.name == "sigchi-a" { "small" } else { "normalsize" }
    let label-weight = if cfg.name == "sigplan" { "bold" } else { cap-weight }
    set text(font: cap-font, weight: cap-weight, size: cfg.size.at(cap-step))
    set par(leading: comp(cfg, sz: cap-step))
    let cap = {
      if it.numbering != none {
        text(weight: label-weight)[#it.supplement #it.counter.display(it.numbering)#it.separator]
      }
      it.body
    }
    layout(size => {
      let w = measure(cap).width
      if w <= size.width {
        align(center, cap)
      } else {
        // Use the full column width for justification and left-align the final caption line.
        block(width: 100%, align(left, { set par(justify: true); cap }))
      }
    })
  }

  let env-block(it, above: 0pt, below: 0pt) = {
    block(above: above, below: 0pt, it)
    // A zero-height paragraph restores indentation after the environment.
    // Its spacing collapses with the following gap, as \addvspace does; block below-spacing would add to it.
    {
      set par(spacing: below)
      h(cfg.parindent)
    }
  }
  show figure: it => context {
    if in-topmatter.get() {
      it
    } else {
      set block(above: cfg.intextsep, below: cfg.intextsep)
      it
      h(cfg.parindent)
    }
  }
  set figure(gap: cfg.abovecaptionskip)
  // Remove the reference wrapper's float behavior and its inherited centering.
  show figure.where(kind: thm-figure-kind): it => { set align(start); it.body }

  // Model \@arstrut through text metrics: inset alone cannot shrink the global one-em ascent.
  show table: it => {
    set text(top-edge: 0.7 * cfg.baselineskip, bottom-edge: -0.3 * cfg.baselineskip)
    set par(leading: 0pt)
    it
  }
  set table(inset: table-inset, stroke: none)
  set table.hline(stroke: light-rule)

  set math.equation(numbering: "(1)")
  // Equations and code blocks may continue a paragraph; Typst cannot detect a LaTeX-style blank line after them.
  show math.equation.where(block: true): set block(
    above: tex-skip(cfg, cfg.medskip),
    below: tex-skip(cfg, cfg.medskip),
  )

  // Zero-width markers reproduce \llap, keeping the body indent independent of label width.
  let enum-pats = if cfg.name == "sigplan" { ("1.", "a.", "i.", "A.") } else { ("(1)", "(a)", "(i)", "(A)") }
  // Enlarge Libertinus Math's bullet to match newtxmath, preserving its layout box.
  // The vertical shift aligns the enlarged disc with the math axis.
  let big-bullet = context box(
    width: measure($bullet$).width, height: measure($bullet$).height,
    place(right + horizon, dy: -0.2em, text(size: 1.65em)[$bullet$]))
  let list-marks = (big-bullet, text(weight: "bold")[–], [∗], [·])
  let llap(c) = context { h(-measure(c).width); c }
  let labelsep = if amsart-lists { 5 * tp } else { 4 * tp }
  // amsart derives margins with \settowidth at counter 13 (amsart.cls, list setup).
  let label-w(k) = measure(numbering(enum-pats.at(k), 13)).width
  let leftmargin = if amsart-lists {
    (
      label-w(0) + labelsep + cfg.parindent,
      label-w(1) + labelsep,
      label-w(2) + labelsep,
      label-w(3) + labelsep,
      10 * tp, 10 * tp,
    )
  } else {
    let nested = 0.5 * labelsep + 6.5 * tp
    (cfg.parindent + 2 * labelsep + 6.5 * tp, nested, nested, nested, nested, nested)
  }
  // Margins follow total list depth; marker styles follow the nesting depth of their own list kind.
  let list-depth = counter("acm-list-depth")
  let enum-depth = counter("acm-enum-depth")
  let item-depth = counter("acm-item-depth")
  let list-gap = tex-skip(cfg, cfg.smallskip)
  let list-block(it, kind-depth) = {
    list-depth.update(n => n + 1)
    kind-depth.update(n => n + 1)
    context {
      let d = list-depth.get().first()
      let inner = {
        let li = calc.min(d, leftmargin.len() - 1)
        let ei = calc.min(enum-depth.get().first(), 3)
        let ii = calc.min(item-depth.get().first(), 3)
        set enum(indent: leftmargin.at(li) - labelsep,
          numbering: (..ns) => llap(numbering(enum-pats.at(ei), ..ns)))
        set list(indent: leftmargin.at(li) - labelsep, marker: llap(list-marks.at(ii)))
        it
      }
      if d == 1 { env-block(inner, above: list-gap, below: list-gap) } else { inner }
    }
    list-depth.update(n => n - 1)
    kind-depth.update(n => n - 1)
  }
  show enum: it => list-block(it, enum-depth)
  show list: it => list-block(it, item-depth)
  set enum(numbering: (..ns) => llap(numbering(enum-pats.at(0), ..ns)),
    indent: leftmargin.at(0) - labelsep, body-indent: labelsep,
    spacing: comp(cfg))
  set list(marker: llap(list-marks.at(0)),
    indent: leftmargin.at(0) - labelsep, body-indent: labelsep,
    spacing: comp(cfg))

  show quote.where(block: true): it => env-block(
    above: list-gap, below: list-gap,
    block(width: 100%, inset: (left: leftmargin.at(0), right: leftmargin.at(0)), {
      set par(first-line-indent: 0pt)
      it.body
      if it.attribution != none { linebreak(); align(end, [— #it.attribution]) }
    }),
  )

  // Compensate for Typst raw text's built-in size reduction to retain the surrounding font size.
  show raw: it => {
    set text(font: cfg.fonts.mono, size: 1.25em)
    if it.block {
      block(above: tex-skip(cfg, cfg.smallskip), below: tex-skip(cfg, cfg.smallskip))[
        #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg), spacing: 0pt)
        #it.lines.map(l => l.body).join(linebreak())
      ]
    } else {
      it.lines.first().body
    }
  }

  set bibliography(style: "association-for-computing-machinery", title: cfg.strings.references)
  show bibliography: set text(size: cfg.size.footnotesize)
  show bibliography: set par(leading: comp(cfg, sz: "footnotesize"))

  set footnote.entry(
    separator: line(length: cfg.footnote-rule-short, stroke: 0.4pt),
    clearance: cfg.footins-skip - cfg.footnote-rule-kern-above,
    gap: cfg.footnote-rule-kern-below,
    indent: 0pt,
  )
  show footnote.entry: set text(size: cfg.size.footnotesize)
  show footnote.entry: set par(leading: comp(cfg, sz: "footnotesize"))

  body
}

#let _marginpar(body, centering: false) = context {
  let cfg = cfg-state.get()
  let mp = cfg.marginpar
  assert(mp != none, message: "faithful-acmart: sidebar/marginfigure/margintable need a margin-note column (format: \"sigchi-a\")")
  // Horizontal alignment keeps the note anchored in the flow.
  // The vertical offset aligns its first baseline with LaTeX's margin-note anchor.
  place(left, dx: -(mp.width + mp.sep), dy: -14.65 * tp, box(width: mp.width, {
    set text(size: cfg.size.small)
    set par(leading: comp(cfg, sz: "small"), spacing: comp(cfg, sz: "small"), justify: false, first-line-indent: 0pt)
    // Render note figures directly to bypass the body float spacing and indent shim.
    show figure: it => block(width: 100%, spacing: 0pt, {
      if it.kind == table and it.caption != none { it.caption; v(cfg.abovecaptionskip) }
      it.body
      if it.kind != table and it.caption != none { v(cfg.abovecaptionskip); it.caption }
    })
    if centering { align(center, body) } else { body }
  }))
}

#let sidebar(body) = _marginpar(body)
#let marginfigure(body) = _marginpar(body, centering: true)
#let margintable(body) = _marginpar(body, centering: true)

#let fulltextwidth(body) = context {
  let cfg = cfg-state.get()
  let mp = cfg.marginpar
  assert(mp != none, message: "faithful-acmart: fulltextwidth needs a margin-note column (format: \"sigchi-a\")")
  let off = mp.width + mp.sep
  in-topmatter.update(true)
  pad(left: -off, block(width: 100% + off, {
    set figure(placement: none)
    body
  }))
  in-topmatter.update(false)
}
