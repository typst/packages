// ---------- polymath/lib.typ ----------

// ── Axler accent colour ──────────────────────────────────────────────────────
#let _accent = rgb("#2E5FA3") // blue used in LADR covers

// ── Box colours ──────────────────────────────────────────────────────────────
#let _defn-fill   = rgb("#FFFDE8")
#let _defn-stroke = rgb("#CFC040")
#let _thm-fill    = rgb("#EBF0FA")
#let _thm-stroke  = rgb("#8BAAD4")
#let _prf-fill    = rgb("#F2FAF4")
#let _prf-stroke  = rgb("#6A9E7A")
#let _ans-fill    = rgb("#F5F0FF")
#let _ans-stroke  = rgb("#9070C8")
#let _conj-fill   = rgb("#FFF8E1")
#let _conj-stroke = rgb("#D4A000")

// ── Counters / depth state ───────────────────────────────────────────────────
#let _q        = counter("polymath.q")
#let _p        = counter("polymath.p")
#let _sp       = counter("polymath.sp")
#let _pt_depth  = state("polymath.pt-depth", 0)
#let _ans_depth = state("polymath.ans-depth", 0)

// ── Template function — apply with: #show: template ──────────────────────────
#let template(doc) = {
  set text(
    font: "New Computer Modern",
    size: 8.5pt,
    fallback: false,
  )
  set page(
    numbering: "1",
    margin: (top: 1.25in, bottom: 1.25in, left: 1.25in, right: 1.25in),
  )
  set par(leading: 0.75em, spacing: 1.2em)
  set math.equation(numbering: none, supplement: [Equation])
  show link: it => text(fill: _accent, it)
  show math.equation.where(block: true): it => {
    v(0.3em, weak: true)
    it
    v(0.3em, weak: true)
  }
  doc
}

// ── QED mark (filled blue square, Axler style) ────────────────────────────────
#let _qed = text(fill: _accent)[■]

// ── Axler-style content boxes ─────────────────────────────────────────────────
#let _axler-box(label, fill-col, stroke-col, title, body) = block(
  width: 100%,
  inset: (x: 1em, top: 0.55em, bottom: 0.8em),
  radius: 3pt,
  fill: fill-col,
  stroke: 0.6pt + stroke-col,
  spacing: 1em,
)[
  #text(fill: _accent)[#label]#if title != none [: #emph(title)] \
  #body
]

// ── Header ───────────────────────────────────────────────────────────────────
#let header(
  name: none,
  note: none,
  author: none,
  course: none,
  hw: none,
  date: none,
  professor: none,
  topic: none,
  related: none,
  material: none
) = {
  let title = if note != none { note } else { name }

  [
    #if title != none [
      #text(fill: _accent, weight: 700, size: 1.15em)[#title]
      #v(0.2em)
    ]
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 1em,
      align: (left, right),
      [
        #if author   != none { [#author] } \
        #if course   != none { [#course] } \
        #if hw       != none { [Homework #hw] } \
        #if topic    != none { [#topic] } \
        #if material != none { [#material] } \
      ],
      [
        #if date      != none { [#date] } \
        #if professor != none { [#professor] } \
        #if related   != none { [#related] } \
      ],
    )
    #line(length: 100%, stroke: 0.5pt + luma(160))
    #v(0.6em)
  ]
}

// ── Question — #qs(title: [...])[body] ───────────────────────────────────────
#let qs(title: none, body) = {
  _q.step()
  _p.update(0)
  _sp.update(0)
  context {
    let n = _q.get().at(0)
    _axler-box(str(n) + ".", white, luma(190), title, body)
  }
}

// ── Exercise — #ex(num: 3, loc: [section 2.1])[body] ─────────────────────────
// Renders as: "Exercise 3, section 2.1"
#let ex(num: none, loc: none, body) = {
  _p.update(0)
  _sp.update(0)
  let label = if num == none {
    [Exercise]
  } else if loc == none {
    [Exercise #num]
  } else {
    [Exercise #num, #loc]
  }
  _axler-box(label, white, luma(190), none, body)
}

// ── Part — #pt(title: [...])[body] ───────────────────────────────────────────
#let pt(title: none, body) = {
  _pt_depth.update(d => d + 1)
  context if _pt_depth.get() == 1 {
    _p.step()
    _sp.update(0)
    context {
      let n = _p.get().at(0)
      let label = ("a","b","c","d","e","f","g","h").at(n - 1) + "."
      let in-ans = _ans_depth.get() > 0
      let fill-col   = if in-ans { _ans-fill }   else { white }
      let stroke-col = if in-ans { _ans-stroke }  else { luma(210) }
      _axler-box(label, fill-col, stroke-col, title, body)
    }
  } else {
    _sp.step()
    context {
      let n = _sp.get().at(0)
      let label = ("i","ii","iii","iv","v","vi","vii","viii").at(n - 1) + "."
      let in-ans = _ans_depth.get() > 0
      let fill-col   = if in-ans { _ans-fill }   else { white }
      let stroke-col = if in-ans { _ans-stroke }  else { luma(225) }
      _axler-box(label, fill-col, stroke-col, title, body)
    }
  }
  _pt_depth.update(d => d - 1)
}

