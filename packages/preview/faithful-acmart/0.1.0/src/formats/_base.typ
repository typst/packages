// Shared machinery for the per-format builders in this directory.
//
// Every acmart format is `\LoadClass[<size>]{amsart}` (acmart.dtx:3090) with a
// per-format default size, then geometry/columns/fonts layered on top. The font
// ladder and the amsart skip derivation are therefore identical across formats;
// only the chosen base size and the geometry differ. This file holds the shared
// pieces so each `formats/<name>.typ` is just its measurements + format flags.

// LaTeX lengths are TeX points (1pt = 1/72.27in); Typst's pt is a PostScript
// point (1/72in). `tp` converts a TeX-point count into a Typst length so the
// geometry matches exactly. Paper sizes use `in` directly.
#let tp = 72.0 / 72.27 * 1pt

// --- Font-size ladder (amsart's \@typesizes; amsart.cls) -------------------
//
// amsart's `\@typesizes` table is a clamped 11-entry window into a single master
// font ladder, with `normalsize` at the entry for the chosen base. The master
// ladder's (size, baselineskip) pairs, in TeX points (sizes are the
// \@viipt…\@xxvpt step macros: 10.95/14.4/17.28/20.74/24.88), 0-indexed:
#let _ladder-size = (5, 6, 7, 8, 9, 10, 10.95, 12, 14.4, 17.28, 20.74, 24.88)
#let _ladder-bls = (6, 7, 8, 10, 11, 12, 13, 14, 17, 20, 24, 30)
// Our 9 named steps are amsart \@typesizes indices 3..11, i.e. offsets -3..+5
// from `normalsize`. (Indices 1/2 — Tiny/tiny — are unused here.)
#let _step-offset = (
  scriptsize: -3, footnotesize: -2, small: -1, normalsize: 0,
  large: 1, Large: 2, LARGE: 3, huge: 4, Huge: 5,
)

// Resolve the amsart size ladder for a base font size (one of "8pt".."12pt").
// Returns the `size`/`bls` step dicts, the resolved normalsize font-size and
// baselineskip, and the amsart \small/\med/\bigskip (0.7x the article values,
// via amsart's \@adjustvertspacing). `baseline-stretch` models LaTeX's
// \baselinestretch after the font-size table is resolved: sizes stay unchanged,
// but every effective baselineskip and derived vertical skip is multiplied.
// `allowed` names the sizes a given format accepts (acmsmall takes the full
// 8..12 range).
#let size-ladder(
  font-size,
  allowed: (8pt, 9pt, 10pt, 11pt, 12pt),
  format: "",
  baseline-stretch: 1,
) = {
  assert(
    type(font-size) == length and font-size in allowed,
    message: "faithful-acmart: option `font-size` must be a length, one of "
      + allowed.map(repr).join("/")
      + (if format != "" { " for the " + format + " format" } else { "" })
      + " (got " + repr(font-size) + ").",
  )
  let base = int(calc.round(font-size / 1pt)) // 10pt -> 10
  // 0-based index of `normalsize` in the master ladder (10pt -> index 5 = 10/12).
  let ni = base - 5
  let pick(arr, step) = arr.at(calc.clamp(ni + _step-offset.at(step), 0, _ladder-size.len() - 1))
  let size = (:)
  let bls = (:)
  for step in _step-offset.keys() {
    size.insert(step, pick(_ladder-size, step) * tp)
    bls.insert(step, baseline-stretch * pick(_ladder-bls, step) * tp)
  }
  // amsart's \@adjustvertspacing derives the skips from the normalsize
  // baselineskip: \bigskip = .7\baselineskip, \medskip = \bigskip/2,
  // \smallskip = \medskip/2. At 10pt (bls 12) this is 8.4 / 4.2 / 2.1.
  let bigskip = 0.7 * bls.normalsize
  (
    size: size,
    bls: bls,
    font-size: size.normalsize,
    baselineskip: bls.normalsize,
    bigskip: bigskip,
    medskip: bigskip / 2,
    smallskip: bigskip / 4,
  )
}

// The generic acmart section fonts (acmart.dtx:8415, the definitions that apply
// when a format's \ifcase branch is empty — e.g. acmsmall/manuscript). family is
// a role into `fonts`; size is a step name in `size`. Per-format builders pass a
// modified copy (e.g. sf `large` headings for acmlarge/acmtog, serif `Large`
// bold for sigconf).
#let generic-sec-fonts = (
  section:       (family: "sans", weight: "bold", style: "normal", size: "normalsize"),
  subsection:    (family: "sans", weight: "bold", style: "normal", size: "normalsize"),
  subsubsection: (family: "sans", weight: "regular", style: "italic", size: "normalsize"),
  // run-in paragraph heading inherits the default body family (\itshape only, no
  // family switch) — serif for journals, sans under sans-default (sigchi-a).
  paragraph:     (family: "body", weight: "regular", style: "italic", size: "normalsize"),
)

