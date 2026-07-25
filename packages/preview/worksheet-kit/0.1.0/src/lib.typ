// ditto — reusable components for guided worksheets

// ── colors ─────────────────────────────────────────────────────────────────

#let kernelblue      = rgb(20,  60,  110)
#let kernelblue-dark = rgb(14,  44,  82)
#let boxgray         = rgb(245, 246, 248)
#let rulegray        = rgb(195, 199, 204)
#let worklines       = rgb(210, 214, 219)
#let appgreen        = rgb(40,  95,  70)
#let appgreenbg      = rgb(240, 247, 243)
#let hintgold        = rgb(130, 95,  20)
#let hintbg          = rgb(253, 249, 240)
#let defblue         = rgb(30,  80,  140)
#let defbg           = rgb(237, 243, 252)

// ── exported components ────────────────────────────────────────────────────

/// Blue-bordered box for kernel facts / things worth memorising.
#let kernelbox(body) = block(
  fill: boxgray,
  stroke: 0.8pt + kernelblue,
  radius: 2pt,
  inset: (left: 8pt, right: 8pt, top: 6pt, bottom: 6pt),
  width: 100%,
)[#body]

/// Dark-navy-header box for derivations and worked steps.
/// title — short phrase describing the move being made.
#let stepbox(title, body) = block(
  stroke: 0.6pt + kernelblue-dark,
  radius: 1pt,
  width: 100%,
  breakable: true,
)[
  #block(
    fill: kernelblue,
    inset: (x: 9pt, y: 6pt),
    width: 100%,
    radius: (top: 1pt),
  )[#text(fill: white, weight: "bold", size: 10pt)[#title]]
  #block(inset: (x: 9pt, y: 7pt))[#body]
]

/// Green-header box for applications and "in practice" examples.
/// title — pass a custom string when the application is specific enough to name.
#let appbox(title, body) = block(
  stroke: 0.6pt + appgreen,
  radius: 1pt,
  width: 100%,
  breakable: true,
  fill: appgreenbg,
)[
  #block(
    fill: appgreen,
    inset: (x: 9pt, y: 6pt),
    width: 100%,
    radius: (top: 1pt),
  )[#text(fill: white, weight: "bold", size: 10pt)[#title]]
  #block(inset: (x: 9pt, y: 7pt))[#body]
]

/// Gold-tinted hint box — visible enough to notice, quiet enough
/// not to give away the answer.
#let hint(body) = block(
  fill: hintbg,
  stroke: (left: 2.5pt + hintgold, rest: 0.5pt + hintgold),
  radius: 1pt,
  inset: (left: 10pt, right: 9pt, top: 7pt, bottom: 7pt),
  width: 100%,
)[
  #text(weight: "bold", fill: hintgold, size: 9.5pt)[Hint] \
  #body
]

/// Blue-tinted definition box for introducing vocabulary.
#let definition(term, body) = block(
  fill: defbg,
  stroke: (left: 3pt + defblue, rest: 0.5pt + rulegray),
  radius: 1pt,
  inset: (left: 10pt, right: 9pt, top: 7pt, bottom: 7pt),
  width: 100%,
)[
  #text(weight: "bold", fill: defblue)[#term] — #body
]

/// Auto-numbered practice problem.
/// Call as #problem[...] — the counter increments automatically.
/// Reset with #problem-counter.update(0) if needed.
#let problem-counter = counter("problem")

#let problem(body) = {
  problem-counter.step()
  block(
    stroke: 0.5pt + rulegray,
    radius: 1pt,
    width: 100%,
    inset: (x: 10pt, y: 8pt),
  )[
    #text(weight: "bold", fill: kernelblue)[
      Problem #context problem-counter.display()
    ]
    #h(6pt)
    #body
  ]
}

/// Space to work by hand.
/// lines — number of blank lines (default 5).
/// title — prompt shown above the lines (default "Try it yourself:").
#let workspace(lines: 5, title: [Try it yourself:]) = {
  v(6pt)
  text(size: 10pt, style: "italic", fill: kernelblue-dark)[#title]
  for i in range(1, lines) {
    v((lines) * 1pt)
  }
}

/// Inline blank for fill-in-the-blank style questions.
/// space — width of the blank (e.g. 3cm).
#let blanks(space) = {
  box(width: space, stroke: (bottom: 0.5pt))
}

/// Prevent a section from breaking across pages while preserving
/// the full text width so display equations remain centered.
#let nobreak(body) = block(
  breakable: false,
  width: 100%,
)[
  #body
]
