// ============================================================
// thETS — Sections préliminaires : avant-propos, remerciements,
// résumé et abstract (section 10 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": tr
#import "state.typ": doc-author, doc-lang, doc-title
#import "blocks.typ": (
  clear-double-page, no-folio, preliminary-heading, preliminary-open,
)

// --- Avant-propos (facultatif) ---------------------------------------------
// Marqueur : ouvre le bloc, le texte suit librement dans le document.
#let foreword = context preliminary-open(tr(doc-lang.get()).foreword)

// --- Remerciements (facultatif) --------------------------------------------
#let acknowledgements = context preliminary-open(
  tr(doc-lang.get()).acknowledgements,
)

// --- Gabarit commun résumé / abstract ---------------------------------------
// Titre du document en tête, auteur, puis « RÉSUMÉ » ou « ABSTRACT »,
// le texte en interligne simple, et les mots-clés en fin de bloc.
#let abstract-template(title, section-name, keywords-label, keywords, body) = {
  clear-double-page()
  no-folio
  set par(leading: cfg.leading-single, spacing: cfg.par-spacing)

  align(center, {
    set par(
      leading: cfg.leading-single,
      spacing: cfg.baselineskip,
      justify: false,
    )
    block(strong(title))
    block(context doc-author.get())
    block(preliminary-heading(section-name))
  })

  body

  v(cfg.baselineskip, weak: false)
  strong(keywords-label)
  h(0.35em)
  keywords
  clear-double-page()
}

// --- Résumé ------------------------------------------------------------------
// Document français : #resume(keywords: "mot1, mot2")[texte]
// Document anglais  : #resume(title: [Titre français], keywords: "...")[texte]
#let resume(title: none, keywords: "", body) = context {
  let s = tr(doc-lang.get())
  let t = if title == none { doc-title.get() } else { title }
  abstract-template(t, s.resume, s.keywords-fr, keywords, body)
}

// --- Abstract ----------------------------------------------------------------
// Document français : #abstract(title: [English title], keywords: "...")[texte]
// Document anglais  : #abstract(keywords: "...")[texte]
#let abstract(title: none, keywords: "", body) = context {
  let s = tr(doc-lang.get())
  let t = if title == none { doc-title.get() } else { title }
  abstract-template(t, s.abstract, s.keywords-en, keywords, body)
}
