// Body elements: captions, lists, tables, code, display math, footnotes.
//
// acmsmall (journal) caption: sans-serif small (9pt), label and text same
// weight, period label separator; figure named "Fig.", table caption on top.
// The caption package's singlelinecheck centers captions that fit one line and
// left-justifies longer ones. Enumerate labels are parenthesized: (1), (2), ...

#import "spacing.typ": comp, tex-skip

#let apply-body(cfg, body) = {
  // Figure/table supplements and caption separator. Journals use "Fig.";
  // proceedings keep caption's default "Figure" name. The table name follows the
  // main language, as in acmart's babel caption hooks.
  show figure.where(kind: image): set figure(supplement: if cfg.bibstrip { [Fig.] } else { [Figure] })
  show figure.where(kind: table): set figure(supplement: cfg.strings.table)
  show figure.where(kind: table): set figure.caption(position: top)
  // In LaTeX, figure/table environments are floats unless the source opts into a
  // non-floating placement. Typst's figure() is in-flow by default, so give ACM
  // body figures a floating default and let special wrappers opt out explicitly.
  set figure(placement: auto)
  set figure.caption(separator: if cfg.bibstrip or cfg.name == "sigplan" { [. ] } else { [: ] })

  // Caption typography + singlelinecheck (center if one line, else left-justify)
  show figure.caption: it => context {
    let cap-font = if cfg.bibstrip { cfg.fonts.sans } else { cfg.fonts.body }
    let cap-weight = if cfg.bibstrip or cfg.name == "sigplan" { "regular" } else { "bold" }
    let cap-size = if cfg.bibstrip { cfg.size.small } else { cfg.size.normalsize }
    let cap-step = if cfg.bibstrip { "small" } else { "normalsize" }
    set text(font: cap-font, weight: cap-weight, size: cap-size)
    set par(leading: comp(cfg, sz: cap-step))
    layout(size => {
      let w = measure(it).width
      if w <= size.width {
        align(center, it)
      } else {
        set par(justify: true)
        align(left, it)
      }
    })
  }

  // Float spacing: \intextsep (12pt) around [h] floats, \abovecaptionskip (12pt)
  // between figure body and caption. (Floats sit on \lineskip, not \baselineskip,
  // so unlike text blocks they take no line-box compensation.)
  let env-block(it, above: 0pt, below: 0pt) = {
    block(above: above, below: below, it)
    // LaTeX environments such as figure/table/list end with normal paragraph
    // indentation enabled. Typst's global `all: false` only knows "after any
    // block", so reintroduce the paragraph start after ACM block environments.
    // If the next item is a heading, this does not visibly indent it: display
    // headings are blocks, and run-in headings cancel/adjust the ambient indent
    // in parts/headings.typ.
    h(cfg.parindent)
  }
  show figure: it => {
    set block(above: cfg.intextsep, below: cfg.intextsep)
    it
    h(cfg.parindent)
  }
  set figure(gap: cfg.abovecaptionskip)

  // Tables: booktabs-like tight rows. booktabs.sty v1.61803398 sets
  // \lightrulewidth=.05em and \heavyrulewidth=.08em; the default hline is the
  // light rule, with top/bottom rules opt-in at the table source.
  set table(
    inset: (left: 0.6em, right: 0.6em, top: 0.11em, bottom: 0.36em),
    stroke: none,
  )
  set table.hline(stroke: 0.05em)

  // Display equations in acmart/amsart are numbered by default and carry
  // generous \abovedisplayskip/\belowdisplayskip. Typst's native display math is
  // visually too tight, so wrap only block equations in TeX-like vertical space.
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): set block(
    above: tex-skip(cfg, cfg.medskip),
    below: tex-skip(cfg, cfg.medskip),
  )

  // amsart list labels (inherited by acmsmall; amsart.cls:870-884):
  //   enumerate: (1) / (a) / (i) / (A)   itemize: • / bold – / ∗ / ·
  // Geometry (acmart.dtx:4426): body at \leftmargin (≈24.5pt, level 1), label
  // hanging left with \labelsep=4pt, items one baselineskip apart (tight). Typst
  // has no fixed hanging-label box (\llap), so we land the body at \leftmargin via
  // `indent` + marker width + `body-indent`(=\labelsep): for the wide "(1)" the
  // marker hangs at ~\parindent; for the narrow bullet we widen `indent` so its
  // body still reaches \leftmargin (= leftmargin - labelsep - bullet width). See DESIGN.
  // Vertical spacing: amsart sets level-1 \topsep = \listisep = \smallskipamount
  // (acmart.dtx:4446-4451) with \itemsep = \parsep = 0, i.e. items sit one
  // \baselineskip apart (the global par leading) and the whole list is offset
  // from the surrounding text by a \smallskip. tex-skip() converts that topsep
  // to the block gap; tight items inherit the baseline-grid leading.
  let list-gap = tex-skip(cfg, cfg.smallskip)
  let list-block(it) = env-block(it, above: list-gap, below: list-gap)
  show enum: it => list-block(it)
  show list: it => list-block(it)
  set enum(numbering: "(1)(a)(i)(A)", indent: cfg.parindent, body-indent: cfg.list-labelsep,
    spacing: comp(cfg))
  set list(marker: ([$bullet$], text(weight: "bold")[–], [∗], [·]),
    indent: cfg.list-leftmargin - 2 * cfg.list-labelsep, body-indent: cfg.list-labelsep,
    spacing: comp(cfg))

  // Monospace (Inconsolata/zi4) for inline and block code. Typst's raw default
  // is smaller than LaTeX \texttt/verbatim; force it back to the surrounding
  // font size, and give display code the same smallskip-style breathing room as
  // LaTeX's verbatim/trivlist.
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

  // Bibliography (fires only on the "typst" backend): Typst's built-in ACM CSL,
  // footnotesize (8pt), "References". The faithful default is the "bibtex" backend (the
  // ACM-Reference-Format.bst port); "typst" is the CSL approximation.
  set bibliography(style: "association-for-computing-machinery", title: [References])
  show bibliography: set text(size: cfg.size.footnotesize)
  show bibliography: set par(leading: comp(cfg, sz: "footnotesize"))

  // Footnotes: footnotesize (8pt), short 4pc rule (\footnoterule).
  set footnote.entry(
    separator: line(length: cfg.footnote-rule-short, stroke: 0.4pt),
    // \skip\footins (7pt) of glue, then \footnoterule's \kern-3pt pulls the rule
    // up, so the body-to-rule gap is ~4pt; \kern2.6pt below the rule = gap.
    clearance: cfg.footins-skip - cfg.footnote-rule-kern-above,
    gap: cfg.footnote-rule-kern-below,
    indent: 0pt,
  )
  show footnote.entry: set text(size: cfg.size.footnotesize)
  show footnote.entry: set par(leading: comp(cfg, sz: "footnotesize"))

  body
}
