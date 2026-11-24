// Front matter: title block (\maketitle), first-page notes
// (\printFirstPageNotes) and the graphical abstract / highlights pages.
#import "globals.typ": *
#import "utils.typ": *

// Marks ----------------------------------------------------------------------

#let star-mark(n, fonts) = with-font(fonts.math, "⋆" * n) // \tnotemark
#let cor-mark(n, fonts) = with-font(fonts.math, "∗" * n) // \cormark
#let maltese(fonts) = with-font(fonts.math, "✠") // deceased author

// Affiliations ----------------------------------------------------------------

/// Format an affiliation. Structured affiliations are dictionaries whose
/// entries are printed in the order given, each followed by its separator:
/// `<key>sep` if present, else "," (none after `country` and after the last
/// entry), like `\affiliation{organization=..., postcodesep={}, ...}`.
#let format-affiliation(aff) = {
  if type(aff) != dictionary { return aff }
  let keys = aff.keys().filter(k => not k.ends-with("sep"))
  let parts = ()
  for (i, key) in keys.enumerate() {
    let last = key == "country" or i == keys.len() - 1
    let sep = aff.at(key + "sep", default: if last { none } else { [,] })
    parts.push([#aff.at(key)#sep])
  }
  parts.join(" ")
}

/// The letter marking an affiliation: its position in `affiliations`, or
/// the letter of a numeric id that is not defined (as the LaTeX class does).
/// Any other unknown id is an error.
#let aff-letter(id, affiliations) = {
  let id = str(id)
  let idx = affiliations.keys().position(k => k == id)
  if idx != none { return numbering("a", idx + 1) }
  assert(
    id.match(regex("^[0-9]+$")) != none,
    message: "unknown affiliation id \"" + id + "\"; the ids in "
      + "`affiliations` are " + repr(affiliations.keys()),
  )
  numbering("a", int(id))
}

// Authors ---------------------------------------------------------------------

#let corresponding-level(author) = {
  let c = author.at("corresponding", default: false)
  if c == true { 1 } else if type(c) == int { c } else { 0 }
}

