#import "@preview/bullseye:0.1.0" as bullseye

#let acmart(
  // Only 'acmsmall' is currently supported.
  format: "acmsmall",

  // extra package options
  nonacm: false, // disable all ACM-specific formatting
  anonymous: false,
  review: false, // line numbers

  // Title, subtitle, authors, abstract, ACM ccs, keywords
  title: "Title",
  subtitle: none,
  shorttitle: none,
  authors: (),
  shortauthors: none,
  abstract: none,
  ccs: none,
  keywords: none,

  publication: none,

  // copyright
  copyright: none,
  copyright-year: 2023,
) = {

  let publication = (
    // supported 'journal' value: "JACM", "PACML"
    journal: "PACMPL",
    volume: 1,
    number: [CONF], // for PACMPL the 'number' field may be "ICFP", "PLDI", "POPL" etc.
    article-number: 1,
    year: 1,
    month: 1,
    doi: "XXXXXXX.XXXXXXX",
  ) + publication

  let journal-name = if publication.journal == "JACM" {
    (
      full: "Journal of the ACM",
      short: "J. ACM"
    )
  } else if publication.journal == "PACMPL" {
    (
      full: "Proceedings of the ACM on Programming Languages",
      short: "Proc. ACM Program. Lang."
    )
  } else {
    none
  }

  let anonymousAuthors = ((name: "Anonymous Author(s)", orcid: none, email: none, affiliation: none),)
  if anonymous {
    authors = anonymousAuthors
    shortauthors = "Anon."
  }

  let _authors = {
    let list = ()
    for author_or_group in authors {
      // either author group ...
      let author_group = author_or_group.at("authors", default: none)
      if (author_group != none) {
        for author in author_group {
          let a = author
          a.insert("affiliation", author_or_group.affiliation)
          list.push(a)
        }
      // or single author ...
      } else {
        list.push(author_or_group)
      }
    }

    assert(list.all(author => "name" in author.keys()), message: "all authors need a name")
    assert(list.all(author => "email" in author.keys()), message: "all authors need an email (possibly 'none')")
    assert(list.all(author => "orcid" in author.keys()), message: "all authors need an orcid (possibly 'none')")
    assert(list.all(author => "affiliation" in author.keys()), message: "all authors need an affiliation")

    list
  }

  if shorttitle == none {
    shorttitle = title
  }

  if shortauthors == none {
    shortauthors = _authors.map(a => a.name).join(", ", last: ", and ")
  }

  let mainFont = "Linux Libertine O"
  let sfFont = "Linux Biolinum O"
  let ttFont = ("Inconsolatazi4", "Dejavu Sans Mono", "Libertinus Mono",)
  let mathFont = "Libertinus Math"
  let mathTtFont = "Latin Modern Mono"

  let ACMPurple    = cmyk( 55%, 100%, 0%, 15%)
  let ACMDarkBlue  = cmyk(100%,  58%, 0%, 21%)

  let parIndentAmount = 9.5pt
  let parIndent = h(parIndentAmount)

  let displayMonth(month) = (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ).at(month - 1)

  let show_(body) = {
    // Set document metadata
    set document(
      title: title,
      author: _authors.map(author => author.name),
    )

    show link: it => {
      if (type(it.dest) == str) {
        // links to URLs are blue
        set text(fill: ACMDarkBlue)
        it
      } else {
        // others are purple
        set text(fill: ACMPurple)
        it
      }
    }
    show cite: set text(fill: ACMPurple)

    show math.equation: set text(font: mathFont)
    show math.equation: set block(above: 1em, below: 1em)

    // Configure the page.
    set page(
      width:  6.75in,
      height: 10in,
      margin: (
          top:    58pt + 30pt,
          bottom: 39pt + 24pt,
          left:   46pt,
          right:  46pt
        ),
      header: context {
        set text(size: 8pt, font: sfFont)
        let (currentpage,) = counter(page).get()
        if currentpage != 1 {
          let acm-article-page = [#publication.article-number:#counter(page).display()]
          [
            #stack(
              block(
                height: 10pt,
                width: 100%,
                if calc.rem(currentpage, 2) == 0 [
                  #acm-article-page
                  #h(1fr)
                  #shortauthors
                ] else [
                  #shorttitle
                  #h(1fr)
                  #acm-article-page
                ]
              ),
              block(height: 20pt, width: 100%)
            )
          ]
        } else {
          // block(height: 100%, width:100%, fill:blue)
        }
      },
      header-ascent: 0%,
      footer: context {
        set text(size: 8pt)
        let (currentpage,) = counter(page).get()
        let currentfooting = if nonacm [] else [
            #journal-name.short,
            Vol. #publication.volume,
            No. #publication.number,
            Article #publication.article-number,
            Publication date: #displayMonth(publication.month) #publication.year.
          ]
        block(
          height: 24pt,
          width: 100%,
          if calc.rem(currentpage, 2) == 0 {
            align(bottom + left, currentfooting)
            } else {
            align(bottom + right, currentfooting)
            }
        )
      },
      footer-descent: 0%,
    )

    set text(font: mainFont, size: 10pt, spacing: 80%)

    set heading(numbering: "1.1")

    let block-heading(above: none, below: none, it) = {
      if above.weak != none { v(weak: true, above.weak) }
      block(above: above.strong, below: below.strong, sticky: true, {
        if it.numbering != none {
          counter(heading).display(it.numbering)
          h(10pt)
        }
        if (it.level == 1) { upper(it.body) } else { it.body }
      })
      if below.weak != none { v(weak: true, below.weak) }
    }

    show heading: set text(font: sfFont, size: 10pt, weight: "bold")

    show heading.where(level: 1): bullseye.show-target(paged: it => {
      block-heading(
        above: (weak: none, strong: 1.6em),
        below: (weak: 0.85em, strong: 0.5em),
        it
      )
    })

    show heading.where(level: 2): bullseye.show-target(paged: it => {
      block-heading(
        above: (weak: none, strong: 1.5em),
        below: (weak: 1em, strong: 0.5em),
        it
      )
    })

    show heading.where(level: 3): bullseye.show-target(paged: it => {
      v(0.5em)
      set text(weight: "regular", style: "italic")
      h(-parIndentAmount) + counter(heading).display(it.numbering) + h(10pt) + it.body + [.] + h(2pt)
    })

    show heading.where(level: 4): bullseye.show-target(paged: it => {
      v(0.5em)
      set text(weight: "regular", style: "italic")
      it.body + [.] + h(2pt)
    })

    show heading.where(level: 5): bullseye.show-target(paged: it => {
      set text(weight: "regular")
      it.body + h(2pt)
    })

    show list.where(tight: false): set block(above: 1em, below: 1em)
    show enum.where(tight: false): set block(above: 1em, below: 1em)
    show terms.where(tight: false): set block(above: 1em, below: 1em)

    set list(
      indent: 1em,
      marker: (box(baseline: 150%, circle(radius: 1.8pt, fill: black)), [‣], [–]),
    )

    set enum(
      indent: 1em,
      numbering: "(1)",
    )

    set terms(
      indent: 1.5em,
      hanging-indent: 1em,
    )

    set par(
      justify: true,
      leading: 5.35pt,
      first-line-indent: parIndentAmount,
      spacing: 5.35pt)

    set figure(
      gap: 1.125em,
      placement: top,
    )

    show figure.where(placement: none): set block(above: 2em, below: 2em)

    show figure.where(kind: table): set figure.caption(position: top)

    show figure.caption: bullseye.show-target(paged: it => {
      set text(size: 9pt, font: sfFont, spacing: 95%)
      align(center,
        stack(dir: ltr,
          [#it.supplement~#context it.counter.display(it.numbering).],
          h(.5em),
          it.body
        )
      )
    })
    show figure: set place(clearance: 3.1em)

    // Known limitation: with this definition the last stroke at the end
    // of the array is a bit too close to the content of the last row.
    // I (Gabriel) have not found a reasonable way to render it better.
    set table(
      inset: (x, y) => if (y == 0) { 5pt } else { 3pt },
      stroke: (x, y) => {
        if y == 0 { (top:1pt) }
        else if y == 1 { (top: 0.5pt) }
        else { (top: 0pt, bottom: 1pt) }
      }
    )

    show raw: set text(font: ttFont, spacing: 100%)
    show raw.where(block:true): set block(above: 1em, below: 1em)
    show raw.where(block:true): set text(size: 7pt)
    show raw.where(block:true): bullseye.show-target(paged: it => {
      pad(x: 1em, y:0.5em, it)
    })

    show quote: set block(above: 1em, below: 1em)
    show quote: set pad(x: 2em)

    let number(body) = {
      if not review { body }
      else {
        set par.line(numbering: it => text(red, str(it)))
        body
      }
    }

    // Display content
    number(context {
      if bullseye.target() == "html" {
        show math.equation: html.frame
        show math.equation.where(block: false): box
        body
      } else {
        body
      }
    })
  } // show_

  let make-title() = {
    let pdf_title_page() = {
      set par(justify: true, leading: 0.555555em, spacing: 0pt)

      // Display title
      block(below: 14.4pt, {
        set text(font: sfFont, size: 14.4pt, weight: "bold")
        par(title)
      })

      // Display authors
      block(above: 0pt, below: 12pt, {
        let displayAuthor(author) = [#text(font: sfFont, size: 11pt, upper(
          if (author.orcid == none) {
            author.name
          } else {
            link("https://orcid.org/" + author.orcid, author.name)
          }
        ))]
        let displayAuthors(authors) = authors.map(displayAuthor).join(", ", last: " and ")

        let displayAffiliations(affiliations) = {
          let displayAffiliation(affiliation) = if affiliation != none {
            text(font: mainFont, size: 9pt)[
              #affiliation.institution, #affiliation.country
            ]}
          if type(affiliations) == array {
            affiliations.map(displayAffiliation).join[ and ]
          } else { displayAffiliation(affiliations) }
        }

        par(leading: 5.7pt, spacing: 0pt, {
          for author_or_group in authors {
            // either author group ...
            let author_group = author_or_group.at("authors", default: none)
            if (author_group != none) {
              displayAuthors(author_group) + [, ]
              displayAffiliations(author_or_group.affiliation) + [\ ]
            // or single author ...
            } else {
              displayAuthor(author_or_group) + [, ]
              displayAffiliations(author_or_group.affiliation) + [\ ]
            }
          }
        })
      })

      // Display abstract
      if abstract != none {
        set par(justify: true, spacing: 0.555555em, first-line-indent: 9.7pt)
        set text(size: 9pt)
        block(above: 0pt, below: 10.7pt,
          block(abstract))
      }

      // Display CCS concepts:
      if ccs != none {
        block(width: 100%, above: 0pt, below: 9.5pt,
          par(text(size: 9pt, spacing: 60%)[CCS Concepts: #{
            ccs.fold((), (acc, concept) => {
              acc + ([
                #box(baseline: -50%, circle(radius: 1.25pt, fill: black))
                #strong(concept.at(0))
                #sym.arrow.r
                #{concept.at(1).fold((), (acc, subconcept) => {
                    acc + (if subconcept.at(0) >= 500 {
                      [ *#subconcept.at(1)*]
                    } else if subconcept.at(0) >= 300 {
                      [ _#subconcept.at(1)_]
                    } else {
                      [ #subconcept.at(1)]
                    }, )
                  }).join(";")
                }],)
            }).join(";")
            "."
          }]))
      }

      // Display keywords
      if keywords != none {
        block(width: 100%, above: 0pt, below: 10pt,
          par(text(size: 9pt)[
            Additional Key Words and Phrases: #keywords.join(", ")]))
      }

      // Display ACM reference format
      if not nonacm {
        block(width: 100%, above: 0pt, below: 10pt,
          par(leading: 0.5em, text(size: 9pt, context [
            #strong[ACM Reference Format:]\
            #_authors.map(author => author.name).join(", ", last: " and ").
            #publication.year.
            #title.
            #emph(journal-name.short)
            #publication.volume,
            #publication.number,
            Article #publication.article-number (#displayMonth(publication.month) #publication.year),
            #counter(page).display((..nums) => [
              #link((page: nums.pos().last(), x:0pt, y:0pt))[#nums.pos().last()]
              page#if(nums.pos().last() > 1) { [s] }.
            ],both: true)
            #link("https://doi.org/" + publication.doi)
          ])))
      }

      // place footer
      set text(size: 8pt)
      set par(leading: 0.6em)
      place(bottom, float: true, clearance: .5em, block(width: 100%)[
        #line(length: 100%, stroke: 0.4pt + black)
        #v(.5em)
        #par(spacing: 0pt)[
        #if authors.len() == 1 [Author's] else [Authors']
        Contact Information: #{
          let displayAuthor(author) = [#if (author.orcid == none) {
            author.name
          } else {
            link("https://orcid.org/" + author.orcid, author.name)
          }]
          let displayEmail(author) = [#{
            if author.at("email", default: none) != none [, #author.email]
          }]
          let displayAuthors(authors) = authors.map(displayAuthor).join("; ")
          let displayAffiliations(affiliations) = {
            let displayAffiliation(affiliation) = if affiliation != none {
              if affiliation.at("institution", default: none) != none [#affiliation.institution]
              if affiliation.at("city", default: none) != none [, #affiliation.city]
              if affiliation.at("state", default: none) != none [, #affiliation.state]
              if affiliation.at("country", default: none) != none [, #affiliation.country]
            }
            if type(affiliations) == array {
              affiliations.map(displayAffiliation).join(" and ")
            } else { displayAffiliation(affiliations) }
          }
          let output = ()
          for author_or_group in authors {
            // either author group ...
            let author_group = author_or_group.at("authors", default: none)
            if (author_group != none) {
              output.push(displayAuthors(author_group) + [, ] +
                displayAffiliations(author_or_group.affiliation))
            // or single author ...
            } else {
              output.push(displayAuthor(author_or_group) + [, ] +
                displayAffiliations(author_or_group.affiliation) +
                displayEmail(author_or_group))
            }
          }
          output.join("; ") + [.]
        }]

        #if not nonacm [
          #v(1.1em)
          #line(length: 100%, stroke: 0.4pt + black)
          #v(.5em)
          Permission to make digital or hard copies of all or part of this
          work for personal or classroom use is granted without fee provided
          that copies are not made or distributed for profit or commercial
          advantage and that copies bear this notice and the full citation on
          the first page.
          Copyrights for third-party components of this work must be honored.
          For all other uses, contact the owner/author(s).
          // Copyrights for components of this work owned by
          // others than the author(s) must be honored. Abstracting with credit is
          // permitted. To copy otherwise, or republish, to post on servers or to
          // redistribute to lists, requires prior specific permission
          // and#h(.5pt)/or  a fee. Request permissions from
          // permissions\@acm.org.\
          #v(.75em)
          #sym.copyright #copyright-year Copyright held by the owner/author(s).\
          ACM 2475-1421/#publication.year/#publication.month#[-ART]#publication.article-number\
          #link("https://doi.org/" + publication.doi)
        ]
      ])
    }

    let html_title_page() = {
      html.header({
        html.h1(class:"title", title)

        html.ul(class: "authors", {
          let displayAuthor(author) = {
            html.span(class: "author-name", author.name)
            let orcid = author.orcid
            let email = author.email
            let opts = 0
            if (orcid != none) { opts += 1 }
            if (email != none) { opts += 1 }
            if (opts > 0) [ (]
            if (orcid != none) { html.a(href:("https://orcid.org/" + orcid), "orcid") }
            if (opts > 1) [, ]
            if (email != none) { html.a(href:("mailto:" + email), "email") }
            if (opts > 0) [)]
          }
          let displayAuthors(authors) = authors.map(displayAuthor).join(", ", last: " and ")
          let displayAffiliations(affiliations) = {
            let displayAffiliation(affiliation) = if affiliation != none {
              html.span(class: "author-affiliation")[
                #affiliation.institution, #affiliation.country
              ]
            }
            if type(affiliations) == array {
              affiliations.map(displayAffiliation).join[ and ]
            } else { displayAffiliation(affiliations) }
          }

          for author_or_group in authors {html.li({
            // either author group ...
            let author_group = author_or_group.at("authors", default: none)
            if (author_group != none) {
              displayAuthors(author_group) + [:\ ]
              displayAffiliations(author_or_group.affiliation)
            // or single author ...
            } else {
              displayAuthor(author_or_group) + [:\ ]
              displayAffiliations(author_or_group.affiliation)
            }
          })}
        })

        // Missing: CCS concepts, keywords, license.

        html.div(class:"abstract", {
          html.div(class: "abstract-title")[Abstract]
          abstract
        })
      })
    }

    context {
      if bullseye.target() == "html" { html_title_page() }
      else { pdf_title_page() }
    }
  } // make-title

  let acknowledgments(content) = [
    #[ #set heading(numbering: none, outlined: false)
       = Acknowledgments
    ]
    #content
  ]

  let appendix(content) = [
    #show heading: set heading(numbering: "A.1")
    #counter(heading).update(0)
    #content
  ]

  (
    show_: show_,
    make-title: make-title,
    acknowledgments: acknowledgments,
    appendix: appendix,
  )
}
