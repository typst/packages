#import "@preview/hydra:0.6.2": hydra

// courtesy of https://github.com/jbirnick/typst-headcount/blob/d796ab0294d608f9746f3609a71d80b9a93499b8/lib.typ
#let normalize-length(array, length) = {
  if array.len() > length {
    array = array.slice(0, length)
  } else if array.len() < length {
    array += (length - array.len()) * (0,)
  }

  return array
}

#let dependent-numbering(style, levels: 1) = n => {
  numbering(style, ..normalize-length(counter(heading).get(), levels), n)
}


// courtesy of https://github.com/jneug/typst-tools4typst/blob/32f774377534339f7bd073133fded363cb4a200f/src/get.typ#L176-L196
// removed type() == "string" comparison
#let dict-merge(..dicts) = {
  if dicts.pos().all(v => std.type(v) == dictionary) {
    // if all-of-type("dictionary", ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

#let today = datetime.today()
#let summer = datetime(year: today.year(), month: 7, day: 1)
#let is-spring-semester = today < summer
#let semester-dk = if is-spring-semester {
  "Forårssemesteret"
} else {
  "Efterårssemesteret"
}
#let semester-en = if is-spring-semester {
  "Spring Semester"
} else {
  "Fall Semester"
}

#let is-chapter-page(chapter-label) = {
  let current = counter(page).get()
  return query(chapter-label).any(m => (
    counter(page).at(m.location()) == current
  ))
}

// only applies when pages are not roman numbered, thus no label argument
#let custom-header(name: none) = context {
  if not is-chapter-page(<chapter>) {
    if calc.even(here().page()) [
      #counter(page).display("1 of 1", both: true)
      #h(1fr)
      #name #hydra(1)
    ] else [
      #hydra(2)
      #h(1fr)
      #counter(page).display("1 of 1", both: true)
    ]
  }
}

#let custom-footer(chapter-label) = context {
  if is-chapter-page(chapter-label) {
    align(center, counter(page).display(page.numbering))
  }
}

#let clear-page(skip-double) = {
  if skip-double {
    set page(header: none, footer: none)
    pagebreak(weak: true, to: "odd")
  } else {
    pagebreak(weak: true)
  }
}


#let set-chapter-style(
  numbering: none,
  name: none,
  double-page-skip: true,
  body,
) = {
  set heading(numbering: numbering, outlined: true)
  set page(header: custom-header(name: name))
  counter(heading).update(
    0,
  ) // Reset the chapter counter (appendices start at A)
  // numbering of figures and equations
  set figure(numbering: dependent-numbering(numbering)) if (
    numbering != none
  )
  set math.equation(numbering: dependent-numbering("(" + numbering + ")")) if (
    numbering != none
  )

  // references show chapter / appendix
  show heading.where(level: 1): set heading(supplement: name)

  show heading.where(level: 1): it => {
    clear-page(double-page-skip)


    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)

    set par(first-line-indent: 0pt, justify: false)
    show: block
    v(3cm)
    if name != none {
      // set chapter/appendix whatever if exists
      text(size: 18pt)[#it.supplement #counter(heading).display()]
      v(.5cm)
    }
    text(
      size: 24pt,
    )[#it.body <chapter>] // allow us to query this label to make header work properly
    v(.75cm)
  }
  body // actually show what comes afterwards
}

#let custom-heading(it, p-top, p-bottom) = {
  if it.numbering == none {
    block(pad(top: p-top, bottom: p-bottom, it.body))
  } else {
    pad(top: p-top, bottom: p-bottom, grid(
      columns: (30pt, 1fr),
      counter(heading).display(it.numbering), it.body,
    ))
  }
}

#let show-if-not-none(val, name) = {
  if val != none [#name #val]
}
