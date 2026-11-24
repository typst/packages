// ============================================================
// thETS — Page de présentation du jury.
// Portage de \makejury (section 10 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": long-date, tr
#import "state.typ": is-doctorate, is-masters, is-project
#import "blocks.typ": clear-double-page, no-folio, preliminary-heading

#let bl = cfg.baselineskip

// Un membre du jury : nom, rôle, département, affiliation.
// `member` est un dictionnaire (name, dept, affiliation) ; `affiliation`
// vaut none pour « École de technologie supérieure » (valeur par défaut).
#let jury-entry(member, role, lang) = {
  if member == none { return }
  let name = member.at("name", default: "")
  let dept = member.at("dept", default: none)
  let affil = member.at("affiliation", default: none)

  name + ", " + role
  linebreak()
  let second = if dept != none and affil != none {
    dept + " " + affil
  } else if dept != none {
    dept
  } else if affil != none {
    affil
  } else { none }
  if second != none { second }
  v(bl, weak: false)
}

#let make-jury(
  doc-type: "thesis",
  lang: "fr",
  defense-date: none,
  supervisor: none,
  cosupervisor: none,
  chair: none,
  jury: (),
  external-examiners: (),
  independent-examiner: none,
) = {
  let s = tr(lang)

  clear-double-page()
  no-folio
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)

  align(center, {
    preliminary-heading(s.jury-title)
    if is-project(doc-type) { s.jury-eval-project } else if is-masters(
      doc-type,
    ) { s.jury-eval-masters } else { s.jury-eval-thesis }
    linebreak()
    v(bl, weak: false)
    s.jury-composed
    v(6 * bl, weak: false)
  })

  // Rôles : le libellé dépend du type de document.
  let sup-role = if is-project(doc-type) {
    s.role-supervisor-project
  } else if is-masters(doc-type) { s.role-supervisor-masters } else {
    s.role-supervisor-thesis
  }
  let cosup-role = if is-project(doc-type) {
    s.role-cosupervisor-project
  } else if is-masters(doc-type) { s.role-cosupervisor-masters } else {
    s.role-cosupervisor-thesis
  }

  jury-entry(supervisor, sup-role, lang)
  jury-entry(cosupervisor, cosup-role, lang)
  jury-entry(chair, s.role-chair, lang)
  for m in jury { jury-entry(m, s.role-jury, lang) }
  for m in external-examiners { jury-entry(m, s.role-external, lang) }
  jury-entry(independent-examiner, s.role-independent, lang)

  // Bloc « soutenance » calé vers le bas ; absent pour un rapport de projet.
  v(1fr)
  if not is-project(doc-type) {
    align(center, {
      if is-doctorate(doc-type) { s.defense-thesis } else { s.defense-masters }
      linebreak()
      v(bl, weak: false)
      s.defense-date-prefix + upper(long-date(defense-date, lang))
      linebreak()
      v(bl, weak: false)
      s.defense-place
    })
  }

  pagebreak()
  no-folio
  clear-double-page()
}
