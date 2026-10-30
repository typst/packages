// Draft look-alike of the Moja PG title page; geometry measured from a
// generated one (Arial 10 pt, 14.17 pt line distance, 38.6 mm left offset).

#import "i18n.typ": strings

#let generated-title-page(
  lang: "pl",
  kind: "engineering",
  title-pl: none,
  title-en: none,
  authors: (),
  supervisor: none,
  consultant: none,
  faculty: none,
  field: none,
  specialization: none,
  level: auto,
  mode: none,
  logo: none,
) = {
  let s = strings.at(lang)
  let level = if level != auto { level } else if kind == "master" { s.level-second } else { s.level-first }

  set text(10pt, top-edge: "cap-height", bottom-edge: "baseline")
  set par(justify: false, first-line-indent: 0pt, leading: 14.17pt - 0.716em, spacing: 14.17pt - 0.716em)

  let line(label, value) = if value != none [#label: #value \ ]

  place(top + left, dx: 32mm, dy: 21mm, {
    if logo != none {
      logo
    } else if faculty != none {
      text(9pt, weight: "bold", fill: rgb("#003c7d"))[POLITECHNIKA GDAŃSKA \ #upper(faculty)]
    }
  })

  pad(left: 38.6mm, right: 28mm, top: 58mm, bottom: 30mm, block(height: 100%, {
    for (i, a) in authors.enumerate() {
      if i > 0 { v(14.17pt) }
      par({
        line(s.student, a.name)
        line(s.album, a.at("album", default: none))
        line(s.level, a.at("level", default: level))
        line(s.mode, a.at("mode", default: mode))
        line(s.field, a.at("field", default: field))
        line(s.specialization, a.at("specialization", default: specialization))
      })
    }

    v(1fr, weak: false)
    text(12pt, weight: "bold", upper(s.kinds.at(kind)))
    v(42pt)

    par[#s.title-pl: #title-pl]
    v(14.17pt)
    par[#s.title-en: #title-en]
    v(56pt)

    par(line(s.supervisor, supervisor) + line(s.consultant, consultant))
    v(1.6fr)
  }))
}
