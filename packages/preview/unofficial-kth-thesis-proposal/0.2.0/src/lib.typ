/// KTH Degree Project Proposal Template
/// Usage:
///   #import "@preview/unofficial-kth-thesis-proposal:0.1.0": proposal
///   #show: proposal

#let kth-logo = image("assets/KTH_logo_RGB_bla.svg")

#show link: underline

#let proposal(
  title: "DEGREE PROJECT PROPOSAL",
  body,
) = {
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
    #text(size: 18pt, weight: "bold", title)
  ]
  pagebreak()

  show heading.where(level: 1): it => {
    set text(weight: "bold", size: 11pt)
    block(
      above: 1em,
      below: 1em,
      sticky: true,
      upper(it.body),
    )
  }

  // ---- Main content ----
  body
}
