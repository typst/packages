#import "@preview/fontawesome:0.1.0": fa-icon

#let precis-dates(args) = {
  align(bottom)[
      #table(
        inset: 0pt,
        row-gutter: 0.15cm,
        stroke: none, 
        columns: (1fr, 1fr),
        ..args.dates.map( entry =>{
          return (
            text(size: 7pt, entry.type),
            text(size: 7pt, entry.date.display())
          )
      }).flatten())

      #if (args.doi != none){ text(size: 7pt, link("http://doi.org/" + args.doi, [DOI: #args.doi]))}
    //#footnoteSize[DOI: #link("http://doi.org/" + doi, doi)]
  ]

}

#let author(author) = {
  text(author.name)
  if ( author.corresponding == true ) [#strong[\*]]
  if ( author.at("orcid", default: none) != none ) {
    h(0.23em)
    link("http://orcid.org/" + author.orcid, fa-icon("orcid", fa-set: "Brands", fill: rgb(166,206,57)))
  }
}

#let precis-title-authors-abstract(args) = {
  block(text(size: 15pt, weight:500, args.title))
  args.authors.map(author).join(", ", last: " and ")
  v(1.618em, weak: true)

  for ((title, content)) in args.abstracts {
    if (args.abstracts.len() > 1){block[*#title*]}
    content
  }
}


#let precis(args) = {
    pad(
    top: 0.3em, bottom: 0.3cm,
    x: 0em,
    grid(
      columns: (1.4fr,5fr),
      gutter: 0em,
      precis-dates(args),
      precis-title-authors-abstract(args)
    )
  )
}