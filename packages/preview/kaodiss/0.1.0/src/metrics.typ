// =============================================================================
// Layout metrics
//
// Every value in this file is taken from the kaobook class (A4, \hscale =
// \vscale = 1mm) or measured in documents typeset with kaobook + newpxtext.
// Change values here only if you deliberately want to deviate from kaobook.
// =============================================================================

// --- Page geometry (kaobook \marginlayout / \widelayout) ---------------------
#let paper = "a4"
#let page-width = 210mm
#let page-height = 297mm
#let top = 27.4mm
#let bottom = 27.4mm
#let inner = 24.8mm
#let text-width = 107mm
#let margin-sep = 6.2mm // \marginparsep
#let margin-width = 47.7mm // \marginparwidth
#let outer-far = page-width - inner - text-width - margin-sep - margin-width // 24.3mm
#let wide-outer = 24.8mm // \widelayout: symmetric margins, no margin column
#let wide-width = page-width - inner - wide-outer // 160.4mm

// --- Font sizes ---------------------------------------------------------------
// kaobook loads newpxtext with `scaled=.97` on top of KOMA's 10pt sizes.
#let font-scale = 0.97
// TeX Gyre Heros is loaded with `helvratio=.93` relative to the scaled serif.
#let sans-scale = 0.8985
#let koma-sizes = (
  tiny: 5pt,
  scriptsize: 7pt,
  footnotesize: 8pt,
  small: 9pt,
  normalsize: 10pt,
  large: 12pt,
  Large: 14.4pt,
  LARGE: 17.28pt,
  huge: 20.74pt,
  Huge: 24.88pt,
)
#let size = koma-sizes.pairs().map(((k, v)) => (k, v * font-scale)).to-dict()
#let sans-size = koma-sizes.pairs().map(((k, v)) => (k, v * sans-scale)).to-dict()

// Baseline skips: KOMA values x \linespread{1.07}. Measured 12.79pt for the
// body text in a kaobook PDF, hence a factor of 1.066.
#let linespread = 1.066
#let koma-baselineskips = (
  tiny: 6pt,
  scriptsize: 8pt,
  footnotesize: 9.5pt,
  small: 11pt,
  normalsize: 12pt,
  large: 14pt,
  Large: 18pt,
  LARGE: 22pt,
  huge: 25pt,
  Huge: 30pt,
)
#let baselineskip = koma-baselineskips.pairs().map(((k, v)) => (k, v * linespread)).to-dict()

// Typst measures line spacing between the bottom edge of one line and the top
// edge of the next. We fix both edges relative to the font size, so that the
// leading needed for a given baseline skip can be computed exactly.
#let top-edge = 0.75em
#let bottom-edge = -0.25em
#let leading-for(key) = baselineskip.at(key) - size.at(key)

// TeX puts the first baseline \topskip (10pt) below the top of the text area,
// Typst puts it top-edge (0.75em) below. The page margin compensates.
#let topskip = 10pt
#let top-correction = topskip - 0.75 * size.normalsize
// The last line may sit with its baseline exactly on the bottom of the TeX
// text area; Typst needs room for the descender edge below it.
#let bottom-correction = 0.25 * size.normalsize

// Space between paragraphs (KOMA parskip=half), measured baseline-to-baseline
#let par-skip-baseline = 19.1pt
// Converts a baseline-to-baseline distance into a Typst block gap.
#let gap(baseline-distance, above-size: size.normalsize, below-size: size.normalsize) = (
  baseline-distance - 0.25 * above-size - 0.75 * below-size
)
#let par-spacing = gap(par-skip-baseline)

// --- Headings (baseline distances measured in a kaobook PDF) -------------
#let heading-metrics = (
  // level: (size-key, distance from previous baseline, distance to next baseline)
  "2": (key: "Large", above: 41.6pt, below: 29.55pt),
  "3": (key: "large", above: 36.2pt, below: 25.95pt),
  "4": (key: "normalsize", above: 34.0pt, below: 25.95pt),
)

// --- Running heads (kaobook scrheadings) ----------------------------------------
#let head-baseline = 42.65pt // from the top of the page
#let head-number-box = 7mm
#let head-rule-gap = 3mm
#let head-rule-width = 0.5pt

// --- Chapter heading (kaobook \chapterstylekao) -------------------------------
#let chapter-baseline = 97.55pt // from the top of the page
#let chapter-content-baseline = 157.9pt // first baseline after the heading
#let chapter-number-scale = 2.85
#let chapter-rule-width = 1pt
#let chapter-rule-below = 2mm // rule ends 2mm below the title baseline
// Plain chapters (front and back matter)
#let plain-chapter-baseline = 101.5pt
#let plain-chapter-content-baseline = 151.0pt

// --- Margin material ----------------------------------------------------------
#let marginnote-vadjust = 0pt // kaobook: 0.8mm, but a kaobook PDF aligns baselines
#let margin-par-skip = 6pt // \parskip=0.5pc in margin paragraphs
#let margin-clearance = 6pt
#let caption-skip = 6pt

// --- Colours --------------------------------------------------------------------
// xcolor dvipsnames, as used by kaobook.
#let colors = (
  cite: rgb("#2e3092"), // Blue: years in citations
  link: black, // Black: internal links
  url: rgb("#3c8031"), // OliveGreen: URLs
  box-fill: luma(95%), // gray!10 background of Challenge/Objective boxes
  theorem-fill: rgb(97%, 97%, 97%), // shadethm background
  rule: black,
  code-number: rgb(25%, 25%, 25%),
)
