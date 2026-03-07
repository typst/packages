#import "requirements.typ": linguify
#import linguify: linguify
#import "template.typ": lang-database

#let acknowledgements(body) = {
  align(left, text(1.4em, weight: 700, linguify(
    "acknowledgements",
    from: lang-database,
  )))
  if body != none {
    body
    v(15mm)
  }
}
