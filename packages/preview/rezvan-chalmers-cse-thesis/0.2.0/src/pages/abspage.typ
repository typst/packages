#import "lib.typ": join

#let abspage(faith, school, title, subtitle, authors, department, abstract, keywords) = {
  let fmt-auth = if faith {
    upper
  } else {
    smallcaps
  }
  [
    #title\
    #subtitle\
    #fmt-auth(authors.join([\ ]))\
    #department\
    #join(school, " and ")
    #v(8pt)
    #show heading: set text(size: 17pt)
    #heading(outlined: false)[Abstract]
    #v(8pt)
    #abstract
  ]
  v(1fr)
  if keywords.len() > 0 {
    [*Keywords*: #keywords.join(", ")]
  }
  v(10pt)
}