#let author-marks(author, affiliations, fonts) = {
  let ids = as-array(author.at("affiliations", default: ()))
  let marks = ids.map(id => emph(aff-letter(id, affiliations)))
  let cor = corresponding-level(author)
  if cor > 0 { marks.push(cor-mark(cor, fonts)) }
  marks += as-array(author.at("footnotes", default: ())).map(n => [#n])
  if author.at("deceased", default: false) { marks.push(maltese(fonts)) }
  marks
}

#let render-author(author, affiliations, fonts) = {
  let n = split-name(author)
  let given = if n.given != none { text(fill: given-name-color, n.given) }
  let name = if given == none {
    n.family
  } else if is-chinese(author) {
    [#n.family~#given]
  } else {
    [#given~#n.family]
  }
  let prefix = author.at("prefix", default: none)
  let suffix = author.at("suffix", default: none)
  let degree = author.at("degree", default: none)
  let role = author.at("role", default: none)
  let marks = author-marks(author, affiliations, fonts)

  if prefix != none [#prefix ]
  name
  if suffix != none [ #suffix]
  if marks.len() > 0 {
    super(typographic: false, size: 0.67em, marks.join(","))
  }
  if degree != none [, #degree]
  if role != none [ (#role)]
}

// Title block --------------------------------------------------------------

/// Appearance of the `\title[mode=...]` variants.
#let title-modes = (
  title: (size: sizes.LARGE, fill: black, above: 0pt),
  alt: (size: sizes.large, fill: black, above: 6pt),
  sub: (size: sizes.large, fill: luma(20%), above: 6pt),
  trans: (size: sizes.normal, fill: luma(40%), above: 6pt),
  transsub: (size: sizes.small, fill: luma(50%), above: 6pt),
)

/// Letter-spaced capitals, as in "A B S T R A C T".
#let spaced-caps(body) = text(tracking: 0.1667em, upper(body))

#let hrule(stroke) = block(line(length: 100%, stroke: stroke))

/// The title block of `\MaketitleBox`: titles, authors, affiliations and
/// the article-info/abstract panel between two grey rules. Vertical gaps
/// reproduce the baseline positions of the LaTeX output.
#let make-title(
  titles: (),
  n-title-notes: 0,
  authors: (),
  affiliations: (:),
  blind: false,
  abstract: none,
  abstract-title: none,
  keywords: (),
  keywords-title: none,
  classifications: (),
  fonts: default-fonts,
) = {
  set par(first-line-indent: 0pt, justify: false, hanging-indent: 0pt)
  set block(spacing: 0pt)
  set align(left)

  // Titles; the first baseline sits 10pt below the top of the text area.
  let prev = none
  for (mode, body) in titles {
    let st = title-modes.at(mode)
    let size = st.size.first()
    let gap = if prev == none {
      10pt - 0.7 * size
    } else {
      baseline-gap(st.above + st.size.last(), prev, size)
    }
    v(gap)
    let marks = if mode == "title" and n-title-notes > 0 {
      let stars = range(1, n-title-notes + 1).map(i => star-mark(i, fonts))
      super(typographic: false, size: 0.67em, stars.join(","))
    }
    block(with-size(st.size, text(fill: st.fill)[#body#marks]))
    prev = size
  }
  if prev == none { prev = 0pt }

  // Authors and affiliations (hidden for double-blind review)
  if blind {
    v(10mm)
  } else {
    if authors.len() > 0 {
      v(baseline-gap(26.9pt, prev, 12pt))
      let names = authors.map(a => render-author(a, affiliations, fonts))
      block(with-size(sizes.large, names.join(", ", last: " and ")))
      prev = 12pt
    }
    if affiliations.len() > 0 {
      v(baseline-gap(21.4pt, prev, 8pt))
      block(with-size(sizes.footnotesize, {
        set text(style: "italic")
        set par(spacing: 3.45pt)
        for (i, aff) in affiliations.values().enumerate() {
          let letter = numbering("a", i + 1)
          let mark = super(typographic: false, size: 0.75em, letter)
          par[#mark#format-affiliation(aff)]
        }
      }))
      prev = 8pt
    }
  }

  // \dashrule{0pt}{3pt}, unless nothing precedes it
  if titles.len() > 0 or blind or authors.len() > 0 or affiliations.len() > 0 {
    v(baseline-gap(11.74pt, prev, 0pt))
    hrule(0.4pt + rule-color)
  }

  let has-info = keywords.len() > 0 or classifications.len() > 0
  if abstract != none or has-info {
    // ARTICLE INFO (keywords box) and ABSTRACT, side by side
    let rule-to-text = baseline-gap(9.55pt, 0pt, 8pt)
    let info = if has-info {
      v(8.2pt)
      block(spaced-caps[Article#h(0.5em)Info])
      v(5.85pt)
      hrule(0.2pt)
      v(rule-to-text)
      with-size(sizes.footnotesize, {
        if keywords.len() > 0 {
          par[#emph(keywords-title):]
          for k in keywords { par(k) }
        }
        for (label, codes) in classifications { par[#emph[#label:] #codes] }
      })
    }
    let abs = if abstract != none {
      v(9.2pt)
      block(spaced-caps(abstract-title))
      v(4.85pt)
      hrule(0.2pt)
      v(rule-to-text)
      with-size(sizes.footnotesize, {
        set par(justify: true)
        set par(first-line-indent: (amount: par-indent, all: false))
        abstract
      })
    }
    grid(
      columns: (25%, 10%, 65%),
      info, [], abs,
    )

    // \dashrule{6pt}{3pt}
    v(baseline-gap(8.24pt, 8pt, 0pt))
    hrule(0.4pt + rule-color)
  }
}

// First-page notes ---------------------------------------------------------

#let icon(name) = box(image("../assets/cas-" + name + ".jpeg", height: 8pt))

#let url-dest(url) = if url.contains("://") { url } else { "https://" + url }

/// Pairs `(value, author)` for every value of `key` over all authors.
#let collect(authors, key) = {
  let out = ()
  for a in authors {
    for v in as-array(a.at(key, default: none)) { out.push((v, a)) }
  }
  out
}

#let social-sites = (
  (key: "facebook", name: "Facebook", base: "https://www.facebook.com/"),
  (key: "twitter", name: "Twitter", base: "https://twitter.com/"),
  (key: "gplus", name: "Google+", base: "https://plus.google.com/"),
  (key: "linkedin", name: "LinkedIn", base: "https://www.linkedin.com/in/"),
)

/// All first-page notes, as hidden-marker footnotes in the order of
/// `\printFirstPageNotes`. Each note is `(mark, body, ragged)`.
#let front-notes(
  title-notes: (),
  nonum-notes: (),
  corresponding-notes: (),
  author-notes: (),
  authors: (),
  blind: false,
  logos: true,
  fonts: default-fonts,
) = {
  let mono(s) = with-mono(fonts.mono, s)
  let item(value, author) = [#value (#short-name(author))]
  let url-link(url) = link(url-dest(url), mono(url))
  let orcid-link(id) = link("https://orcid.org/" + id, mono(id))
  let notes = ()
  for (i, n) in title-notes.enumerate() {
    notes.push((star-mark(i + 1, fonts), n, false))
  }
  for n in nonum-notes { notes.push(([], n, false)) }

  if not blind {
    for (i, n) in corresponding-notes.enumerate() {
      notes.push((cor-mark(i + 1, fonts), n, false))
    }
    if authors.any(a => a.at("deceased", default: false)) {
      notes.push((maltese(fonts), [Deceased author.], false))
    }

    let emails = collect(authors, "email")
    if emails.len() > 0 {
      let label = if logos {
        [#icon("email") ]
      } else if emails.len() == 1 {
        [_Email address:_ ]
      } else {
        [_Email addresses:_ ]
      }
      let items = emails.map(((e, a)) => item(mono(e), a))
      notes.push(([], [#label#items.join("; ")], true))
    }

    let urls = collect(authors, "url")
    if urls.len() > 0 {
      let label = if logos [#icon("url") ] else [_URL:_ ]
      let items = urls.map(((u, a)) => item(url-link(u), a))
      notes.push(([], [#label#items.join("; ")], true))
    }

    let orcids = collect(authors, "orcid")
    if orcids.len() > 0 {
      let items = orcids.map(((o, a)) => item(orcid-link(o), a))
      notes.push(([], [#smallcaps[orcid]\(s): #items.join("; ")], true))
    }

    for site in social-sites {
      let ids = collect(authors, site.key)
      if ids.len() > 0 {
        let label = if logos [#icon(site.key) ] else [#site.name: ]
        let items = ids.map(((id, a)) => {
          let url = if id.contains("://") { id } else { site.base + id }
          item(link(url, mono(url)), a)
        })
        notes.push(([], [#label#items.join(", ")], true))
      }
    }

    for (i, n) in author-notes.enumerate() {
      notes.push(([#(i + 1)], n, false))
    }
  }

  // The footnotes are anchored at the top of the current column, so their
  // entries end up at the bottom of the first page (column).
  place(top, {
    for (mark, body, ragged) in notes {
      let note = footnote(numbering: (..) => mark, body)
      if ragged [#note<cas-frontnote-ragged>] else [#note<cas-frontnote>]
    }
  })
}

// Graphical abstract and highlights pages -------------------------------------

/// A page in front of the article (`PrelimsAbstract`): heading, title,
/// author names and the given content; no running head or foot.
#let prelim-page(heading, body, title: none, authors: (), blind: false) = page(
  columns: 1,
  header: none,
  footer: none,
  {
    set par(first-line-indent: 0pt, justify: false)
    v(10pt - 0.7 * 14pt)
    block(spacing: 0pt, with-size((14pt, 16pt), heading))
    v(baseline-gap(23.9pt, 14pt, 12pt))
    block(spacing: 0pt, with-size(sizes.large, strong(title)))
    v(baseline-gap(18pt, 12pt, 10pt))
    let names = if blind { hide[Authors] } else {
      authors.map(full-name).join(", ")
    }
    block(spacing: 0pt, names)
    v(12.3pt)
    body
  },
)
