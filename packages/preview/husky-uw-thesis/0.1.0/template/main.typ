#import "@preview/husky-uw-thesis:0.1.0": thesis

#show: thesis.with(
  title: [Your Dissertation Title],
  author: "Your Name",
  degree: "Doctor of Philosophy",
  year: "2026",
  program: "Your Department",
  chair: (
    name: "Chair Name",
    department: "Chair's Department",
  ),
  committee: (
    // First entry should be the chair. Include all reading committee members.
    // Do NOT include professional titles (Dr., PhD, etc.).
    (name: "Chair Name", role: "Chair"),
    (name: "Second Member Name", role: none),
    (name: "Third Member Name", role: none),
  ),
  abstract: [
    Your abstract goes here.
  ],

  // Uncomment and change to "thesis" for a master's thesis:
  // doc-type: "thesis",

  // Font configuration (defaults shown):
  // font: ("Palatino Linotype", "Palatino", "TeX Gyre Pagella", "Libertinus Serif"),
  // mono-font: ("Fira Code", "Fira Mono", "DejaVu Sans Mono"),
  // font-size: 12pt,
)

// ============================================================
// Your dissertation content starts here.
// Page numbers begin at 1 automatically.
// ============================================================

// Uncomment for a table of contents:
// #outline(title: "Table of Contents", indent: auto)
// #pagebreak()

= Introduction

// Your introduction here.

== Motivation

== Outline

= Background

= Methods

= Results

= Discussion

= Conclusion

// Bibliography example:
// #bibliography("refs.bib", style: "american-physics-society")
