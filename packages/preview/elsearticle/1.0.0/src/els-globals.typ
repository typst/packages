#let textfont = ("XITS", "STIX Two Text", "New Computer Modern")
#let mathfont = ("XITS Math", "STIX Two Math", "New Computer Modern Math")

#let font-size = (
  script: 7pt,
  footnote: 8pt,
  small: 10pt,
  normal: 12pt,
  author: 12pt,
  title: 17.2pt,
)

#let review = (
  indent: 1.5em,
  paper: "us-letter",
  type: "review",
  margins: (left: 39.7mm, right: 39.7mm, top: 39.7mm, bottom: 39.7mm),
  leading: 1.1em,
  above: 1.6em,
  below: 1.3em,
  spacing: 2em,
  footer-descent: 20%
)

#let preprint = (
  indent: 1.5em,
  paper: "us-letter",
  type: "preprint",
  margins: (left: 39.7mm, right: 39.7mm, top: 43.7mm, bottom: 61.5mm),
  leading: 0.5em,
  above: 1.4em,
  below: 0.85em,
  spacing: 1.75em,
  footer-descent: 20%
)

#let one-p = (
  indent: 1.5em,
  paper: "a4",
  type: "1p",
  margins: (left: 37.5mm, right: 37.5mm, top: 45.2mm, bottom: 47.9mm),
  leading: 0.5em,
  above: 1.4em,
  below: 0.85em,
  spacing: 1.75em,
  footer-descent: 5%
)

#let three-p = (
  indent: 1.5em,
  paper: "a4",
  type: "3p",
  margins: (left: 22.8mm, right: 22.8mm, top: 38.8mm, bottom: 38.3mm),
  leading: 0.5em,
  above: 1.4em,
  below: 0.85em,
  spacing: 1.75em,
  footer-descent: 8%
)

#let five-p = (
  indent: 1.24em,
  paper: "a4",
  type: "5p",
  margins: (left: 12.9mm, right: 12.9mm, top: 80pt, bottom: 80pt),
  leading: 0.5em,
  above: 1.25em,
  below: 0.85em,
  spacing: 1.5em,
  footer-descent: 10%
)

#let isappendix = state("isappendix", false)