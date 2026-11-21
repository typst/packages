#import "src/settings.typ": *
#import "@preview/acrostiche:0.7.0": init-acronyms as _acrostiche-init, acr, display-def, display-short, display-full, print-index, acrfull, acrfullpl, acrfullcap, acrfullplcap, reset-acronym, reset-all-acronyms, mark-acr-used, acrpl, acrcap

#let print-glossary = print-index
#let glossary-body = acr

/// Whether we are inside a heading (used by glossary to choose long-form only).
#let _in-heading = state("spbu-in-heading", false)

/// Stores case-specific long forms for acronyms.
#let _acronym-cases = state("spbu-acronym-cases", (:))

/// Initialize acronyms with optional case forms.
///
/// Each entry can be a string (long form) or a dictionary:
/// ```typst
/// #init-acronyms((
///   "НИР": (
///     long: "научно-исследовательская работа",
///     твор: "научно-исследовательской работой",
///   ),
/// ))
/// ```
#let init-acronyms(acronyms) = {
  let standard = (:)
  let cases = (:)
  for (key, def) in acronyms {
    if type(def) == dictionary {
      let acr-def = (:)
      for field in ("long", "short", "long-pl", "short-pl") {
        if field in def { acr-def.insert(field, def.at(field)) }
      }
      if "long" not in acr-def {
        panic("Acronym \"" + key + "\" must have a 'long' definition")
      }
      standard.insert(key, acr-def)
      let case-forms = (:)
      for (k, v) in def {
        if k not in ("long", "short", "long-pl", "short-pl") {
          case-forms.insert(k, v)
        }
      }
      if case-forms.len() > 0 { cases.insert(key, case-forms) }
    } else {
      standard.insert(key, def)
    }
  }
  _acrostiche-init(standard)
  _acronym-cases.update(cases)
}

/// Display an abbreviation. In headings, shows only the long form (no abbreviation).
/// In body text, behaves like acrostiche's acr().
/// Use `падеж` to specify a grammatical case (e.g. "твор", "род").
#let glossary(key, plural: false, cap: false, падеж: none) = {
  context {
    if _in-heading.get() {
      if падеж != none {
        let cases = _acronym-cases.get()
        let fallback = display-def(key, plural: plural, cap: false)
        let result = if key in cases and падеж in cases.at(key) {
          cases.at(key).at(падеж)
        } else {
          fallback
        }
        if cap and type(result) == str {
          upper(result.first()) + result.slice(result.first().len())
        } else {
          result
        }
      } else {
        let result = display-def(key, plural: plural, cap: false)
        if cap and type(result) == str {
          upper(result.first()) + result.slice(result.first().len())
        } else {
          result
        }
      }
    } else {
      acr(key, plural: plural, cap: false)
    }
  }
}

#let special-section(title) = {
  show heading.where(level: 1): set block(width: 100%, breakable: false)
  show heading.where(level: 1): set align(center)

  heading(level: 1, numbering: none, outlined: true)[#title]
}

/// Create an appendix heading with Russian alphabet numbering.
/// The body receives appendix-specific numbering for figures, tables, and equations.
/// Example: `#appendix("А", "Сведения ...")[ ... ]` renders "ПРИЛОЖЕНИЕ А" on the first line and "Сведения ..." on the second, centered.
#let appendix(letter, title, body) = {
  pagebreak()
  show heading.where(level: 1): set block(width: 100%, breakable: false)
  show heading.where(level: 1): set align(center)

  heading(level: 1, numbering: none, outlined: true)[
    ПРИЛОЖЕНИЕ #letter \
    #if title != "" [#title]
  ]
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(math.equation).update(0)
  set figure(numbering: letter + ".1")
  set math.equation(numbering: "(" + letter + ".1)")
  body
}

