// Theorem environments and references, proofs, and acknowledgments.

#import "spacing.typ": tex-skip
#import "punct.typ": add-punct
#import "../formats/_base.typ": tp

#let cfg-state = state("acmart-cfg", none)

#let anon-state = state("acmart-anon", false)

// The figure wrapper provides a referenceable target and a counter shared by theorem heads and references.
#let thm-figure-kind = "acm-theorem"

#let thm-counter = counter(figure.where(kind: thm-figure-kind))

// Read the heading pattern at the theorem so appendix numbering is preserved.
// Unnumbered headings leave the section counter unchanged.
#let _section-number(loc) = {
  let h = counter(heading).at(loc)
  if h.len() == 0 { return none }
  let prev = query(selector(heading.where(level: 1)).before(loc))
    .filter(it => it.numbering != none)
  if prev.len() == 0 { return none }
  numbering(prev.last().numbering, h.first())
}

// Before any numbered section, LaTeX uses section zero in \thetheorem.
#let _thm-number(loc) = {
  let sec = _section-number(loc)
  let n = thm-counter.at(loc).first()
  if sec != none { [#sec.#n] } else { [0.#n] }
}

#let thm-ref(it) = context {
  let loc = it.element.location()
  let sup = if it.supplement == auto { it.element.supplement } else { it.supplement }
  link(loc, if sup in (none, []) { _thm-number(loc) } else [#sup#sym.space.nobreak#_thm-number(loc)])
}

#let _head-font(style, c) = if style == "smallcaps" { smallcaps(c) } else if style == "bold" { text(weight: "bold", c) } else { emph(c) }

// The trailing zero-height paragraph restores indentation after the environment, as amsthm does with \@endpefalse.
#let thm-block(cfg, head, body, topsep: none, indent: auto, head-sep: 0.5em) = {
  let gap = tex-skip(cfg, if topsep == none { 0.5 * cfg.baselineskip } else { topsep })
  block(above: gap, below: 0pt, width: 100%)[
    #h(if indent == auto { cfg.parindent } else { indent })
    // Keep these adjacent: a markup newline would add a space to head-sep.
    #head#h(head-sep)#body
  ]
  {
    set par(spacing: gap)
    h(cfg.parindent)
  }
}

#let _theorem-env(default-name, kind) = (
  (body, name: none, title: default-name) => figure(
    kind: thm-figure-kind, supplement: title, numbering: "1", outlined: false,
    context {
      let cfg = cfg-state.get()
      let number = _thm-number(here())

      let hf = if kind == "plain" { cfg.thm.plain-head } else { cfg.thm.def-head }
      // \thm@headpunct inherits the note font, including sigplan's reset to normal.
      let head = if name == none or cfg.thm.note-inherits-head {
        _head-font(hf, if name != none { [#title #number (#name).] } else { [#title #number.] })
      } else {
        [#_head-font(hf, [#title #number]) (#name).]
      }
      thm-block(cfg, head, if kind == "plain" { emph(body) } else { body }, indent: cfg.thm.indent)
    },
  )
)

#let theorem = _theorem-env([Theorem], "plain")
#let lemma = _theorem-env([Lemma], "plain")
#let corollary = _theorem-env([Corollary], "plain")
#let proposition = _theorem-env([Proposition], "plain")
#let conjecture = _theorem-env([Conjecture], "plain")

#let definition = _theorem-env([Definition], "definition")
#let example = _theorem-env([Example], "definition")
#let remark = _theorem-env([Remark], "definition")

#let acks(body) = context {
  if anon-state.get() { return }
  heading(level: 1, numbering: none)[#cfg-state.get().strings.acks]
  body
}

#let proof(body, name: none) = {
  context {
    let cfg = cfg-state.get()
    let name = if name != none { name } else { cfg.strings.proof }
    // The proof uses \topsep and \labelsep from its trivlist, independently of the theorem style (acmart.dtx, proof).
    thm-block(cfg, _head-font(cfg.thm.proof-head, add-punct(name, fix: cfg.fix-quirks)),
      [#body #h(1fr)#sym.square.stroked],
      topsep: 6 * tp, indent: cfg.thm.proof-indent,
      head-sep: (if cfg.amsart-lists { 5 } else { 4 }) * tp)
  }
}
