#import "els-globals.typ": *
#import "els-utils.typ": *

#let default-author = (
  name: none,
  affiliation: none,
  corr: none,
  id: "a"
)

#let make-author(author) = box({
  author.name

  let auth-institution = if author.institutions.at(0) == "" {
    none
  } else {
    author.institutions.map((key)=>{
      key
    })
  }

  let auth-rest = if (author.at("corresponding", default: false) == true){
      (sym.ast,)
    }

  sym.space.thin
  if auth-institution == none {
    super({
      auth-rest.join([ ])
    })
  } else {
    super({
      (auth-institution + auth-rest).join([,])
    })
  }
})

#let make-authors(authors) = par({
  set text(size: font-size.author)
  authors.map(make-author).join(", ", last: " and ")
})

#let make-author-meta(authors) = {
  let names = ()
  for author in authors {
    if type(author.name) == content {
      names.push(author.name.text)
    } else {
      names.push(author.name)
    }
  }
  return names.join(" ")
}

#let make-corresponding-author(authors, els-columns) = for author in authors {
  if author.at("corresponding", default: false) == true {
    place(
      float: true,
      bottom,
      {
        v(0.5em)
        let line-length = if els-columns == 1 {9.6em} else {4.6em}
        line(length: line-length, stroke: 0.25pt)
        v(-0.75em)
        set text(size: 10pt)
        set par(leading: 0.5em,)
        if els-columns == 1 {
           [#h(1em);#super[#sym.ast]#h(0.1em);Corresponding author. E-mail address: #if (author.at("email", default: none)) != none {author.email} else {text("No email provided")}]
        } else {
            [#h(1em);#super[#sym.ast]#h(0.1em);Corresponding author. #linebreak() #h(1.4em);E-mail address: #if (author.at("email", default: none)) != none {author.email} else {text("No email provided")}]
        }
      }
    )
  }
}

#let make-institution(key, value) = {
  super[#key]
  if key != "" {
    sym.space.thin
  }
  text(style:"italic", value)
}

#let make-institutions(institutions) = {
  for (key, value) in institutions{
    make-institution(key, value)
    linebreak()
  }
}

#let make-title(title: none, authors: (), institutions: ()) = align(center, {
  par(leading: 0.95em, text(size: font-size.title, title))
  v(0.9em)
  text(size: font-size.author, make-authors(authors))
  v(0.2em)
  par(leading: 0.65em, text(size: font-size.small, make-institutions(institutions), top-edge: 0.5em))
  v(1.75em)
})

// Format the abstract
#let make-abstract(abstract, keywords, els-format) = if abstract != none {
  set par(justify: true)
  line(length: 100%, stroke: 0.5pt)
  v(-0.25em)
  text(weight: "bold")[Abstract]
  if els-format.type.contains("review") {v(0.5em)} else {v(-0.2em)}
  abstract
  if els-format.type.contains("review") {linebreak()} else {v(0em)}
  if keywords != () {
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