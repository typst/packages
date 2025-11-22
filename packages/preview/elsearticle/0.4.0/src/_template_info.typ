#import "_globals.typ": *
#import "_utils.typ": *

#let default-author = (
  name: none,
  affiliation: none,
  corr: none,
  id: "a"
)

#let template_info(title, abstract, authors, keywords, els-columns) = {
  // Set authors and affiliation
  let names = ()
  let names_meta = ()
  let affiliations = ()
  let coord = none
  for author in authors {
    let new_author = create_dict(default-author, author)
    let auth = (box(new_author.name), super(new_author.id))
    if new_author.corr != none {
      if new_author.id != none {
        auth.push(super((",", text(baseline: -1.5pt, "*")).join()))
      } else {
        auth.push(super(text(baseline: -1.5pt, "*")))
      }
      if els-columns == 1 {
        coord = ("Corresponding author. E-mail address: ", new_author.corr).join()
      } else {
        coord = ([Corresponding author. #linebreak() #h(1.4em) E-mail address: ], new_author.corr).join()
      }
    }
    names.push(box(auth.join()))
    names_meta.push(new_author.name)

    if new_author.affiliation == none {
      continue
    }
    else {
      affiliations.push((super(new_author.id), new_author.affiliation, v(font-size.script)).join())
    }
  }

  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: " and ")
  }

  // Format title and affiliation
  let els-authors = align(center,{
    par(leading: 0.75em, text(size: font-size.title, title))
    v(0pt)
    text(size: font-size.author, author-string)
    v(font-size.small)
    par(leading: 1em, text(size: font-size.small, emph(affiliations.join()), top-edge: 0.5em))
  })

  // Format the abstract
  let els-abstract = if abstract != none {
    line(length: 100%)
    text(weight: "bold", [Abstract])
    v(1pt)
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
    line(length: 100%)
  }

  let els-info = (
    els-authors: els-authors,
    els-abstract: els-abstract,
    coord: coord,
    els-meta: names_meta
  )

  return els-info
}