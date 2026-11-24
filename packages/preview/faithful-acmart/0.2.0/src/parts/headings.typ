// Render numbered and unnumbered headings with ACM typography and spacing.

#import "spacing.typ": comp, tex-skip
#import "punct.typ": add-punct

// \if@nobreak suppresses spacing between adjacent headings.
// Track body paragraphs separately so a heading's own text does not break adjacency.
#let _in-heading = state("acm-in-heading", false)
#let _body-since-heading = state("acm-body-since-heading", false)

#let heading-number(it) = {
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).at(it.location()))
  }
}

#let sec-font(cfg, level) = {
  let f = cfg.sec-fonts.at(level)
  (font: cfg.fonts.at(f.family), weight: f.weight, style: f.style, size: cfg.size.at(f.size))
}

#let run-in-heading(body, cfg, f, before: 0pt, indent: 0pt, ambient: true, num: none, dot: true, sep: none) = {
  v(before, weak: true)
  // A run-in after body text inherits an indent; directly after a display heading it starts flush.
  h(if ambient { indent - cfg.parindent } else { indent })
  set text(font: f.font, style: f.style, weight: f.weight, size: f.size)
  if num != none [#num#h(1em)]
  if dot { add-punct(body, fix: cfg.fix-quirks) } else { body }
  if sep == auto [ ] else { h(cfg.runin-sep) }
}

#let render-heading(it, cfg) = context {
  let lvl = it.level
  let bls = cfg.baselineskip
  let num = if lvl <= cfg.secnumdepth { heading-number(it) }

  // The query includes this heading; the preceding one is at -2.
  let prevh = query(selector(heading).before(here())).at(-2, default: none)
  let body-since = _body-since-heading.get()
  // \@startsection suppresses beforeskip after a display heading.
  // Front-matter labels are excluded because they do not use that sectioning mechanism.
  let suppress-before = it.outlined and prevh != none and prevh.outlined and prevh.level <= 2 and not body-since
  let ambient = not suppress-before
  _in-heading.update(true)
  _body-since-heading.update(false)

  if lvl <= 2 {
    let f = sec-font(cfg, if lvl == 1 { "section" } else { "subsection" })
    let title = it.body
    block(above: if suppress-before { 0pt } else { tex-skip(cfg, 0.75 * bls) },
      below: tex-skip(cfg, 0.25 * bls), sticky: true)[
      #set text(font: f.font, weight: f.weight, style: f.style, size: f.size)
      #set par(justify: false, leading: comp(cfg))
      // The space keeps the title word intact in PDF tags; an empty spacer causes glyph-by-glyph tagging.
      #if num != none [#num#box(width: 1em, sym.space)#title] else { title }
    ]
  } else if lvl == 3 {
    // A display block's below-gap does not reach a run-in paragraph, so the run-in carries it.
    run-in-heading(it.body, cfg, sec-font(cfg, "subsubsection"),
      before: tex-skip(cfg, if suppress-before { 0.25 * bls } else { 0.5 * bls }),
      indent: 0pt, ambient: ambient, num: num)
  } else if lvl == 4 {
    run-in-heading(it.body, cfg, sec-font(cfg, "paragraph"),
      before: tex-skip(cfg, if suppress-before { 0.25 * bls } else { 0.5 * bls }),
      indent: cfg.parindent, ambient: ambient, num: none)
  } else {
    run-in-heading(it.body, cfg,
      (font: cfg.fonts.body, weight: "regular", style: "normal", size: cfg.size.normalsize),
      before: tex-skip(cfg, 0pt), indent: 0pt, ambient: ambient, num: none, dot: false, sep: auto)
  }
  _in-heading.update(false)
}

// \noindentparagraph is exposed separately because heading elements cannot select this variant.
#let noindentparagraph(cfg, body) = run-in-heading(body, cfg, sec-font(cfg, "paragraph"),
  before: tex-skip(cfg, 0.5 * cfg.baselineskip), indent: 0pt, num: none, dot: false)
