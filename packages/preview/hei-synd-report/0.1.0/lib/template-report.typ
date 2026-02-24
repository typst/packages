//
// Description: Report Typst Template
// Author     : Silvan Zahno
//
#import "helpers.typ": *
#import "pages-report.typ": *

#let report(
  option: (
    lang: "en",
    type: "draft"
  ),
  doc: (
    title    : none,
    abbr     : none,
    subtitle : none,
    url      : none,
    logos: (
      tp_top    : none,
      tp_bottom : none,
      tp_main   : none,
      header    : none,
    ),
    authors: (
      (
        name        : none,
        abbr        : none,
        email       : none,
        url         : none,
      ),
    ),
    school: (
      name        : none,
      major       : none,
      orientation : none,
      url         : none,
    ),
    course: (
      name     : none,
      url      : none,
      prof     : none,
      class    : none,
      semester : none,
    ),
    keywords : ("Typst", "Template", "Report"),
    version  : "v0.1.0",
  ),
  date: datetime.today(),
  tableof : (
    toc: true,
    tof: false,
    tot: false,
    tol: false,
    toe: false,
    maxdepth: 3,
  ),
  body) = {
  // Sanitize inputs
  doc.title    = doc.at("title", default: none)
  doc.abbr     = doc.at("abbr", default: none)
  doc.subtitle = doc.at("subtitle", default: none)
  doc.url      = doc.at("url", default: none)
  doc.logos    = if doc.at("logos", default: none) == none {
    (
      tp_topleft  : none,
      tp_topright : none,
      tp_main     : none,
      header      : none,
    )
  } else {
    doc.logos
  }
  doc.logos.tp_topleft  =  doc.logos.at("tp_topleft", default: none)
  doc.logos.tp_topright =  doc.logos.at("tp_topright", default: none)
  doc.logos.tp_main     =  doc.logos.at("tp_main", default: none)
  doc.logos.header      =  doc.logos.at("header", default: none)
  doc.authors           = if doc.at("authors", default: none) == none {
    (
      (
        name        : none,
        abbr        : none,
        email       : none,
        url         : none,
      ),
    )
  } else {
    doc.authors
  }
  for a in doc.authors {
    a.name        =  a.at("name", default: none)
    a.abbr        =  a.at("abbr", default: none)
    a.email       =  a.at("email", default: none)
    a.url         =  a.at("url", default: none)
  }
  doc.school           = if doc.at("school", default: none) == none {
    (
      name        : none,
      major       : none,
      orientation : none,
      url         : none,
    )
  } else {
    doc.school
  }
  doc.school.name       =  doc.school.at("name", default: none)
  doc.school.major      =  doc.school.at("major", default: none)
  doc.school.orientation =  doc.school.at("orientation", default: none)
  doc.school.url        =  doc.school.at("url", default: none)

  doc.course            =  doc.at("course", default: none)
  doc.course           = if doc.at("course", default: none) == none {
    (
      name     : none,
      url      : none,
      prof     : none,
      class    : none,
      semester : none,
    )
  } else {
    doc.course
  }
  doc.course.name       =  doc.course.at("name", default: none)
  doc.course.url        =  doc.course.at("url", default: none)
  doc.course.prof       =  doc.course.at("prof", default: none)
  doc.course.class      =  doc.course.at("class", default: none)
  doc.course.semester   =  doc.course.at("semester", default: none)
  doc.keywords          =  doc.at("keywords", default: ("Typst", "Template", "Report"))
  doc.version           =  doc.at("version", default: none)

  // basic properties
  set document(author: doc.authors.map(a => if a.name != none {a.name} else {""}), title: doc.title, keywords: doc.keywords, date: date)
  set page(margin: (top:3cm, bottom:3cm, left:3cm, right:2.5cm))

  // header and footer
  set page(
    header: context(if here().page() >=2 [
      #set text(small)
      #table(
        columns: (80%, 20%),
        stroke: none,
        inset: -0.5em,
        align: (x, y) => (left+bottom, right+top).at(x),
        [#if doc.abbr != none {[#smallcaps(doc.abbr)]} #if doc.abbr != none and doc.title != none {[/]} #if doc.title != none {smallcaps(doc.title)}],
        [#v(1.2cm)#doc.logos.header]
      )
      #if doc.logos.header != none {[
        #line(start: (-0.5em, 0cm), length: 85%, stroke: 0.5pt)
      ]} else {[
        #line(start: (-0.5em, 0cm), length: 100%, stroke: 0.5pt)
      ]}
      ]),
    footer: context( if here().page() >=2 [
        #set text(small)
        #line(start: (85%, 0cm), length: 15%, stroke: 0.5pt)
        #enumerating-emails(names:doc.authors.map(a => a.abbr), emails:doc.authors.map(a => a.email)) #if doc.authors.first().abbr != none {[/]} #date.display("[year]") #h(1fr) #context counter(page).display("1 / 1", both: true)
    ]),
  )

  // font & language
  set text(
    font: (
      "Libertinus Serif",
      "Fira Sans",
    ),
    fallback: true,
    lang: option.lang
  )

  // heading
  show heading: set block(above: 1.2em, below: 1.2em)
  set heading(numbering: "1.1")

  show heading.where(level: 1): (it) => {
    set text(size: huge)
    set block(above: 1.2em, below: 1.2em)
    if it.numbering != none {
      let num = numbering(it.numbering, ..counter(heading).at(it.location()))
      let prefix = num + h(0.5em) + text(code-border)[|] + h(0.5em)
      unshift-prefix(prefix, it.body)
    } else {
      it
    }
  }

  show heading.where(level: 2): (it) => {
    if it.numbering != none {
      let num = numbering(it.numbering, ..counter(heading).at(it.location()))
      unshift-prefix(num + h(0.8em), it.body)
    }
  }

  // link color
  //show link: it => text(fill:blue, underline(it))
  //show link: it => text(fill:hei-blue, it)
  show link: it => text(fill:gray-80, it)

  show raw.where(block: false): set text(weight: "semibold")
  //show raw.where(block: false): it => {
  //  highlight(
  //    fill:code-bg,
  //    top-edge: "ascender",
  //    bottom-edge: "bounds",
  //    extent:1pt, it)
  //}
  show raw.where(block: true): set text(size: tiny)
  show raw.where(block: true): it => {
    block(
      fill: code-bg,
      width:100%,
      inset: 10pt,
      radius: 4pt,
      stroke: 0.1pt + code-border,
      it,
    )
  }

  // Captions
  set figure(numbering: "1", supplement: get-supplement)
  set figure.caption(separator: " - ") // With a nice separator
  set math.equation(numbering: "(1)", supplement: i18n("equation-name"))

  show: word-count

  // Title page
  page-title-report(
    type:option.type,
    doc: doc,
    date: date,
  )

  pagebreak()
  // Table of content
  toc(
    tableof: tableof,
    titles: (
      toc: i18n("toc-title"),
      tot: i18n("tot-title"),
      tof: i18n("tof-title"),
      tol: i18n("tol-title"),
      toe: i18n("toe-title"),
    ),
    before: <sec:glossary>
  )

  // Main body
  set par(justify: true)

  body
}
