// MIT-Thesis.typ — Main document
// Compile with:  typst compile MIT-Thesis.typ

#import "@preview/muddy-mit-thesis:0.1.0": mitthesis, start-appendix, tracked

// ═══════════════════════════════════════════════════════════════════════════
//  Apply the template
// ═══════════════════════════════════════════════════════════════════════════

#show: mitthesis.with(
  title: [The Atomic Theory as Applied To Gases, with Some
          Experiments on the Viscosity of Air],

  authors: (
    (
      name:         "Silas W. Holman",
      department:   "Department of Physics",
      prev-degrees: (),
    ),
  ),

  degrees: (
    (name: "Bachelor of Science in Physics", department: "Department of Physics"),
  ),

  supervisors: (
    (name: "Edward C. Pickering", title: "Professor of Physics", department: "Department of Physics"),
  ),

  readers: (
    (name: "Marcus Gavius Apicius",   title: "Professor of Cooking Arts",    department: "Department of Food Science"),
    (name: "Marie-Antoine Carême",    title: "Professor of Haute Cuisine",   department: "Department of Food Science"),
    (name: "Miles Gloriosus",         title: "Professor of Personal Pronouns", department: "Department of Rhetoric"),
  ),

  acceptors: (
    (
      name:       "Tertius Castor",
      department: "Professor of Log Dams",
      title:      "Graduate Officer, Department of Research",
    ),
  ),

  degree-month:  "June",
  degree-year:   "1876",
  thesis-date:   "May 18, 1876",

  institution:   "Massachusetts Institute of Technology",

  cc-license:    none,  // set to (name: "CC BY-NC-ND 4.0", url: "...") to use a CC licence

  abstract-body: include "abstract.typ",
)

// ═══════════════════════════════════════════════════════════════════════════
//  Front matter
// ═══════════════════════════════════════════════════════════════════════════

#include "acknowledgments.typ"

#include "biography.typ"

// ─── Table of contents ───────────────────────────────────────────────────────
#outline(
  title:  [Contents],
  indent: 0pt,
)

// ─── List of figures ─────────────────────────────────────────────────────────
// Use heading(numbering: none) so LoF appears in the TOC without getting a
// chapter number (Typst's outline() sets outlined:false on its own title).
#heading(numbering: none)[List of Figures]
#outline(
  title:  none,
  target: figure.where(kind: image),
  indent: auto,
)

// ─── List of tables ──────────────────────────────────────────────────────────
#heading(numbering: none)[List of Tables]
#outline(
  title:  none,
  target: figure.where(kind: table),
  indent: auto,
)

// ═══════════════════════════════════════════════════════════════════════════
//  Chapters
// ═══════════════════════════════════════════════════════════════════════════

#include "chapter1.typ"

// ═══════════════════════════════════════════════════════════════════════════
//  Appendices
// ═══════════════════════════════════════════════════════════════════════════

// Switch to appendix numbering (A, B, …) and reset the chapter counter.
#start-appendix()

#include "appendixa.typ"

#include "appendixb.typ"

// ═══════════════════════════════════════════════════════════════════════════
//  Bibliography
// ═══════════════════════════════════════════════════════════════════════════

#bibliography(
  "mitthesis-sample.bib",
  style:  "ieee",
  title:  [References],
)
