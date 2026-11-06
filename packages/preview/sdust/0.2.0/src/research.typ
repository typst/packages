// ── research ─────────────────────────────────────────
// arXiv / ICML-style paper: ruled title, authors with affiliation marks,
// full-width indented abstract, then the body (two columns by default).
//
// author: strings, or dicts (name:, affiliation: 1 | (1, 2), equal: bool,
//         email:). affiliations: array, numbered from 1 in order.

#import "branding.typ": *
#import "base.typ": base-style

#let _paper-font = ("Times New Roman", "Times", "Libertinus Serif")

#let _as-dict(a) = if type(a) == dictionary { a } else { (name: a) }

#let _marks(a) = {
  let aff = a.at("affiliation", default: ())
  let aff = if type(aff) == array { aff } else { (aff,) }
  let marks = aff.map(str)
  if a.at("equal", default: false) { marks.push("*") }
  if marks.len() > 0 { super(marks.join(",")) }
}

#let _author-line(authors) = (
  authors.map(a => box[#a.name#_marks(a)]).join(h(1.2em))
)

#let _title-block(title, subtitle, authors, affiliations, date, repo) = {
  let emails = authors.filter(a => a.at("email", default: none) != none)
  let any-equal = authors.any(a => a.at("equal", default: false))
  set par(justify: false, first-line-indent: 0pt)
  line(length: 100%, stroke: 3pt)
  v(0.4em)
  align(center, text(size: 17pt, weight: "bold", hyphenate: false)[#title])
  if subtitle != none {
    align(center, text(size: 12pt, style: "italic")[#subtitle])
  }
  v(0.2em)
  line(length: 100%, stroke: 0.8pt)
  v(1em)
  align(center, {
    text(size: 11pt, weight: "bold", _author-line(authors))
    if affiliations.len() > 0 {
      v(0.4em)
      text(size: 9pt, affiliations.enumerate()
        .map(((i, x)) => box[#super(str(i + 1))#x])
        .join(h(1em)))
    }
    if any-equal or emails.len() > 0 or date != none {
      v(0.3em)
      set text(size: 8.5pt)
      let parts = ()
      if emails.len() > 0 {
        parts.push[Correspondence to: #emails.map(a => [#a.name #link("mailto:" + a.email)[
            #text(fill: blue.darken(20%))[#raw(a.email)]
          ]]).join(", ")]
      }
      if date != none { parts.push(date) }
      parts.join(h(0.6em) + sym.dot.c + h(0.6em))
    }
    if repo != none {
      v(0.3em)
      let label = repo.replace(regex("^https?://(www\\.)?"), "").trim("/", at: end)
      text(size: 9pt, fill: rgb("#1a5fb4"), link(repo, raw(label)))
    }
  })
  v(1.2em)
}

#let _abstract-block(abstract, keywords) = {
  align(center, text(size: 11pt, weight: "bold")[Abstract])
  v(0.3em)
  pad(x: 3em, {
    set par(first-line-indent: 0pt)
    abstract
    if keywords != none {
      v(0.5em)
      [*Keywords:* #if type(keywords) == array { keywords.join(", ") } else { keywords }]
    }
  })
  v(1em)
}

#let research(
  title: default-title,
  subtitle: none,
  running-title: auto,
  author: default-author,
  affiliations: (sdu-university,),
  date: none,
  repo: none,
  abstract: none,
  keywords: none,
  columns: 2,
  outline: false,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  let authors = (if type(author) == array { author } else { (author,) }).map(_as-dict)
  // Single affiliation and no explicit marks: tag every author with it.
  let authors = if affiliations.len() == 1 {
    authors.map(a => if "affiliation" in a { a } else { a + (affiliation: 1) })
  } else { authors }
  let running = if running-title == auto { title } else { running-title }

  show: base-style
  set page(
    paper: "a4",
    margin: (x: 1.9cm, top: 2.3cm, bottom: 2.3cm),
    numbering: "1",
    columns: columns,
    header: context if here().page() > 1 and running != none {
      set text(size: 8.5pt)
      stack(spacing: 0.4em, align(center, emph(running)), line(length: 100%, stroke: 0.4pt))
    },
  )
  set text(font: _paper-font, size: 10pt)
  set par(justify: true, leading: 0.55em, spacing: 0.55em, first-line-indent: 1em)
  set heading(numbering: "1.1")
  show heading: set block(above: 1.4em, below: 0.8em)
  show heading.where(level: 1): it => {
    set text(size: 11.5pt, weight: "bold")
    block(if it.numbering != none [#counter(heading).display(). #h(0.3em)#it.body] else { it.body })
  }
  show heading.where(level: 2): set text(size: 10pt, weight: "bold")
  show heading.where(level: 3): it => block(text(size: 10pt, style: "italic", weight: "regular", it.body))
  set figure(gap: 0.8em)
  show figure.caption: set text(size: 9pt)
  set std.columns(gutter: 0.8cm)
  set footnote.entry(separator: line(length: 30%, stroke: 0.4pt))

  let front = {
    _title-block(title, subtitle, authors, affiliations, date, repo)
    if abstract != none { _abstract-block(abstract, keywords) }
  }
  place(top, float: true, scope: "parent", front)
  if outline { std.outline(depth: outline-depth) }
  body
}
