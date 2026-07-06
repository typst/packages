// Knots — theorem-likes built on frame-it, custom-skinned for Scholia.
// frame-it makes each a `figure(kind:"frame")`, so we inherit native @label
// cross-references and Typst numbering for free. Colours come from the active
// theme palette (by supplement), not from the frame definitions below.
#import "@preview/frame-it:2.0.0" as frame-it
#import "colors.typ": *
#import "visual.typ": mark, label-it
#import "fonts.typ": default-fonts

// All knots share one kind ("frame") → one counter (amsthm `[theorem]` style).
// The supplement string is how the style tells them apart; the colours passed
// here are placeholders (our style ignores them and reads the active palette).
#let (
  theorem, lemma, proposition, corollary,
  definition, axiom, assumption, notation,
  example, remark,
  conjecture, claim,
) = frame-it.frames(
  base-color: palettes.light.thm,
  theorem:     ("Theorem",     palettes.light.thm),
  lemma:       ("Lemma",       palettes.light.thm),
  proposition: ("Proposition", palettes.light.thm),
  corollary:   ("Corollary",   palettes.light.thm),
  conjecture:  ("Conjecture",  palettes.light.thm),
  claim:       ("Claim",       palettes.light.thm),
  definition:  ("Definition",  palettes.light.def),
  axiom:       ("Axiom",       palettes.light.def),
  assumption:  ("Assumption",  palettes.light.def),
  notation:    ("Notation",    palettes.light.def),
  example:     ("Example",     palettes.light.eg),
  remark:      ("Remark",      palettes.light.def),
)

// Colour dispatch: def-family = teal, eg-family = amber, everything else = blue.
#let _def-family = ("Definition", "Axiom", "Assumption", "Notation")
#let _eg-family  = ("Example",)

// the frame-it style factory: (title, tags, body, supplement, number, accent)
#let knot-style(title, tags, body, supplement, number, _accent) = context {
  let p = active.get()
  let a = if supplement in _def-family { p.def }
          else if supplement in _eg-family  { p.eg  }
          else { p.thm }
  set align(left) // frame-it frames live in a figure caption, which centres by default

  if supplement == "Remark" {
    // a remark is unboxed, italic in the definition colour
    block(above: 8pt, below: 8pt, {
      text(style: "italic", fill: p.def)[#supplement #number]
      if title != none { text(style: "italic", fill: p.ink)[ (#title)] }
      text(fill: p.def)[.]
      h(0.4em)
      body
    })
  } else {
    block(
      width: 100%, breakable: true, fill: tint(p, a),
      stroke: (left: 2.2pt + a),
      inset: (left: 12pt, right: 11pt, top: 8pt, bottom: 8pt),
      above: 10pt, below: 10pt,
      {
        text(font: default-fonts.heading, weight: "bold", fill: a)[#supplement #number]
        if title != none { text(font: default-fonts.heading, style: "italic", fill: p.ink)[ (#title)] }
        for tag in tags { h(0.5em); label-it(tag) }
        text(font: default-fonts.heading, weight: "bold", fill: a)[.]
        h(0.4em)
        body
      },
    )
  }
}

// proofs end on a small solid square (qed) in the theorem colour
#let proof(body) = context {
  let p = active.get()
  block(above: 6pt, below: 8pt, {
    text(font: default-fonts.heading, style: "italic", fill: p.muted)[Proof.]
    h(0.4em)
    body
    h(1fr)
    mark(p.thm, size: 6pt)
  })
}

// activate the knot style + section-tied "N.n" numbering; call as `#show: ...`
#let theorem-rules(body) = {
  show figure.where(kind: "frame"): set figure(
    numbering: n => numbering("1.1", counter(heading).get().first(), n),
  )
  show: frame-it.frame-style(knot-style)
  body
}
