#let disclaimer(
  title: "",
  degree: "",
  author: "",
  submission-date: "",
) = {

  // --- Disclaimer ---
  v(1fr)
  text("Disclaimer", weight: 600, size: 1.4em)

  v(1.5em)
  
  text("I confirm that this " + lower(degree) + "’s thesis is my own work and I have documented all sources and material used.", size: 1.1em)

  v(25mm)
  grid(
      columns: 2,
      gutter: 1fr,
      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space Munich, #submission-date #sym.space #sym.space #sym.space #sym.space #sym.wj],
      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space #sym.space #author #sym.space #sym.space #sym.space #sym.space #sym.space #sym.wj]
    )

  v(15%)

  pagebreak()
}
