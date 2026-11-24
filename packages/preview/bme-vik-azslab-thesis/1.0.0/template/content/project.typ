// -------------------------------------------------------------------------------
// Feladatkiírás (a tanszéken atveheto, kinyomtatott változat)
// ----------------------------------------------------------------------------

#let create-project() = {
  set page(margin: 2.5cm)
  set text(font: "New Computer Modern")
  set par(
    justify: true,

  )
  align(center)[#text(weight: "bold", size: 14pt)[FELADATKIÍRÁS]]

  block(above: 2em)[
    A feladatkiírást a tanszéki adminisztrációban lehet átvenni, és a leadott munkába eredeti, tanszéki pecséttel ellátott és a tanszékvezető által aláírt lapot kell belefűzni (ezen oldal _helyett_, ez az oldal csak útmutatás). Az elektronikusan feltöltött dolgozatban már nem kell beleszerkeszteni ezt a feladatkiírást.
  ]
  pagebreak(weak: true)
}

#create-project()