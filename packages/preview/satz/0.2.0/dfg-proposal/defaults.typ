// Physical PDF points; TeX's pt is 1/72.27 inch, Typst's pt is 1/72 inch.
#let baseline = 13.6 * 72 / 72.27 * 1pt
#let paragraph-skip = 5.5pt
// Arial's cap/x heights at the prescribed 11 PDF-point body size.
#let cap = 1467 / 2048 * 11pt
#let x-height = 1062 / 2048 * 11pt

// DFG 53.01: emtpb/KOMA vertical rhythm, translated to Typst line-box gaps.
#let defaults = (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  page: (paper: "a4", header-ascent: 24.442pt, margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)),
  typography: (
    font: "Arial", size: 11pt,
    leading: baseline - cap,
    paragraph-spacing: baseline + paragraph-skip - cap,
    hyphenate: true,
  ),
  headings: (
    numbering: "1.1.1.1",
    h1-size: 11pt, h1-above: baseline * 1.9 + paragraph-skip - cap,
    h1-below: baseline * 1.01 + paragraph-skip - cap,
    h2-size: 11pt, h2-above: baseline + paragraph-skip + 3.25 * x-height - cap,
    h2-below: baseline + paragraph-skip + 1.5 * x-height - cap,
    h3-size: 11pt, h3-above: baseline * 1.5 + paragraph-skip - cap,
    h3-below: baseline * 1.01 + paragraph-skip - cap,
    h4-size: 11pt, h4-above: baseline + paragraph-skip + 3.25 * x-height - cap,
    h4-below: baseline + paragraph-skip - cap,
  ),
  decorative: (
    header-size: 9 * 72 / 72.27 * 1pt,
    list-spacing: baseline + paragraph-skip - cap,
    list-indent: 17.9669pt, list-body-indent: 5.475 * 72 / 72.27 * 1pt,
    list-block-spacing: baseline + paragraph-skip - cap + 3 * 72 / 72.27 * 1pt,
  ),
  colors: (bg-paper: white, text-main: black, brand-primary: black),
  links: (color: black, url-color: black),
  tables: (font-size: 11pt, inset: (x: 6 * 72 / 72.27 * 1pt, top: baseline * 0.7 - cap, bottom: baseline * 0.3)),
  captions: (size: 11pt, alignment: left),
  bibliography: (style: "apa"),
)
