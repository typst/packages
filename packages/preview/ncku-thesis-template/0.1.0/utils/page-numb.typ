#let begin-of-roman-page-num(doc) = {
  counter(page).update(1)
  set page(numbering: "i")
  doc
}

#let begin-of-arabic-page-num(doc) = {
  counter(page).update(1)
  set page(numbering: "1")
  doc
}
