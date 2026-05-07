// nametag.typ — single 4x3 in conference badge
//
// Each call sets the page to 4 x 3 in and renders one badge. Call once
// per attendee — Typst will start a new page for each.
//
// Logos are passed as bytes (e.g. `read("iri.png")`) so paths resolve
// relative to the *calling* file, not this package.

#let nametag(
  name: "",
  affiliation: "",
  subaffiliation: "",
  conference: "Annual Research Symposium",
  year: "2026",
  accent-color: rgb("#0d3b66"),
  logo-left: none,
  logo-right: none,
) = {
  // ---- Design tokens ----
  let ink = rgb("#000000")
  let muted = rgb("#555555")
  let faint = rgb("#777777")
  let hairline = rgb("#e5e5e5")

  // Font fallbacks let this render on machines without the licensed
  // fonts (CI, collaborators, Universe sandbox).
  let heading-font = ("Industry Inc Test Base", "Industry Inc", "Industry", "Impact")
  let body-font = ("Oriya MN", "Oriya Sangam MN", "Times New Roman")

  // ---- Page = the badge itself ----
  set page(
    width: 4in,
    height: 3in,
    margin: 0pt,
    fill: white,
  )

  // ---- Outer frame: a 3-row grid (header / body / footer) ----
  block(
    width: 100%,
    height: 100%,
    stroke: 0.5pt + hairline,
    radius: 6pt,
    clip: true,
    {
      grid(
        columns: 1,
        rows: (auto, 1fr, auto),

        // ---- Header bar ----
        block(
          width: 100%,
          fill: ink,
          inset: (x: 14pt, y: 9pt),
          grid(
            columns: (1fr, auto),
            align: (left + horizon, right + horizon),
            text(
              font: heading-font,
              size: 10pt,
              fill: white,
              tracking: 0.6pt,
              upper(conference),
            ),
            text(
              font: heading-font,
              size: 10pt,
              fill: accent-color,
              year,
            ),
          ),
        ),

        // ---- Body (fills remaining vertical space) ----
        block(
          width: 100%,
          height: 100%,
          inset: (x: 18pt, y: 14pt),
          align(center + horizon)[
            #text(
              font: body-font,
              weight: "bold",
              size: 26pt,
              fill: ink,
            )[#name]
            #v(4pt)
            #box(width: 56pt, height: 4pt, fill: accent-color)
            #v(14pt)
            #text(font: body-font, size: 13pt, fill: rgb("#333333"))[#affiliation]
            #if subaffiliation != "" [
              #v(3pt)
              #block(
                width: 90%,
                text(
                  font: body-font,
                  size: 11pt,
                  fill: faint,
                )[#subaffiliation],
              )
            ]
          ],
        ),

        // ---- Footer with logos ----
        block(
          width: 100%,
          stroke: (top: 0.5pt + hairline),
          inset: (x: 14pt, y: 6pt),
          grid(
            columns: (1fr, 1fr),
            align: (left + horizon, right + horizon),
            if logo-left != none {
              image(logo-left, height: 24pt, fit: "contain")
            } else { [] },
            if logo-right != none {
              image(logo-right, height: 24pt, fit: "contain")
            } else { [] },
          ),
        ),
      )
    },
  )
}