#let toc() = {
  set par(first-line-indent: 0pt)
  align(center, text(size: 16pt, weight: "bold")[СОДЕРЖАНИЕ])
  v(1em)
  show outline.entry.where(level: 1): it => {
    v(1em)
    it
  }
  outline(title: none, indent: 2em, depth: 2)
}

#let title-page(
  title: "",
  author: "",
  organization: "САНКТ-ПЕТЕРБУРГСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ",
  doc-type: "ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ",
  supervisor: "",
  supervisor-degree: "",
  supervisor-department: "",
  supervisor-full: "",
  direction: "",
  program: "",
  city: "Санкт-Петербург",
  year: "",
) = {
  page(
    paper: page-settings.paper,
    margin: page-settings.margin,
    numbering: none,
  )[
    #set text(hyphenate: false)
    #set par(first-line-indent: 0pt)
    #align(center + horizon)[
      #organization
      #if direction != "" [
        \ Направление: #direction
      ]
      #if program != "" [
        \ ООП: #program
      ]

      #v(6cm)

      *#doc-type*

      #v(1em)

      #let section(topic, content) = {
        align(left, grid(columns: 2, align: top, column-gutter: 0.25em,
          text(weight: "bold", topic), [#content]
        ))
      }

      #section("Тема задания:", title)
      #v(1em)
      #section("Выполнил:", author)

      #let supervisor-content = if supervisor-full != "" {
        supervisor-full
      } else {
        str(
          supervisor-degree + ", " +
          if supervisor-department != "" { supervisor-department + ", " } else { "" } +
          supervisor
        )
      }

      #if supervisor-full != "" or supervisor != "" [
        #v(1em)
        #section("Руководитель НИР:", supervisor-content)
      ]

      #v(1fr)

      #city \
      #year
    ]
  ]
}

#let template(
  title: "",
  author: "",
  organization: "САНКТ-ПЕТЕРБУРГСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ",
  doc-type: "ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ",
  supervisor: "",
  supervisor-degree: "",
  supervisor-department: "",
  supervisor-full: "",
  direction: "",
  program: "",
  city: "Санкт-Петербург",
  year: "",
  acronyms: (:),
  body,
) = {
  init-acronyms(acronyms)
  set page(
    paper: page-settings.paper,
    margin: page-settings.margin,
    numbering: page-settings.numbering,
    number-align: page-settings.number-align,
  )
  set text(
    size: text-settings.size,
    lang: text-settings.lang,
    fill: text-settings.fill,
  )
  set par(
    first-line-indent: par-settings.first-line-indent,
    justify: true,
    leading: 1em,
  )
  show heading.where(level: 1): set heading(numbering: heading-settings.level-1-numbering)
  show heading.where(level: 2): set heading(numbering: heading-settings.level-2-numbering)
show heading.where(level: 1): it => {
    set text(weight: "bold", hyphenate: false)
    if it.numbering == none {
      set block(width: 100%, breakable: false)
      set align(center)
      block(width: 100%, breakable: false)[
        #align(center)[
          #it
        ]
      ]
    } else {
      block(inset: (left: 2.5em), breakable: false)[
        #it
      ]
    }
}
  show heading.where(level: 2): it => {
      block(inset: (left: 2.5em), breakable: false)[
        #it
      ]
  }
  show footnote: set text(size: font-size - 2pt)
  set math.equation(numbering: "(1)")
  set ref(supplement: none)
  set figure(numbering: "1")
  set figure.caption(separator: " \u{2014} ")
  show figure.where(kind: image): set figure(supplement: "Рисунок")
  show figure.where(kind: table): set figure(supplement: "Таблица")
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set par(leading: 0pt)

  title-page(title: title, author: author, organization: organization, doc-type: doc-type, supervisor: supervisor, supervisor-degree: supervisor-degree, supervisor-department: supervisor-department, supervisor-full: supervisor-full, direction: direction, program: program, city: city, year: year)

  pagebreak()

  toc()

  pagebreak()

  body
}
