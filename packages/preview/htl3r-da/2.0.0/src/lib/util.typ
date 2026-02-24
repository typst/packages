#import "settings.typ" as settings
#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.7": *
#import "global.typ" as global

/// Definiert den aktuellen Autor eines Kapitels. Der Autor eines
/// Kapitels sollte immer nach dem Kapitel-Heading definiert werden.
/// Definiert man den Autor nicht, so wird der Autor des vorherigen
/// Kapitels angenommen.
#let author(name) = context {
  if name != global.author.get() {
    pagebreak(weak: true)
  }
  global.author.update(name)
}

/// Converts a date to a german format, currently not implemented in typst.
#let format-date(date) = {
  let months = (
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember",
  )
  (
    date.display("[day]. ")
      + months.at(date.month() - 1)
      + date.display(" [year]")
  )
}

#let format-department(department) = {
  let departments = (
    ITN: "Informationstechnologie/Netzwerktechnik",
    ITM: "Informationstechnologie/Medientechnik",
    M: "Mechatronik",
  )
  departments.at(department)
}

/// Creates a completly blank page, useful for book binding
#let blank-page() = context {
  page(header: none, footer: none, [])
}

/// Markiert eine Abkürzung, sodass diese nachgeschlagen werden kann.
/// Die Abkürzung sollte in den definierten Abkürzungen
/// beinhaltet sein. Ansonsten ist diese nicht nachschlagbar.
#let abbr(body) = [
  #link(label("ABBR_DES_" + body.text), body) #label("ABBR_" + body.text)
]

/// Markiert eine Abkürzung, sodass diese nachgeschlagen werden kann.
/// Die Abkürzung sollte in den definierten Abkürzungen
/// beinhaltet sein. Ansonsten ist diese nicht nachschlagbar.
/// Die Abkürzung ist dabei im Plural gehalten.
#let abbrp(body) = [
  #let singular = body.text.slice(0, body.text.len() - 1)
  #link(label("ABBR_DES_" + singular), body) #label("ABBR_" + singular)
]

#let code(caption: none, description: none, skips: none, body) = {
  let nested() = {
    codly(
      header: description,
      skips: skips,
    )
    body
  }
  return figure(
    nested(),
    caption: caption,
    supplement: [Quellcode],
    kind: "code",
  )
}

#let code-file(
  caption: none,
  filename: none,
  lang: none,
  text: none,
  range: none,
  ranges: none,
  skips: none,
) = {
  let nested() = {
    codly(
      header: filename,
      ranges: ranges,
      range: range,
      skips: skips,
    )
    raw(text, block: true, lang: lang)
  }
return figure(
    nested(),
    caption: caption,
    supplement: [Quellcode],
    kind: "code",
  )
}

/// Positioniert mehrere Abbildungen auf einer Zeile
#let fspace(total-width: settings.FIGURE_WIDTH, ..figures) = {
  let figures = figures.pos()
  let gutter = 2em
  let shave = gutter * (figures.len() - 1) / figures.len()
  let width = 100% / figures.len() - shave
  let columns = range(figures.len()).map(_ => width)
  set block(width: 100%, above: 2em, below: 2em, breakable: false)
  align(center)[#block(width: total-width)[
      #show figure: set image(width: 100%)
      #grid(
        columns: columns,
        gutter: gutter,
        align: bottom,
        ..figures
      )
    ]]
}

#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let insert-blank-page() = {
  if global.disable-book-binding.get() {
    return
  }
  set page(header: none, footer: none)
  pagebreak(to: "odd", weak: true)
}

#let comp(content) = {
  return ("comp", content)
}
