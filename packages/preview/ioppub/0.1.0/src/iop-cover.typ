#let make-precis(
  keywords: (),
  abstract: [],
) = {
  v(1em)

  // Abstract heading
  align(horizon)[
    #set text(font: "Carlito", size: 11pt, weight: "bold")
    Abstract
  ]
  if abstract.len() > 0 {
    block(width: 76%)[
      #set text(size: 10pt)
      #set par(justify: false, leading: 0.65em)
      #abstract
    ]
    v(0.8em)
  }

  // Keywords
  if keywords.len() > 0 {
    set text(size: 10pt)
    block(width: 76%)[Keywords: #keywords.join(", ")]
  }

  line(length: 100%, stroke: 0.5pt)
}

#let make-institution(key, value) = {
  super[#key]
  [#metadata("") #label("institution." + key)]
  if key != "" {
    sym.space.thin
  }
  text(value)
}

#let make-institutions(institutions) = par({
  set text(size: 9pt)
  for (key, value) in institutions {
    make-institution(key, value)
    linebreak()
  }
})

#let make-author(author) = box({
  author.name.join(" ")

  let auth-institution = if author.institutions.at(0) == "" {
    none
  } else {
    author.institutions.map(key => {
      text(fill: rgb(0, 0, 102), link(label("institution." + key), key))
    })
  }

  let auth-corres = {
    if (author.at("corresponding", default: false) == true) {
      (text(fill: rgb(0, 0, 245), sym.ast),)
    }
  }

  let auth-orcid = {
    if (author.at("orcid", default: none)) != none {
      link("https://orcid.org/" + author.orcid, box(
        image("resources/orcid.svg", height: 10pt),
        height: 0.8em,
      ))
    }
  }

  sym.space.thin
  if auth-institution == none {
    super({ auth-corres })
    auth-orcid
  } else {
    super({ (auth-institution + auth-corres).join([,]) })
    auth-orcid
  }
})

#let make-authors(authors) = par({
  set text(size: 11pt)
  set block(width: 76%)
  authors.map(make-author).join(", ")
})

#let make-corresponding-note(authors) = {
  let corres-authors = authors.filter(author => {
    author.at("corresponding", default: false) == true
  })

  if corres-authors.len() > 0 {
    v(1.5em)
    set text(size: 9pt)
    [\*Author to whom any correspondence should be addressed.]
  }
}

#let make-email(authors) = {
  let corres-authors = authors.filter(author => {
    author.at("corresponding", default: false) == true
  })

  if corres-authors.len() > 0 {
    v(1.5em)
    set text(size: 9pt)
    let email = corres-authors.at(0).at("email", default: none)
    [E-mail: ]
    if email != none {
      link("mailto:" + email, email)
    } else {
      "xxx@xxx.xx"
    }
  }
}

#let make-date(paper-info) = {
  text(size: 9pt, [
    Received
    #if paper-info.received != none { paper-info.received } else { "xxxxxx" }\
    Accepted for publication
    #if paper-info.accept != none { paper-info.accept } else { "xxxxxx" }\
    Published
    #if paper-info.published != none { paper-info.published } else { "xxxxxx" }
  ])
}

#let make-title(
  title: [Full length journal article adapted and reset according to the typesetting specifications for this model],
  authors: (),
  institutions: (),
  paper-info: none,
) = {
  show par: block.with(below: 0em)
  v(0.75em)
  par(leading: 1.5em, text(font: "Carlito", size: 24pt, weight: "bold", title))
  v(1.8em)
  make-authors(authors)
  v(1.25em)
  set block(width: 76%)
  make-institutions(institutions)
  make-corresponding-note(authors)
  make-email(authors)
  v(1.5em)
  make-date(paper-info)
}

#let make-header(
  authors,
  journal,
  paper-info,
) = {
  let authors-header = if authors.len() > 2 {
    let (first_name, last_name) = authors.first().name
    first_name.at(0) + " " + last_name + emph(" et al")
  } else if authors.len() == 2 {
    let (first_name1, last_name1) = authors.at(0).name
    let (first_name2, last_name2) = authors.at(1).name
    first_name1.at(0) + " " + last_name1 + " and " + first_name2.at(0) + " " + last_name2
  } else {
    let (first_name, last_name) = authors.first().name
    first_name.at(0) + " " + last_name
  }

  let doi = if paper-info.doi != none {
    paper-info.doi
  } else {
    "https://doi.org/XXXX/XXXX"
  }

  let journal-header = [#journal.abbreviation *#paper-info.volume* (#paper-info.year)  #paper-info.paper-id]

  return context if counter(page).get().first() == 1 {
    set text(size: 11pt, font: "Carlito")
    [*IOP* Publishing]
    h(1fr)
    set text(size: 9pt)
    [#journal.name]
    v(-1em)
    [#line(length: 100%, stroke: 0.5pt)]
    v(-0.5em)
    [#journal-header]
    h(1fr)
    [#link(doi)]
  } else {
    set text(size: 9pt, font: "Carlito")
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [#journal-header], [#authors-header],
    )
    v(-0.8em)
    [#line(length: 100%, stroke: 0.5pt)]
  }
}

#let make-footer(
  paper-info,
  journal,
) = context if counter(page).get().first() == 1 {
  set text(font: "Carlito")
  grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    text(size: 8pt)[#if paper-info.issn != none {
      "xxxx-xxxx/xx/xxxxxx"
    }],
    text(size: 7pt)[#counter(page).get().first()],
    text(size: 8pt, journal.foot-info),
  )
} else {
  align(center)[#text(size: 7pt, font: "Carlito")[#counter(page).get().first()]]
}
