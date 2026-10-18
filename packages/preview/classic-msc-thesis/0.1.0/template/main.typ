// ============================================================================
//  Master's Thesis — main document
//
//  Compile with:   typst compile main.typ
//  Live preview:   typst watch main.typ
//
//  This file wires the front matter + chapters + back matter together through
//  the `classic-msc-thesis` template. Replace the placeholder content with your
//  own; the order of sections is fixed by the template, so you only edit
//  content here (and in the chapters/ files).
// ============================================================================

#import "@preview/classic-msc-thesis:0.1.0": thesis, abbrev-table, flex-caption

#show: thesis.with(
  // ---- metadata ----
  title: "The Title of Your Master's Thesis",
  // subtitle: "An optional subtitle",
  author: "Your Name",
  degree: "MSc in Your Programme",
  university: "Name of Your University",
  department: "Faculty or Department",
  supervisor: "Dr. Supervisor Name",
  tutor: "Dr. Tutor Name",
  institute: "Host Research Institute",   // where the work was carried out; set to none to omit
  location: "City",
  date: datetime.today(),

  // Title-page logos. By default these are placeholder boxes so the template
  // compiles out of the box. Replace them with your real logo files, both sized
  // to the same height, e.g.:
  //   logo:           image("figures/university-logo.svg", height: 1.7cm),
  //   logo-secondary: image("figures/institute-logo.png",  height: 1.7cm),
  // Set either (or both) to none for a text-only header.
  logo: rect(width: 3.6cm, height: 1.7cm, stroke: 0.5pt + luma(160), radius: 2pt)[
    #align(center + horizon)[#text(size: 8pt, fill: luma(130))[University logo]]
  ],
  logo-secondary: rect(width: 3.2cm, height: 1.7cm, stroke: 0.5pt + luma(160), radius: 2pt)[
    #align(center + horizon)[#text(size: 8pt, fill: luma(130))[Institute logo]]
  ],

  // ---- front matter ----
  // Certificate of Direction. A short certifying statement (delete it, or set
  // `certificate: none`, if you only want a signature space) followed by three
  // signature blocks. Each block is a narrow role row above a tall blank row
  // whose bottom rule is the signature line — sign, or paste a digital
  // signature, in the space above it.
  certificate: [
    #v(1fr)
    #align(center)[#text(size: 18pt, weight: "bold")[Certificate of Direction]]
    #v(1.2cm)

    *Dr. Tutor Name*, as Academic Tutor, and *Dr. Supervisor Name*, as Project
    Supervisor, hereby certify that this Master's Thesis, entitled "*The Title of
    Your Master's Thesis*", has been carried out by *Your Name* under their
    direction and fulfils the requirements to be submitted and defended for the
    degree of MSc in Your Programme.

    #v(0.4cm)
    City, #datetime.today().display("[day] [month repr:long] [year]")
    #v(1.4cm)

    #align(center)[
      #table(
        columns: (12cm),
        rows: (auto, 2.6cm, auto, 2.6cm, auto, 2.6cm),
        // signature line = bottom rule on the tall (odd-indexed) rows
        stroke: (x, y) => if calc.odd(y) { (bottom: 0.6pt + black) } else { none },
        align: left + horizon,
        inset: (x: 0pt, top: 16pt, bottom: 4pt),
        [*Academic Tutor* #h(0.6em) #text(size: 10pt, fill: luma(110))[Dr. Tutor Name]], [],
        [*Project Supervisor* #h(0.6em) #text(size: 10pt, fill: luma(110))[Dr. Supervisor Name]], [],
        [*Author* #h(0.6em) #text(size: 10pt, fill: luma(110))[Your Name]], [],
      )
    ]
    #v(1fr)
  ],

  acknowledgments: [
    Use this section to thank the people and institutions that supported your
    work: your supervisor and tutor, your research group or department, funding
    bodies, and anyone who helped along the way. Keep it warm but concise — a few
    short paragraphs are plenty.

    A second paragraph can acknowledge family and friends. This block is optional:
    set `acknowledgments: none` in `main.typ` to omit it entirely.
  ],

  abstract: [
    The abstract is a self-contained summary of the whole thesis, usually between
    200 and 350 words. State the problem and its context, what you did, the main
    results, and why they matter, in a single unbroken passage that a reader can
    understand without the rest of the document.

    Open with the motivation and the gap your work addresses. Then describe your
    approach at a high level — enough for the reader to grasp the method without
    the detail of the Methodology chapter. Close with your principal findings,
    expressed concretely, and one sentence on their significance. Avoid citations,
    undefined abbreviations, and figures here; the abstract must stand on its own.
  ],
  keywords: [first keyword, second keyword, third keyword, fourth keyword],

  // A List of Abbreviations (optional). Provide (short, long) pairs and the
  // section is generated automatically; leave it out to omit the section.
  abbreviations: (
    ("DNA", "Deoxyribonucleic Acid"),
    ("API", "Application Programming Interface"),
    ("SVG", "Scalable Vector Graphics"),
    ("TSV", "Tab-Separated Values"),
  ),

  // ---- toggles (all default to on) ----
  show-toc: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  heading-numbering: true,

  // ---- back matter ----
  bibliography: bibliography("references.bib", style: "apa"),
  appendix: include "chapters/05-appendix.typ",
)

// ---- main-matter chapters (arabic numbered) ----
#include "chapters/01-introduction.typ"
#include "chapters/02-methodology.typ"
#include "chapters/03-results.typ"
#include "chapters/04-discussion.typ"
