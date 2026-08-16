// Theorem-like environments for acmart, matching the amsthm-based acmplain /
// acmdefinition styles. For acmsmall:
//   acmplain (theorem/lemma/corollary/proposition/conjecture):
//     head = small caps, body = italic, indent = parindent, .5bl above/below,
//     head spec "Name Number (Note)." then 0.5em then body (run-in).
//   acmdefinition (definition/example/remark):
//     head = italic, body = roman.
//   proof: head "Proof." small caps, roman body, trailing QED square.
// All share one counter, numbered within the section: 1.1, 1.2, ...

#import "spacing.typ": tex-skip

// Active format config, published by acmart() so the environment functions
// (which users call directly) can read format-specific measurements.
#let cfg-state = state("acmart-cfg", none)

// Whether the document is anonymized (acmart `anonymous` option), published by
// acmart() so body-level environments can suppress identity-revealing content.
#let anon-state = state("acmart-anon", false)

#let thm-counter = counter("acm-thm")

// Mirror LaTeX's \thesection: the first-level section counter formatted with
// whatever heading numbering is currently active. Reading the pattern from the
// nearest preceding heading (rather than using the bare integer) makes theorems
// in an appendix print "A.5", not "1.5", tracking `set heading(numbering: "A.1")`.
// Must be called inside a `context`. Returns `none` when there is no numbered
// section yet (theorem before any heading, or unnumbered sections).
#let _section-number() = {
  let h = counter(heading).get()
  if h.len() == 0 { return none }
  let prev = query(selector(heading).before(here()))
  if prev.len() == 0 or prev.last().numbering == none { return none }
  numbering(prev.last().numbering, h.first())
}

// Shared theorem/proof frame: a .5bl-above/below block, first line unindented but
// offset by \parindent, then the run-in "<head>. " followed by the body.
#let thm-block(cfg, head, body) = block(
  above: tex-skip(cfg, 0.5 * cfg.baselineskip),
  below: tex-skip(cfg, 0.5 * cfg.baselineskip),
  width: 100%,
)[
  #set par(first-line-indent: 0pt)
  #h(cfg.parindent)
  #head.#h(0.5em)
  #body
]

#let _theorem-env(default-name, head-style, body-style) = (
  // `title` overrides the displayed environment name; it defaults to the env's
  // own name (default-name is captured from the enclosing scope).
  (body, name: none, title: default-name) => {
    thm-counter.step()
    context {
      let cfg = cfg-state.get()
      let sec = _section-number()
      let n = thm-counter.get().first()
      let number = if sec != none { [#sec.#n] } else { [#n] }

      let head = {
        let h = [#title #number]
        if name != none { h = [#h (#name)] }
        if head-style == "smallcaps" { smallcaps(h) } else { emph(h) }
      }
      // amsthm sets the env in a trivlist whose \topsep is the style's "space
      // above/below" (.5bl); the baseline pitch is \baselineskip + \topsep, so
      // tex-skip() converts it to the block gap (cf. \@startsection headings).
      thm-block(cfg, head, if body-style == "italic" { emph(body) } else { body })
    }
  }
)

// acmplain environments
#let theorem = _theorem-env([Theorem], "smallcaps", "italic")
#let lemma = _theorem-env([Lemma], "smallcaps", "italic")
#let corollary = _theorem-env([Corollary], "smallcaps", "italic")
#let proposition = _theorem-env([Proposition], "smallcaps", "italic")
#let conjecture = _theorem-env([Conjecture], "smallcaps", "italic")

// acmdefinition environments
#let definition = _theorem-env([Definition], "italic", "normal")
#let example = _theorem-env([Example], "italic", "normal")
#let remark = _theorem-env([Remark], "italic", "normal")

// acks: the acknowledgments environment (acmart.dtx:8850). An unnumbered section
// titled "Acknowledgments" (\acksname, acmart.dtx:8839); the global heading show
// rule supplies the sans-bold section styling. Suppressed entirely in anonymous
// mode, where acmart `\excludecomment{acks}` drops the block (acmart.dtx:8896).
#let acks(body) = context {
  if anon-state.get() { return }
  // \acksname, localized to the main language (acmart.dtx:3310-3337).
  heading(level: 1, numbering: none)[#cfg-state.get().strings.acks]
  body
}

// proof: unnumbered, small-caps "Proof." head, roman body, trailing QED. The
// head defaults to the localized \proofname (acmart.dtx:8753); pass `name` to
// override (the optional argument of the LaTeX `proof` environment).
#let proof(body, name: none) = {
  context {
    let cfg = cfg-state.get()
    let name = if name != none { name } else { cfg.strings.proof }
    // proof uses \topsep 6pt (= .5bl); same conversion as theorems.
    thm-block(cfg, smallcaps(name), [#body #h(1fr)#sym.square.stroked])
  }
}
