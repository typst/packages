#import "data.typ": *
#import "options.typ": *

#let backmatter(content) = {
  set heading(numbering: "A.1")
  counter(heading).update(0)
  state("backmatter").update(true)
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
