// ─── ARTICLE HEADER (title block, abstract, info bar) ─────────────────────────
#import "theme.typ": default-theme

// Visible strings — override individual keys via the `labels:` parameter.
#let default-header-labels = (
  abstract:    "Abstract",
  keywords:    "Keywords: ",
  email:       "E-mail: ",
  supervisors: "Supervisors: ",
  doi:         "DOI: ",
  submitted:   "Submitted: ",
  defended:    "Defended: ",
  accepted:    "Accepted: ",
  published:   "Published: ",
)

// ── Keyword line helper ──
#let keywords-line(kws, theme: default-theme, labels: default-header-labels) = {
  set text(size: 8pt, font: theme.font-sans)
  text(weight: "bold", fill: theme.accent, labels.keywords)
  text(style: "italic", kws)
}

// ── Info box (supervisors, dates, DOI, license) ──
#let info-box(
  supervisors: none,
  email:       none,
  submitted:   none,
  defended:    none,
  accepted:    none,
  published:   none,
  doi:         none,
  license:     none,
  theme:       default-theme,
  labels:      default-header-labels,
) = {
  set text(size: 7.8pt, font: theme.font-sans)
  if email != none {
    text(fill: theme.accent, weight: "bold", labels.email)
    for (i, addr) in email.enumerate() {
      if i > 0 { text(", ") }
      link("mailto:" + addr)[#addr]
    }
    linebreak()
  }
  if supervisors != none { text(fill: theme.accent, weight: "bold", labels.supervisors); supervisors; linebreak() }
  if doi         != none { text(fill: theme.accent, weight: "bold", labels.doi);       doi;       linebreak() }
  if submitted   != none { text(fill: theme.accent, weight: "bold", labels.submitted); submitted; h(10pt) }
  if defended    != none { text(fill: theme.accent, weight: "bold", labels.defended);  defended;  h(10pt) }
  if accepted    != none { text(fill: theme.accent, weight: "bold", labels.accepted);  accepted;  h(10pt) }
  if published   != none { text(fill: theme.accent, weight: "bold", labels.published); published; linebreak() }
  if license     != none { v(3pt); text(size: 7.5pt, fill: theme.text-muted, license) }
}

// ── Abstract box ──
#let abstract-box(abstract-content, keywords: none, theme: default-theme, labels: default-header-labels) = {
  box(
    fill:   theme.accent-bg,
    radius: 2pt,
    inset:  (x: 6pt, y: 5pt),
    width:  100%,
    {
      text(fill: theme.accent, weight: "bold", size: 9pt, font: theme.font-sans, labels.abstract)
      v(4pt)
      set text(size: 8.5pt, font: theme.font-sans)
      abstract-content
      if keywords != none { v(6pt); keywords-line(keywords, theme: theme, labels: labels) }
    },
  )
}

// ── Main entry point ──
#let show-article-header(
  title: "",
  authors: (),
  affiliations: (),
  date: none,
  abstract: none,
  keywords: none,
  show-info: true,
  supervisors: none, email: none, submitted: none, defended: none,
  accepted: none, published: none, doi: none, license: none,
  theme: default-theme,
  labels: default-header-labels,
) = {
  set par(justify: false, leading: 0.4em)
  text(fill: theme.accent, weight: "black", size: 20pt, font: theme.font-sans, title)
  v(-5pt)

  if authors.len() > 0 {
    set text(size: 9pt, font: theme.font-sans, weight: "bold")
    authors.map(a => {
      if type(a) == str {
        a
      } else {
        let nums = if type(a.affils) == array { a.affils } else { (a.affils,) }
        let ids = nums.map(n => [#n]).join([, ])
        if ids == none { a.name } else { a.name + super[#ids] }
      }
    }).join(", ")
    v(-5pt)
  }

  if affiliations.len() > 0 {
    set text(size: 8pt, font: theme.font-sans)
    for aff in affiliations {
      text(weight: "bold", str(aff.id) + " ")
      aff.text
      linebreak()
    }
    v(3pt)
  }

  if abstract != none {
    abstract-box(abstract, keywords: keywords, theme: theme, labels: labels)
    v(4pt)
  }

  if show-info {
    info-box(
      email: email, supervisors: supervisors,
      submitted: submitted, defended: defended,
      accepted: accepted, published: published,
      doi: doi, license: license,
      theme: theme, labels: labels,
    )
  }

  v(3pt)

  if date != none {
    set text(size: 7.5pt, font: theme.font-sans, fill: theme.text-muted)
    date
    v(0pt)
  }

  line(length: 100%, stroke: 0.3pt)
}
