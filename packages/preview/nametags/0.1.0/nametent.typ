// nametent.typ — folded table tent
//
// Tabloid landscape (11 x 8.5) folded along the horizontal center
// becomes an 11 x 4.25 tent. The top half is rotated 180° so both
// sides read upright after folding.
//
// Logos are passed as bytes (e.g. `read("iri.png")`) so paths resolve
// relative to the *calling* file, not this package.

#let nametent(
  name: "",
  affiliation: "",
  conference: "Annual Research Symposium",
  year: "2026",
  accent-color: rgb("#0d3b66"),
  logo-left: none,
  logo-right: none,
) = {
  // ---- Design tokens ----
  let ink = rgb("#000000")
  let hairline = rgb("#e5e5e5")
  let heading-font = ("Industry Inc Test Base", "Industry Inc", "Industry", "Impact")
  let body-font = ("Oriya MN", "Oriya Sangam MN", "Times New Roman")

  // Pick a name size that keeps the longest name on one line.
  let name-size = if name.len() > 16 {
    52pt
  } else if name.len() > 12 {
    60pt
  } else {
    68pt
  }

  // ---- Reusable single-panel layout (one half of the folded sheet) ----
  let panel = block(
    width: 11in,
    height: 4.25in,
    fill: white,
    grid(
      columns: 1,
      rows: (auto, 1fr),
      row-gutter: 0pt,

      // Header bar
      block(
        width: 100%,
        fill: ink,
        inset: (x: 28pt, y: 9pt),
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(
            font: heading-font,
            size: 11pt,
            fill: white,
            tracking: 0.7pt,
            upper(conference),
          ),
          text(
            font: heading-font,
            size: 11pt,
            fill: accent-color,
            year,
          ),
        ),
      ),

      // Body — three columns: left logo | name | right logo
      block(
        width: 100%,
        height: 100%,
        inset: (x: 32pt, y: 18pt),
        grid(
          columns: (1.4in, 1fr, 1.4in),
          column-gutter: 20pt,
          align: (left + horizon, center + horizon, right + horizon),

          if logo-left != none {
            image(logo-left, width: 1.4in, fit: "contain")
          } else { [] },

          align(center + horizon)[
            #text(
              font: body-font,
              weight: "bold",
              size: name-size,
              fill: ink,
            )[#name]
            #v(10pt)
            #box(width: 96pt, height: 5pt, fill: accent-color)
            #if affiliation != "" [
              #v(12pt)
              #text(
                font: body-font,
                size: 22pt,
                fill: rgb("#333333"),
              )[#affiliation]
            ]
          ],

          if logo-right != none {
            image(logo-right, width: 1.4in, fit: "contain")
          } else { [] },
        ),
      ),
    ),
  )

  // ---- Page setup: tabloid landscape (folds to 11 x 4.25) ----
  set page(
    width: 11in,
    height: 8.5in,
    margin: 0pt,
    fill: white,
  )

  grid(
    columns: 1,
    rows: (4.25in, 4.25in),
    row-gutter: 0pt,
    rotate(180deg, reflow: true, panel),
    panel,
  )
}
