// src/presets.typ - Standard Label Sheet & Grid Layout Presets for Typst Mail Merge

#let presets = (
  // Avery 5160 / 8160 - Standard Address Labels (3 columns x 10 rows = 30 per sheet, US Letter)
  avery-5160: (
    columns: 3,
    rows: 10,
    width: 2.625in,
    height: 1.0in,
    column-gutter: 0.125in,
    row-gutter: 0in,
    page-margin: (top: 0.5in, bottom: 0.5in, left: 0.1875in, right: 0.1875in),
    paper: "us-letter",
    cell-padding: 4pt,
  ),

  // Avery 5161 - Address Labels (2 columns x 10 rows = 20 per sheet, US Letter)
  avery-5161: (
    columns: 2,
    rows: 10,
    width: 4.0in,
    height: 1.0in,
    column-gutter: 0.16in,
    row-gutter: 0in,
    page-margin: (top: 0.5in, bottom: 0.5in, left: 0.17in, right: 0.17in),
    paper: "us-letter",
    cell-padding: 4pt,
  ),

  // Avery 5162 - Address / File Folder Labels (2 columns x 7 rows = 14 per sheet, US Letter)
  avery-5162: (
    columns: 2,
    rows: 7,
    width: 4.0in,
    height: 1.33in,
    column-gutter: 0.16in,
    row-gutter: 0in,
    page-margin: (top: 0.84in, bottom: 0.84in, left: 0.17in, right: 0.17in),
    paper: "us-letter",
    cell-padding: 5pt,
  ),

  // Avery 5163 - Shipping Labels (2 columns x 5 rows = 10 per sheet, US Letter)
  avery-5163: (
    columns: 2,
    rows: 5,
    width: 4.0in,
    height: 2.0in,
    column-gutter: 0.14in,
    row-gutter: 0in,
    page-margin: (top: 0.5in, bottom: 0.5in, left: 0.18in, right: 0.18in),
    paper: "us-letter",
    cell-padding: 6pt,
  ),

  // Avery 5164 - Large Shipping Labels / Badges (2 columns x 3 rows = 6 per sheet, US Letter)
  avery-5164: (
    columns: 2,
    rows: 3,
    width: 4.0in,
    height: 3.33in,
    column-gutter: 0.14in,
    row-gutter: 0in,
    page-margin: (top: 0.5in, bottom: 0.5in, left: 0.18in, right: 0.18in),
    paper: "us-letter",
    cell-padding: 8pt,
  ),

  // Avery L7160 - Metric A4 Address Labels (3 columns x 7 rows = 21 per sheet, A4)
  avery-l7160: (
    columns: 3,
    rows: 7,
    width: 63.5mm,
    height: 38.1mm,
    column-gutter: 2.5mm,
    row-gutter: 0mm,
    page-margin: (top: 15.1mm, bottom: 15.1mm, left: 7.2mm, right: 7.2mm),
    paper: "a4",
    cell-padding: 4pt,
  ),

  // Avery L7163 - Metric A4 Address Labels (2 columns x 7 rows = 14 per sheet, A4)
  avery-l7163: (
    columns: 2,
    rows: 7,
    width: 99.1mm,
    height: 38.1mm,
    column-gutter: 2.5mm,
    row-gutter: 0mm,
    page-margin: (top: 15.1mm, bottom: 15.1mm, left: 4.7mm, right: 4.7mm),
    paper: "a4",
    cell-padding: 4pt,
  ),

  // A4 Standard 3x8 Grid Labels (3 columns x 8 rows = 24 per sheet, A4)
  a4-3x8: (
    columns: 3,
    rows: 8,
    width: 70mm,
    height: 36mm,
    column-gutter: 0mm,
    row-gutter: 0mm,
    page-margin: (top: 4.5mm, bottom: 4.5mm, left: 0mm, right: 0mm),
    paper: "a4",
    cell-padding: 4pt,
  ),

  // A4 Standard 2x7 Grid Labels (2 columns x 7 rows = 14 per sheet, A4)
  a4-2x7: (
    columns: 2,
    rows: 7,
    width: 105mm,
    height: 42.3mm,
    column-gutter: 0mm,
    row-gutter: 0mm,
    page-margin: (top: 0mm, bottom: 0mm, left: 0mm, right: 0mm),
    paper: "a4",
    cell-padding: 5pt,
  ),

  // Name Badges 2x4 (2 columns x 4 rows = 8 per sheet, US Letter)
  badge-2x4: (
    columns: 2,
    rows: 4,
    width: 3.5in,
    height: 2.25in,
    column-gutter: 0.5in,
    row-gutter: 0.25in,
    page-margin: (top: 0.5in, bottom: 0.5in, left: 0.5in, right: 0.5in),
    paper: "us-letter",
    cell-padding: 6pt,
  ),

  // Table Place Cards / Large Badges 2x2 (2 columns x 2 rows = 4 per sheet, US Letter)
  card-2x2: (
    columns: 2,
    rows: 2,
    width: 3.75in,
    height: 4.5in,
    column-gutter: 0.5in,
    row-gutter: 0.5in,
    page-margin: (top: 0.75in, bottom: 0.75in, left: 0.375in, right: 0.375in),
    paper: "us-letter",
    cell-padding: 8pt,
  )
)
