// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// Curriculum Vitae — included via cv: include "cv.typ" in dissertation.typ.
// The "Curriculum Vitae" heading is added automatically by the template.

#set text(size: 9pt)

// Bio
// ───
#grid(
  columns: (1fr, auto),
  gutter: 1.5em,
  [
    Firstname Lastname was born on dd Month YYYY in Hometown, Country.
    He/She received the B.Sc. and M.Sc. degrees in [Field] from [University] in
    YYYY and YYYY, respectively. Subsequently, he/she joined the [Laboratory] at
    [University] under the supervision of Prof. Dr. [Supervisor] to pursue a
    doctoral degree. His/Her research interests include [topic A] and [topic B].
  ],
  // Replace with your own photo:
  // image("figures/photo.jpg", width: 3cm),
  rect(width: 3cm, height: 3.8cm, stroke: 0.5pt, fill: luma(240))[
    #align(center + horizon, text(size: 7pt, fill: luma(120))[Photo])
  ],
)

#v(1em)

// Education
// ─────────
#text(size: 12pt, weight: "bold")[Education]
#v(0.3em)
#table(
  columns: (3.2cm, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 2.5pt),
  [20XX -- 20XX],
  [*Ph.D. in [Field]*, [University]. \
    Dissertation: _"Title of This Dissertation"_. \
    Supervisor: Prof. Dr. Supervisor Name.],

  [20XX -- 20XX], [*M.Sc. in [Field]*, [University].],
  [20XX -- 20XX], [*B.Sc. in [Field]*, [University].],
)

#v(0.8em)

// Publications
// ────────────
#text(size: 12pt, weight: "bold")[Publications]
#v(0.3em)

_Journal Articles_
#v(0.2em)
#set enum(numbering: "[1]", indent: 0pt)

+ F. Lastname, A. Coauthor, and P. Professor, "Title of Journal Paper,"
  _IEEE Trans. VLSI Systems_, vol.~XX, no.~X, pp.~1–14, 20XX.

+ F. Lastname and A. Coauthor, "Title of Second Journal Paper,"
  _IEEE Design & Test_, vol.~XX, no.~X, pp.~1–10, 20XX.

#v(0.5em)
_Conference Papers_
#v(0.2em)

+ F. Lastname and A. Coauthor, "Title of Conference Paper,"
  in _Proc. Design Automation Conference (DAC)_, 20XX.

+ F. Lastname and A. Coauthor, "Title of Second Conference Paper,"
  in _Proc. DATE_, 20XX.

#v(0.8em)

// Chip Tape-outs
// ──────────────
#text(size: 12pt, weight: "bold")[Chip Tape-outs]
#v(0.3em)
#table(
  columns: (1.8cm, 2.2cm, 1cm, auto),
  stroke: none,
  inset: (x: 0pt, y: 2.5pt),
  table.header(
    text(weight: "bold", [Name]),
    text(weight: "bold", [Technology]),
    text(weight: "bold", [Year]),
    text(weight: "bold", [Role]),
  ),
  [Chip A], [TSMC Xnm], [20XX], [Lead designer],
  [Chip B], [GF Xnm], [20XX], [Contributor],
)
#text(size: 8pt, style: "italic")[See Appendix~B for details on each chip.]

#v(0.8em)

// Teaching
// ────────
#text(size: 12pt, weight: "bold")[Teaching]
#v(0.3em)
#table(
  columns: (3.2cm, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 2.5pt),
  [20XX -- 20XX], [Head Teaching Assistant, _Course Name_, [University].],
  [20XX], [Teaching Assistant, _Course Name_, [University].],
)

#v(0.8em)

// Awards & Honors
// ───────────────
#text(size: 12pt, weight: "bold")[Awards & Honors]
#v(0.3em)
- Best Paper Award, Conference Name, 20XX.
- Excellence Scholarship, [University], 20XX.
