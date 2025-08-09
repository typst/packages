
#let orcidLogo(
  // The ORCID identifier with no URL, e.g. `0000-0000-0000-0000`
  orcid: none,
) = {
  /* Logos */
  let orcidSvg = ```<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 24 24"><path fill="#AECD54" d="M21.8,12c0,5.4-4.4,9.8-9.8,9.8S2.2,17.4,2.2,12S6.6,2.2,12,2.2S21.8,6.6,21.8,12z M8.2,5.8c-0.4,0-0.8,0.3-0.8,0.8s0.3,0.8,0.8,0.8S9,7,9,6.6S8.7,5.8,8.2,5.8z M10.5,15.4h1.2v-6c0,0-0.5,0,1.8,0s3.3,1.4,3.3,3s-1.5,3-3.3,3s-1.9,0-1.9,0H10.5v1.1H9V8.3H7.7v8.2h2.9c0,0-0.3,0,3,0s4.5-2.2,4.5-4.1s-1.2-4.1-4.3-4.1s-3.2,0-3.2,0L10.5,15.4z"/></svg>```.text

  if (orcid == none) {
    // Do not
    box(height: .7em, baseline: -20%, [#image(bytes(orcidSvg))])
    return
  }

  link("https://orcid.org/" + orcid)[#box(height: .7em, baseline: -20%)[#image(bytes(orcidSvg))]]
}  

#let display_authors(authors) = {
  if authors.len() > 0 {
    set text(17pt)
    block()[
      #authors.map(author => {
        author.name
        h(1pt)
        if "affiliations" in author {
          super(typographic: false)[#author.affiliations]
        }
        if "orcid" in author {
          orcidLogo(orcid: author.orcid)
        }
      }).join(", ", last: ", and ")
    ]
  }
}

#let display_affiliations(affiliations) = {
  if affiliations.len() > 0 {
    block()[
      #affiliations.map(affiliation => {
        super(affiliation.id)
        h(1pt)
        affiliation.name
      }).join(", ")
    ]
  }
}

#let display_abstract(abstract) = {
    block()[
      #text(size: 20pt)[*Abstract*]
      #linebreak()
      #abstract
    ]
}

#let generate_header(authors, fill: black) = context {
  let header_authors =  if authors.len() > 2 {
    authors.at(0).name + " et al."
  } else if authors.len() > 0 {
    authors.map(author => {author.name}).join(" & ")
  } else { "" }
  set align(center)
  set text(fill)
  let page_nb = here().page()
  block(width: 21cm - 2in + 2cm)[
      #if page_nb > 1 {
        if calc.odd(page_nb) {
          header_authors
          h(1fr)
          counter(page).display()
        } else {
          counter(page).display()
          h(1fr)
          header_authors
        }
        box(line(length: 100%, stroke: 1pt + fill))
      }
  ]
}

#let generate_footer(fill: black) = context {
  set align(center)
  block(width: 21cm - 2in + 2cm)[
      #if here().page() > 1 {
        box(line(length: 100%, stroke: 1pt + fill))
        set text(fill)
        counter(page).display()
    }
  ]
}

#let table_note(body) = {
  set align(center)
  block(width: 21cm - 2in - 3cm, above: .55em)[
    #set text(9pt)
    #set align(left)
    #body
  ]
}

#let appendix(body) = {
  counter(heading).update(0)
  set heading(
    numbering: "A.1",
    supplement: [Appendix],
  )
  show heading.where(level: 1): it => [
    #set align(center)
    #set text(size: 12pt, weight: "bold")
    #block(above: 2em, below: 1em)[
      #it.supplement #counter(heading).display(): #it.body
    ]
  ]
  show heading.where(level: 2): it => [
    #set text(weight: "bold", size: 11pt)
    #block(above: 1.6em, below: 1em)[
      #counter(heading).display()#h(.5em)#it.body
    ]
  ]
  show heading.where(level: 3): it => [
    #set text(style: "italic", size: 11pt)
    #v(1.6em)
    #counter(heading).display()#h(.5em)#it.body.#h(.5em)
  ]

  body

}
