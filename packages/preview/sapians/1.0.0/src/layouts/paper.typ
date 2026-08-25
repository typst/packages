#import "../tokens.typ": *
#import "../components/index.typ": *

// SAPIANS Scientific Article / Paper Layout (Crisp White Edition)
// Branding defaults carry the SAPIANS identity; every one of them is a
// parameter so the layout works for any venue or organization.
/// The two-column scientific-article page layout: sets the A4 page, base
/// typography, and a centered title block (kicker, title, authors), then
/// lays the body out in two justified columns. Apply it once per document
/// with a show rule — it sets page-level rules, so it cannot be called
/// from inside another container (a card, a box, ...) or from a live doc
/// example; see the usage snippet below.
///
/// ```typ
/// #import "@local/sapians:1.0.0": * // x-release-please-version
///
/// #show: sapians-article.with(
///   title: "A Fixed Paper Title",
///   abstract: [A short summary of the contribution.],
///   authors: (
///     (name: "First Author", affiliation: "Institution One"),
///     (name: "Second Author", affiliation: "Institution Two"),
///   ),
///   keywords: ("alpha", "beta", "gamma"),
/// )
///
/// = Introduction
/// Body text flows in two columns from here on.
/// ```
/// -> content
#let sapians-article(
  /// Document and title-block title. -> str
  title: "SAPIANS Scientific Article",

  /// Abstract shown in a bordered box under the title. The abstract block
  /// (and `keywords`, if any) is omitted entirely when `none`.
  /// -> none | str | content
  abstract: none,

  /// Authors, each either a plain name or a dictionary with `name` and
  /// optional `affiliation` keys, e.g. `(name: "Ada", affiliation: "MIT")`.
  /// Rendered as one column per author under the title. -> array
  authors: (),

  /// Keywords listed at the end of the abstract box, joined with commas.
  /// Ignored when `abstract` is `none`. -> array
  keywords: (),

  /// Document language, forwarded to `set text(lang: ...)`. -> str
  lang: "en",

  /// Uppercase kicker shown above the title, e.g. `"SAPIANS RESEARCH
  /// ARTICLE"`. -> str
  kicker: "SAPIANS RESEARCH ARTICLE",

  /// Venue name shown in the page footer. -> str
  journal: "SAPIANS Journal of Applied AI & Design",

  /// Label shown before the abstract text. -> str
  abstract-title: "Abstract",

  /// Label shown before the keyword list. -> str
  keywords-title: "Keywords",

  /// Article body, laid out in two columns. Supplied automatically by
  /// `#show: sapians-article.with(...)`. -> content
  body,
) = {
  set document(title: title, author: authors.map(a => if type(a) == str {
    a
  } else { a.name }))

  set page(
    paper: "a4",
    margin: (x: 20mm, top: 22mm, bottom: 22mm),
    fill: sapians-paper,
    footer: context [
      #grid(
        columns: (1fr, auto),
        text(size: 7.2pt, fill: sapians-muted-dark)[#journal],
        text(size: 7.2pt, fill: sapians-muted-dark, weight: "bold")[#counter(
          page,
        ).display()],
      )
    ],
  )

  set text(
    font: font-sans,
    fill: sapians-text-dark,
    size: 8.8pt,
    lang: lang,
  )

  set par(justify: true, leading: 0.58em)

  // Paper Title Header
  align(center)[
    #text(
      fill: sapians-terracotta,
      size: 7.5pt,
      weight: "bold",
      tracking: 0.15em,
    )[#upper(kicker)]
    #v(2.5mm)
    #text(fill: sapians-text-dark, size: 17pt, weight: "bold")[#title]
    #v(3.5mm)
    #if authors.len() > 0 [
      #grid(
        columns: authors.len(),
        gutter: 8mm,
        ..authors.map(a => {
          if type(a) == str [
            #text(size: 8.5pt, weight: "bold")[#a]
          ] else [
            #text(size: 8.5pt, weight: "bold")[#a.name] \
            #if "affiliation" in a [ #text(
              size: 7.2pt,
              fill: sapians-muted-dark,
            )[#a.affiliation] ]
          ]
        })
      )
    ]
    #v(3.5mm)
  ]

  if abstract != none [
    #align(center)[
      #block(
        width: 90%,
        fill: sapians-card-bg,
        radius: radius-sm,
        stroke: stroke-light,
        inset: 3.5mm,
      )[
        #align(left)[
          #text(
            weight: "bold",
            size: 8.0pt,
            fill: sapians-text-dark,
          )[#abstract-title] \
          #v(1.2mm)
          #text(size: 7.6pt, fill: sapians-muted-dark)[#abstract]
          #if keywords.len() > 0 [
            #v(1.8mm)
            #text(size: 7.2pt)[*#keywords-title:* #keywords.join(", ")]
          ]
        ]
      ]
    ]
    #v(3.5mm)
  ]

  // Two column layout for paper body
  show heading: it => [
    #v(2mm)
    #text(fill: sapians-text-dark, weight: "bold", size: 10pt)[#it.body]
    #v(1mm)
  ]

  columns(2, gutter: 5mm)[
    #body
  ]
}
