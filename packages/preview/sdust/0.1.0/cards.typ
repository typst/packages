// ══════════════════════════════════════════════════════
// TITLED CARDS + QUESTION / ANSWER BLOCKS
// ══════════════════════════════════════════════════════

// end-of-proof tombstone symbol — add it yourself where you want it.
#let QED = h(1fr) + box(width: 0.6em, height: 0.6em, stroke: 0.8pt + black)

// Internal base for the titled cards below: coloured header bar + tinted body.
#let _titled-card(
  title: none,
  width: 100%,
  header-fill: rgb("#334155"),
  body-fill: rgb("#f8fafc"),
  border: rgb("#d8dde6"),
  body-text-fill: rgb("#1c1e26"),
  body-font: auto,
  body-size: 10.5pt,
  body-leading: 0.65em,
  content,
) = std.block(
  width: width,
  stroke: 0.5pt + border,
  radius: 2pt,
  clip: true,
  {
    if title != none {
      std.block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        fill: header-fill,
        inset: (left: 14pt, right: 14pt, top: 8pt, bottom: 8pt),
        text(fill: white, weight: "bold", size: 10.5pt, title),
      )
    }
    std.block(
      width: 100%,
      above: 0pt,
      below: 0pt,
      fill: body-fill,
      inset: (left: 14pt, right: 14pt, top: 10pt, bottom: 10pt),
      {
        set par(leading: body-leading)
        set text(fill: body-text-fill, size: body-size, ..(if body-font == auto { (:) } else { (font: body-font) }))
        content
      },
    )
  },
)

// gray default block, e.g. #block(title: "Note")[Body text.]
#let block(title: none, width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#6b7280"), body-fill: rgb("#f3f4f6"),
  border: rgb("#d1d5db"), body-text-fill: rgb("#1f2937"),
  content,
)

// blue theorem, e.g. #theorem(title: "Theorem 1")[For all $x$, ...]
#let theorem(title: "Theorem", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#1565c0"), body-fill: rgb("#ecf3fc"),
  border: rgb("#b3cdeb"), body-text-fill: rgb("#0d2e57"),
  content,
)

// purple corollary, e.g. #corollary[Follows directly from Theorem 1.]
#let corollary(title: "Corollary", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#6d28d9"), body-fill: rgb("#f3ecfd"),
  border: rgb("#d8b9f2"), body-text-fill: rgb("#3b1257"),
  content,
)

// green definition, e.g. #definition(title: "Definition (Group)")[A set $G$ with ...]
#let definition(title: "Definition", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#2e7d32"), body-fill: rgb("#ecfdf5"),
  border: rgb("#a7f3d0"), body-text-fill: rgb("#14532d"),
  content,
)

// red example, e.g. #example[Let $x = 2$, then ...]
#let example(title: "Example", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#c62828"), body-fill: rgb("#fdeced"),
  border: rgb("#f2b9bc"), body-text-fill: rgb("#5a1212"),
  content,
)

// white/neutral proof — same shape as example, plain colour,
// e.g. #proof[By induction on $n$. ...]  (add `#QED` yourself if wanted)
#let proof(title: "Proof", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#4b5563"), body-fill: white,
  border: rgb("#d1d5db"), body-text-fill: rgb("#1f2937"),
  [#content],
)

// ═══════════════════════════
// QUESTION AND ANSWER BLOCKS
// ═══════════════════════════

// prompt block, e.g. #question(title: "Exercise 1")[Solve for $x$.]
#let question(title: none, body) = std.block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  fill: luma(245),
  [
    #if title != none {
      strong(title)
      h(0.5em)
    }
    #body
  ],
)

// indented answer body under a #question, e.g. #answer[$x = 2$.]
#let answer(body) = std.block(
  width: 100%,
  inset: (left: 10pt, right: 10pt, top: 4pt, bottom: 10pt),
  stroke: (left: 1pt + luma(180)),
  body,
)
