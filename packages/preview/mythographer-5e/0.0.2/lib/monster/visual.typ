///////////////////////////////////////////////////
/// RED TRIANGLE
#let triangle-bar(self) = {
  let triangle-bar = polygon(
    fill: self.bar.fill,
    (0pt, 0pt),
    (100%, 1.5pt),
    (0pt, 3pt),
  )

  let placed-bar = [
    #v(-0.5em)
    #triangle-bar
    #v(-0.5em)
  ]

  return placed-bar
}
