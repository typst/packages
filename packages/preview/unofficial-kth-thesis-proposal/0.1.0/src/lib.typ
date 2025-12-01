/// KTH Degree Project Proposal Template
/// Usage:
///   #import "@preview/kth-thesis-proposal:0.1.0": proposal
///   #show: proposal

#let kth-logo = image("assets/KTH_logo_RGB_bla.svg")

#show link: underline

#let section(label, content) = {
  text(weight: "bold", size: 11pt, upper(label))
  linebreak()
  content
  v(1em)
}

#let proposal(body) = {
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )
  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  set par(justify: true, leading: 0.65em)

  // ---- Cover page ----
  align(center + horizon)[
    #image("assets/KTH_logo_RGB_bla.svg", width: 40%)
    #v(3em)
    #text(size: 18pt, weight: "bold")[DEGREE PROJECT PROPOSAL]
  ]
  pagebreak()

  // ---- Main content ----
  body
}
