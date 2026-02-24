#import "els-globals.typ": *
#import "els-utils.typ": *

#let default-author = (
  name: none,
  affiliation: none,
  corr: none,
  id: "a"
)

#let template-info(title, abstract, authors, keywords, els-columns, els-format) = {
  // Set authors and affiliation
  let names = ()
  let names-meta = ()
  let affiliations = ()
  let coord = none
  for author in authors {
    let new-author = default-author + author
    let auth = (box(new-author.name), super(new-author.id))
    if new-author.corr != none {
      if els-columns == 1 {
        coord = ("Corresponding author. E-mail address: ", new-author.corr).join()
      } else {
        coord = ([Corresponding author. #linebreak() #h(1.4em) E-mail address: ], new-author.corr).join()
      }

      if new-author.id != none {
        auth.push(super((",", text(baseline: -1.5pt, "*")).join()))
      } else {
        auth.push(super(text(baseline: -1.5pt, "*")))
      }
    }
    names.push(box(auth.join()))
    names-meta.push(new-author.name)

    if new-author.affiliation == none {
      continue
    }
    else {
      affiliations.push((super(new-author.id), new-author.affiliation, linebreak()).join())
    }
  }

  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: " and ")
  }

  // Format title and affiliation
  let els-authors = align(center, {
    par(leading: 0.95em, text(size: font-size.title, title))
    v(0.9em)
    text(size: font-size.author, author-string)
    v(0.2em)
    par(leading: 0.65em, text(size: font-size.small, emph(affiliations.join()), top-edge: 0.5em))
    v(1.75em)
  })

  // Format the abstract
  let els-abstract = if abstract != none {
    set par(justify: true)
    line(length: 100%, stroke: 0.5pt)
    v(-0.25em)
    text(weight: "bold")[Abstract]
    if els-format.type.contains("review") {v(0.5em)} else {v(-0.2em)}
    abstract
    if els-format.type.contains("review") {linebreak()} else {v(0em)}
    if keywords != none {
      let kw = ()
      for keyword in keywords{
        kw.push(keyword)
      }

    let kw-string = if kw.len() > 1 {
        kw.join(", ")
      } else {
        kw.first()
      }
      text((emph("Keywords: "), kw-string).join())
    }
    v(-0.2em)
    line(length: 100%, stroke: 0.5pt)
    if els-format.type.contains("review") {v(-0.75em)}
    else if els-format.type.contains("5p") {v(-0.25em)}
    else {none}
  }

  let els-info = (
    els-authors: els-authors,
    els-abstract: els-abstract,
    coord: coord,
    els-meta: names-meta
  )

  return els-info
}