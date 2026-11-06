#let std-bibliography = bibliography

#let default-backmatter(
  bibliography: [],
  bib-style: "",
) = {
  set std-bibliography(style: bib-style)
  bibliography
}
