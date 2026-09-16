// ─── THESIS / ARTICLE ENTRY POINT ─────────────────────────────────────────────
// The single show-rule users apply: `#show: thesis.with(..)`. It orchestrates the
// cover page, page/header/footer layout, the article title block, and the table of
// contents, then lays out the document body. Every customisable value is a
// parameter with a sensible default.
#import "theme.typ": default-theme, resolve-theme, theme-state
#import "cover.typ": show-cover, default-cover-labels
#import "article-header.typ": show-article-header, default-header-labels
#import "layout.typ": show-layout

#let thesis(
  // ── Core metadata ──
  title: "",
  authors: (),                  // (str | (name: str, affils: (int,)))[]
  affiliations: (),             // ((id: int, text: str),)
  date: auto,                   // cover date (str/content); auto ⇒ omitted on cover

  // ── Cover-page fields ──
  birthday: none,
  student-id: none,
  degree: none,
  major: none,
  department: none,
  faculty: none,
  university: none,
  location: none,
  submission-text: none,
  supervisor: none,
  co-supervisor: none,
  logo: none,

  // ── Front-matter info bar ──
  email: none,                  // (str,) — shown as mailto links
  submitted: none,
  defended: none,
  accepted: none,
  published: none,
  doi: none,
  license: none,

  // ── Abstract ──
  abstract: none,
  keywords: none,

  // ── Running head / footer ──
  short-author: auto,           // auto ⇒ surname of first author
  short-title: auto,            // auto ⇒ title
  foot-info: "",

  // ── "Compiled on" line under the title block ──
  manuscript-date: auto,        // auto ⇒ today; none ⇒ hidden; or custom content

  // ── Feature toggles ──
  cover: true,
  show-abstract: true,
  show-outline: true,
  header-footer: true,
  columns: 2,

  // ── Theming & localisation ──
  accent: none,                 // shortcut to override only the accent color
  theme: (:),                   // full theme overrides (merged onto defaults)
  labels: (:),                  // override visible strings (see default-*-labels)

  body,
) = {
  // ── Resolve theme ──
  let overrides = theme
  if accent != none { overrides = overrides + (accent: accent) }
  let th = resolve-theme(overrides)

  // ── Resolve labels ──
  let cover-labels  = default-cover-labels + labels
  let header-labels = default-header-labels + labels

  // ── PDF metadata (must precede any content) ──
  let author-names = authors.map(a => if type(a) == str { a } else { a.name })
  set document(title: title, author: author-names)

  // Install the active theme for body-level helpers (note-block, rho-box).
  theme-state.update(th)

  // ── Cover page ──
  if cover {
    show-cover(
      title: title,
      authors: authors,
      email: email,
      birthday: birthday,
      student-id: student-id,
      degree: degree,
      major: major,
      department: department,
      faculty: faculty,
      university: university,
      location: location,
      date: if date == auto { none } else { date },
      submission-text: submission-text,
      supervisor: supervisor,
      co-supervisor: co-supervisor,
      logo: logo,
      theme: th,
      labels: cover-labels,
    )
  }

  // ── Derive running-head strings ──
  let head-author = if short-author == auto {
    let first = if authors.len() > 0 { authors.at(0) } else { none }
    let name = if first == none { "" } else if type(first) == str { first } else { first.name }
    name.split(" ").last()
  } else { short-author }
  let head-title = if short-title == auto { title } else { short-title }

  // Apply the page/header/footer/heading layout to everything that follows.
  show: it => show-layout(
    it,
    theme: th,
    column-count: columns,
    lead-author: head-author,
    short-title: head-title,
    foot-info: foot-info,
    institution: if university != none { university } else { "" },
    show-header-footer: header-footer,
  )

  counter(page).update(1)

  // ── Supervisors line for the info bar (safe join) ──
  let supervisors = {
    let parts = ()
    if supervisor != none { parts.push(supervisor) }
    if co-supervisor != none { parts.push(co-supervisor) }
    if parts.len() > 0 { parts.join(", ") } else { none }
  }

  // ── "Compiled on" line ──
  let mdate = if manuscript-date == auto {
    [This manuscript was compiled on #datetime.today().display("[month repr:long] [day], [year]")]
  } else { manuscript-date }

  // ── Title block ──
  show-article-header(
    title: title,
    authors: authors,
    affiliations: affiliations,
    date: mdate,
    abstract: if show-abstract { abstract } else { none },
    keywords: if show-abstract { keywords } else { none },
    show-info: true,
    supervisors: supervisors,
    email: email,
    submitted: submitted,
    defended: defended,
    accepted: accepted,
    published: published,
    doi: doi,
    license: license,
    theme: th,
    labels: header-labels,
  )

  // Two-level heading numbers for the contents and the body that follows.
  set heading(numbering: "1.1")

  // ── Table of contents ──
  if show-outline {
    show outline: set outline(title: none)
    text(font: th.font-sans, weight: "bold", fill: th.accent, size: 11pt)[Contents]
    v(0.4em)
    outline(depth: 3, indent: auto)
    colbreak()
  }

  body
}
