#let disclaimer(
  title: "",
  degree: "",
  author: "",
  submissionDate: none,
) = {

  // --- Disclaimer ---
  pagebreak()
  
  v(1fr)
  text("Disclaimer", weight: 600, size: 1.4em)

  v(1.5em)
  
  text("I confirm that this " + degree + "’s thesis is my own work and I have documented all sources and material used.", size: 1.1em)

  v(25mm)
  grid(
      columns: 2,
      gutter: 1fr,
      //"Munich, " + submissionDate,
      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space (Date) #sym.space #sym.space #sym.space #sym.space #sym.wj],
      overline[#sym.wj #sym.space #sym.space #sym.space #sym.space #sym.space (#author) #sym.space #sym.space #sym.space #sym.space #sym.space #sym.wj]
    )

  v(15%)

  pagebreak()
  pagebreak()
}
