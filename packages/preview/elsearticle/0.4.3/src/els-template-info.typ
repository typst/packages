#import "els-globals.typ": *
#import "els-utils.typ": *

#let default-author = (
  name: none,
  affiliation: none,
  corr: none,
  id: "a"
)

#let template-info(title, abstract, authors, keywords, els-columns) = {
  // Set authors and affiliation
  let names = ()
  let names-meta = ()
  let affiliations = ()
  let coord = none
  for author in authors {
    let new-author = create-dict(default-author, author)
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
    par(leading: 0.75em, text(size: font-size.title, title))
    v(1em)
    text(size: font-size.author, author-string)
    v(font-size.small)
    par(leading: 1em, text(size: font-size.small, emph(affiliations.join()), top-edge: 0.5em))
    v(2*font-size.small)
  })

  // Format the abstract
  let els-abstract = if abstract != none {
    line(length: 100%, stroke: 0.5pt)
    text(weight: "bold", [#h(-indent-size); Abstract])
    v(0.5em)
    h(-indent-size); abstract
    linebreak()
    if keywords !=none {
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
    line(length: 100%, stroke: 0.5pt)
  }

  let els-info = (
    els-authors: els-authors,
    els-abstract: els-abstract,
    coord: coord,
    els-meta: names-meta
  )

  return els-info
}
