//
// Description: HEVS Thesis Typst Template
// Author     : Silvan Zahno
//
#import "helpers.typ": *
#import "pages-thesis.typ": *

#let thesis(
  option: (
    type        : "final",  // "draft"
    lang        : "en",     // "de", "fr"
    template    : "thesis", // "midterm"
  ),
  doc: (
    title    : "Thesis Template",
    subtitle : "Longer Subtitle",
    author: (
      name        : "Firstname Lastname",
      email       : "firstname.lastname@hevs.ch",
      degree      : "Bachelor",
      affiliation : "HEI-Vs",
      place       : "Sion",
      url         : "https://synd.hevs.io",
      signature   : none,
    ),
    keywords : ("HEI-Vs", "Systems Engineering", "Infotronics", "Thesis", "Template"),
    version  : "v0.1.0",
  ),
  summary-page : (
    logo: none,
    objective: none,
    content: none,
  ),
  professor: none,
  expert: none,
  school: none,
  date: (
    submission: datetime.today(),
    mid-term-submission: datetime.today(),
    today: datetime.today(),
  ),
  tableof : (
    toc: true,
    tof: false,
    tot: false,
    tol: false,
    toe: false,
    maxdepth: 3,
  ),
  logos: (
    topleft: none,
    topright: none,
    bottomleft: none,
    bottomright: none,
  ),
  title-extra-content-top: none,
  title-extra-content-bottom: none,
  body) = {
  // Sanitize inputs
  doc.title    = doc.at("title", default: none)
  doc.subtitle = doc.at("subtitle", default: none)
  doc.author   = if doc.at("author", default: none) == none {
    (
      name: none,
      email: none,
      degree: none,
      affiliation: none,
      place: none,
      url: none,
      signature: none
    )
  } else {
    doc.author
  }
  doc.author.name = doc.author.at("name", default: none)
  doc.author.email = doc.author.at("email", default: none)
  doc.author.degree = doc.author.at("degree", default: none)
  doc.author.affiliation = doc.author.at("affiliation", default: none)
  doc.author.place = doc.author.at("place", default: none)
  doc.author.url = doc.author.at("url", default: none)
  doc.author.signature = doc.author.at("signature", default: none)
  doc.keywords = doc.at("keywords", default: ("Typst", "Template", "Thesis", "HEI-Vs", "Systems Engineering"))
  doc.version  = doc.at("version", default: "v0.1.0")
  summary-page = if summary-page == none {
    (
      logo: none,
      objective: none,
      content: none,
    )
  } else {
    summary-page
  }
  summary-page.logo = summary-page.at("logo", default: none)
  summary-page.objective = summary-page.at("objective", default: none)
  summary-page.content = summary-page.at("content", default: none)
  summary-page = if summary-page.logo == none and summary-page.objective == none and summary-page.content == none {
    none
  } else {
    summary-page
  }
  professor = if professor == none {
    (
      name: none,
      email: none,
      affiliation: none,
    )
  } else {
    professor
  }
  professor.name = professor.at("name", default: none)
  professor.email = professor.at("email", default: none)
  professor.affiliation = professor.at("affiliation", default: none)
  expert = if expert == none {
    (
      name: none,
      email: none,
      affiliation: none,
    )
  } else {
    expert
  }
  expert.name = expert.at("name", default: none)
  expert.email = expert.at("email", default: none)
  expert.affiliation = expert.at("affiliation", default: none)
  school = if school == none {
    (
      name: none,
      shortname: none,
      orientation: none,
      specialisation: none,
    )
  } else {
    school
  }
  school.name = school.at("name", default: none)
  school.shortname = school.at("shortname", default: none)
  school.orientation = school.at("orientation", default: none)
  school.specialisation = school.at("specialisation", default: none)
  date = if date == none {
    (
      submission: datetime.today(),
      mid-term-submission: datetime.today(),
      today: datetime.today(),
    )
  } else {
    date
  }
  date.submission = date.at("submission", default: datetime.today())
  date.mid-term-submission = date.at("mid-term-submission", default: datetime.today())
  date.today = date.at("today", default: datetime.today())
  tableof = if tableof == none {
    (
      toc: true,
      tof: false,
      tot: false,
      tol: false,
      toe: false,
      maxdepth: 3,
    )
  } else {
    tableof
  }
  tableof.toc = tableof.at("toc", default: true)
  tableof.tof = tableof.at("tof", default: false)
  tableof.tot = tableof.at("tot", default: false)
  tableof.tol = tableof.at("tol", default: false)
  tableof.toe = tableof.at("toe", default: false)
  tableof.maxdepth = tableof.at("maxdepth", default: 3)
  logos = if logos == none {
    (
      topleft: none,
      topright: none,
      bottomleft: none,
      bottomright: none,
    )
  } else {
    logos
  }
  logos.topleft = logos.at("topleft", default: none)
  logos.topright = logos.at("topright", default: none)
  logos.bottomleft = logos.at("bottomleft", default: none)
  logos.bottomright = logos.at("bottomright", default: none)
  // basic properties
  set document(author: if doc.author.name != none {doc.author.name} else {""} , title: doc.title, keywords: doc.keywords, date: date.today)
  set page(margin: (top:3.5cm, bottom:3.5cm, rest:3.5cm))

  // header and footer
  set page(
    header: context(if here().page() >=2 [
    #set text(small)
      #h(1fr) #smallcaps(doc.title)
    ]),
    footer: context( if here().page() >=2 [
      #set text(small)
      #h(1fr) #counter(page).display("I / 1", both: false)
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
  // paragraph
  show par: set par(spacing: 1em)

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
    } else {
      it
    }
  }

  // link color
  //show link: it => text(fill:blue, underline(it))
  show link: it => text(fill:hei-blue, it)

  // code blocks
  set raw(syntaxes:"syntax/VHDL.sublime-syntax")
  set raw(syntaxes:"syntax/riscv.sublime-syntax")

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

  // Title page
  page-title-thesis(
    title: doc.title,
    subtitle: doc.subtitle,
    date: date.submission,
    lang: option.lang,
    template: option.template,
    school: school,
    author: doc.author,
    professor: professor,
    expert: expert,
    logos: logos,
    extra-content-top: title-extra-content-top,
    extra-content-bottom: title-extra-content-bottom,
  )

  // Table of Todos if draft
  if option.type == "draft" {
    pagebreak()
    outline-todos()
  }

  // Summary
  if option.template == "thesis" and summary-page != none {
    pagebreak()
    summary(
      title: doc.title,
      student: doc.author.name,
      year: date.submission.display("[year]"),
      degree: school.orientation,
      field: school.specialisation,
      professor: professor,
      //partner: partner,
      logos: (
        main: summary-page.logo,
        topleft: logos.topleft,
        bottomright: logos.bottomright,
      ),
      objective: summary-page.objective,
      address: summary-page.address,
      lang: option.lang,
    )[#summary-page.content]
  }

  // Report info
  pagebreak()
  page-reportinfo(
    author: doc.author,
    date: date.today,
    lang: option.lang,
  )

  // Table of ...
  pagebreak()
  toc(
    tableof: tableof,
    titles: (
      toc: i18n("toc-title", lang: option.lang),
      tot: i18n("tot-title", lang: option.lang),
      tof: i18n("tof-title", lang: option.lang),
      tol: i18n("tol-title", lang: option.lang),
      toe: i18n("toe-title", lang: option.lang),
    ),
    before: <sec:glossary>
  )

  // Main body
  set par(justify: true)
  set page(
    header: context(if here().page() >=2 [
    #set text(small)
      #h(1fr) #smallcaps(doc.title)
    ]),
    footer: context( if here().page() >=2 [
      #set text(small)
      #h(1fr) #counter(page).display("1 / 1", both: true)
    ]),
  )
  counter(page).update(1)

  body
}
