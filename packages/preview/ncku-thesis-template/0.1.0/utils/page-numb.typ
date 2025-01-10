#let begin_of_roman_page_num(doc) = {
  counter(page).update(1)
  set page(numbering: "i")
  doc
}

#let begin_of_arabic_page_num(doc) = {
  counter(page).update(1)
  set page(numbering: "1")
  doc
}
