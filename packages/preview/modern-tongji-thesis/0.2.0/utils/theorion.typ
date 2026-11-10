#import "@preview/theorion:0.6.0": make-frame, theorion-i18n-map, set-inherited-levels, set-theorion-numbering, set-qed-symbol

// Theorem render — title + body inline (same paragraph), matching LaTeX \theoremstyle{definition}
#let thm-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" {
    strong[#full-title] + sym.space
  }
  body
}

// Proof render — inline QED
#let pf-render(prefix: none, title: "", full-title: auto, body) = {
  strong[证明] + sym.space + body + box(width: 0em) + h(1fr) + sym.wj + $square$
}

// Theorem environments — module-level so chapter files can access them.
// Each type has an independent counter, matching LaTeX's \newtheorem{}.
#let (thm-ctr, thm-box, thm, show-thm) = make-frame(
  "theorem", theorion-i18n-map.at("theorem"), inherited-levels: 1, render: thm-render,
)
#let (cor-ctr, cor-box, cor, show-cor) = make-frame(
  "corollary", theorion-i18n-map.at("corollary"), inherited-levels: 1, render: thm-render,
)
#let (lem-ctr, lem-box, lem, show-lem) = make-frame(
  "lemma", theorion-i18n-map.at("lemma"), inherited-levels: 1, render: thm-render,
)
#let (prop-ctr, prop-box, prop, show-prop) = make-frame(
  "proposition", theorion-i18n-map.at("proposition"), inherited-levels: 1, render: thm-render,
)
#let (conj-ctr, conj-box, conj, show-conj) = make-frame(
  "conjecture", theorion-i18n-map.at("conjecture"), inherited-levels: 1, render: thm-render,
)
#let (assume-ctr, assume-box, assume, show-assume) = make-frame(
  "assumption", theorion-i18n-map.at("assumption"), inherited-levels: 1, render: thm-render,
)
#let (dfn-ctr, dfn-box, dfn, show-dfn) = make-frame(
  "definition", theorion-i18n-map.at("definition"), inherited-levels: 1, render: thm-render,
)
#let (exmp-ctr, exmp-box, exmp, show-exmp) = make-frame(
  "example", theorion-i18n-map.at("example"), inherited-levels: 1, render: thm-render,
)
#let (rem-ctr, rem-box, rem, show-rem) = make-frame(
  "remark", theorion-i18n-map.at("remark"), inherited-levels: 1, render: thm-render,
)
#let (pf-ctr, pf-box, pf, show-pf) = make-frame(
  "proof", theorion-i18n-map.at("proof"), render: pf-render,
)
