#import "template/data.typ": authors

#let author(short, body) = {
  let author = authors.find(author => author.short == short)

  if (author == none) {
    panic("there's no matching author's short")
  }

  show par: it => block(stroke: (left: author.color), inset: (left: .5em), it)

  body
}
