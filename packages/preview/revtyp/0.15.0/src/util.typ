
#import "@preview/scienceicons:0.1.0": orcid-icon

#let orcid(orcid) = {
  if not (orcid.starts-with("https://") or orcid.starts-with("http://")) {
    orcid = "https://orcid.org/" + orcid
  }
  link(orcid, orcid-icon(color: rgb("#AECD54"), height: 0.8em, baseline: 0pt))
}

#let sanitize-header-footer(header, footer) = {
  if "title" not in header { header.insert("title", none) }
  if "rule" not in header { header.insert("rule", true) }
  for key in ("left", "right") {
    if key not in header { header.insert(key, none) }
    if type(header.at(key)) != dictionary {
      header.insert(key, (even: header.at(key), odd: header.at(key)))
    }
  }
  if "badges" not in header { header.insert("badges", ()) }

  for key in ("title-left", "title-right", "center") {
    if key not in footer { footer.insert(key, none) }
  }

  (header, footer)
}

#let sanitize-authors(authors) = {
  // allow passing a single author
  if type(authors) == dictionary { authors = (authors,) }
  // expand multi-author entries
  let i = 0
  while i < authors.len() {
    let a = authors.at(i)
    if "names" in a {
      for name in a.remove("names") {
        authors.insert(i, (name: name, ..a))
        i += 1
      }
    }
    i += 1
  }
  authors = authors.map(a => {
    // handle affiliation alias "at"
    if "at" in a.keys() {
      a.insert("affiliation", a.remove("at"))
    }
    // ensure affiliation is an array
    if type(a.affiliation) == str {
      a.insert("affiliation", (a.remove("affiliation"),))
    }
    // trim whitespaces (but allow manual linebreak)
    if "name" in a.keys() {
      if a.name.starts-with("\n") { a.insert("prebreak", true) }
      a.insert("name", a.name.trim())
    }
    a
  })

  authors = authors.filter(a => "name" in a.keys())

  authors
}

#let keep-together(content) = {
  if type(content) == str and "\n" in content {
    // allow manual linebreaks
    show " ": sym.space.nobreak
    show "-": sym.hyph.nobreak
    content
  } else {
    box(content)
  }
}


