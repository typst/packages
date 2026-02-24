#import "@preview/oxifmt:0.2.1": strfmt
#import "i18n.typ": i18n

#let default-title(title) = {
  show: block.with(width: 100%)
  set align(center)
  set text(size: 1.75em, weight: "bold")
  title
}

#let default-author(authors) = context {
  show: block.with(width: 100%, below: par.leading)
  let (gettext, locale) = i18n(text.lang)
  set text(cjk-latin-spacing: none)
  authors.map(author => {
    [#author.name#super(author.insts.map(it => numbering("1", it + 1)).join(","))]
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
  }).join(gettext("comma"))
}

#let default-affiliation(affiliations) = {
  show: block.with(width: 100%)
  set text(size: 0.8em)
  set par(leading: 0.4em)
  affiliations.enumerate().map(((ik, address)) => {
    super(numbering("1", ik + 1))
    h(1pt)
    address
  }).join(linebreak())
}

#let default-author-info(authors, affiliations, styles: (:)) = context {
  set align(center)
  let styles = (
    author: default-author,
    affiliation: default-affiliation,
    ..styles
  )
  (styles.author)(authors)
  (styles.affiliation)(affiliations.values())
}

#let default-abstract(abstract, keywords) = context {
  let (gettext, locale) = i18n(text.lang)
  set par(first-line-indent: 0em)
  // Abstract and keyword block
  if abstract != [] {
    block(below: par.leading, {
      box(width: 4em, box(width: 3em, strong([摘#h(1fr)要])) + strong([：]))
      abstract
    })
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
  set par(first-line-indent: (amount: 2em, all: true))
  set figure(placement: top)
  set figure.caption(separator: h(.5em))
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => context {
    strong({
      it.supplement
      counter(figure.where(kind: it.kind)).display(it.numbering)
    })
    it.separator
    it.body
  }
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
