#let preface(
  twoside: false,
  ..args,
  it,
) = {
  if twoside {
    pagebreak() + " "
  }
  counter(page).update(0)
  set page(numbering: "I")
  it
}