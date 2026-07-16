// Section heading styling for acmart.
//
// acmsmall uses amsart's \@startsection skips with acmart's fonts (the acmsmall
// per-format override is empty, so the generic acmart definitions apply):
//   section (1):       sffamily bfseries, mixed case, before .75bl, after .25bl
//   subsection (2):    sffamily bfseries, mixed case, before .75bl, after .25bl
//   subsubsection (3): sffamily itshape, run-in (negative afterskip), dot
//   paragraph (4):     itshape (serif),  run-in, indented \parindent, dot
//   subparagraph (5):  inherited amsart run-in body font, no added dot
// where bl = \baselineskip. Section number is followed by \quad (1em). secnumdepth
// is 3, so paragraphs (level 4) are unnumbered. The paragraph after a heading is
// not indented (Typst handles this via first-line-indent (all: false)). (acmart
// stopped uppercasing section titles in v2.08; the bundled class is v2.18.)

#import "spacing.typ": comp, tex-skip

#let heading-number(it) = {
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).at(it.location()))
  }
}

// Resolve a per-level entry of cfg.sec-fonts (family role -> actual font, size
// step -> length). Each format supplies its own \@secfont/\@subsecfont/… via the
// format dict (acmart.dtx:8415); the level STRUCTURE (skips, run-in, indent) is
// format-independent (acmart.dtx:8356), so only the fonts come from data.
#let sec-font(cfg, level) = {
  let f = cfg.sec-fonts.at(level)
  (font: cfg.fonts.at(f.family), weight: f.weight, style: f.style, size: cfg.size.at(f.size))
}

// Run-in heading: heading text flows inline, the following paragraph continues
// on the same line. Returning inline content from the show rule achieves this;
// a weak v() supplies the vertical space before without breaking the run-in.
#let run-in-heading(it, cfg, f, before: 0pt, indent: 0pt, num: none, dot: true) = {
  v(before, weak: true)
  // Cancel the automatic first-line indent down to the desired `indent`. This
  // also absorbs the paragraph-start shim emitted after ACM block environments
  // (figures/tables/lists), so a figure immediately followed by a run-in heading
  // does not gain a second indent.
  h(indent - cfg.parindent)
  set text(font: f.font, style: f.style, weight: f.weight, size: f.size)
  if num != none [#num#h(1em)]
  it.body
  if dot [.]
  h(cfg.runin-sep) // horizontal gap to the body text (|afterskip|)
}

#let render-heading(it, cfg) = {
  let lvl = it.level
  let bls = cfg.baselineskip
  // secnumdepth (acmart.dtx:8419): levels beyond it are unnumbered (sigchi=1,
  // sigchi-a=0). Paragraphs (level 4) are always unnumbered regardless.
  let num = if lvl <= cfg.secnumdepth { heading-number(it) }

  // \@startsection puts a heading a full \baselineskip + |beforeskip| below the
  // previous baseline, and the body a \baselineskip + afterskip below the
  // heading; tex-skip() converts those skips to Typst block gaps (the heading and
  // body lines are at the body size, so the default "normalsize" applies).
  if lvl <= 2 {
    // display heading: own line, ragged right, mixed case as written. Font per
    // format (acmsmall sf bold; sigconf serif Large bold; …). before .75bl, after .25bl.
    let f = sec-font(cfg, if lvl == 1 { "section" } else { "subsection" })
    let title = it.body
    block(above: tex-skip(cfg, 0.75 * bls), below: tex-skip(cfg, 0.25 * bls), sticky: true)[
      #set text(font: f.font, weight: f.weight, style: f.style, size: f.size)
      #set par(justify: false, leading: comp(cfg))
      #if num != none [#num#h(1em)]
      #title
    ]
  } else if lvl == 3 {
    // subsubsection: before .5bl, run-in
    run-in-heading(it, cfg, sec-font(cfg, "subsubsection"),
      before: tex-skip(cfg, 0.5 * bls), indent: 0pt, num: num)
  } else if lvl == 4 {
    // paragraph: indented, run-in, before .5bl, unnumbered (secnumdepth 3)
    run-in-heading(it, cfg, sec-font(cfg, "paragraph"),
      before: tex-skip(cfg, 0.5 * bls), indent: cfg.parindent, num: none)
  } else {
    // subparagraph: acmart does not override the base \subparagraph in the
    // generic/journal formats; the upstream sample shows an unstyled run-in title
    // with no added dot and no paragraph indent.
    run-in-heading(it, cfg,
      (font: cfg.fonts.body, weight: "regular", style: "normal", size: cfg.size.normalsize),
      before: tex-skip(cfg, 0.5 * bls), indent: 0pt, num: none, dot: false)
  }
}
