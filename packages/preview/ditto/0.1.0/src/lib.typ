// ditto — reusable components for guided worksheets

// ── colors ─────────────────────────────────────────────────────────────────

#let kernelblue      = rgb(20,  60,  110)
#let kernelblue-dark = rgb(14,  44,  82)
#let boxgray         = rgb(245, 246, 248)
#let rulegray        = rgb(195, 199, 204)
#let worklines       = rgb(210, 214, 219)
#let appgreen        = rgb(40,  95,  70)
#let appgreenbg      = rgb(240, 247, 243)
#let defblue         = rgb(30,  80,  140)
#let defbg           = rgb(237, 243, 252)

// ── endnote state ──────────────────────────────────────────────────────────

#let _answer-state = state("answers", ())

// ── exported components ────────────────────────────────────────────────────

/// Blue-bordered box for kernel facts / things worth memorising.
/// title — optional label shown in bold above the list
#let kernelbox(title: none, body) = block(
  fill: boxgray,
  stroke: 0.8pt + kernelblue,
  radius: 2pt,
  inset: (left: 8pt, right: 8pt, top: 6pt, bottom: 6pt),
  width: 100%,
)[
  #if title != none [
    #text(weight: "bold", fill: kernelblue)[#title] \
    #v(2pt)
  ]
  #body
]

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
  #block(inset: (x: 9pt, y: 7pt), width: 100%)[#body]
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
  #block(inset: (x: 9pt, y: 7pt), width: 100%)[#body]
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

/// Auto-numbered practice problem counter.
#let problem-counter = counter("problem")

/// Accumulates an answer for the current problem into the endnote state.
/// Renders nothing inline — answers appear only via #render-answers.
#let answer(body) = context {
  let n = problem-counter.get()
  _answer-state.update(ans => ans + ((n.first(), body),))
}

/// Renders the accumulated answers section.
/// Does nothing if no answers were added — always safe to call at document end.
#let render-answers() = context {
  let answers = _answer-state.final()
  if answers.len() == 0 { return }

  line(length: 100%, stroke: 0.5pt + rulegray)
  v(6pt)
  text(size: 13pt, weight: "bold", fill: defblue)[Answers]
  v(6pt)
  for (num, body) in answers {
    block(
      fill: defbg,
      stroke: (left: 3pt + defblue, rest: 0.5pt + rulegray),
      radius: 1pt,
      inset: (left: 10pt, right: 9pt, top: 7pt, bottom: 7pt),
      width: 100%,
    )[
      #text(weight: "bold", fill: defblue)[Answer #num] \
      #body
    ]
    v(4pt)
  }
}

/// Auto-numbered practice problem.
/// hint — optional content shown upside-down and right-aligned inside the box.
/// Call as #problem[...] or #problem(hint: [...])[...]
/// Reset counter with #problem-counter.update(0) if needed.
#let problem(hint: none, body) = {
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
    #if hint != none {
      align(right)[
        #rotate(180deg, reflow: true)[
          #text(size: 10pt)[*Hint:* #hint]
        ]
      ]
    }
  ]
}

/// Space to work.
/// lines — number of blank lines.
/// title — prompt shown above the lines (default "Try it yourself:").
#let workspace(lines: 7, title: [Try it yourself:]) = {
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
