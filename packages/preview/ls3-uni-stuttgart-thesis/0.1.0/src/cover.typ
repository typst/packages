// cover.typ
//
// LS3 mittelblau cover page. Page 1 of the thesis.
// Ports the LaTeX coverpage.tex visual design to Typst.
//
// Coordinate system note. The LaTeX original uses TikZ with the page
// coordinate system anchored at the bottom-left (positive y goes up).
// Typst's place() anchors at the top-left (positive y goes down). All offsets
// from the LaTeX original have been converted with `y_typst = 297mm - y_latex`.
// Page is A4 portrait, 210mm x 297mm. Page center is at (105mm, 148.5mm).

#import "common.typ": colors, fonts
#import "logos.typ": default-university-logo, default-chair-logo
#import "university-block.typ": university-block

// Build the cover page. Called by the thesis() show rule.
//
// Parameters.
//   author       string, displayed in large white text
//   cover-title  content, the title as it appears on the cover (may use \ to break lines)
//   language         "english" or "german"
//   university-logo  auto (bundled logo), none, or image(...) of the official
//                    University of Stuttgart logo PDF, cropped automatically
//   institute        institute line set below the university logo
//   chair            chair line set below the institute
//   chair-logo       auto (bundled LS3 logo), none, or content
//   sans-font        font family or stack for the cover text
#let cover-page(
  author: "",
  cover-title: [],
  language: "english",
  university-logo: auto,
  institute: "",
  chair: "",
  chair-logo: auto,
  sans-font: fonts.sans,
) = {
  set page(
    paper: "a4",
    margin: 0pt,
    background: none,
    header: none,
    footer: none,
  )

  let uni-block = university-block(
    logo: if university-logo == auto { default-university-logo(language) } else { university-logo },
    language: language,
    institute: institute,
    chair: chair,
    sans-font: sans-font,
  )
  // A passed chair logo gets the bundled logo's 25mm width unless it sets
  // its own.
  let disc-logo = if chair-logo == auto {
    default-chair-logo()
  } else {
    set image(width: 25mm)
    chair-logo
  }

  rect(width: 100%, height: 100%, fill: white, stroke: none)[
    // Mittelblau circle. Radius 80mm. LaTeX places center at
    // (page.center + (1cm, -5cm)) which in TikZ means 5cm DOWN from center.
    // Center in Typst coords (from top): (115mm, 198.5mm).
    #place(top + left, dx: 115mm - 80mm, dy: 198.5mm - 80mm,
      circle(radius: 80mm, fill: colors.mittelblau, stroke: none)
    )

    // White accent disc with LS3 logo. Radius 20mm. LaTeX places center at
    // (page.center + (5.7cm, -10.4cm)) = (162mm, 252.5mm in Typst coords).
    #place(top + left, dx: 162mm - 20mm, dy: 252.5mm - 20mm,
      circle(radius: 20mm, fill: white, stroke: 0.5pt + colors.anthrazit)[
        #set align(center + horizon)
        #disc-logo
      ]
    )

    // University logo with institute and chair lines, top-left at
    // (10mm, 10mm) from the page corner, laid out like the institute logo
    // the LaTeX template used.
    #place(top + left, dx: 10mm, dy: 10mm, uni-block)

    // Author name, large white sans, anchored top-left at (page.center +
    // (-5cm, -2cm)) = (55mm, 168.5mm in Typst coords). Text width 120mm.
    #place(top + left, dx: 55mm, dy: 168.5mm,
      box(width: 120mm)[
        #set text(font: sans-font, size: 24pt, fill: white, weight: "regular")
        #author
      ]
    )

    // Cover title, huge bold white sans. Anchored at (page.center +
    // (-5cm, -4cm)) = (55mm, 188.5mm in Typst coords). LaTeX sets
    // baselineskip=30pt for tight multi-line titles.
    #place(top + left, dx: 55mm, dy: 188.5mm,
      box(width: 120mm)[
        #set par(leading: 10pt)
        #set text(font: sans-font, size: 24pt, fill: white, weight: "bold")
        #cover-title
      ]
    )
  ]

  // Force the next section (title page) onto the next odd / recto page so
  // a blank verso sits between cover and title page in a bound book.
  pagebreak(to: "odd")
}