// ── Answer box — #ans[...] ────────────────────────────────────────────────────
#let ans(body) = {
  _ans_depth.update(d => d + 1)
  block(
    width: 100%,
    inset: (x: 1em, top: 0.55em, bottom: 0.8em),
    radius: 3pt,
    fill: _ans-fill,
    stroke: 0.6pt + _ans-stroke,
    spacing: 1em,
  )[#body]
  _ans_depth.update(d => d - 1)
}

// ── Example box — #eg(title: [...])[...] ─────────────────────────────────────
#let eg(title: none, body) = _axler-box(
  "Example", white, luma(190), title, body,
)

// ── Proof block (green, flush-right QED) — #prf[...] ─────────────────────────
#let prf(body) = block(
  width: 100%,
  inset: (x: 1em, top: 0.55em, bottom: 0.8em),
  radius: 3pt,
  fill: _prf-fill,
  stroke: 0.6pt + _prf-stroke,
  spacing: 1em,
)[
  #text(fill: _accent)[_Proof._] #body #h(1fr) #_qed
]

// ── Definition — #defn(title: [...])[...] ────────────────────────────────────
#let defn(title: none, body) = _axler-box(
  "Definition", _defn-fill, _defn-stroke, title, body,
)

// ── Notation — #notn(title: [...])[...] ──────────────────────────────────────
#let notn(title: none, body) = _axler-box(
  "Notation", _defn-fill, _defn-stroke, title, body,
)

// ── Theorem — #thm(title: [...])[...] ────────────────────────────────────────
#let thm(title: none, body) = _axler-box(
  "Theorem", _thm-fill, _thm-stroke, title, body,
)

// ── Lemma — #lemma(title: [...])[...] ────────────────────────────────────────
#let lemma(title: none, body) = _axler-box(
  "Lemma", _thm-fill, _thm-stroke, title, body,
)

// ── Proposition — #prop(title: [...])[...] ───────────────────────────────────
#let prop(title: none, body) = _axler-box(
  "Proposition", _thm-fill, _thm-stroke, title, body,
)

// ── Corollary — #cor(title: [...])[...] ──────────────────────────────────────
#let cor(title: none, body) = _axler-box(
  "Corollary", _thm-fill, _thm-stroke, title, body,
)

// ── Axiom — #axiom(title: [...])[...] ────────────────────────────────────────
#let axiom(title: none, body) = _axler-box(
  "Axiom", _defn-fill, _defn-stroke, title, body,
)

// ── Postulate — #postulate(title: [...])[...] ────────────────────────────────
#let postulate(title: none, body) = _axler-box(
  "Postulate", _defn-fill, _defn-stroke, title, body,
)

// ── Conjecture — #conj(title: [...])[...] ────────────────────────────────────
// Amber colour signals the claim is unproven.
#let conj(title: none, body) = _axler-box(
  "Conjecture", _conj-fill, _conj-stroke, title, body,
)

// ── Remark — #note[...] ──────────────────────────────────────────────────────
#let note(body) = block(
  inset: (left: 1em, top: 0.4em, bottom: 0.4em),
  stroke: (left: 2pt + _accent),
)[_Remark._ #body]

// ── Aside / digression — #aside[...] ─────────────────────────────────────────
// A tangential thought; grey rule distinguishes it from a Remark.
#let aside(body) = block(
  inset: (left: 1em, top: 0.4em, bottom: 0.4em),
  stroke: (left: 2pt + luma(160)),
)[_Aside._ #body]

// ── Epigraph — #epigraph(attribution: [...])[...] ────────────────────────────
// Opening quote, centered and italic, for the top of a document or section.
#let epigraph(attribution: none, body) = {
  align(center)[
    #emph(body)
    #if attribution != none [
      #v(0.3em, weak: true)
      #text(size: 0.88em, fill: luma(90))[— #attribution]
    ]
  ]
  v(0.8em)
}

// ── Block quote — #blockquote(attribution: [...])[...] ────────────────────────
// A left-ruled quoted passage with optional attribution.
#let blockquote(attribution: none, body) = block(
  inset: (left: 1em, top: 0.4em, bottom: 0.4em),
  stroke: (left: 2pt + luma(160)),
)[
  #emph(body)
  #if attribution != none [
    #linebreak()
    #text(size: 0.88em, fill: luma(90))[— #attribution]
  ]
]
