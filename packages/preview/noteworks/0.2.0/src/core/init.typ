// =====================================================
// INIT - Document initialization show rule
// =====================================================
// Apply in main.typ, before any content:
//
//   #show: noteworthy.with(
//     title: "My Notes",
//     authors: ("Me",),
//     theme: "aether",
//   )
//
// Every option defaults to the package's bundled configuration;
// pass only what you want to change. The resolved configuration
// is stored in a document state that all components read.

#import "./setup.typ": default-config, nw-state
#import "./scheme.typ": schemes

#let noteworthy(
  // Metadata
  title: auto,
  subtitle: auto,
  authors: auto,
  affiliation: auto,
  logo: auto,
  // Appearance
  theme: auto, // scheme name, e.g. "aether" (see schemes)
  font: auto,
  title-font: auto,
  // Structure & numbering
  chapter-name: auto,
  subchap-name: auto,
  heading-numbering: auto,
  pad-chapter-id: auto,
  pad-page-id: auto,
  // Blocks
  show-solution: auto,
  solutions-text: auto,
  problems-text: auto,
  box-margin: auto,
  box-inset: auto,
  block-design: auto,
  body,
) = {
  let pick(v, d) = if v == auto { d } else { v }
  let d = default-config

  let meta = (
    title: pick(title, d.meta.title),
    subtitle: pick(subtitle, d.meta.subtitle),
    authors: pick(authors, d.meta.authors),
    affiliation: pick(affiliation, d.meta.affiliation),
    logo: pick(logo, d.meta.logo),
  )
  let c = (
    font: pick(font, d.c.font),
    title-font: pick(title-font, d.c.title-font),
    chapter-name: pick(chapter-name, d.c.chapter-name),
    subchap-name: pick(subchap-name, d.c.subchap-name),
    show-solution: pick(show-solution, d.c.show-solution),
    solutions-text: pick(solutions-text, d.c.solutions-text),
    problems-text: pick(problems-text, d.c.problems-text),
    box-margin: pick(box-margin, d.c.box-margin),
    box-inset: pick(box-inset, d.c.box-inset),
    pad-chapter-id: pick(pad-chapter-id, d.c.pad-chapter-id),
    pad-page-id: pick(pad-page-id, d.c.pad-page-id),
    heading-numbering: pick(heading-numbering, d.c.heading-numbering),
    block-design: pick(block-design, d.c.block-design),
  )
  let theme-name = lower(pick(theme, d.theme-name))
  let theme-dict = schemes.at(theme-name, default: schemes.at("noteworthy-dark"))

  nw-state.update((meta: meta, c: c, theme: theme-dict, theme-name: theme-name))

  set page(
    paper: "a4",
    fill: theme-dict.page-fill,
    margin: (x: 1in, y: 1in),
  )
  set text(font: c.font, size: 11pt, fill: theme-dict.text-main)
  set heading(numbering: c.heading-numbering)
  set document(
    title: meta.title,
    author: if type(meta.authors) == array { meta.authors.join(", ") } else { meta.authors },
  )

  body
}
