// ---------- homework-template.typ ----------

// ── Axler accent colour ──────────────────────────────────────────────────────
#let _accent = rgb("#2E5FA3") // blue used in LADR covers

// ── Box colours (matched to LADR 4th ed.) ────────────────────────────────────
#let _defn-fill   = rgb("#FFFDE8")
#let _defn-stroke = rgb("#CFC040")
#let _thm-fill    = rgb("#EBF0FA")
#let _thm-stroke  = rgb("#8BAAD4")
#let _prf-fill    = rgb("#F2FAF4")
#let _prf-stroke  = rgb("#6A9E7A")
#let _ans-fill    = rgb("#F5F0FF")
#let _ans-stroke  = rgb("#9070C8")

// ── Counters / depth state ───────────────────────────────────────────────────
#let _q        = counter("homework-template.q")
#let _p        = counter("homework-template.p")
#let _sp       = counter("homework-template.sp")
#let _pt_depth  = state("homework-template.pt-depth", 0)
#let _ans_depth = state("homework-template.ans-depth", 0)

// ── Global text & page ───────────────────────────────────────────────────────
#set text(
  font: "New Computer Modern",
  size: 10.5pt,
  fallback: false,
)

#set page(
  numbering: "1",
  margin: (top: 1.25in, bottom: 1.25in, left: 1.25in, right: 1.25in),
)

// ── Paragraph spacing (Axler uses generous leading) ──────────────────────────
#set par(leading: 0.75em, spacing: 1.2em)

// ── Math ─────────────────────────────────────────────────────────────────────
// Change numbering to "(1)" if you want all display equations numbered.
#set math.equation(numbering: none, supplement: [Equation])

// ── Show rules ───────────────────────────────────────────────────────────────
#show link: it => text(fill: _accent, it)

// Tighten vertical space around display equations
#show math.equation.where(block: true): it => {
  v(0.3em, weak: true)
  it
  v(0.3em, weak: true)
}

// ── Vector shorthand ─────────────────────────────────────────────────────────
#let vc(sym) = $arrow(#sym)$

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
  name,       // required — pass a string or none
  course,     // required — pass a string or none
  hw,         // required — pass a string or none
  date,       // required — pass a string or none
  professor: none,
  topic: none,
  related: none,
  material: none
) = [
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align: (left, right),
    [
      #if name      != none { [#name] } \
      #if course    != none { [#course] } \
      #if hw        != none { [Homework #hw] } \
    ],
    [
      #if date      != none { [#date] } \
      #if professor != none { [#professor] } \
    ],
  )
  #line(length: 100%, stroke: 0.5pt + luma(160))
  #v(0.6em)
]

// ── Question — #qs(title: [question text])[body] ─────────────────────────────
#let qs(title: none, body) = {
  _q.step()
  _p.update(0)
  _sp.update(0)
  context {
    let n = _q.get().at(0)
    _axler-box(str(n) + ".", white, luma(190), title, body)
  }
}

// ── Part — #pt(title: [part text])[body] ─────────────────────────────────────
#let pt(title: none, body) = {
  _pt_depth.update(d => d + 1)
  context if _pt_depth.get() == 1 {
    // top-level: a., b., c., …
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
    // sub-part: i., ii., iii., …
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

// ── Answer box — #ans[...] block for answers/solutions ───────────────────────
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

// ── Proof block (green box, flush-right QED) ──────────────────────────────────
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

// Definition box — yellow, #defn(title: [...])[...]
#let defn(title: none, body) = _axler-box(
  "Definition", _defn-fill, _defn-stroke, title, body,
)

// Theorem / result box — blue, #thm(title: [...])[...]
#let thm(title: none, body) = _axler-box(
  "Theorem", _thm-fill, _thm-stroke, title, body,
)

// Example box — white, #eg(title: [...])[...]
#let eg(title: none, body) = _axler-box(
  "Example", white, luma(190), title, body,
)

// Notation box — yellow (same as defn), #notn(title: [...])[...]
#let notn(title: none, body) = _axler-box(
  "Notation", _defn-fill, _defn-stroke, title, body,
)

// ── Remark / note (left-accent rule, Axler margin-note style) ─────────────────
#let note(body) = block(
  inset: (left: 1em, top: 0.4em, bottom: 0.4em),
  stroke: (left: 2pt + _accent),
)[_Remark._ #body]
