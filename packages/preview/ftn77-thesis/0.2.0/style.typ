#import "src/common.typ" as _common

/// IEEE csl for bibliography style
#let ieee = path("assets/csl/ieee.xml")
/// GitHub Light tmTheme for code blocks
#let gh-light = path("assets/theme/GitHub Light.tmTheme")

/// Deprecated use teal instead since cyan is not present in std
#let cyan = rgb("41BACB")
#let teal = cyan
#let blue = rgb("044B53")
#let navy = rgb("003153")
#let aqua = rgb("44BCCC")
#let gray = rgb(0, 0, 0, 10.2%) // rgb("E5E5E5") on white bg
#let red = rgb("AD1E20")
#let purple = rgb("C201C9")
#let yellow = rgb("eb996f")
#let gold = rgb("#d4a72c")


#let form-factor() = if page.width != auto { page.width / 21cm } else { 1 }

#let cover(
  body,
  body-size: auto,
  title-size: auto,
  title-outlined: false,
  title-bookmarked: true,
  body-font: ("Times New Roman", "Liberation Serif"),
  sans-font: ("Arial", "Liberation Sans"),
  logo-scale: auto,
  margin: auto,
  fill: none,
  text-fill: black,
) = context {
  set page(footer: none, header: none, fill: fill)
  set page(margin: if margin == auto { 1.5cm * form-factor() } else { margin })
  set text(
    if body-size == auto { 12pt * form-factor() } else { body-size },
    font: body-font,
    hyphenate: false,
    fill: text-fill,
  )

  show title: block.with(width: 90%)
  show title: align.with(center)
  show title: set text(
    if title-size == auto { 17pt * form-factor() } else { title-size },
    font: sans-font,
  )
  show title: set par(justify: false)

  show image: scale.with(
    100% * if logo-scale == auto { 80% * form-factor() } else { logo-scale },
    reflow: true,
  )

  set grid(inset: (bottom: 0.67em, left: 0.16em, right: 0.16em))
  set grid.hline(stroke: text-fill + 0.5pt)

  show heading: hide
  show heading: place.with(center + top)
  heading(
    level: 1,
    outlined: title-outlined,
    bookmarked: title-bookmarked,
    supplement: [Формулар],
  )[Насловна страна]

  body
}

#let form(
  body-size: auto,
  body-font: ("Arial", "Segoe UI Symbol", "Liberation Sans", "Noto Sans Symbols2"),
  body,
) = context {
  set page(footer: none, header: none)
  set text(
    10pt * form-factor(),
    font: body-font,
  )

  set table(inset: .5em)

  body
}

#let form-heading(
  logo-scale: auto,
  body-size: auto,
  body-font: ("Arial", "Segoe UI Symbol", "Liberation Sans", "Noto Sans Symbols2"),
  body,
) = context {
  set text(
    9pt * form-factor(),
    font: body-font,
  )

  show image: scale.with(
    100% * if logo-scale == auto { form-factor() } else { logo-scale },
    reflow: true,
  )

  body
}

#let pre(body) = {
  set page(
    number-align: center,
    supplement: [стр.],
    // can set margin in style, overrides thesis::margin
  )

  // show smallcaps: set text(script: "Latn")

  body
}

