#let std-bibliography = bibliography

#let default-backmatter(
  bibliography: [],
  bib-style: "ieee",
) = {
  set std-bibliography(style: bib-style)
  bibliography
}
