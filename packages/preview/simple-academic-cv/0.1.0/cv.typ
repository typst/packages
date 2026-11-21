// vertical whitespace multiplier
#let cv-spacing = state("cv-spacing", 1.0)

// SECTION TITLE
// ------------
//    body
#let section(title, body) = { heading(level: 1, title); body }

// subheadings within a SECTION, styled by lvl 2 show rule in cv()
#let subsection(title) = heading(level: 2, title)

// two-column entry, left aligned & right aligned, e.g.
// University Name                                        City Name
// Position Name                               Some Long Date Range
#let entry(textleft, ..therest) = {
  let textright = therest.pos().at(0, default: none)
  if textright == none { textleft } else {
    grid(columns: (1fr, auto), column-gutter: 1em, textleft, align(right, textright))
  }
}

// small indented detail line under an entry
#let details(textleft, ..therest) = { pad(left: 1.5em, entry(textleft, ..therest)) }

// labelled rows where each row is (label, content) or (label, content, date)
// Label      content that can wrap and stay in its own block etc       date
// Label      content
#let rows(..rows) = context {
  let sp = cv-spacing.get()
  set par(justify: false)
  grid(
    columns: (auto, 1fr, auto),
    column-gutter: 1.5em,
    row-gutter: 0.95em * sp,
    ..rows.pos().map(row => (
      emph(row.at(0)), row.at(1), align(right, row.at(2, default: []))
    )).flatten(),
  )
}

// a block for a talk, poster, etc.
// each venue is (venue, date) or  (kind, venue, date)
#let talk(title,  kind: none, author: none, ..venues) = context {
  let sp = cv-spacing.get()
  [
    #emph(title) \
    #set par(spacing: 0.35em * sp)
    #set block(spacing: 0.35em * sp)
    #pad(left: 1em)[
      #if kind   != none [#kind \ ]
      #if author != none [Authors: #author \ ]
      #for ven in venues.pos() {
        if ven.len() == 3 {
          [#ven.at(0) \ ]
          entry(ven.at(1), ven.at(2))
        } else { entry(..ven) }
      }
    ]
  ]
}

// a grant, scholarship, etc
#let funding(title, budget: none, ..fields) = context {
  let sp = cv-spacing.get()
  let lines = fields.named().pairs().map(((key, val)) => [#key: #val])
  emph(title)
  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    row-gutter: 0.65em * sp,
    lines.at(0, default: []), if budget != none { underline[Budget: #budget] },
    ..lines.slice(calc.min(1, lines.len())).map(line => (line, [])).flatten(),
  )
}

// Place                                          Dates
// job-title
// optional free-form yapping
#let job(place, dates, title, ..therest) = {
  let description = therest.pos().at(0, default: none)
  entry(strong(place), dates)
  emph(title)
  pad(left: 1em, right: 1em, {
    if description != none { parbreak(); description }
  })
}

//////////////////////////////////////////////////////////////
//                   the actual document                    //
//////////////////////////////////////////////////////////////
#let cv(
  name: "",
  me: none,           // your last name: emboldened in citations and author lists
  header-columns: (), // whatever number of columns, under the name
  header-columns-separator:none, // thing between the columns
  paper: "a4",
  margin: 1in,
  spacing: 1.0, // scales vertical whitespace
  fonts: (:), // body, bold, name, heading..
  font-sizes: (:), // body, name,section, subsection
  link-color: rgb("#1a4f8b"),
  bib: none, // bibliogrpahy("refs.bib", style:"apa")
  bib-show: false,
  body,
) = {

  let sp = spacing
  cv-spacing.update(spacing)

  // font sizes
  let fonts = (body: "New Computer Modern", bold: none, name: none, heading: none) + fonts
  let body-size = font-sizes.at("body", default: 11pt)
  let font-sizes = (
    body:       body-size,
    name:       2.0 * body-size,
    section:    1.2 * body-size,
    subsection: 1.0 * body-size,
  ) + font-sizes

  // bold text. Accepts a separate bold family at regular font weight if given
  let bold(arg, font: none) = {
    let f = if font != none { font } else { fonts.bold }
    if f == none { strong(arg) } else { text(font: f, weight: "regular", arg) }
  }
  show strong: arg => if fonts.bold == none { arg } else { text(font: fonts.bold, weight: "regular", arg.body) }

  set page(paper: paper,      margin: margin)
  set text(font:  fonts.body, size:   font-sizes.body)
  set par(spacing: 0.65em * sp, leading: 0.56em)

  // embolden thyself (names matching `me` will be displayed in bold for citations, authorlists, etc)
  show: item => if me == none { item } else {

    let escape(s) = s.replace(regex("[\\\\.*+?^${}()|\\[\\]-]"), m => "\\" + m.text)
    let (last,  first) = if type(me) == str { (me,  none) } else { (me.last, me.at("first", default: none)) }
    let ln   = escape(last)
    let pre  = if last.first().match(regex("\\w")) != none { "\\b" } else { "" }
    let post = if last.last().match(regex("\\w")) != none { "\\b" }  else { "" }
    let cap = "(?:\\p{Lu}\\.|\\p{Lu}{1,3}\\b)"
    let more = "(?:[ -]?"  + cap + ")*"
    let patt = if first == none {
      let initials = "\\b" + cap + more
      initials + " " + ln + post + "|" + pre + ln + post + "(?:,? " + initials + ")?"

    } else {
      let f = escape(first.first())
      let initials = "\\b(?:" + escape(first) + "|" + f + "(?:\\.|\\p{Lu}{0,2}\\b))" + more
      initials + " " + ln + post + "|" + pre + ln + post + ",? " + initials
    }
    show regex(patt): strong
    item
  }

  show math.equation: set text(weight: "regular")

  show link: stuff => if link-color == none { stuff } else { text(fill: link-color, stuff) }

  // general section vibe
  show heading.where(level: 1): item => {
    v(0.9em * sp)
    block(breakable: false, sticky: true, below: 0.6em * sp)[
      #text(size: font-sizes.section, bold(upper(item.body), font: fonts.heading))
      #v(-0.8em * sp)
      #line(length: 100%, stroke: 0.06 * font-sizes.body)
    ]
  }
  show heading.where(level: 2): item => {
    v(0.4em * sp)
    block(sticky: true, text(size: font-sizes.subsection,  bold(underline(item.body))))
  }

  // CV header
  let header-cells = if header-columns-separator == none { header-columns } else { header-columns.intersperse(header-columns-separator) }
  align(center, [
    #text(size: font-sizes.name, bold(name, font: fonts.name))
    #if header-cells.len() > 0 {
      v(0.3em * sp)
      context {
        let width = calc.max(..header-columns.map(col => measure(col).width))
        let sep = header-columns-separator
        let cells = if sep == none { header-columns } else { header-columns.intersperse(sep) }
        let cols  = if sep == none { (width,) * header-columns.len() } else {
          ((width,) * header-columns.len()).intersperse(auto)
        }
        grid(
          columns: cols,
          column-gutter: 1.5em,
          align: horizon+center,
          ..cells
        )
      }
    }
  ])
  v(0.5em * sp)

  // the rest of the CV
  body

  // bibliography. The intention is to do in-text citations and not to print a "bibliography"
  // or section at the end as one would an article or something. Set bib-show to true if you
  // do want to print a bibliography
  if bib != none {
    show bibliography: bibby => if bib-show { bibby }
    bib
  }

}
