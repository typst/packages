#import "@preview/oxifmt:0.2.1": strfmt
#import "i18n.typ": i18n

#let default-title(title) = {
  show: block.with(width: 100%)
  set align(center)
  set text(size: 1.75em, weight: "bold")
  title
}

#let default-author(author) = context {
  let (gettext, locale) = i18n(text.lang)
  set text(cjk-latin-spacing: none)
  [#author.name#super(author.insts.map(it => numbering("a", it + 1)).join(","))]
  if author.corresponding {
    footnote[
      #gettext("corresponding.note")
      #strfmt(gettext("corresponding.address"), address: author.address)
      #if author.email != none {
        [#strfmt(gettext("corresponding.email"), email: author.email)]
      }
    ]
  }
  if author.cofirst == "thefirst" [
    #footnote(gettext("cofirst")) <fnt:cofirst-author>
  ] else if author.cofirst == "cofirst" [
    #footnote(<fnt:cofirst-author>)
  ]
}

#let default-affiliation(id, address) = {
  set text(size: 0.8em)
  super(str.from-unicode(97 + id))
  h(1pt)
  address
}

#let default-author-info(authors, affiliations) = {
  {
    show: block.with(width: 100%)
    authors.map(it => default-author(it)).join(", ")
  }
  let used_affiliations = authors.map(it => it.insts).flatten().dedup().map(it => affiliations.keys().at(it))
  {
    show: block.with(width: 100%)
    set par(leading: 0.4em)
    used_affiliations.enumerate().map(((ik, key)) => {
      default-affiliation(ik, affiliations.at(key))
    }).join(linebreak())
  }
}

#let default-abstract(abstract, keywords) = context {
  let (gettext, locale) = i18n(text.lang)
  // Abstract and keyword block
  if abstract != [] {
    heading(gettext("abstract"), numbering: none, outlined: false)
    par(first-line-indent: 1em, abstract)
    if keywords.len() > 0 {
      strong(gettext("keywords.title"))
      strfmt(gettext("keywords.text"), keywords: keywords.join(gettext("keywords.sep")))
    }
  }
  v(1em)
}

#let default-body(body) = context {
  let (gettext, locale) = i18n(text.lang)
  show heading.where(level: 1): set block(above: 1em, below: 1em)
  set par(first-line-indent: 1em)
  set figure(placement: top)
  set figure.caption(separator: ". ")
  show figure.where(kind: table): set figure.caption(position: top)
  set footnote(numbering: "1")
  body
}

#let template = (
  default-title: default-title,
  default-author: default-author,
  default-affiliation: default-affiliation,
  default-author-info: default-author-info,
  default-abstract: default-abstract,
  default-body: default-body,
)
