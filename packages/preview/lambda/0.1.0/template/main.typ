#import "@preview/lambda:0.1.0": thesis, note-block

// Optional: abbreviation management (https://typst.app/universe/package/abbr).
// Remove these three lines and the @ABBR use below if you don't need it.
#import "@preview/abbr:0.3.0"
#show: abbr.show-rule
#abbr.make(("DOC", "dissolved organic carbon"))

// ─────────────────────────────────────────────────────────────────────────────
// All configuration lives in this single call. Delete any field you don't need;
// most are optional and hidden when omitted. Set a feature toggle to `false` to
// turn that section off (cover, abstract, outline, header/footer, columns).
// ─────────────────────────────────────────────────────────────────────────────
#show: thesis.with(
  // ── Document metadata ──
  title: "A Concise, Descriptive Title for Your Thesis or Article",
  authors: (
    (name: "Ada Lovelace", affils: (1,)),
    (name: "Alan Turing", affils: (1, 2)),
  ),
  affiliations: (
    (id: 1, text: "Department of Example Studies, University of Somewhere"),
    (id: 2, text: "Institute for Further Research"),
  ),

  // ── Cover page ──
  degree: "Master of Science",
  major: "Example Studies",
  department: "Department of Example Studies",
  faculty: "Faculty of Science",
  university: "University of Somewhere",
  location: "Somewhere",
  date: "June 2026",
  submission-text: "Submitted in partial fulfilment of the requirements for the",
  supervisor: "Prof. Grace Hopper",
  co-supervisor: "Dr. Katherine Johnson",
  logo: none, // e.g. image("logo.png") or a path string

  // ── Front-matter info bar ──
  email: ("ada.lovelace@example.edu",),
  doi: none,
  submitted: none,
  defended: none,
  accepted: none,
  published: none,
  license: "Unrestricted use, distribution, and reproduction is permitted in any medium, provided the original author and source are credited.",

  // ── Abstract ──
  abstract: [
    Replace this paragraph with your abstract. It is shown in a tinted box at the
    top of the first content page. Summarise the question, approach, and main
    findings in a few sentences. The acronym @DOC will expand on first use.
  ],
  keywords: "keyword one, keyword two, keyword three",

  // ── Feature toggles (set any to false to disable) ──
  cover: true,
  show-abstract: true,
  show-outline: true,
  header-footer: true,
  columns: 2,

  // ── Optional theming (uncomment to customise) ──
  // accent: rgb("#8a1538"),                 // change the accent colour
  // theme: (
  //   font-serif: ("Libertinus Serif",),    // use only web-safe / bundled fonts
  //   font-sans:  ("Libertinus Serif",),
  // ),
  // labels: (abstract: "Résumé"),           // localise visible labels
)

// ═════════════════════════════════════════════════════════════════════════════
// CONTENT — write your thesis / article below.
// ═════════════════════════════════════════════════════════════════════════════

= Introduction

Replace this text with your introduction. You can cite sources like @example2024
and cross-reference figures such as @fig:example. Headings are numbered
automatically and appear in the table of contents.

#figure(
  rect(width: 100%, height: 4cm, fill: luma(240), stroke: none), // placeholder
  caption: [A placeholder figure. Replace the `rect` with `image("figure.png")`.],
) <fig:example>

== Background

=== A Sub-subsection

#note-block(title: "Note")[
  Use `note-block` to highlight an aside, definition, or callout. Omit the title
  for an untitled box.
]

= Methods

= Results

= Discussion

= Conclusion

// ── References ────────────────────────────────────────────────────────────────
#colbreak()
#bibliography("refs.bib", style: "apa")

// ── Appendix ──────────────────────────────────────────────────────────────────
#colbreak()
#set figure(numbering: n => "S" + str(n))
#counter(figure).update(0)
#counter(table).update(0)
#set heading(numbering: none)

= Appendix

== Supplementary Information

Supplementary figures and tables go here.
