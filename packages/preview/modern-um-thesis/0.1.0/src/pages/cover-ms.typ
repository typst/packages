#import "../utils/line.typ": *

/// Generate cover page for Master's thesis
///
/// This is a replica of the thesis cover .doc file provided by University of Macau
///
/// -> content
#let cover-ms(
  /// Date of submission
  ///
  /// -> datetime
  date: datetime.today(),
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: true,
  /// Thesis information
  ///
  /// -> dictionary
  info: (:),
) = {
  set page(margin: (top: 1.5in, bottom: 1.2in, left: 1.5in, right: 1.5in))
  set par(leading: 0.17em, spacing: 0.17em, justify: true)
  set align(center)
  set pagebreak(weak: true, to: if double-sided { "odd" })

  ////////////////
  // Cover page //
  ////////////////
  set text(size: 14pt)

  grid(
    columns: 1,
    gutter: (
      0.75em + 39pt,
      0.17em + 21pt,
      0.17em + 28pt,
      1.33em + 140pt,
      0.75em + 140pt,
      0.75em + 18pt,
      0.17em,
    ),
    align: center + top,

    // Empty line
    text(size: 10pt)[\ ],
    // Title
    info.title-en,
    text(size: 12pt)[by],
    // Name
    info.author-en,
    // Degree Title
    info.degree-en,
    // Year
    [#datetime.today().year()],
    // University Logo
    image("../assets/UM-Logo_Monotone.png", height: 79.1pt),
    // Academic Unit
    info.academic-unit-en,
    [University of Macau],
  )

  pagebreak()

  ////////////////
  // Title page //
  ////////////////
  set text(size: 12pt)

  grid(
    columns: 1,
    gutter: (
      0.75em + 39pt,
      0.17em + 21pt,
      1.33em,
      1.33em,
      0.17em,
      0.17em + 28pt,
      0.17em + 28pt,
      0.17em,
      0.17em + 28pt,
      0.75em + 28pt,
      0em,
    ),
    align: center + top,

    // Empty line
    [\ ],
    // Thesis Title
    info.title-en,
    // Name of Author
    [by],
    [#info.author-en],
    [\ ],
    [A thesis submitted in partial fulfillment of the\
      requirements for the degree of],
    // Degree Title
    info.degree-en,
    // Name of Academic Unit
    [#info.academic-unit-en],
    [University of Macau],
    // Expected Degree Awarding Year
    [#date.year()],
    // Approval Signature
    [\ \ \ \ \ \
      #grid(
        columns: 2,
        rows: 7,
        row-gutter: (0.17em, 1.33em),
        align: (center + top),

        grid.cell(
          x: 0,
          y: 0,
          colspan: 1,
          rowspan: 6,
        )[Approved by],
        uline(),
        [Supervisor],
        uline(),
        uline(),
        uline(),
        uline(),
        grid.cell(
          x: 0,
          y: 6,
          colspan: 2,
          rowspan: 1,
        )[Date#uline()],
      )
    ],
  )

  pagebreak()
}
