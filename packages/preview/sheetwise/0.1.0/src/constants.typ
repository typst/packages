#let _paper-sizes = (
  a6: (width: 105mm, height: 148mm),
  a5: (width: 148mm, height: 210mm),
  a4: (width: 210mm, height: 297mm),
  a3: (width: 297mm, height: 420mm),
  sra3: (width: 320mm, height: 450mm),
  letter: (width: 8.5in, height: 11in),
  legal: (width: 8.5in, height: 14in),
  tabloid: (width: 11in, height: 17in),
)

#let _mark-black = cmyk(0%, 0%, 0%, 100%)
#let _paper-white = cmyk(0%, 0%, 0%, 0%)
#let registration-color = cmyk(100%, 100%, 100%, 100%)

#let _proof-color = cmyk(85%, 45%, 0%, 0%)
#let _bleed-color = cmyk(0%, 70%, 90%, 0%)
#let _safe-color = cmyk(70%, 0%, 70%, 0%)
#let _label-color = cmyk(0%, 0%, 0%, 70%)

#let _default-mark-style = (
  color: _mark-black,
  registration-color: registration-color,
  length: 5mm,
  offset: 3.1751mm,
  bleed-offset: 0pt,
  no-bleed-offset: 2mm,
  thickness: 0.1764mm,
  knockout: true,
  knockout-color: _paper-white,
  knockout-padding: 0.7pt,
  file-header-size: 5pt,
  file-header-color: _label-color,
  file-header-inset: 1mm,
  page-border-color: _mark-black,
  page-border-thickness: 0.1764mm,
)

#let _default-marks = (
  crop: true,
  crop-mode: "auto",
  bleed: false,
  safe: false,
  registration: false,
  color-bar: false,
  fold: false,
  file-header: false,
  page-border: false,
)

#let _disabled-marks = (
  crop: false,
  crop-mode: "auto",
  bleed: false,
  safe: false,
  registration: false,
  color-bar: false,
  fold: false,
  file-header: false,
  page-border: false,
)
