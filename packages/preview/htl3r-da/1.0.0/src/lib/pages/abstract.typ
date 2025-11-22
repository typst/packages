#import "../util.typ": insert-blank-page

#let create-page(
  abstract-german,
  abstract-english,
) = [
  = Kurzfassung
  #abstract-german
  #insert-blank-page()
  = Abstract
  #abstract-english
]
