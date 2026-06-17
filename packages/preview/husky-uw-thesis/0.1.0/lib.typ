// ============================================================
// husky-uw-thesis — University of Washington thesis/dissertation template
// https://grad.uw.edu/current-students/enrollment-through-graduation/thesis-dissertation/
// ============================================================

/// Format a doctoral dissertation or master's thesis for the
/// University of Washington Graduate School.
///
/// The three required preliminary pages (title, copyright, abstract)
/// are generated automatically from the metadata you provide.
/// Body content follows with page numbering starting at 1.
///
/// - title (content): Dissertation or thesis title.
/// - author (str): Your full name, matching your UW student record.
/// - degree (str): Degree title as it will appear on your diploma.
/// - year (str): Year your degree will be conferred.
/// - program (str): Department or school authorized to offer the degree.
///     Do NOT prefix with "UW" or "University of Washington".
/// - chair (dictionary): `(name: str, department: str)` for committee chair.
/// - committee (array): Reading committee members. Each entry is
///     `(name: str)` or `(name: str, role: str)`. The chair should be
///     included here as well with `role: "Chair"`.
/// - abstract (content): Abstract text (double-spaced, left-aligned).
/// - doc-type (str): `"dissertation"` or `"thesis"`.
/// - font (str, array): Body text font. Default: `"Palatino Linotype"`.
/// - mono-font (str): Monospace font for `raw` blocks. Default: `"Fira Code"`.
/// - font-size (length): Base font size. Default: `12pt`.
/// - margin (dictionary): Page margins. Default: 1 in top/bottom/right, 1.5 in left.
/// - body (content): The rest of your document.
/// -> content
#let thesis(
  title: [Your Dissertation Title],
  author: "Your Name",
  degree: "Doctor of Philosophy",
  year: "2026",
  program: "Your Department",
  chair: (name: "Chair Name", department: "Chair's Department"),
  committee: (
    (name: "Chair Name", role: "Chair"),
    (name: "Second Member Name", role: none),
    (name: "Third Member Name", role: none),
  ),
  abstract: [],
  doc-type: "dissertation",
  font: ("Palatino Linotype", "Palatino", "TeX Gyre Pagella", "Libertinus Serif"),
  mono-font: ("Fira Code", "Fira Mono", "DejaVu Sans Mono"),
  font-size: 12pt,
  margin: (top: 1in, bottom: 1in, left: 1.5in, right: 1in),
  body,
) = {
  // ---- Global page & text setup ----
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    header: none,
  )
  set text(font: font, size: font-size, lang: "en")
  set par(leading: 0.65em)
  show raw: set text(font: mono-font)

  // ---- Helpers ----
  let prelim-text = if doc-type == "thesis" {
    [A thesis]
  } else {
    [A dissertation]
  }

  // ---- Page 1: Title Page ----
  align(center)[
    #v(1fr)

    #text(size: 14pt, weight: "bold")[#title]

    #v(2em)

    #author

    #v(3em)

    #prelim-text \
    submitted in partial fulfillment of the \
    requirements for the degree of

    #v(1em)

    #degree

    #v(2em)

    University of Washington

    #v(1em)

    #year

    #v(2em)

    Reading Committee:

    #v(0.5em)

    #for member in committee [
      #member.name#if member.at("role", default: none) != none [, #member.role]
      \
    ]

    #v(2em)

    Program Authorized to Offer Degree:

    #v(0.5em)

    #program

    #v(1fr)
  ]

  pagebreak()

  // ---- Page 2: Copyright Page ----
  align(center + horizon)[
    ©Copyright #year \
    #author
  ]

  pagebreak()

  // ---- Page 3: Abstract ----
  align(center)[
    University of Washington

    #v(1.5em)

    Abstract

    #v(1.5em)

    #text(weight: "bold")[#title]

    #v(1.5em)

    #author

    #v(1.5em)

    Chair of the Supervisory Committee: \
    #chair.name \
    #chair.department
  ]

  v(1.5em)

  // Abstract body: double-spaced, left-aligned
  {
    set par(leading: 1.2em, first-line-indent: 0pt)
    abstract
  }

  pagebreak()

  // ---- Body ----
  set page(numbering: "1")
  counter(page).update(1)
  set par(leading: 0.65em, first-line-indent: 1.5em, justify: true)
  // First paragraph after a heading should not be indented
  show heading: it => {
    it
    par(text(size: 0pt, ""))
  }

  body
}