#let base(
  body,
  body-size: 11pt,
  body-font: ("Times New roman", "Segoe UI Symbol", "Liberation Serif", "Noto Sans Symbols2"),
  math-size: 11pt,
  math-font: ("Cambria Math", "Tex Gyre Pagella Math", "Libertinus Math"),
  raw-size: 10pt,
  raw-font: ("Courier New", "Liberation Mono"),
  accent: navy,
  url-footnotes: true,
  old-style-numbers: true,
) = {
  set text(
    body-size,
    font: body-font,
  )
  show raw: set text(raw-size, font: raw-font)
  set raw(theme: gh-light)
  show math.equation: set text(math-size, font: math-font)

  show figure.where(kind: raw): set figure(supplement: [Листинг])
  show figure.where(kind: _common.graph): set figure(supplement: [График])

  show bibliography: bib => {
    show link: l => {
      show regex("^\w+://"): _ => none
      l
    }

    bib
  }

  show outline: it => if query(it.target).filter(it => it.outlined).len() > 0 { it } // hide outline if no entries
  show outline: set heading(outlined: true)
  show outline.entry: it => {
    show repeat: set text(accent)

    if it.element.func() == heading {
      it
    } else {
      // figures
      link(
        it.element.location(),
        it.indented(
          text(accent, weight: "medium")[#it.prefix()],
          it.inner(),
        ),
      )
    }
  }
  show link: it => {
    if type(it.dest) == str {
      text(accent)[#it]

      if (
        url-footnotes
          and it.body != [#it.dest]
          and ("http", "https", "ftp").any(proto => it.dest.starts-with(proto))
          and it.body != [#it.dest.replace(regex("^\w+://((www\.)?(doi.org/))?"), "")]
      ) {
        footnote[#link(it.dest)]
      }
    } else {
      it
    }
  }
  set footnote.entry(separator: line(stroke: 0.3pt + accent, length: 30%))

  set enum(numbering: n => text(accent)[#numbering("1.", n)])
  set list(marker: lvl => text(accent)[#(
    sym.bullet,
    sym.bullet.stroked,
    sym.bullet.op,
    sym.bullet.tri,
  ).at(lvl, default: sym.hyph)])

  show heading: set text(accent, hyphenate: false, number-type: "lining")
  show heading: set block(above: 2.2em, below: 1.1em)
  show heading.where(level: 1): set block(above: 3em, below: 1.9em)
  show heading.where(level: 1): smallcaps

  show heading.where(level: 1): align.with(center)
  show heading: align.with(left)

  set par(justify: true, first-line-indent: 1em)
  show par: set text(number-type: if old-style-numbers { "old-style" } else { "lining" })

  show terms: it => {
    show repeat: set text(accent)
    show repeat: box.with(width: 1fr)
    show link: set text(accent)

    it
  }

  set figure.caption(separator: sym.colon, position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => [
    #text(
      fill: accent,
      weight: "medium",
      number-type: "lining",
    )[#it.supplement#sym.space.nobreak#it.counter.display()#it.separator] #it.body
  ]

  show figure.where(kind: table).or(figure.where(kind: raw)): set block(breakable: true)
  show figure.caption: set block(sticky: true)

  show table: set text(number-type: "lining", number-width: "tabular")

  show cite.where(form: "normal"): set text(number-type: "lining", number-width: "tabular")

  show ref.where().or(link).or(footnote): set text(number-type: "lining")

  body
}

#let _hydra(body, accent: navy) = {
  import "@preview/hydra:0.6.3": hydra

  set page(header: context {
    let odd = calc.odd(here().page())

    set align(if odd { right } else { left })
    set text(0.9em, style: "italic", weight: "thin", accent)

    hydra(if odd { 1 } else { 2 })
  })

  body
}

#let main(
  hydra: true,
  accent: navy,
  chapter-relative-fig-nums: true,
  body,
) = {
  set heading(
    numbering: "1.1",
    supplement: [Потпоглавље],
  )
  show heading.where(level: 1): set heading(supplement: [Поглавље])
  set figure(
    numbering: if chapter-relative-fig-nums {
      n => numbering("1.1", counter(heading).get().first(), n)
    } else { "1" },
  )
  set math.equation(
    numbering: if chapter-relative-fig-nums {
      n => numbering("(1.1)", counter(heading).get().first(), n)
    } else { "(1)" },
  )

  set par(justify: true, first-line-indent: 1em)

  show: if hydra { _hydra.with(accent: accent) } else { text }

  body
}

#let appendices(
  hydra: false,
  accent: navy,
  chapter-relative-fig-nums: true,
  body,
) = {
  set heading(
    numbering: _common.sr-numbering,
    supplement: [Додатак],
  )
  set figure(
    numbering: if chapter-relative-fig-nums {
      n => _common.sr-numbering(counter(heading).get().first(), n)
    } else { "1" },
  )
  set math.equation(
    numbering: if chapter-relative-fig-nums {
      n => [(#_common.sr-numbering(counter(heading).get().first(), n))]
    } else { "(1)" },
  )

  set par(justify: true, first-line-indent: 1em)

  show: if hydra { _hydra.with(accent: accent) } else { text }

  body
}

#let abbr = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },

  group: (name, index, total, body) => body,

  entry: (entry, index, total) => [
    / #entry.short: #entry.long#entry.label #h(1fr) #entry.pages.join(", ")
    // / #entry.short: #entry.long#entry.label #repeat(".") #entry.pages.join(", ")
  ],
)

#let terms = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },

  group: (name, index, total, body) => body,

  entry: (entry, index, total) => {
    // Format the reference
    let reference = if entry.reference == none {
      []
    } else {
      if entry.reference.supplement == none {
        [ #cite(label(entry.reference.key))]
      } else {
        [
          #cite(
            label(entry.reference.key),
            supplement: entry.reference.supplement,
          )]
      }
    }

    let term = if entry.long != none { entry.long } else { entry.short }
    let term = upper(term.first()) + term.slice(term.first().len())

    [
      / #term: #entry.description#reference #h(1fr) #entry.pages.join(", ")
      // / #term: #entry.description#reference #repeat(".") #entry.pages.join(", ")
    ]
  },
)
