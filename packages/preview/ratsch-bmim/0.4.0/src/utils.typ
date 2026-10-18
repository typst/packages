#import "data.typ": *
#import "options.typ": *

#let abstract(body) = {
  // abstract environment for the article class
  set par(leading: .5em)
  set text(font: "Source Sans 3", spacing: 80%, size: 1.1em)
  text(weight: "semibold", fill: color-cd2026.blue)[Abstract.]
  text(style: "normal")[#body]
}

#let backmatter(content) = {
  set heading(numbering: "A.1", supplement: "Anhang")
  counter(heading).update(0)
  state("backmatter").update(true)
  {
    show heading: none
    [
      #pagebreak(to: "odd", weak: true)
      #heading(numbering: none)[Anhang] <appendix>
    ]
  }
  content
}

#let translatedMonth(dt, lang) = {
  if lang == "de" {
    months.at(dt.month() - 1)
  } else {
    dt.display("[month repr:long]")
  }
}

#let print-date(date) = {
  let opts = options.final()
  if type(date) != datetime {
    date
  } else [#date.day(). #translatedMonth(date, opts.lang) #date.year()]
}

#let print-semester(date) = {
  let opts = options.final()
  if type(date) != datetime {
    none
  } else {
    if date.month() > 3 and date.month() < 10 {
      [Sommersemester #date.year()]
    } else {
      let followYear = date + duration(days: 365)
      [Wintersemester #date.year()/#followYear.year()]
    }
  }
}

#let heading-prefix-numbering(..args, loc: none) = context {
  let hdr = counter(heading).at(
    if loc == none { here() } else { loc }
  )
  let chain = hdr + args.pos()
  return chain.map(str).join(".")
}

#let page-is-chap-start() = {
  return query(heading.where(level: 1))
    .map(it => it.location().page())
    .contains(here().page())
}

#let current-title(lvl: 1) = context {
  let headings = query(heading.where(level: lvl).before(here()))
  if headings == () { return none}
  headings.last().body
}

#let page-number() = numbering(here().page-numbering(), here().page())

#let is-empty(value) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    str: "",
    content: [],
  )
  let t = repr(type(value))
  if t in empty-values {
    return value == empty-values.at(t)
  } else {
    return value == none
  }
}

#let show-marks(m, ys) = context {
  if m == none { return }
  let y = if type(ys) == array { ys } else { (ys,) }
  let p = m.pages
  if p != "both" and ((p == "odd") != calc.odd(counter(page).get().first())) {
    return
  }
  let l = line(length: m.length, stroke: m.stroke)
  for _y in y { place(top + left, dx: m.xdist, dy: _y, l) }
}