// A heading numbering pattern for a given secnumdepth (acmart.dtx:8419). secnum
// depth 3 numbers through subsubsection; deeper paragraphs stay unnumbered (the
// show rule omits level-4 numbers). <=0 means no section numbers at all.
#let numbering-for-depth(depth) = if depth <= 0 { none } else { ("1", "1.1", "1.1.1").at(calc.min(depth, 3) - 1) }

// Assemble a full format dict from the per-format distinctions plus the shared,
// format-independent constants (float spacing, list geometry, footnote rules,
// badges, fonts). Every acmart format is amsart with geometry/columns layered on
// (acmart.dtx:3090/3754); only the named arguments below actually differ.
#let make-format(
  name: none,
  // Coarse layout family for the running-head/footer + folio-default dispatch in
  // lib.typ (so those don't hard-code format-name lists): "journal" (manuscript /
  // acmsmall / acmlarge / acmtog), "proceedings" (sigconf / sigplan / acmengage /
  // sigchi-a), or "cover" (acmcp). Per-format head layouts still read `name`.
  kind: "journal",
  ladder: none,            // result of size-ladder()
  paper: none,
  margin: none,            // dict: top/bottom + inside/outside (or left/right)
  foot-skip: 24 * tp,      // \footskip
  columns: 1,
  columnsep: 0pt,
  parindent: 10 * tp,
  title-style: "journal-left", // \@mktitle@i / @iii / @iv
  // \@titlefont / \@subtitlefont per format (acmart.dtx:6911/6946). family is a
  // role into `fonts`; size is a step name. Default = the journal @i style
  // (\LARGE\sffamily\bfseries title, \normalsize\mdseries subtitle).
  title-font: (family: "sans", weight: "bold", size: "LARGE"),
  subtitle-font: (family: "sans", weight: "regular", size: "normalsize"),
  // \@authorfont / \@affiliationfont (acmart.dtx:7191/7199). Default = acmart's
  // generic \Large\sffamily name / \normalsize\normalfont affiliation (used by
  // acmlarge + manuscript); acmsmall and the conference formats override.
  author-font: (family: "sans", weight: "regular", size: "Large"),
  affil-font: (family: "serif", weight: "regular", size: "normalsize"),
  bibstrip: true,              // journal footer (\if@ACM@journal)
  sans-default: false,
  urlstyle-sans: false,
  secnumdepth: 3,
  // acmcp narrows the @i title by 6pc to clear the top-right cover infobox
  // (\advance\hsize by -6pc, acmart.dtx:6988); 0 for every other format.
  title-width-reduction: 0pt,
  sec-fonts: generic-sec-fonts,
) = {
  let l = ladder
  (
    name: name,
    kind: kind,
    columns: columns,
    columnsep: columnsep,
    paper: paper,
    margin: margin,
    // acmart's paper-top -> head-top distance (\topmargin) is captured in each
    // format's `margin.top` comment; Typst positions the running head via head.sep,
    // so only the head-baseline separation is stored here.
    head: (sep: 14 * tp),
    foot: (skip: foot-skip),
    // typography (scales with the base font size)
    font-size: l.font-size,
    baselineskip: l.baselineskip,
    size: l.size,
    bls: l.bls,
    smallskip: l.smallskip, medskip: l.medskip, bigskip: l.bigskip,
    // float spacing, list geometry, footnote rules and badges are
    // format-independent (acmart.dtx:3906/4426/5581).
    intextsep: 12 * tp, abovecaptionskip: 12 * tp,
    footnote-rule-short: 4 * 12 * tp,
    footnote-rule-kern-above: 3 * tp, footnote-rule-kern-below: 2.6 * tp,
    footins-skip: 7 * tp,
    parindent: parindent,
    parskip: 0pt,
    list-labelsep: 4 * tp,
    list-leftmargin: 24.5 * tp,
    runin-sep: 3.5 * tp,
    badge-width: 3 * 12 * tp,
    heading-numbering: numbering-for-depth(secnumdepth),
    secnumdepth: secnumdepth,
    // format-specific layout flags (the acmart \ifcase\ACM@format@nr switch)
    title-style: title-style,
    title-font: title-font,
    subtitle-font: subtitle-font,
    author-font: author-font,
    affil-font: affil-font,
    bibstrip: bibstrip,
    sans-default: sans-default,
    urlstyle-sans: urlstyle-sans,
    title-width-reduction: title-width-reduction,
    sec-fonts: sec-fonts,
    fonts: (
      serif: "Libertinus Serif",
      sans: "Libertinus Sans",
      mono: "Inconsolatazi4", // acmart uses zi4 (Inconsolata) for \texttt
      math: "Libertinus Math",
      // The document's DEFAULT body family. acmart sets \sffamily as the document
      // default for sigchi-a (acmart.dtx:4073), so its whole body — abstract, CCS,
      // footnotes, footer, run-in headings — is sans, not just the section titles.
      // Any component rendering default body text should use this role (not `serif`
      // directly) so `sans-default` propagates by construction; reach for `serif`/
      // `sans` only when a specific family is required regardless of format.
      body: if sans-default { "Libertinus Sans" } else { "Libertinus Serif" },
    ),
  )
}
